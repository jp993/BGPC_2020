function [pred_smart,pred_error,pred_canon,measure_mat] = Kalman_FD_predictor(my_data,my_model,PH,varargin)
%
% my_data: iddata
% my_model: identified model
% PH: Prediction Horizon
%

%% Read inputs
p = inputParser;
addParameter(p,'confidence_k',4,@isnumeric);
addParameter(p,'faulty_samples',6,@isnumeric);
parse(p,varargin{:});

FD_settings.confidence_interval_k=p.Results.confidence_k; % Prediction confidence interval for 1-step Fault Detection
FD_settings.n_faulty_samples_th=p.Results.faulty_samples; % Number of faulty samples allowed before white flag
FD_settings.steps_PH=PH; % prediction horizon = sample_time * steps_PH    [min]

%% Convert model from idss to struct (this improves performance by a lot)
model_struct.A=my_model.A; model_struct.B=my_model.B; model_struct.C=my_model.C; model_struct.D=my_model.D;
model_struct.NoiseVariance=my_model.NoiseVariance;
model_struct.K=my_model.K;
model_struct.InputDelay=my_model.InputDelay;

my_model=model_struct;
%-----------------------------------------%

%% Measurements and inputs
% Measurements
my_measurement=my_data.OutputData;
% Input
my_input=my_data.InputData;
% add model delay if existing
delay_val=my_model.InputDelay;
input1=[zeros(delay_val(1),1); my_input(:,1); NaN*ones(max(delay_val)-delay_val(1),1)];
input2=[zeros(delay_val(2),1); my_input(:,2); NaN*ones(max(delay_val)-delay_val(2),1)];
my_input=[input1 input2];

%% Variables initialization
% ---------- output initialization ----------
n_samples=length(my_measurement);
pred_error = zeros(n_samples,PH);
pred_smart = zeros(n_samples,PH);
pred_canon = zeros(n_samples,PH);
measure_mat = zeros(n_samples,PH);

% ---------- FD algorithm status ----------
FD_status.fault_counter=0;
FD_status.filter_white_flag=0;

% ---------- Kalman filter initialization ----------
[X_0,P_0] = Kalman_initialization(my_model,'infinite');
% measure noise estimation is initialized with high value
R_t=10000*my_model.NoiseVariance;
% initial X(t|t), P(t|t)
X_smart_t_t=X_0;
P_smart_t_t=P_0;
X_canon_t_t=X_0;
P_canon_t_t=P_0;


%% Prediction for each step
for ind_time=1:length(my_measurement)-PH
    
    %% CURRENT TIME: t+1
    FD_status.current_time_ind=ind_time;
    
    %% ========== current inputs and measurements ==============
    % u(t), u(t+1), y(t), y(t+1)
    if ind_time>1
        u_t=my_input(ind_time-1,:);
        y_t=my_measurement(ind_time-1);
    else
        u_t=[0 0];
        y_t=0;
    end
    u_t1=my_input(ind_time,:);
    y_t1=my_measurement(ind_time);
    
    % input from t+1 until t+N
    u_t_TO_tn=my_input(ind_time:ind_time+PH-1,:);
    % =============================================================================================================================
    
    %% ========== 1-step prediction ===================
    % canon 1-step prediction
    [X_canon_t1_t,P_canon_t1_t,Y_canon_t1_t,Py_canon_t1_t] = One_step_prediction(y_t,u_t,u_t1,X_canon_t_t,P_canon_t_t,R_t,my_model);
    % 1-step prediction using R(t)
    [X_smart_t1_t,P_smart_t1_t,Y_t1_t,Py_t1_t] = One_step_prediction(y_t,u_t,u_t1,X_smart_t_t,P_smart_t_t,R_t,my_model);
    % ==============================================================================================================================
    
    %% ========== N-steps prediction ===================
    % canonical prediction
    [canon_prediction,canon_SD] = N_steps_predictor(X_canon_t1_t,P_canon_t1_t,Y_canon_t1_t,Py_canon_t1_t,u_t_TO_tn,PH,my_model);
    % algorithm prediction
    [my_prediction,my_SD] = N_steps_predictor(X_smart_t1_t,P_smart_t1_t,Y_t1_t,Py_t1_t,u_t_TO_tn,PH,my_model);
    % ==============================================================================================================================
    
    %% ======= CGM only fault detection using prediction =========
    % confidence interval is k*(prediction_SD)
    m=FD_settings.confidence_interval_k;
    % CGM related faults
    [fd_CGM] = one_step_FD(y_t1,my_prediction(1),my_SD(1),m);
    FD_status.FD_CGM = fd_CGM;
    % ==============================================================================================================================
    
    %% ========== State update =========================
    [X_smart_t1_t1,P_smart_t1_t1,X_canon_t1_t1,P_canon_t1_t1,R_t1,FD_status] = ...
        Update_state(y_t1,u_t1,X_canon_t1_t,P_canon_t1_t,X_smart_t1_t,P_smart_t1_t,my_model.NoiseVariance,fd_CGM,FD_status,FD_settings,my_model);
    % ==============================================================================================================================
    
    %% update for next time step
    P_smart_t_t=P_smart_t1_t1;
    X_smart_t_t=X_smart_t1_t1;
    P_canon_t_t=P_canon_t1_t1;
    X_canon_t_t=X_canon_t1_t1;
    R_t=R_t1;
    
    %% store output
    
    % full window prediction error (standard deviation)
    pred_error(ind_time,:)=my_SD';
    % full window prediction
    pred_smart(ind_time,:)=my_prediction';
    pred_canon(ind_time,:)=canon_prediction';
    % full window measurement
    measure_mat(ind_time,:) = my_measurement(ind_time+[0:PH-1])';
    
    %% reset filter white flag in case it was raised
    FD_status.filter_white_flag=0;
    
end

end


function [fault_signal] = one_step_FD(y_t1,prediction,SD,m)
%
% 1-step ahead Fault Detection
%
% If the measurement (y_t1) is outside of the confidence interval given by the
% prediction then a fault is signaled.
%
% Confidence interval of the prediction is given by:
% [prediction +- (SD*m)]
%
% where
% SD: prediction standard deviation
% m: coefficient
%

if  y_t1 > prediction + m*SD || y_t1 < prediction - m*SD
    fault_signal=1; % Fault detected!
else
    fault_signal=0; % No fault detected
end


end


