function r = rates(t,y,p)
% the function calculates volumetric rates (q)

%% Designation of the variables
Cx = y(:,1);               % biomass concentration, [gX/L]
Cglc = y(:,2);               % glucose concentration, [glc/L]

%% Designation of the parameters

% Biomass
% TK = p(1);                  % experimental temperature, [°K]
t_lag = p(3);               % lag-time, [h]
Ks = p(4);                  % saturation constant, [glc/L]
% m_glc = p(5);               % rate of glucose consumption for maintenance, [glc/(gX * h)]
% Yx_glc_true = p(6);         % true biomass yield on glucose, [gX/glc]

%% lag-time
mu_max = zeros(size(y(:,1)));
for i=1:length(mu_max)
    if t(i) >= t_lag
%         mu_max(i) = (8.9877e18 * exp(-111900 / (TK * 8.314))) / (1 + 5.8935e50 * exp(-296900 / (TK * 8.314)));
        mu_max(i) = p(2);
    else
        mu_max(i) = 0;
    end
end
clear i
 
%% Kinetic equations
mu = mu_max .* Cglc ./ (Ks + Cglc);      % Monod equation expresses specific rate of biomas formation, [gX/(gX*h)]
q_X = mu .* Cx;               % volumetric rate biomass formation, [gX/(L*h)]

r_glc = zeros(size(y(:,1))); 
q_glc = zeros(size(y(:,1)));
for i=1:length(mu)
    if mu(i) == 0
        r_glc(i) = 0;
        q_glc(i) = r_glc(i) .* Cx(i);
    else
        r_glc(i) = ((1/Yx_glc_true) .* mu(i) + m_glc);  % specific rate of glucose consumption, [glc/(gX*h)]
        q_glc(i) = r_glc(i)  .* Cx(i);                     % volumetric rate glucose consumption, [glc/(L*h)]
    end
end

%% Output matrix
r = [mu r_glc q_X q_glc];

end