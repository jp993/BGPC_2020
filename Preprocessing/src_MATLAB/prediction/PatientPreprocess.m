function proc_data = PatientPreprocess(patient,method)
% Preprocessing of patient data for model identification, using specified method
%
% methods:
% 'no':                 no preprocessing
% 'mean_scale':         subtract mean
% 'first_value_scale':  subtract first value
% 'input_transf':       transforms insulin using CR
% 'IR_integrator':      integrate meal and insulin signals
% 'CR_CF_norm':         adjust impulsive response gain using CR and CF
% 'bayesian':           bayesian smoothing of CGM
% 'smooth':             smoothing of CGM

%% check method
valid_methods={'no','mean_scale','first_value_scale','input_transf','IR_integrator','CR_CF_norm','bayesian','smooth'};

if ~any(ismember(valid_methods,method))
    error(['Invalid method, valid methods are: [' strjoin(valid_methods,',') ']'])
end

%% patient data
% time
patient.time = datenum(patient.time);
time = patient.time*24*60; % minutes
Ts = round(time(2)-time(1));

% signals
CGM = patient.CGM;
basal = patient.basal/60; % U/h -> U/min
bolus = patient.bolus/60; % U/h -> U/min
meal = patient.meal;

% therapy values
CR = patient.CR;
CF = patient.CF;
OL_basal = patient.insulin_basal_value/60; % U/h -> U/min

%% initialize output
if strcmp(method,'no')
    proc_data=iddata(CGM,[basal+bolus meal],Ts);
    proc_data.Tstart=patient.time(1);
    proc_data.SamplingInstants=patient.time;
    proc_data.TimeUnit='days';
    return
end

%% integrator settings
tau_I=400;
tau_M=500;

%% input preprocessing

switch method
    
    case 'mean_scale'
        proc_Y = CGM;
        proc_I = basal+bolus;
        proc_M = meal;
        
        proc_Y=(proc_Y-mean(proc_Y));
        proc_I=(proc_I-mean(proc_I));
        proc_M=(proc_M-mean(proc_M));
    
    case 'input_transf'
        % transform insulin using CR
        
        proc_Y=CGM;
        proc_Y=(proc_Y-mean(proc_Y));
        
        M = meal;
%         M=hypo_treatment;
        proc_I=(basal+bolus)-OL_basal-(M./CR);
        
        proc_M=meal;
        proc_M=(proc_M-mean(proc_M));
%         proc_I=proc_I-nominal_basal_insulin-(proc_M./CR);
        
    case 'IR_integrator'
        % integrate meal and insulin signals
        
        proc_I = Integrator_filter(proc_I-mean(proc_I),time,Ts,tau_I);
        proc_M = Integrator_filter(proc_M-mean(proc_M),time,Ts,tau_M);
        
    case 'CR_CF_norm'
        % adjust impulsive response gain using CR and CF
        CF=mean(CF);
        CR=mean(CR);
        
        proc_I = Gain_filter(proc_I-mean(proc_I),time,Ts,-CF);
        proc_M = Gain_filter(proc_M-mean(proc_M),time,Ts,CF/CR);
        
        proc_I = Integrator_filter(proc_I,time,Ts,tau_I);
        proc_M = Integrator_filter(proc_M,time,Ts,tau_M);
end

%% output preprocessing
switch method
    
    case 'bayesian'
        % bayesian smoothing of CGM data
        
        proc_Y = bayes_smoothing(proc_Y-mean(proc_Y), time', 1);
        
    case 'smooth'
        % smoothing of CGM data
        
        proc_Y=smooth(proc_Y-mean(proc_Y),'lowess');
        
end

%% scaling
if strcmp(method,'first_value_scale')
    proc_Y=(proc_Y-proc_Y(1));
    proc_I=(proc_I-proc_I(1));
    proc_M=(proc_M-proc_M(1));
else
    proc_Y=(proc_Y-mean(proc_Y));
    proc_I=(proc_I-mean(proc_I));
    proc_M=(proc_M-mean(proc_M));
end

%% output
% iddata format
proc_data=iddata(proc_Y,[proc_I proc_M],Ts);
% time info
proc_data.Tstart=patient.time(1);
proc_data.SamplingInstants=patient.time;
proc_data.TimeUnit='days';

end

function my_out = Gain_filter(my_input,my_time,Ts,gain)
% subtract mean
% my_input=my_input-mean(my_input);
% transfer function
filt_gain=c2d(tf(gain),Ts);
% time measure unit
filt_gain.TimeUnit='minutes';
% simulation starts at zero initial time
my_time=my_time-my_time(1);
% gain filter
my_out=lsim(filt_gain,my_input,my_time);
end

function my_out = Integrator_filter(my_input,my_time,Ts,tau)
% subtract mean
% my_input=my_input-mean(my_input);
% transfer function
integrator=c2d(tf(-1,[tau 1]),Ts);
% time measure unit
integrator.TimeUnit='minutes';
% simulation starts at zero initial time
my_time=my_time-my_time(1);
% integrator filter
my_out=lsim(integrator,my_input,my_time);

end

