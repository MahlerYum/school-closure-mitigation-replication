function out = solve_model(p, varsigma, gamma, subsidy)
%SOLVE_MODEL Solve the two investment decisions for each household type.

validateattributes(varsigma, {'numeric'}, {'scalar', '>', 0, '<=', 1});
validateattributes(gamma, {'numeric'}, {'scalar', 'finite', '>=', 1});
validateattributes(subsidy, {'numeric'}, {'scalar', '>=', 0, '<', 1});

m = [1 - p.m_delta; 1 + p.m_delta];
phi = p.phi_mu * [1 - p.phi_delta; 1 + p.phi_delta];
income_type = [1; 1; 2; 2];
ability_type = [1; 2; 1; 2];
income = m(income_type);
ability = phi(ability_type);
school0 = varsigma * p.g;
school1 = gamma * p.g;
price1 = [1 - subsidy; 1];
weight1 = p.eta * p.alpha;


e1_by_income = optimal_spending(m, price1, school1, weight1, p);
e1 = e1_by_income(income_type);
weights = p.counts / sum(p.counts);
e0 = archived_spending(income, ability, school0, p);

h1 = human_capital(ability, e0, school0, 1, p);
h2 = human_capital(ability, e1, school1, h1, p);
log_income = log(income);
centered_income = log_income - weights.' * log_income;
ige = (weights .* centered_income).' * log(h2) / ...
      (weights.' * centered_income.^2);

out = struct('ige', ige, 'mean_h2', weights.' * h2, ...
    'gini_h2', weighted_gini(h2, weights), ...
    'gini_income', weighted_gini(income, weights), ...
    'investment_share', (weights.' * (e0 + e1) / 2) / (weights.' * income), ...
    'e0', e0, 'e1', e1, 'h1', h1, 'h2', h2, 'income', income, ...
    'ability', ability, 'weights', weights);
end

function e = optimal_spending(m, price, school, weight, p)
e = zeros(size(m));
for j = 1:numel(m)
    relative_input = (school * p.e_bar * price(j) / m(j))^p.psi;
    foc = @(x) weight * (1 - x) - x - relative_input * x^(1 - p.psi);
    e(j) = m(j) * fzero(foc, [0, 1]) / price(j);
end
end

function e = archived_spending(income, ability, school0, p)
h_grid = logspace(0, log10(1 + p.h_max), 100) - 1;
v_grid = p.eta * (1 - p.alpha) * log(h_grid(2:end));
e = zeros(size(income));
for j = 1:numel(income)
    h_next = @(spending) human_capital(ability(j), spending, school0, 1, p);
    objective = @(spending) -log(income(j) - spending) ...
        - archived_continuation(h_next(spending), h_grid(2:end), v_grid);
    e(j) = golden_section(objective, 0, income(j));
end
end

function value = archived_continuation(h, grid, values)
if h < grid(1)
    value = -Inf;
else
    value = interp1(grid, values, min(h, grid(end)), 'linear');
end
end

function best = golden_section(objective, lower, upper)
ratio = (3 - sqrt(5)) / 2;
left = lower + ratio * (upper - lower);
right = lower + (1 - ratio) * (upper - lower);
f_left = objective(left);
f_right = objective(right);
while right - left > 1e-10
    if f_left >= f_right
        lower = left;
        left = right;
        f_left = f_right;
        right = lower + (1 - ratio) * (upper - lower);
        f_right = objective(right);
    else
        upper = right;
        right = left;
        f_right = f_left;
        left = lower + ratio * (upper - lower);
        f_left = objective(left);
    end
end
best = (left + right) / 2;
end

function h_next = human_capital(phi, e, school, h, p)
inputs = (e ./ p.e_bar).^p.psi + school.^p.psi;
h_next = phi .* inputs.^(p.alpha / p.psi) .* h.^(1 - p.alpha);
end

function index = weighted_gini(values, weights)
pairwise_gap = abs(bsxfun(@minus, values, values.'));
index = (weights.' * pairwise_gap * weights) / (2 * (weights.' * values));
end
