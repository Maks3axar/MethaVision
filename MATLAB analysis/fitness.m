function f = fitness(x)
%% Load experimental data and to be evaluated data
load('raw data/40°C(2).mat')
% load('x.mat')
% [Cx0 t_lag mu_max@T Ks]

t_exp = raw_data(:,1); % experimental time, [h]
Cx_exp = raw_data(:,2); % experimental biomass concentration, [gX/L]
T_exp = raw_data(1,3); % experimental growth T, [°C]
% Cglc_exp = glc;

%% Define time-line & T°C
t = 0:0.1:t_exp(end)+5;     % time, h

%% Load the initial conditions of the variables
y0 = initial_conditions(x);

%% Load parameter vector
p = parameters(x,T_exp);

%% Integration

ode_opt = odeset('NonNegative',1:2, 'RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 0.1);
[t,y] = ode45(@ode, t, y0, ode_opt, p); % ode15s

% %%
% % x = z{1,1};
% % A = z{1,2};
% % fitness function for parameter estimation
% A = importdata('batch5.txt'); % import experimental data: dry biomass versus time
% t_exp = A(:,1); % experimental time, h
% glc_m = A(:,2); % measured glucose, g/L
% Cx_m = A(:,3); % measured dry biomass, gDW/L
% ac_m = A(:,4); % measured acetate, g/L
% 
% %% Define time-line
% t_lag = x(4);                   % time delay of the growth, h
% t = (t_lag:0.1:t_exp(end)+3);     % time, h
% 
% %% Load the initial conditions of the variables
% y0 = initial_conditions(x);
% 
% %% Load parameters
% p = parameters(x);
% 
% %% Integration
% ode_opt = odeset('NonNegative',1:3, 'RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 0.1); %[]; , 'MaxStep', 0.1
% [t,y] = ode15s(@ode_batch, t, y0, ode_opt, p); % ode45 or ode15s
 
%% check and panish deviation from experimental points
% form matrix of experimental data
% S = [glc_m Cx_m ac_m]; % 
% S = [Cx_exp Cglc_exp]; % 
S = [Cx_exp]; % 

% select those y's for which experimental measurements exist
y = [y(:,1)]; % y(:,1)  y(:,2)

% interpolates simulated data at time points where real measurements exist
    SimInt = zeros(size(S));   % creates emptly matrix for interpolated data from simulated matrix
    k = 1;                     % index of simulated data

    for i = 1:length(t_exp);     % index of 'experimental' data
        while 1
            if (t (k) <= t_exp(i)) && (t_exp (i)<= t(k+1));
                SimInt(i,1:end) = y(k,1:end) + ((y(k+1,1:end) - y(k,1:end))./...
                (t(k+1) - t(k))).*(t_exp(i) - t(k)); % interpolation
                break
            end 
            k = k+1;
        end % for k
    end % for i

%% calculates squared errors
squared_errors = (S - SimInt).^2;  
% squared_errors = ((S - SimInt) ./ S).^2;  

w = ones(size(squared_errors));
w(1,:) = 1e2;
% w(end,:) = 10;

squared_errors = squared_errors .* w;

% %% weighting entire variables
% % w_Cx_m = mean(Cx_m);
% % w_glc_m = mean(glc_m);
% % w_ac_m = mean(ac_m);
% w1 = 1; % glc
% w2 = 10; % Cx
% w3 = 1; % ac
% % w1 = w_ac_m / w_Cx_m;
% % w2 = w_ac_m / w_glc_m;
% % w3 = 10;
% weights = [w1 w2 w3];
% 
% m = size(SimInt,1);
% b = ones(m,1);
% c = b * weights;
% W = squared_errors .* c; 
 
%% weighting specific time region 
% Z = ones(size(W));
%  for i = 1:length(t_exp);
%      w = 1;
%      if t_exp(i) > 0 && t_exp(i)< 2000
%          w = 50;
%      end
% %     squared_errors(i) = w*((S(i) - SimInt(i))^2);
%     Z(i,:) = w * W(i,:);     
%  end 

%%
% mu_max_glc = p(1); % maximal specific growth rate on glucose, 1/h
% t_lag = p(10);
% % alfa = p(11);
% % cc = 0.001*exp(alfa*t_lag);
% 
% if cc <= mu_max_glc
%     f1 = 100;
% else
%     f1 = 0;
% end

% r = rates(y,p);
% mu_d = p(10); % specific death rate, 1/h
% 
% if r(end,3) ==  mu_d
%     f1 = 0;
% else
%     f1 = (r(end,3) - mu_d)^2 * 10000;
% end
    
%%
% Yxs = p(7);
% Yxp = p(8);
% if Yxp > Yxs
%     f2 = 100;
% else
%     f2 = 0;
% end

%% calculates f-value 
% f_1 = sum(sum(squared_errors));
f_1 = sum(squared_errors);
% f_2 = f_1 .* weight;
% f = sum(f_2);

% corrected_squared_errors = squared_errors;
% corrected_squared_errors = W;
% corrected_squared_errors(isnan(corrected_squared_errors)) = 0;
% f0 = sum(sum(corrected_squared_errors));
% f = f0 + f1 + f2;
f = f_1;
end
