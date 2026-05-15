function R2 = R_squared(t_model, y_model, t_measured, y_measured)
% calculation of R-squared for modeled trajetories over experimental data

% * t_model - time-line of model-data
% * y_model - modeled y's
% * t_measured - time-line for measured trajectories
% * y_measured - measured y's

%% Remove NaNs from measured dataset
C = [t_measured y_measured];
j = 1;

for h = 1:length(C)
    if isnan(C(j,2))
        C(j,:) = [];
    else
        j = j+1;
    end
end 

t_measured = C(:,1);
y_measured = C(:,2);

%% interpolates simulated  data at time points where real measurements exist
SimInt = zeros(size(t_measured));   % Interpolated from Simulated; creates null matrix for interpolated data from simulated matrix
k = 1; % index of simulated data

for i = 1:length(t_measured)     % index of 'experimental' data
    while 1
        if (t_model(k) <= t_measured(i)) && (t_measured(i)<= t_model(k+1));
           SimInt(i) = y_model(k) + ((y_model(k+1) - y_model(k))./...
           (t_model(k+1) - t_model(k))).*(t_measured(i) - t_model(k)); % interpolation
           break
        end 
        k = k+1;
    end % for k
end % for i

%% calculates squared errors for modeled data
squared_errors = ((y_measured - SimInt).^2);
sum1 = sum(squared_errors);

%% calculate squared errors for non-fitted data
average = mean(y_measured); 
y_measured_error = (y_measured - average).^2;
sum2 = sum(y_measured_error);

%% calculation of R_squared
R2 = 1 - (sum1/sum2);

end