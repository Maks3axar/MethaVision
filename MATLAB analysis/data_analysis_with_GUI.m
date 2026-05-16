%% Cell Cycle & Growth Rate Analysis (with GUI Integration)
% This scipt contains pipeline with automated processing, analysis, and visualization of experimental microbiological data. The script bridges high-throughput image analysis with kinetic growth modeling for bioreactor and cultivation monitoring.

% Key Features:
% Image Data Aggregation: Automatically merges and vertically concatenates multi-replicate dataset matrix files (`dataset.mat`) across multiple experimental timepoints ($t = 3, 5, 7, 9$ hours).
% Interactive Data Inspection (GUI): Integrates with a custom Graphical User Interface (`ScatterGUI`) to visualize single-cell scattering parameters dynamically for each timepoint.
% Growth Kinetics Modeling: Loads optical density records (`OD600.mat`) across independent biological replicates to calculate culture growth rates.
% Statistical Analysis & Error Handling: Computes the mean durations and standard deviations for distinct cell cycle phases (e.g., $G_1/S/G_2$ and $M$ phases).
% Automated Plotting: Generates publication-ready figures featuring custom markers, error bars (`errorbar`), and formatted axis layouts to track cell cycle distribution dynamics over time.

% File Requirements
% To run the script successfully, ensure the following workspace files are present in your directory:
    % dataset.mat – Containing the structured matrix arrays (`photoanalysisS_X_X`) from image processing.
    % OD600.mat – Containing time-series optical density calibration data.
    % ScatterGUI.m – The dependent GUI function utilized for scattering profile visualization.

% Developer: Dr. Maksim Zakhartsev (C1BioEngineering, Moscow, Russia)
% Release Date: 20.02.2026

%% Loading data from processed photos
load dataset.mat

photoanalysisS_3 = vertcat(photoanalysisS_3_1, photoanalysisS_3_2, photoanalysisS_3_3);
photoanalysisS_5 = vertcat(photoanalysisS_5_1, photoanalysisS_5_2, photoanalysisS_5_3);
photoanalysisS_7 = vertcat(photoanalysisS_7_1, photoanalysisS_7_2, photoanalysisS_7_3);
photoanalysisS_9 = vertcat(photoanalysisS_9_1, photoanalysisS_9_2, photoanalysisS_9_3);

timepoint = [3; 5; 7; 9]; % Экспериментальное время, [h]

ScatterGUI(photoanalysisS_3, timepoint(1));
ScatterGUI(photoanalysisS_5, timepoint(2));
ScatterGUI(photoanalysisS_7, timepoint(3));
ScatterGUI(photoanalysisS_9, timepoint(4));

%% Growth rate analysis 
% load experimental dataset on OD600(t)
load OD600.mat
% data represent growth of the culture in three independent repitions
% the optical density of the culture is measured at 600 [nm]
% x(:,1) - time, [h]
% x(:,2) - flask 1, [OU] @ 600 [nm]
% x(:,3) - flask 2, [OU] @ 600 [nm]
% x(:,4) - flask 3, [OU] @ 600 [nm]

avrOD600 = zeros(3,length(OD600))';
% calculate average and std for OD600 at each timepoint
for i=1:length(OD600)
    avrOD600(i,1) = OD600(i,1); % time
    avrOD600(i,2) = mean(OD600(i,2:4)); % average OD600
    avrOD600(i,3) = std(OD600(i,2:4)); % standart deviation of OD600
end
clear i

%% ODE model
% define experimental data
t_exp = avrOD600(:,1); % experimental time, [h]
OD600_exp = avrOD600(:,2); % averaged optical density of the bimass @ 600 [nm], [OU] 

% Define simulation time-vector
t_model = (0:0.01:t_exp(end)+1)'; % simulation time, [h]

% define initial values of the variables
y0 = initial_conditions(OD600_exp(1));

% Load parameter vector
load x.mat
% x(1) - initial lag-time, [h]
% x(2) - initial maximal mu, [1/h]
p = parameters(x);

% Integration
ode_opt = odeset('NonNegative',1, 'RelTol', 1e-6, 'AbsTol', 1e-6, 'MaxStep', 0.1);
[t_model,y_model] = ode45(@ode, t_model, y0, ode_opt, p); % ode15s

% % Reports
% report = reports(t,y,r,t_exp,Cx_exp,x);

t_lag = p(1);
R2 = R_squared(t_model, y_model, t_exp, OD600_exp);

