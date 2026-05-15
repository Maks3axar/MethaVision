function dOD600dt = ode(t,y,p)
%% Designation of the variables
OD600 = y(1);

%% Designation of the parameters
t_lag = p(1); % lag-time, [h]

if t >= t_lag
    mu_max = p(2); % maximal specific rate of biomass growth, [1/h]
else
    mu_max = 0;
end

dOD600dt = mu_max * OD600;
end