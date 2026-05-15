function rates = rate_equations(t,y,p)
%% desides whether y's is a vector or a matrix
[d1,d2] = size(y);
if d1 == 1 || d2 == 1
    Cx = y(1);                   % biomass concentration, [gDW/L]
    Cglc = y(2);                 % glucose concentration, [g_glc/L]
else
    Cx = y(:,1);                   % biomass concentration, [gDW/L]
    Cglc = y(:,2);                 % glucose concentration, [g_glc/L]
end

%% Designation of the parameters
% TK = p(1);
t_lag = p(3);
Ks_glc = p(4);                  % saturation constant, g_Cglc/L
m_glc = p(5);
Yx_glc_true = p(6);

% lag-time
[d1,d2] = size(t);
if d1 ~= 1 || d2 ~= 1
    ind = t > t_lag;
    mu_max = ones(size(t)) * p(2);
    mu_max = mu_max .* ind;
elseif d1 == 1 || d2 == 1
    if t >= t_lag
        %     mu_max = (8.9e18 * exp(-111900 / (TK * 8.314))) / (1 + 5.9e50 * exp(-296900 / (TK * 8.314)));
        mu_max = p(2); % maximal specific rate of biomass growth on glucose, [g_DW/(g_DW*h)]
    else
        mu_max = 0;
    end
end

%% specific rates
mu = mu_max .* Cglc ./ (Ks_glc + Cglc); % specific rate of biomass growth on glucose, [gDW/(gDW*h)]

[d1,d2] = size(mu);
if d1 ~= 1 || d2 ~= 1
    ind = mu ~= 0;
    r_glc = (1/Yx_glc_true) .* mu + m_glc; % specific rate of glucose consumption, [g_Cglc/(gDW*h)]
    r_glc = r_glc .* ind;
elseif  d1 == 1 || d2 == 1
    if mu == 0
        r_glc = 0;
    else
        r_glc = (1/Yx_glc_true) * mu + m_glc; % specific rate of glucose consumption, [g_Cglc/(gDW*h)] 
    end
end

%% output 
rates = [mu r_glc];
end
