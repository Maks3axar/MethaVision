function report = reports(t,y,r,t_exp,Cx_exp,x)
% reports main values of 

%%
disp('Final concentration [g_i / L]:')
Cx_final = max(y(:,1)); % maximal biommass concentrarion achieved in the experiment, [gX/L]]

R2_Cx = R_squared(t,y(:,1),t_exp,Cx_exp);

%%
disp('specific rates [g_i / (g_x * h)]:')
mu_max = x(3);
r_glc = max(r(:,2)); % maximal specific rate of glucose consumption, [glc/(gX*h)]

%%
disp('yields [g_x / g_i]')
Yx_s = mu_max / r_glc;

%% Output
report = [R2_Cx Cx_final r_glc Yx_s]';
end