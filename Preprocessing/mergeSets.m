%% Run it after .xml files have been parsed 

clear all
close all
clc
dbstop if error

subjs = {'559','563','570','575','588','591'};
subjsV2 = {'540','544','552','567','584','596'};

toMerge = 0;
set = 'Testing'; %Training, Testing
for s = 1:length(subjs)
    
    subj = subjs{s};
    
    load(fullfile(['Ohio' subj],[set '-' subj '-ws-' lower(set)]));
    patientFirstPart = patient;
    
    if(toMerge)
        %Load testing
        load(fullfile(['Ohio' subj],[set '-' subj '-ws-' lower("Testing")]));
        patientSecondPart = patient;
    
        %CGM
        patient.timeseries.CGM.time = [patientFirstPart.timeseries.CGM.time patientSecondPart.timeseries.CGM.time];
        patient.timeseries.CGM.value = [patientFirstPart.timeseries.CGM.value patientSecondPart.timeseries.CGM.value];
    
        %SMBG
        patient.timeseries.SMBG.time	 = [patientFirstPart.timeseries.SMBG.time patientSecondPart.timeseries.SMBG.time];
        patient.timeseries.SMBG.value = [patientFirstPart.timeseries.SMBG.value patientSecondPart.timeseries.SMBG.value];
        
        %Basal insulin
        patient.timeseries.basal_insulin.time	 = [patientFirstPart.timeseries.basal_insulin.time patientSecondPart.timeseries.basal_insulin.time];
        patient.timeseries.basal_insulin.value = [patientFirstPart.timeseries.basal_insulin.value patientSecondPart.timeseries.basal_insulin.value];

        %Insulin bolus
        patient.timeseries.insulin_bolus.bwz_carb_input = [patientFirstPart.timeseries.insulin_bolus.bwz_carb_input patientSecondPart.timeseries.insulin_bolus.bwz_carb_input];
        patient.timeseries.insulin_bolus.time_begin = [patientFirstPart.timeseries.insulin_bolus.time_begin patientSecondPart.timeseries.insulin_bolus.time_begin];
        patient.timeseries.insulin_bolus.time_end = [patientFirstPart.timeseries.insulin_bolus.time_end patientSecondPart.timeseries.insulin_bolus.time_end];
        patient.timeseries.insulin_bolus.type = [patientFirstPart.timeseries.insulin_bolus.type patientSecondPart.timeseries.insulin_bolus.type];
        patient.timeseries.insulin_bolus.value = [patientFirstPart.timeseries.insulin_bolus.value patientSecondPart.timeseries.insulin_bolus.value];

        %CHO intake
        patient.timeseries.cho_intake.time	 = [patientFirstPart.timeseries.cho_intake.time patientSecondPart.timeseries.cho_intake.time];
        patient.timeseries.cho_intake.value = [patientFirstPart.timeseries.cho_intake.value patientSecondPart.timeseries.cho_intake.value];
        patient.timeseries.cho_intake.type = [patientFirstPart.timeseries.cho_intake.type patientSecondPart.timeseries.cho_intake.type];

        %Sleep
        patient.timeseries.sleep.quality = [patientFirstPart.timeseries.sleep.quality patientSecondPart.timeseries.sleep.quality];
        patient.timeseries.sleep.time_begin = [patientFirstPart.timeseries.sleep.time_begin patientSecondPart.timeseries.sleep.time_begin];
        patient.timeseries.sleep.time_end = [patientFirstPart.timeseries.sleep.time_end patientSecondPart.timeseries.sleep.time_end];

        %Basis sleep
        patient.timeseries.basis_sleep.quality = [patientFirstPart.timeseries.basis_sleep.quality patientSecondPart.timeseries.basis_sleep.quality];
        patient.timeseries.basis_sleep.time_begin = [patientFirstPart.timeseries.basis_sleep.time_begin patientSecondPart.timeseries.basis_sleep.time_begin];
        patient.timeseries.basis_sleep.time_end = [patientFirstPart.timeseries.basis_sleep.time_end patientSecondPart.timeseries.basis_sleep.time_end];

        %Temp Basal
        patient.timeseries.temp_basal.value = [patientFirstPart.timeseries.temp_basal.value patientSecondPart.timeseries.temp_basal.value];
        patient.timeseries.temp_basal.time_begin = [patientFirstPart.timeseries.temp_basal.time_begin patientSecondPart.timeseries.temp_basal.time_begin];
        patient.timeseries.temp_basal.time_end = [patientFirstPart.timeseries.temp_basal.time_end patientSecondPart.timeseries.temp_basal.time_end];

        %Work
        patient.timeseries.work.intensity = [patientFirstPart.timeseries.work.intensity patientSecondPart.timeseries.work.intensity];
        patient.timeseries.work.time_begin = [patientFirstPart.timeseries.work.time_begin patientSecondPart.timeseries.work.time_begin];
        patient.timeseries.work.time_end = [patientFirstPart.timeseries.work.time_end patientSecondPart.timeseries.work.time_end];

        %Stressors
        patient.timeseries.stressors.description = [patientFirstPart.timeseries.stressors.description patientSecondPart.timeseries.stressors.description];
        patient.timeseries.stressors.time = [patientFirstPart.timeseries.stressors.time patientSecondPart.timeseries.stressors.time];
        patient.timeseries.stressors.type = [patientFirstPart.timeseries.stressors.type patientSecondPart.timeseries.stressors.type];

        %Hypo event
        patient.timeseries.hypo_event.time = [patientFirstPart.timeseries.hypo_event.time patientSecondPart.timeseries.hypo_event.time];

        %Illness
        patient.timeseries.illness.time = [patientFirstPart.timeseries.illness.time patientSecondPart.timeseries.illness.time];

        %Exercise
        patient.timeseries.exercise.time = [patientFirstPart.timeseries.exercise.time patientSecondPart.timeseries.exercise.time];
        patient.timeseries.exercise.intensity = [patientFirstPart.timeseries.exercise.intensity patientSecondPart.timeseries.exercise.intensity];
        patient.timeseries.exercise.duration = [patientFirstPart.timeseries.exercise.duration patientSecondPart.timeseries.exercise.duration];

        %Basis heart rate
        patient.timeseries.basis_heart_rate.time = [patientFirstPart.timeseries.basis_heart_rate.time patientSecondPart.timeseries.basis_heart_rate.time];
        patient.timeseries.basis_heart_rate.value = [patientFirstPart.timeseries.basis_heart_rate.value patientSecondPart.timeseries.basis_heart_rate.value];

        %Basis gsr
        patient.timeseries.basis_gsr.time = [patientFirstPart.timeseries.basis_gsr.time patientSecondPart.timeseries.basis_gsr.time];
        patient.timeseries.basis_gsr.value = [patientFirstPart.timeseries.basis_gsr.value patientSecondPart.timeseries.basis_gsr.value];

        %Basis skin temperature
        patient.timeseries.basis_skin_temperature.time = [patientFirstPart.timeseries.basis_skin_temperature.time patientSecondPart.timeseries.basis_skin_temperature.time];
        patient.timeseries.basis_skin_temperature.value = [patientFirstPart.timeseries.basis_skin_temperature.value patientSecondPart.timeseries.basis_skin_temperature.value];

        %Basis air temperature
        patient.timeseries.basis_air_temperature.time = [patientFirstPart.timeseries.basis_air_temperature.time patientSecondPart.timeseries.basis_air_temperature.time];
        patient.timeseries.basis_air_temperature.value = [patientFirstPart.timeseries.basis_air_temperature.value patientSecondPart.timeseries.basis_air_temperature.value];

        %Basis steps
        patient.timeseries.basis_steps.time = [patientFirstPart.timeseries.basis_steps.time patientSecondPart.timeseries.basis_steps.time];
        patient.timeseries.basis_steps.value = [patientFirstPart.timeseries.basis_steps.value patientSecondPart.timeseries.basis_steps.value];

    else

        patient = patientFirstPart;

    end    

    patient.meta.ID = patientFirstPart.meta.ID;
    patient.meta.INSULIN_TYPE = patientFirstPart.meta.INSULIN_TYPE;
    %patient.meta.WEIGHT = patientTraining.meta.WEIGHT;
    patient.meta.SEX = patientFirstPart.meta.SEX;
    
    save(fullfile(['Ohio' subj],['Ohio' subj '_' set]),'patient');