figure;
scatter(t_exp, OD600_exp, 'filled', 'MarkerFaceColor', 'b'); % add averaged experimental data
hold on
errorbar(t_exp, OD600_exp, avrOD600(:,3), 'LineStyle', 'none', 'Color', 'k', 'CapSize', 5); % add std to averaged experimental data
plot(t_model,y_model,'-r'); % add simulation 
hold off
xlabel('time, [h]');
ylabel('optical density OD_{600}, [OU]');
title('growth curve \it{Methylococcus capsulatus} KN2');
xline(t_lag, '--', 'lag-time')
text(3.75, 0.35, sprintf('R² = %.3f', R2))
text(3.75, 0.4, sprintf('\\mu_{max} = %.3f [1/h]', p(2)))
text(3.75, 0.45, sprintf('lag-time = %.2f [h]', p(1)))
xlim([0 10])
grid on
axis square

%% analysis of the dynamics of changes in the fractional ratio and size of morphotypes of Methylococcus capsulatus cells
count_summary = zeros(4,12); % Table for accumulating data on the number of morphotypes in a sample
fraction_summary = zeros(4,9); % Table for accumulating data on the fraction of morphotypes in a sample
area_summary = zeros(4,9); % Table for accumulating data on the area of ​​morphotypes in a sample

% Loop through all tables table_1_1, table_1_2, ..., table_2_3
for i = 3:2:9  % The first digit (3, 5, 7, 9) is the experimental time index
    for j = 1:3  % The second digit (1, 2, 3) is the index of the experimental flask
        % Create the name: 'table_1_1', 'table_1_2', ...
        table_name = sprintf('photoanalysisS_%d_%d', i, j);
        
        % Call the Table
        current_table = eval(table_name);
               
        % Example: counting the number of rows
        count_total = height(current_table); % total number of identified objects
        % Filtering data by morphotypes
        idx_monococci = ismember(current_table.class, 'monococci');
        idx_diplococci = ismember(current_table.class, 'diplococci');
        idx_tetracocci = ismember(current_table.class, 'tetracocci');

        % counting the number of morphotypes in classes
        count_monococci = sum(idx_monococci);
        count_diplococci = sum(idx_diplococci);
        count_tetracocci = sum(idx_tetracocci);
        count_Mc = count_monococci + count_diplococci + count_tetracocci; % counting only the cell morphotypes of Methylococcus capsulatus

        fraction_monococci = count_monococci / count_Mc;
        fraction_diplococci = count_diplococci / count_Mc;
        fraction_tetracocci = count_tetracocci / count_Mc;

        area_monococci = mean(current_table.area_m2(idx_monococci)); % average area of ​​monococci
        area_diplococci = mean(current_table.area_m2(idx_diplococci)); % average area of ​​diplococci
        area_tetracocci = mean(current_table.area_m2(idx_tetracocci)); % average area of ​​tetracocci
        
        % entering the result into the summary tables
        k = (i-1)/2;
        count_summary(k,j) = count_monococci;
        count_summary(k,j+3) = count_diplococci;
        count_summary(k,j+6) = count_tetracocci;
        count_summary(k,j+9) = count_Mc;

        fraction_summary(k,j) = fraction_monococci;
        fraction_summary(k,j+3) = fraction_diplococci;
        fraction_summary(k,j+6) = fraction_tetracocci;

        area_summary(k,j) = area_monococci;
        area_summary(k,j+3) = area_diplococci;
        area_summary(k,j+6) = area_tetracocci;
    end
end
clear i
clear j
clear k

avrFraction = zeros(4,6); % Table with statistics by faction
% calculate average and std for Fractions at each timepoint
for i=1:length(timepoint)
    avrFraction(i,1) = mean(fraction_summary(i,1:3)); % average of fraction monococci
    avrFraction(i,2) = std(fraction_summary(i,1:3)); % standart deviation of fraction monococci
    avrFraction(i,3) = mean(fraction_summary(i,4:6)); % average of fraction diplococci
    avrFraction(i,4) = std(fraction_summary(i,4:6)); % standart deviation of fraction diplococci
    avrFraction(i,5) = mean(fraction_summary(i,7:9)); % average of fraction tetracocci
    avrFraction(i,6) = std(fraction_summary(i,7:9)); % standart deviation of fraction tetracocci
end
clear i

avrArea = zeros(4,6); % Table with statistics by faction
% calculate average and std for Fractions at each timepoint
for i=1:length(timepoint)
    avrArea(i,1) = mean(area_summary(i,1:3)); % average of area monococci
    avrArea(i,2) = std(area_summary(i,1:3)); % standart deviation of area monococci
    avrArea(i,3) = mean(area_summary(i,4:6)); % average of area diplococci
    avrArea(i,4) = std(area_summary(i,4:6)); % standart deviation of area diplococci
    avrArea(i,5) = mean(area_summary(i,7:9)); % average of area tetracocci
    avrArea(i,6) = std(area_summary(i,7:9)); % standart deviation of area tetracocci
end
clear i

