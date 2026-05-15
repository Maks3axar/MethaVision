function grafik(t,y,t_exp,Cx_exp,x,p)
t_lag = x(2);
T = p(1)-273;

R2_Cx = R_squared(t,y(:,1),t_exp,Cx_exp);

figure(1)
subplot(2,2,1)
plot(t,y,t_exp,Cx_exp,'ob')
title(['A: concentrations at ' num2str(T),'°C'])
xlabel('Time [h]')
ylabel('C_{\iti} [g_{\iti} / L]')
legend('biomass','glucose')
line([t_lag ; t_lag],[0 ; ceil(max(y(:,2)))],'LineStyle',':') 
line([0 ; t(end)],[max(y(:,1)) ; max(y(:,1))],'LineStyle',':')
text('Interpreter','latex',...
 'String', num2str(R2_Cx), ... 
 'Position',[12.5 1.5],...
 'FontSize',10)

specific_rates = rate_equations(t,y,p);
mu = specific_rates(:,1);         % specific rate of biomass growth on glucose, [gX/(gX*h)]
r_glc = specific_rates(:,2);      % specific rate of glucose consumption, [g_glc/(gX*h)]

subplot(2,2,2)
plot(t,mu,t,r_glc); 
title(['B: specific rates at ' num2str(T),'°C'])
xlabel('Time [h]')
ylabel('r_{\iti} [g_{\iti} / (g_{x}*h)]')
legend('biomass','glucose')
line([t_lag ; t_lag],[0 ; ceil(max(r_glc))],'LineStyle',':')

q_X = mu .* y(:,1);
q_glc = r_glc .* y(:,1);

subplot(2,2,3)
plot(t,q_X,t,q_glc)
title(['C: volumetric rates at ' num2str(T),'°C'])
xlabel('Time [h]')
ylabel('q_{\iti} [g_{\iti} / (L*h)]')
legend('biomass','glucose')
line([t_lag ; t_lag],[0 ; ceil(max(q_glc))],'LineStyle',':') 

subplot(2,2,4)
plot(t,y(:,1),t_exp,Cx_exp,'ob')
title(['D: concentrations of biomass at ' num2str(T),'°C'])
xlabel('Time [h]')
ylabel('C_{\itx} [g_{\iti} / L]')
legend('biomass')
line([t_lag ; t_lag],[0 ; ceil(max(y(:,1)))],'LineStyle',':') 
line([0 ; t(end)],[max(y(:,1)) ; max(y(:,1))],'LineStyle',':')
text('Interpreter','latex',...
 'String', num2str(R2_Cx), ... 
 'Position',[12.5 1.5],...
 'FontSize',10)

end