end
    

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

for s = 1:length(subjsV2)
    
    subj = subjsV2{s};
    
    load(fullfile(['Ohio' subj],[set '-' subj '-ws-' lower(set)]));
    patientFirstPart = patient;
    
    if(toMerge)
        %Load testing
        load(fullfile(['Ohio' subj],[set '-' subj '-ws-' lower("Testing")]));
        patientSecondPart = patient;
    
        %CGM
        patient.timeseries.CGM.time = [patientFirstPart.timeseries.CGM.time patientSecondPart.timeseries.CGM.time];
        patient.timeseries.CGM.value = [patientFirstPart.timeseries.CGM.value patientSecondPart.timeseries.CGM.value];
    
        %SMBG
        patient.timeseries.SMBG.time	 = [patientFirstPart.timeseries.SMBG.time patientSecondPart.timeseries.SMBG.time];
        patient.timeseries.SMBG.value = [patientFirstPart.timeseries.SMBG.value patientSecondPart.timeseries.SMBG.value];
        
        %Basal insulin
        patient.timeseries.basal_insulin.time	 = [patientFirstPart.timeseries.basal_insulin.time patientSecondPart.timeseries.basal_insulin.time];
        patient.timeseries.basal_insulin.value = [patientFirstPart.timeseries.basal_insulin.value patientSecondPart.timeseries.basal_insulin.value];

        %Insulin bolus
        %patient.timeseries.insulin_bolus.bwz_carb_input = [patientTraining.timeseries.insulin_bolus.bwz_carb_input patient.timeseries.insulin_bolus.bwz_carb_input];
        patient.timeseries.insulin_bolus.time_begin = [patientFirstPart.timeseries.insulin_bolus.time_begin patientSecondPart.timeseries.insulin_bolus.time_begin];
        patient.timeseries.insulin_bolus.time_end = [patientFirstPart.timeseries.insulin_bolus.time_end patientSecondPart.timeseries.insulin_bolus.time_end];
        patient.timeseries.insulin_bolus.type = [patientFirstPart.timeseries.insulin_bolus.type patientSecondPart.timeseries.insulin_bolus.type];
        patient.timeseries.insulin_bolus.value = [patientFirstPart.timeseries.insulin_bolus.value patientSecondPart.timeseries.insulin_bolus.value];

        %CHO intake
        patient.timeseries.cho_intake.time	 = [patientFirstPart.timeseries.cho_intake.time patientSecondPart.timeseries.cho_intake.time];
        patient.timeseries.cho_intake.value = [patientFirstPart.timeseries.cho_intake.value patientSecondPart.timeseries.cho_intake.value];
        patient.timeseries.cho_intake.type = [patientFirstPart.timeseries.cho_intake.type patientSecondPart.timeseries.cho_intake.type];

        %Sleep
        patient.timeseries.sleep.quality = [patientFirstPart.timeseries.sleep.quality patientSecondPart.timeseries.sleep.quality];
        patient.timeseries.sleep.time_begin = [patientFirstPart.timeseries.sleep.time_begin patientSecondPart.timeseries.sleep.time_begin];
        patient.timeseries.sleep.time_end = [patientFirstPart.timeseries.sleep.time_end patientSecondPart.timeseries.sleep.time_end];

        %Basis sleep
        patient.timeseries.basis_sleep.quality = [patientFirstPart.timeseries.basis_sleep.quality patientSecondPart.timeseries.basis_sleep.quality];
        patient.timeseries.basis_sleep.time_begin = [patientFirstPart.timeseries.basis_sleep.time_begin patientSecondPart.timeseries.basis_sleep.time_begin];
        patient.timeseries.basis_sleep.time_end = [patientFirstPart.timeseries.basis_sleep.time_end patientSecondPart.timeseries.basis_sleep.time_end];

        %Temp Basal
        patient.timeseries.temp_basal.value = [patientFirstPart.timeseries.temp_basal.value patientSecondPart.timeseries.temp_basal.value];
        patient.timeseries.temp_basal.time_begin = [patientFirstPart.timeseries.temp_basal.time_begin patientSecondPart.timeseries.temp_basal.time_begin];
        patient.timeseries.temp_basal.time_end = [patientFirstPart.timeseries.temp_basal.time_end patientSecondPart.timeseries.temp_basal.time_end];

        %Work
        patient.timeseries.work.intensity = [patientFirstPart.timeseries.work.intensity patientSecondPart.timeseries.work.intensity];
        patient.timeseries.work.time_begin = [patientFirstPart.timeseries.work.time_begin patientSecondPart.timeseries.work.time_begin];
        patient.timeseries.work.time_end = [patientFirstPart.timeseries.work.time_end patientSecondPart.timeseries.work.time_end];

        %Stressors
        patient.timeseries.stressors.description = [patientFirstPart.timeseries.stressors.description patientSecondPart.timeseries.stressors.description];
        patient.timeseries.stressors.time = [patientFirstPart.timeseries.stressors.time patientSecondPart.timeseries.stressors.time];
        patient.timeseries.stressors.type = [patientFirstPart.timeseries.stressors.type patientSecondPart.timeseries.stressors.type];

        %Hypo event
        patient.timeseries.hypo_event.time = [patientFirstPart.timeseries.hypo_event.time patientSecondPart.timeseries.hypo_event.time];

        %Illness
        patient.timeseries.illness.time = [patientFirstPart.timeseries.illness.time patientSecondPart.timeseries.illness.time];

        %Exercise
        patient.timeseries.exercise.time = [patientFirstPart.timeseries.exercise.time patientSecondPart.timeseries.exercise.time];
        patient.timeseries.exercise.intensity = [patientFirstPart.timeseries.exercise.intensity patientSecondPart.timeseries.exercise.intensity];
        patient.timeseries.exercise.duration = [patientFirstPart.timeseries.exercise.duration patientSecondPart.timeseries.exercise.duration];

        %%Basis heart rate
        %patient.timeseries.basis_heart_rate.time = [patientTraining.timeseries.basis_heart_rate.time patient.timeseries.basis_heart_rate.time];
        %patient.timeseries.basis_heart_rate.value = [patientTraining.timeseries.basis_heart_rate.value patient.timeseries.basis_heart_rate.value];

        %Basis gsr
        patient.timeseries.basis_gsr.time = [patientFirstPart.timeseries.basis_gsr.time patientSecondPart.timeseries.basis_gsr.time];
        patient.timeseries.basis_gsr.value = [patientFirstPart.timeseries.basis_gsr.value patientSecondPart.timeseries.basis_gsr.value];

        %Basis skin temperature
        patient.timeseries.basis_skin_temperature.time = [patientFirstPart.timeseries.basis_skin_temperature.time patientSecondPart.timeseries.basis_skin_temperature.time];
        patient.timeseries.basis_skin_temperature.value = [patientFirstPart.timeseries.basis_skin_temperature.value patientSecondPart.timeseries.basis_skin_temperature.value];

        %%Basis air temperature
        %patient.timeseries.basis_air_temperature.time = [patientTraining.timeseries.basis_air_temperature.time patient.timeseries.basis_air_temperature.time];
        %patient.timeseries.basis_air_temperature.value = [patientTraining.timeseries.basis_air_temperature.value patient.timeseries.basis_air_temperature.value];

        %%Basis steps
        %patient.timeseries.basis_steps.time = [patientTraining.timeseries.basis_steps.time patient.timeseries.basis_steps.time];
        %patient.timeseries.basis_steps.value = [patientTraining.timeseries.basis_steps.value patient.timeseries.basis_steps.value];
        
        %Acceleration
        patient.timeseries.acceleration.time = [patientFirstPart.timeseries.acceleration.time patientSecondPart.timeseries.acceleration.time];
        patient.timeseries.acceleration.value = [patientFirstPart.timeseries.acceleration.value patientSecondPart.timeseries.acceleration.value];

    else

        patient = patientFirstPart;
        
    end    

    patient.meta.ID = patientFirstPart.meta.ID;
    patient.meta.INSULIN_TYPE = patientFirstPart.meta.INSULIN_TYPE;
    %patient.meta.WEIGHT = patientTraining.meta.WEIGHT;
    patient.meta.SEX = patientFirstPart.meta.SEX;

    save(fullfile(['Ohio' subj],['Ohio' subj '_' set]),'patient');

end