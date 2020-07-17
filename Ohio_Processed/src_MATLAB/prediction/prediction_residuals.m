function pres = prediction_residuals(my_dataset,my_models,preprocess_method,PH,varargin)
%
% Obtain prediction residuals
%
% INPUTS
% my_dataset: Nx1 patient format data
% my_models: Nx1 cell array of identified models
% preprocess_method: selected preprocessing method - see PatientDatasetPreprocess() for doc
% PH: prediction horizon (steps)
%

p = inputParser;
addParameter(p,'burn_in',100,@isnumeric);
addParameter(p,'verbose',false,@islogical);
addParameter(p,'signed',0,@isnumeric);
parse(p,varargin{:});
burn_in = p.Results.burn_in;
verbose = p.Results.verbose;
signed = p.Results.signed;

disp('Performing prediction...')

%% preprocessing
for ind_pat = 1:length(my_dataset)
    patient = my_dataset{ind_pat};
    test_data{ind_pat} = PatientPreprocess(patient, preprocess_method);
end

%%
if verbose
    parfor_progress(length(my_dataset));
end
parfor N = 1:length(my_dataset)
    
%     % haus-gemacht Kalman
%     [my_pres{N,1},my_pred{N,1}] = my_get_prediction_residuals(test_data{N}, my_models{N}, PH, burn_in);
    
    % matlab kalman
    [matlab_pres{N},matlab_pred{N}] = matlab_get_prediction_residuals(my_models{N},test_data{N},my_dataset{N}.time,PH,burn_in);
    
    if verbose
        parfor_progress;
    end
end
if verbose
    parfor_progress(0);
end

%%
pres = matlab_pres;

%% if requested, ignore negative or positive residuals
for N = 1:length(my_dataset)
    switch signed
        case -1
            pres{N}(pres{N} > 0) = 0;
        case 0
            %
        case 1
            pres{N}(pres{N} < 0) = 0;
    end
end


%%
% N = 1;
% debug_debug(matlab_pred{N},matlab_pres{N},my_pred{N},my_pres{N},test_data{N}.OutputData,my_dataset{N}.time);

end

function debug_debug(matlab_pred,matlab_pres,my_pred,my_pres,y,t)

% plot with matlab prediction
figure
hold on
plot(t, matlab_pred)
plot(t, my_pred)
plot(t, y, 'k')
legend('matlab','my','y')

p1 = normalize(matlab_pres,'range',[0 1]);
p2 = normalize(my_pres,'range',[0 1]);

figure
hold on
plot(t, p1)
plot(t, p2)
legend('matlab','my')

figure
plot(t, p1 - p2)
end

%%
function [pred_res, pred] = matlab_get_prediction_residuals(my_model,my_data,t,PH,burn_in)
% matlab prediction
pred = predict(my_model,my_data,PH,predictOptions('InitialCondition','z'));
pred = pred.OutputData;
% measurements
y = my_data.OutputData;
% prediction residual
pred_res = y - pred;
% remove calibration portions
data_Ts = round(minutes(t(2)-t(1)));
isCalibration = time_portions(t, [0 12]+(PH*data_Ts/60), 30);
pred_res(boolean(isCalibration)) = 0;
% remove burn-in
pred_res(1:burn_in,:) = 0;
end

%%
function [pred_res_norm,yhat_out] = my_get_prediction_residuals(test_data, my_model, PH, burn_in)

% haus-gemacht Kalman
[yhat_smart,sd,yhat_canon,y] = Kalman_FD_predictor(test_data,my_model,PH);
yhat = yhat_canon;

% account for prediction time
yhat = [zeros(PH-1,size(yhat,2)); yhat(1:end-PH+1,:)];
y = [zeros(PH-1,size(yhat,2)); y(1:end-PH+1,:)];
sd = [zeros(PH-1,size(yhat,2)); sd(1:end-PH+1,:)];

% calculate normalized prediction residual
pred_res_norm = (y - yhat) ./ sd;
pred_res_norm = pred_res_norm(:,PH);

% remove burn-in portion
pred_res_norm(1:burn_in,:) = 0;

% output prediction
yhat_out = yhat(:,PH);
yhat_out(1:burn_in,:) = 0;
end

%%
function isPortion = time_portions(time, HH, MM)
% Return portions of time from HH:00 to HH:MM

t = time;
time = datenum(time);

% set calibration interval (in datetime)
HH = mod(HH,24);
HH = HH/24;
MM = MM/60/24;
time_interval = [HH; HH + MM];

isPortion = boolean(zeros(size(t)));
% remove calibration portions
for ind = 1:size(time_interval,2)
    
    cal_start = time_interval(1,ind);
    cal_end = time_interval(2,ind);
    
    x = ( mod(time,1) >= cal_start & mod(time,1) <= cal_end );
    isPortion = (isPortion + x);
end

end



