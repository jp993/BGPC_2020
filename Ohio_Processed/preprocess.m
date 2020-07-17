%% Run it after toTimetable

clear all
close all
clc

addpath(genpath('src_MATLAB'))
addpath(genpath('lib_MATLAB'))
dbclear if error
subjs = {'559','563','570','575','588','591','540','544','552','567','584','596'};
%subjs = {'559','563','570','575','588','591'};
set = 'Testing';

for s = 1:length(subjs)
    
    subj = subjs{s};
    load(fullfile(['Ohio' subj],['Ohio' subj '_' set '_timetable']));
    disp(['Processing patient Ohio' subj]);
    
    %Drop things related to non-common features
    %if(s<=6)
    %    patient.basis_heart_rate = [];
    %    patient.basis_steps = [];
    %    patient.basis_air_temperature = [];
    %    patient.bwz_input = [];
    %else
    %    patient.acceleration = [];
    %end
    
    
    %Drop SMBG
    patient.SMBG = [];
    
    %Drop sleep quality
    patient.sleep_quality = [];
    patient.basis_sleep_quality = [];
    
    %One-hot-encode CHO_type into an indicator
    patient.is_breakfast = zeros(height(patient),1);
    patient.is_lunch = zeros(height(patient),1);
    patient.is_dinner = zeros(height(patient),1);
    patient.is_hypotreatment = zeros(height(patient),1);
    patient.is_snack = zeros(height(patient),1);
    for i = 1:height(patient)
        if(strcmp(patient.CHO_type{i},'Breakfast'))
            patient.is_breakfast(i) = 1;
        end
        if(strcmp(patient.CHO_type{i},'Lunch'))
            patient.is_lunch(i) = 1;
        end
        if(strcmp(patient.CHO_type{i},'Dinner'))
            patient.is_dinner(i) = 1;
        end
        if(strcmp(patient.CHO_type{i},'HypoCorrection'))
            patient.is_hypotreatment(i) = 1;
        end
        if(strcmp(patient.CHO_type{i},'Snack'))
            patient.is_snack(i) = 1;
        end
    end
    patient.CHO_type = [];
    
    %Merge sleep with basis_sleep
    patient.sleep = max([patient.sleep patient.basis_sleep]')';
    patient.basis_sleep = [];
    
    if(strcmp(set,"Training")) %If Training, interpolate
        %Fill CGM NaNs when nan windows are at max 30min (6 samples)
        nan_th = 60/5; %occhio: sta roba e' da settare anche in causal.derivative.m
        [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.CGM,nan_th);
        patient.CGM(short_nan) = interp1(patient.Time(~isnan(patient.CGM)),patient.CGM(~isnan(patient.CGM)),patient.Time(short_nan));
        
        %Same for GSR
        [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.basis_gsr,nan_th);
        patient.basis_gsr(short_nan) = interp1(patient.Time(~isnan(patient.basis_gsr)),patient.basis_gsr(~isnan(patient.basis_gsr)),patient.Time(short_nan));
        
        %Same for skin temperature
        [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.basis_skin_temperature,nan_th);
        patient.basis_skin_temperature(short_nan) = interp1(patient.Time(~isnan(patient.basis_skin_temperature)),patient.basis_skin_temperature(~isnan(patient.basis_skin_temperature)),patient.Time(short_nan));
        
        if(s<=6)
            %Same for heart rate
            [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.basis_heart_rate,nan_th);
            patient.basis_heart_rate(short_nan) = interp1(patient.Time(~isnan(patient.basis_heart_rate)),patient.basis_heart_rate(~isnan(patient.basis_heart_rate)),patient.Time(short_nan));
            
            %Same for air temperature
            [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.basis_air_temperature,nan_th);
            patient.basis_air_temperature(short_nan) = interp1(patient.Time(~isnan(patient.basis_air_temperature)),patient.basis_air_temperature(~isnan(patient.basis_air_temperature)),patient.Time(short_nan));
            
        else
            %Same for acceleration
            [short_nan,long_nan,nan_start,nan_end] = Find_nan_islands(patient.acceleration,nan_th);
            patient.acceleration(short_nan) = interp1(patient.Time(~isnan(patient.acceleration)),patient.acceleration(~isnan(patient.acceleration)),patient.Time(short_nan));
        end
    end
    
    %Nan steps should be 0
    if(s<=6)
        patient.basis_steps(isnan(patient.basis_steps))=0;
    end
    
    %Add Lollo's features
    feats = extract_AP_feats(patient.CGM,patient.basal_insulin*60,patient.bolus_insulin*60,patient.CHO,ones(height(patient),1),ones(height(patient),1),patient.basal_insulin*60,5,1);
    feats.cgm =[];
    patient = [patient feats];
    
    %Add hour of the day
    patient.hour_of_day = patient.Time.Hour;
    
    %Add static and dynamic risk
    [SR,DR] =dynamic_risk_tanh(patient.CGM,patient.der,3.5,0.75,5);
    patient.SR = SR;
    patient.DR = DR;
    
    %Impute night when there is no sleep data
    %patient.sleep = impute_sleep(patient);
    
    %Smoothed exercise
    %patient.exercise_action = getExerciseAction(patient.Time,patient.exercise);
    [b1, b2] = twoCompSysD(patient.exercise,0.02,5);
    patient.exercise_ob_1st = b2;
    patient.exercise_ob_2nd = b1;
    
    % SAVE
    save(fullfile(['Ohio' subj],['Ohio' subj '_' set '_preprocessed']),'patient','metadata');
    
end
