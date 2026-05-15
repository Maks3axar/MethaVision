% Mathematical model for cell cycle phases of Methylococcus capsulatus
% Based on morphotype percentages: monococci (G1/S/G2), diplococci/tetracocci (M)
% mu_max = 0.21 h^-1
% T = ln(2) / mu_max (generation time)
% T_M = T * log2(f_M + 1), where f_M = (P_diplo + P_tetra)/100
% T_G = T - T_M

function [T_G, T_M] = cell_cycle_model(mu_max, f_mono, f_diplo, f_tetra)
    % Inputs:
    %   mu_max: specific growth rate (scalar, e.g., 0.21)
    %   P_mono, P_diplo, P_tetra: percentages at each time point (vectors of same length)
    % Outputs:
    %   T_G, T_M: durations of G1/S/G2 and M phases at each time point (vectors)
    
    % Calculate generation time T (constant, assuming mu_max fixed)
    T = log(2) / mu_max;  % ln(2) = log(2) in MATLAB (natural log)
    
    % Number of time points
    n_points = length(f_mono);
    if length(f_diplo) ~= n_points || length(f_tetra) ~= n_points
        error('Percentage vectors must be the same length');
    end
    
    % Preallocate outputs
    T_G = zeros(n_points, 1);
    T_M = zeros(n_points, 1);
    
    % Loop over time points
    for i = 1:n_points
        % Fractions (0 to 1)
        % f_M = (P_diplo(i) + P_tetra(i)) / 100;
        f_M = (f_diplo(i) + f_tetra(i));
        % f_G = f_mono(i) / 100;  % For validation: f_G + f_M should be ~1
        f_G = f_mono(i);
        
        if abs(f_G + f_M - 1) > 1e-6
            warning('Fractions do not sum to 1 at point %d', i);
        end
        
        % Calculate T_M
        T_M(i) = T * log2(f_M + 1);  % log2 is base-2 log
        
        % Calculate T_G
        T_G(i) = T - T_M(i);
    end
end
