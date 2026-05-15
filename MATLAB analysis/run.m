%% Load experimental data and to be evaluated data
load('raw data/40°C(2).mat')
% load('x.mat'); % [Cx0 t_lag mu_max@T]

t_exp = raw_data(:,1); % experimental time, [h]
Cx_exp = raw_data(:,2); % experimental biomass concentration, [gX/L]
T_exp = raw_data(1,3); % experimental growth T, [°C]

%% Define time-line
t = 0:0.01:t_exp(end)+5;     % time,[h]

%% Load the initial conditions of the variables
y0 = initial_conditions(x);

%% Load parameter vector
p = parameters(x,T_exp);

%% Integration

ode_opt = odeset('NonNegative',1:2, 'RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 0.1);
[t,y] = ode45(@ode, t, y0, ode_opt, p); % ode15s

%% Rates
r = rates(t,y,p);

%% Plot
grafik(t,y,t_exp,Cx_exp,x,p);

%% Reports
report = reports(t,y,r,t_exp,Cx_exp,x);