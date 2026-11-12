function results = run_replication(output_dir, make_figures)
%RUN_REPLICATION Display and save Table 1 and Figures 1-3.
% Set the second argument to false to generate CSV files without graphics.
if nargin < 1 || isempty(output_dir)
    output_dir = 'output_archived';
end
if nargin < 2
    make_figures = true;
end
if ~exist(output_dir, 'dir')
    [ok, message] = mkdir(output_dir);
    assert(ok, 'Could not create output directory: %s', message);
end

models = paper_models();
figure_inputs = {[1; .95; .90; .85; .80; .75], ...
                 [1; 1.025; 1.05; 1.075; 1.1], [0; .1; .2; .3; .4]};
input_names = {'varsigma', 'gamma', 'subsidy_rate'};
x_labels = {'Early public-school input', 'Later public-school input', 'Subsidy rate'};
figure_names = {'School closures without mitigation', ...
                'Prolonged public schooling', 'Means-tested subsidy'};
x_ticks = {0.75:0.05:1, 1:0.05:1.1, 0:0.1:0.4};
y_limits = {[.96, 1.01; .32, .36; .39, .41], ...
            [.96, 1.01; .32, .36; .39, .41], ...
            [.96, 1.01; .30, .36; .38, .41]};
results.table1 = zeros(numel(models), 13);
results.figures = cell(1, numel(figure_inputs));

for j = 1:numel(models)
    p = models(j);
    base = solve_model(p, 1, 1, 0);
    results.table1(j, :) = [j, p.psi, 1 / (1 - p.psi), p.p_phi, p.eta, ...
        p.m_delta, p.phi_delta, p.phi_mu, base.ige, base.investment_share, ...
        base.gini_income, base.gini_h2, base.mean_h2];

    for k = 1:numel(figure_inputs)
        x = figure_inputs{k};
        switch k
            case 1
                scenarios = [x, ones(size(x)), zeros(size(x))];
            case 2
                scenarios = [0.8 * ones(size(x)), x, zeros(size(x))];
            case 3
                scenarios = [0.8 * ones(size(x)), ones(size(x)), x];
        end
        rows = zeros(numel(x), 5);
        for i = 1:numel(x)
            policy = scenarios(i, :);
            out = solve_model(p, policy(1), policy(2), policy(3));
            rows(i, :) = [j, x(i), out.mean_h2 / base.mean_h2, ...
                out.ige, out.gini_h2];
        end
        results.figures{k} = [results.figures{k}; rows];
    end
end

show_table1(results.table1);
write_csv(fullfile(output_dir, 'table1.csv'), ...
    ['model,psi,elasticity,p_phi,eta,m_delta,phi_delta,phi_mu,' ...
     'ige,investment_share,adult_gini,child_gini,mean_h2'], results.table1);
for k = 1:numel(figure_inputs)
    stem = fullfile(output_dir, sprintf('figure%d', k));
    rows = results.figures{k};
    write_csv([stem '.csv'], ['model,' input_names{k} ',mean_h2_ratio,ige,gini_h2'], rows);
    if make_figures
        name = sprintf('Figure %d - %s', k, figure_names{k});
        draw_figure(rows, x_labels{k}, x_ticks{k}, y_limits{k}, k == 1, name, [stem '.pdf']);
    end
end
fprintf('\nOutputs saved to %s\n', output_dir);
end

function show_table1(values)
fprintf('\nTable 1. Parameter estimates\n');
fprintf('%-27s %12s %12s\n', 'Parameter', 'Model 1', 'Model 2');
labels = {'psi', 'Elasticity of substitution', 'p_phi', 'eta', ...
          'm_delta', 'phi_delta', 'phi_mu'};
for j = 1:numel(labels)
    fprintf('%-27s %12.3f %12.3f\n', labels{j}, values(1, j + 1), values(2, j + 1));
end

fprintf('\nBaseline moments\n');
fprintf('%-27s %12s %12s %12s\n', 'Moment', 'Model 1', 'Model 2', 'Target');
labels = {'IGE', 'Private spending / income', 'Adult Gini', ...
          'Child Gini', 'Mean final human capital'};
targets = [.34, .10, .40, .40, 1];
for j = 1:numel(labels)
    fprintf('%-27s %12.6f %12.6f %12.2f\n', ...
        labels{j}, values(1, j + 8), values(2, j + 8), targets(j));
end
end

function write_csv(path, header, rows)
[file, message] = fopen(path, 'w');
assert(file >= 0, 'Could not write %s: %s', path, message);
cleanup = onCleanup(@() fclose(file)); 
fprintf(file, '%s\n', header);
format = [repmat('%.15g,', 1, size(rows, 2) - 1), '%.15g\n'];
fprintf(file, format, rows.');
end

function draw_figure(rows, x_label, x_ticks, y_limits, reverse_x, name, path)
fig = figure('Name', name, 'NumberTitle', 'off', 'Color', 'white', ...
    'Position', [50, 50, 900, 300], 'PaperUnits', 'inches', ...
    'PaperSize', [9, 3], 'PaperPosition', [0, 0, 9, 3]);
labels = {'Avg. Child HK', 'IGE', 'Gini'};
model1 = rows(:, 1) == 1;
model2 = rows(:, 1) == 2;
for j = 1:3
    ax = axes('Parent', fig, 'Position', [.12 + .29 * (j - 1), .22, .205, .62]);
    plot(ax, rows(model1, 2), rows(model1, j + 2), 'b-o', ...
             rows(model2, 2), rows(model2, j + 2), 'r:*', 'LineWidth', 1);
    xlabel(ax, x_label);
    ylabel(ax, labels{j});
    xlim(ax, [min(rows(:, 2)), max(rows(:, 2))]);
    ylim(ax, y_limits(j, :));
    set(ax, 'XTick', x_ticks, 'GridColor', [.85, .85, .85], 'GridAlpha', 1);
    grid(ax, 'on');
    if reverse_x
        set(ax, 'XDir', 'reverse');
    end
end
key = axes('Parent', fig, 'Position', [.31, .88, .42, .09], ...
    'Visible', 'off', 'XLim', [0, 1], 'YLim', [0, 1]);
line(key, [.02, .12], [.5, .5], 'Color', 'b', 'Marker', 'o', 'LineWidth', 1);
text(key, .15, .5, 'Model 1: ES = 2.5');
line(key, [.52, .62], [.5, .5], 'Color', 'r', 'Marker', '*', ...
    'LineStyle', ':', 'LineWidth', 1);
text(key, .65, .5, 'Model 2: ES = 0.5');
print(fig, path, '-dpdf');
end
