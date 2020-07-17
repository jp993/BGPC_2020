clear all
close all
clc

dbstop if error
subjs = {'559','563','570','575','588','591'};
subjs = {'559'};
for s = 1:length(subjs)
    
    subj = subjs{s};
    load(fullfile(['Ohio' subj],['Ohio' subj]));
    
    %Impute Nans in CGM and allineate CGM samples on a 5 min grid
    Time = patient.timeseries.CGM.time(1):minutes(5):patient.timeseries.CGM.time(end);
    Value = nan(1,length(Time));
    for t = 1:length(patient.timeseries.CGM.time)
        d = Time - patient.timeseries.CGM.time(t);
        idx = find(abs(d)==min(abs(d)));
        Value(idx) = patient.timeseries.CGM.value(t);
    end
    patient.timeseries.CGM.time = Time;
    patient.timeseries.CGM.value = Value;
    
    %Transform basal insulin into a time series using the same time grid
    %as CGM
    %a. Shift to the grid
    Value = nan(1,length(Time));
    for t = 1:length(patient.timeseries.basal_insulin.time)
        d = Time - patient.timeseries.basal_insulin.time(t);
        idx = find(abs(d)==min(abs(d)));
        Value(idx) = patient.timeseries.basal_insulin.value(t);
    end
    patient.timeseries.basal_insulin.time = Time;
    patient.timeseries.basal_insulin.value = Value;
    %b. Fill the nans
    val = patient.timeseries.basal_insulin.value(1);
    for i = 2:length(Time)
        if(isnan(patient.timeseries.basal_insulin.value(i)))
            patient.timeseries.basal_insulin.value(i) = val;
        else
            val = patient.timeseries.basal_insulin.value(i);
        end
    end    
    
    %Integrate temp_basal into basal_insulin
    for t = 1:length(patient.timeseries.temp_basal.time_begin)
        d1 = Time - patient.timeseries.temp_basal.time_begin(t);
        idx1 = find(abs(d1)==min(abs(d1)));
        d2 = Time - patient.timeseries.temp_basal.time_end(t);
        idx2 = find(abs(d2)==min(abs(d2)));
        patient.timeseries.basal_insulin.value(idx1:idx2) = patient.timeseries.temp_basal.value(t);
    end 
    patient.timeseries = rmfield(patient.timeseries,'temp_basal');
    
    
    %Transform insulin boluses
    Value = nan(1,length(Time));
    for t = 1:length(patient.timeseries.insulin_bolus.time_begin)
        d = Time - patient.timeseries.insulin_bolus.time_begin(t);
        idx = find(abs(d)==min(abs(d)));
        if(~isnan(Value(idx)))
            disp('WARNING: Found another bolus at given idx. Summing up');
            if(strcmp(patient.timeseries.insulin_bolus.type{t},'normal') || strcmp(patient.timeseries.insulin_bolus.type{t},'normal dual'))
                Value(idx) = Value(idx) + patient.timeseries.insulin_bolus.value(t);
            else
                
                dur = patient.timeseries.insulin_bolus.time_end(t)-patient.timeseries.insulin_bolus.time_begin(t);
                steps = dur/minutes(5);
                for st = 1:steps
                    temp = Value(idx);
                    
                end
            end
        else
            Value(idx) = patient.timeseries.insulin_bolus.value(t);
        end
    end
    patient.timeseries.insulin_bolus.time_begin = Time;
    patient.timeseries.insulin_bolus.value = Value;
    
    %Transform steps into a time series using the same time grid
    %as CGM
    Value = nan(1,length(Time));
    for t = 1:length(patient.timeseries.basis_steps.time)
        d = Time - patient.timeseries.basis_steps.time(t);
        idx = find(abs(d)==min(abs(d)));
        Value(idx) = patient.timeseries.basis_steps.value(t);
    end
    patient.timeseries.basis_steps.time = Time;
    patient.timeseries.basis_steps.value = Value;
    
    %Remove useless fields
    patient.timeseries.stressors = rmfield(patient.timeseries.stressors,{'description','type'});
    
    save(fullfile(['Ohio' subj],['Ohio' subj '_transformed']),'patient');
end