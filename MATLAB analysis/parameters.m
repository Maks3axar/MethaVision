function p = parameters(x)

% OD600_0 = x(1);   % initial biomass innoculum, [OU] @ 600 [nm]
t_lag = x(1);     % initial lag-time, [h]
mu_max = x(2);    % initial maximal mu, [1/h]

% p = [OD600_0 t_lag mu_max ]; 
p = [t_lag mu_max]; 
end