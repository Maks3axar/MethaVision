function [x,fval,exitflag,output] = pattern_search(x,lb,ub,MaxIter_Data,InitialMeshSize_Data, MaxMeshSize_Data)
% this M-file formulates task for Patter Search optimization algorithm

% Start with the default options
options = psoptimset;
% Modify options setting
options = psoptimset(options,'MeshAccelerator', 'on'); % 'off'
options = psoptimset(options,'InitialMeshSize', InitialMeshSize_Data);
options = psoptimset(options,'Cache', 'on');
options = psoptimset(options,'Display', 'final'); % 'off'
options = psoptimset(options,'MaxIter', MaxIter_Data);
options = psoptimset(options,'MaxMeshSize', MaxMeshSize_Data);
options = psoptimset(options,'Display', 'diagnose');
options = psoptimset(options,'OutputFcns', { [] });
options = psoptimset(options,'PlotFcns', {   @psplotbestf @psplotmeshsize @psplotfuncount @psplotbestx });
options = psoptimset(options,'UseParallel', 'always', 'CompletePoll', 'on', 'Vectorized', 'off');
[x,fval,exitflag,output] = ...
patternsearch(@fitness,x,[],[],[],[],lb,ub,[],options);
