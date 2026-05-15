function y0 = initial_conditions(x)

OD600 = x(1);     % initial biomass innoculum, [OU] @ 600 [nm]
% t_lag = x(2);     % initial lag-time, [h]
% mu_max = x(3);    % initial maximal mu, [1/h]

% y0 = [OD600 t_lag mu_max];
y0 = [OD600];
end