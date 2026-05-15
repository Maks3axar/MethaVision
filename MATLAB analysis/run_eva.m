%% run parameter estimation / optimization algorithm

%% load experimental data
load ('raw data/40°C(2).mat')
% load('x.mat') % [Cx0 t_lag mu_max@T Ks]
t_exp = raw_data(:,1); % experimental time, [h]
Cx_exp = raw_data(:,2); % experimental biomass concentration, [gX/L]
T_exp = raw_data(1,3); % experimental growth T, [°C]

%% defindes number of varying parameters
lb = zeros(4,1);
ub(1) = 2;                      % Cx0
ub(2) = t_exp(end)/3;             % t_lag
% ub(2) = 5;             % t_lag
ub(3) = 0.4;                    % mu_max@T°C
ub(4) = 5;              % Ks
ub = ub';

%% Run genetic algorithm (GA) with hybride constrained minimisation function
% 'fmincon'
% TolFun_Data = 1e-3;
% Generations_Data = 10;
% [x,fval,exitflag,output,population,score] = ga_fminunc(nvar,TolFun_Data,Generations_Data, lb, ub);

%% Run patternsearch algorithm 
MaxIter_Data = 1000; % nvar*100;
InitialMeshSize_Data = 1;
MaxMeshSize_Data = []; % 50;
[x,fval,exitflag,output] = pattern_search(x,lb,ub,MaxIter_Data,InitialMeshSize_Data, MaxMeshSize_Data);

%% Run GlobalSearch (gs) algorithm
% gs = GlobalSearch('Display', 'iter','MaxTime',600); % [sec]
% MaxIter_Data = [5]; % 5;
% options = optimset('MaxIter', MaxIter_Data, 'PlotFcns', {  @optimplotx @optimplotfunccount @optimplotfval @optimplotconstrviolation }, 'Algorithm', 'interior-point');
% problem = createOptimProblem('fmincon','objective',@fitness,'x0',x,'lb',lb,'ub',ub,'options',options);
% [x,fval,exitflag,output] = run(gs,problem);

% [x,fval,exitflag,output,lambda,grad,hessian] = GlobalSearch(x,lb,ub,MaxIter_Data);

%% Save optimized results
% save ('x_optimized.mat', 'nvar', 'x', 'x0', 'fval', 'exitflag');
% x = x';
save ('x_optimized.mat', 'x');
% save ('z_optimized.mat', 'z');

save_string = strcat('f=', num2str(fval),'_',num2str(T_exp),'°C_',datestr(now,1),'_',datestr(now,'HH.MM'),'.mat');
save(save_string)

%% run simulation with estimated parameters
% run

%% form matrix of optimized parameters and lower/upper boundaries
% u = [lb x ub];