figure();
subplot(1,2,1)
    hold on
    plot(timepoint, avrFraction(:,1),'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    errorbar(timepoint, avrFraction(:,1), avrFraction(:,2),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrFraction(:,3),'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    errorbar(timepoint, avrFraction(:,3), avrFraction(:,4),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrFraction(:,5),'^-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','m')
    errorbar(timepoint, avrFraction(:,5), avrFraction(:,6),'Color', 'k', 'CapSize', 5) % 'LineStyle', 'none', 
    hold off
ylim([0 0.8])
xlim([0 10])
xlabel('time, [h]');
ylabel('morphotype fraction, \itf_i');
title('A: morphotype fractions \it{Methylococcus capsulatus} KN2');
legend('monococci','','diplococci','','tetracocci', 'Location','northwest');
grid on
axis square

subplot(1,2,2)
    hold on
    plot(timepoint, avrArea(:,1),'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    errorbar(timepoint, avrArea(:,1), avrArea(:,2),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrArea(:,3),'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    errorbar(timepoint, avrArea(:,3), avrArea(:,4),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrArea(:,5),'^-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','m')
    errorbar(timepoint, avrArea(:,5), avrArea(:,6),'Color', 'k', 'CapSize', 5) % 'LineStyle', 'none', 
    hold off
ylim([0 5])
xlim([0 10])
xlabel('time, [h]');
ylabel('object area [\mum^2]');
title('B: object area \it{Methylococcus capsulatus} KN2');
legend('monococci','','diplococci','','tetracocci', 'Location','northwest');
grid on
axis square

%% Calculations for joint flasks in time-points
area_all = zeros(4,3);
area_std_all = zeros(4,3);

        % Filtering data by morphotypes
        idx_monococci_3 = ismember(photoanalysisS_3.class, 'monococci');
        idx_diplococci_3 = ismember(photoanalysisS_3.class, 'diplococci');
        idx_tetracocci_3 = ismember(photoanalysisS_3.class, 'tetracocci');
        area_all(1,1) = mean(photoanalysisS_3.area_m2(idx_monococci_3)); % average area of ​​monococci
        area_std_all(1,1) = std(photoanalysisS_3.area_m2(idx_monococci_3));
        area_all(1,2) = mean(photoanalysisS_3.area_m2(idx_diplococci_3)); % average area of ​​diplococci
        area_std_all(1,2) = std(photoanalysisS_3.area_m2(idx_diplococci_3));
        area_all(1,3) = mean(photoanalysisS_3.area_m2(idx_tetracocci_3)); % average area of ​​tetracocci
        area_std_all(1,3) = std(photoanalysisS_3.area_m2(idx_tetracocci_3));

        idx_monococci_5 = ismember(photoanalysisS_5.class, 'monococci');
        idx_diplococci_5 = ismember(photoanalysisS_5.class, 'diplococci');
        idx_tetracocci_5 = ismember(photoanalysisS_5.class, 'tetracocci');
        area_all(2,1) = mean(photoanalysisS_5.area_m2(idx_monococci_5)); % average area of ​​monococci
        area_std_all(2,1) = std(photoanalysisS_5.area_m2(idx_monococci_5));
        area_all(2,2) = mean(photoanalysisS_5.area_m2(idx_diplococci_5)); % average area of ​​diplococci
        area_std_all(2,2) = std(photoanalysisS_5.area_m2(idx_diplococci_5));
        area_all(2,3) = mean(photoanalysisS_5.area_m2(idx_tetracocci_5)); % average area of ​​tetracocci
        area_std_all(2,3) = std(photoanalysisS_5.area_m2(idx_tetracocci_5));

        idx_monococci_7 = ismember(photoanalysisS_7.class, 'monococci');
        idx_diplococci_7 = ismember(photoanalysisS_7.class, 'diplococci');
        idx_tetracocci_7 = ismember(photoanalysisS_7.class, 'tetracocci');
        area_all(3,1) = mean(photoanalysisS_7.area_m2(idx_monococci_7)); % average area of ​​monococci
        area_std_all(3,1) = std(photoanalysisS_7.area_m2(idx_monococci_7));
        area_all(3,2) = mean(photoanalysisS_7.area_m2(idx_diplococci_7)); % average area of ​​diplococci
        area_std_all(3,2) = std(photoanalysisS_7.area_m2(idx_diplococci_7));
        area_all(3,3) = mean(photoanalysisS_7.area_m2(idx_tetracocci_7)); % average area of ​​tetracocci
        area_std_all(3,3) = std(photoanalysisS_7.area_m2(idx_tetracocci_7));


        idx_monococci_9 = ismember(photoanalysisS_9.class, 'monococci');
        idx_diplococci_9 = ismember(photoanalysisS_9.class, 'diplococci');
        idx_tetracocci_9 = ismember(photoanalysisS_9.class, 'tetracocci');
        area_all(4,1) = mean(photoanalysisS_9.area_m2(idx_monococci_9)); % average area of ​​monococci
        area_std_all(4,1) = std(photoanalysisS_9.area_m2(idx_monococci_9));
        area_all(4,2) = mean(photoanalysisS_9.area_m2(idx_diplococci_9)); % average area of ​​diplococci
        area_std_all(4,2) = std(photoanalysisS_9.area_m2(idx_diplococci_9));
        area_all(4,3) = mean(photoanalysisS_9.area_m2(idx_tetracocci_9)); % average area of ​​tetracocci
        area_std_all(4,3) = std(photoanalysisS_9.area_m2(idx_tetracocci_9));



figure();
subplot(1,2,1)
    hold on
    plot(timepoint, avrFraction(:,1),'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    errorbar(timepoint, avrFraction(:,1), avrFraction(:,2),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrFraction(:,3),'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    errorbar(timepoint, avrFraction(:,3), avrFraction(:,4),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avrFraction(:,5),'^-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','m')
    errorbar(timepoint, avrFraction(:,5), avrFraction(:,6),'Color', 'k', 'CapSize', 5) % 'LineStyle', 'none', 
    % plot([3 5 7 9], [0.3542 0.3265 0.2727 0.2885],'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    % plot([3 5 7 9], [0.6100 0.6380 0.6868 0.6666],'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    % plot([3 5 7 9], [0.0356 0.0354 0.0403 0.0448],'^-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','m')
    hold off
ylim([0 0.8])
xlim([0 10])
xlabel('time, [h]');
ylabel('morphotype fraction, \itf_i');
title('A: morphotype fractions \it{Methylococcus capsulatus} KN2');
% legend('monococci','','diplococci','','tetracocci', 'Location','northwest');
legend('monococci','diplococci','tetracocci', 'Location','northwest');
grid on
axis square

subplot(1,2,2)
    hold on
    plot(timepoint, area_all(:,1),'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    errorbar(timepoint, area_all(:,1), area_std_all(:,1),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, area_all(:,2),'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    errorbar(timepoint, area_all(:,2), area_std_all(:,2),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, area_all(:,3),'^-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','m')
    errorbar(timepoint, area_all(:,3), area_std_all(:,3),'Color', 'k', 'CapSize', 5) % 'LineStyle', 'none', 
    hold off
ylim([0 5])
xlim([0 10])
xlabel('time, [h]');
ylabel('object area [\mum^2]');
title('B: object area \it{Methylococcus capsulatus} KN2');
legend('monococci','','diplococci','','tetracocci', 'Location','northwest');
grid on
axis square  


%% Dynamics of changes in cell cycle parameters of Methylococcus capsulatus
t_d = log(2) / p(2); % doubling time, [h]
cell_cycle_summary = zeros(4,6); % Table for accumulating data on cell cycle duration in a sample

for i = 1:4
    for j = 1:3
        [T_G, T_M] = cell_cycle_model(p(2), fraction_summary(i,j), fraction_summary(i,j+3), fraction_summary(i,j+6));
        cell_cycle_summary(i,j) = T_G; % duration of G1/S/G2 phase
        cell_cycle_summary(i,j+3) = T_M; % duration of the M phase
    end
end
clear i
clear j

avr_cell_cycle = zeros(4,4); % Table with statistics on cell cycle duration in a sample
% calculate average and std for duration of cell cycle at each timepoint
for i=1:length(timepoint)
    avr_cell_cycle(i,1) = mean(cell_cycle_summary(i,1:3)); % average of T_G
    avr_cell_cycle(i,2) = std(cell_cycle_summary(i,1:3)); % standart deviation of T_G
    avr_cell_cycle(i,3) = mean(cell_cycle_summary(i,4:6)); % average of T_M
    avr_cell_cycle(i,4) = std(cell_cycle_summary(i,4:6)); % standart deviation of T_M
end
clear i

figure();
    hold on
    plot(timepoint, avr_cell_cycle(:,1),'o-','MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','b')
    errorbar(timepoint, avr_cell_cycle(:,1), avr_cell_cycle(:,2),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    plot(timepoint, avr_cell_cycle(:,3),'s-', 'MarkerSize', 7,'MarkerEdgeColor','k', 'MarkerFaceColor','r')
    errorbar(timepoint, avr_cell_cycle(:,3), avr_cell_cycle(:,4),'Color', 'k', 'CapSize', 5) %'LineStyle', 'none', 
    hold off
yline(t_d, '--', '\itt_d')
ylim([0 3.5])
xlim([0 10])
xlabel('time, [h]');
ylabel('length of cell cycle phase, [h]');
title('cell cycle duration \it{Methylococcus capsulatus} KN2');
legend('\itt_{G1/S/G2}','','\itt_M','','Location','northwest');
grid on
axis square