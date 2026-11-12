function models = paper_models()
%PAPER_MODELS Full-precision parameters from the original figure driver.
% Rows are Model 1 (substitutes) and Model 2 (complements).
% Columns are psi, m_delta, phi_delta, p_phi, eta, phi_mu, grid maximum.
parameters = [
     0.6, 0.800448426857162, 0.419486883372784, 0.566613509925146, ...
          0.919887745403260, 0.722957208174359, 5;
    -1.0, 0.800462633119163, 0.448734021790100, 0.604440611900877, ...
          1.25079427215673,  1.14044764878684,  3
];

% Joint type counts from the original seeded draws of 500,000 model
% households. Order: low m/low phi, low m/high phi, high m/low phi,
% high m/high phi. These counts reproduce the PDF figure coordinates.
counts = [141300, 108523, 108286, 141891;
          150711,  99112,  98945, 151232];

for j = 1:size(parameters, 1)
    row = parameters(j, :);
    models(j) = struct('psi', row(1), 'm_delta', row(2), ...
        'phi_delta', row(3), 'p_phi', row(4), 'eta', row(5), ...
        'phi_mu', row(6), 'h_max', row(7), 'alpha', 0.25, ...
        'e_bar', 0.10, 'g', 1, 'counts', counts(j, :).'); %#ok<AGROW>
end
end
