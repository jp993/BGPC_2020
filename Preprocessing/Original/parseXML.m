clear all
close all
clc
dbstop if error
subjs = {'559','563','570','575','588','591'};
sex = {'F','M','M','F','F','F'};
set = 'Testing'; %'Training', 'Testing'

for su = 1:length(subjs)
    subj = subjs{su};
    
    disp(['Reading subject ' subj '...']);
    struct = xml2struct(fullfile(set, [subj '-ws-' lower(set) '.xml']));
    disp('OK.')
    

    disp('- Parsing metadata...');
    patient.meta.ID = struct.patient.Attributes.id;
    patient.meta.INSULIN_TYPE = struct.patient.Attributes.insulin_type;
    %patient.meta.WEIGHT = struct.patient.Attributes.weight; %99 is just a
    %placeholder
    patient.meta.SEX = sex{su};
    disp('- OK. (01/19)');

    disp('- Parsing CGM data...');
    glucose = struct.patient.glucose_level.event;
    if(length(glucose)==1)
        patient.timeseries.CGM.time(1) = datetime(struct.patient.glucose_level.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.CGM.value(1) = str2double(struct.patient.glucose_level.event(1).Attributes.value);
    else
        for g = 1:length(glucose)
            patient.timeseries.CGM.time(g) = datetime(struct.patient.glucose_level.event{g}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.CGM.value(g) = str2double(struct.patient.glucose_level.event{g}.Attributes.value);
        end
    end
    disp('- OK. (02/19)');

    disp('- Parsing SMBG data...');
    finger_stick = struct.patient.finger_stick.event;
    if(length(finger_stick)==1)
        patient.timeseries.SMBG.time(1) = datetime(struct.patient.finger_stick.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.SMBG.value(1) = str2double(struct.patient.finger_stick.event(1).Attributes.value);
    else
        for f = 1:length(finger_stick)
            patient.timeseries.SMBG.time(f) = datetime(struct.patient.finger_stick.event{f}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.SMBG.value(f) = str2double(struct.patient.finger_stick.event{f}.Attributes.value);
        end
    end
    disp('- OK. (03/19)');

    disp('- Parsing Basal Insulin data...');
    basal = struct.patient.basal.event;
    if(length(basal)==1)
        patient.timeseries.basal_insulin.time(1) = datetime(struct.patient.basal.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basal_insulin.value(1) = str2double(struct.patient.basal.event(1).Attributes.value);
    else
        for b = 1:length(basal)
            patient.timeseries.basal_insulin.time(b) = datetime(struct.patient.basal.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basal_insulin.value(b) = str2double(struct.patient.basal.event{b}.Attributes.value);
        end
    end
    disp('- OK. (04/19)');

    disp('- Parsing Insulin Bolus data...');
    bolus = struct.patient.bolus.event;
    if(length(bolus)==1)
        patient.timeseries.insulin_bolus.time_begin(1) = datetime(struct.patient.bolus.event(1).Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.insulin_bolus.time_end(1) = datetime(struct.patient.bolus.event(1).Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.insulin_bolus.bwz_carb_input(1) = str2double(struct.patient.bolus.event(1).Attributes.bwz_carb_input);
        patient.timeseries.insulin_bolus.value(1) = str2double(struct.patient.bolus.event(1).Attributes.dose);
        patient.timeseries.insulin_bolus.type{1} = struct.patient.bolus.event(1).Attributes.type;
    else
        for b = 1:length(bolus)
            patient.timeseries.insulin_bolus.time_begin(b) = datetime(struct.patient.bolus.event{b}.Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.insulin_bolus.time_end(b) = datetime(struct.patient.bolus.event{b}.Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.insulin_bolus.bwz_carb_input(b) = str2double(struct.patient.bolus.event{b}.Attributes.bwz_carb_input);
            patient.timeseries.insulin_bolus.value(b) = str2double(struct.patient.bolus.event{b}.Attributes.dose);
            patient.timeseries.insulin_bolus.type{b} = struct.patient.bolus.event{b}.Attributes.type;
        end
    end
    disp('- OK. (05/19)');

    disp('- Parsing Meal data...');
    meal = struct.patient.meal.event;
    if(length(meal)==1)
        patient.timeseries.cho_intake.time(1) = datetime(struct.patient.meal.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.cho_intake.value(1) = str2double(struct.patient.meal.event(1).Attributes.carbs);
        patient.timeseries.cho_intake.type{1} = struct.patient.meal.event(1).Attributes.type;
    else
        for m = 1:length(meal)
            patient.timeseries.cho_intake.time(m) = datetime(struct.patient.meal.event{m}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.cho_intake.value(m) = str2double(struct.patient.meal.event{m}.Attributes.carbs);
            patient.timeseries.cho_intake.type{m} = struct.patient.meal.event{m}.Attributes.type;
        end
    end
    disp('- OK. (06/19)');

    disp('- Parsing Sleep data...');
    sleep = struct.patient.sleep.event;
    if(length(sleep)==1)
        patient.timeseries.sleep.time_begin(1) = datetime(struct.patient.sleep.event(1).Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.sleep.time_end(1) = datetime(struct.patient.sleep.event(1).Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.sleep.quality(1) = str2double(struct.patient.sleep.event(1).Attributes.quality);
    else
        for s = 1:length(sleep)
            patient.timeseries.sleep.time_begin(s) = datetime(struct.patient.sleep.event{s}.Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.sleep.time_end(s) = datetime(struct.patient.sleep.event{s}.Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.sleep.quality(s) = str2double(struct.patient.sleep.event{s}.Attributes.quality);
        end
    end
    disp('- OK. (07/19)');

    disp('- Parsing Basis Sleep data...');
    basis_sleep = struct.patient.basis_sleep.event;
    if(length(basis_sleep)==1)
        patient.timeseries.basis_sleep.time_begin(1) = datetime(struct.patient.basis_sleep.event(1).Attributes.tbegin,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_sleep.time_end(1) = datetime(struct.patient.basis_sleep.event(1).Attributes.tend,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_sleep.quality(1) = str2double(struct.patient.basis_sleep.event(1).Attributes.quality);
    else
        for b = 1:length(basis_sleep)
            patient.timeseries.basis_sleep.time_begin(b) = datetime(struct.patient.basis_sleep.event{b}.Attributes.tbegin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_sleep.time_end(b) = datetime(struct.patient.basis_sleep.event{b}.Attributes.tend,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_sleep.quality(b) = str2double(struct.patient.basis_sleep.event{b}.Attributes.quality);
        end
    end
    disp('- OK. (08/19)');

    disp('- Parsing Temporary Basal Insulin data...');
    if(isfield(struct.patient.temp_basal,'event'))
        temp_basal = struct.patient.temp_basal.event;
        if(length(temp_basal)==1)
            patient.timeseries.temp_basal.time_begin(1) = datetime(struct.patient.temp_basal.event(1).Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.temp_basal.time_end(1) = datetime(struct.patient.temp_basal.event(1).Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.temp_basal.value(1) = str2double(struct.patient.temp_basal.event(1).Attributes.value);
        else
            for t = 1:length(temp_basal)
                patient.timeseries.temp_basal.time_begin(t) = datetime(struct.patient.temp_basal.event{t}.Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.temp_basal.time_end(t) = datetime(struct.patient.temp_basal.event{t}.Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.temp_basal.value(t) = str2double(struct.patient.temp_basal.event{t}.Attributes.value);
            end
        end
    else
        patient.timeseries.temp_basal.time_begin(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.temp_basal.time_end(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.temp_basal.value(1) = nan;
    end
    disp('- OK. (09/19)');

    disp('- Parsing Work data...');
    if(isfield(struct.patient.work,'event'))
        work = struct.patient.work.event;
        if(length(work)==1)
            patient.timeseries.work.time_begin(1) = datetime(struct.patient.work.event(1).Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.work.time_end(1) = datetime(struct.patient.work.event(1).Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.work.intensity(1) = str2double(struct.patient.work.event(1).Attributes.intensity);
        else
            for w = 1:length(work)
                patient.timeseries.work.time_begin(w) = datetime(struct.patient.work.event{w}.Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.work.time_end(w) = datetime(struct.patient.work.event{w}.Attributes.ts_end,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.work.intensity(w) = str2double(struct.patient.work.event{w}.Attributes.intensity);
            end
        end
    else
        patient.timeseries.work.time_begin(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.work.time_end(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.work.intensity(1) = nan;
    end
    disp('- OK. (10/19)');

    disp('- Parsing Stressor data...');
    if(isfield(struct.patient.stressors,'event'))
        stressors = struct.patient.stressors.event;
        if(length(stressors)==1)
            patient.timeseries.stressors.time(1) = datetime(struct.patient.stressors.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.stressors.description{1} = struct.patient.stressors.event(1).Attributes.description;
            patient.timeseries.stressors.type{1} = struct.patient.stressors.event(1).Attributes.type;
        else
            for s = 1:length(stressors)
                patient.timeseries.stressors.time(s) = datetime(struct.patient.stressors.event{s}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.stressors.description{s} = struct.patient.stressors.event{s}.Attributes.description;
                patient.timeseries.stressors.type{s} = struct.patient.stressors.event{s}.Attributes.type;
            end
        end
    else
        patient.timeseries.stressors.time(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.stressors.description{1} = nan;
        patient.timeseries.stressors.type{1} = '';
    end
    disp('- OK. (11/19)');

    disp('- Parsing Hypo Event data...');
    if(isfield(struct.patient.hypo_event,'event'))
        hypo_event = struct.patient.hypo_event.event;
        if(length(hypo_event)==1)
            patient.timeseries.hypo_event.time(1) = datetime(struct.patient.hypo_event.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        else
            for h = 1:length(hypo_event)
                patient.timeseries.hypo_event.time(h) = datetime(struct.patient.hypo_event.event{h}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            end
        end
    else
        patient.timeseries.hypo_event.time(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
    end
    disp('- OK. (12/19)');

    disp('- Parsing Illness data...');
    if(isfield(struct.patient.illness,'event'))
        illness = struct.patient.illness.event;
        if(length(illness)==1)
            patient.timeseries.illness.time(1) = datetime(struct.patient.illness.event(1).Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
        else
            for i = 1:length(illness)
                patient.timeseries.illness.time(i) = datetime(struct.patient.illness.event{i}.Attributes.ts_begin,'InputFormat','dd-MM-uuuu HH:mm:ss');
            end
        end
    else
        patient.timeseries.illness.time(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
    end
    disp('- OK. (13/19)');

    disp('- Parsing Exercise data...');
    if(isfield(struct.patient.exercise,'event'))
        exercise = struct.patient.exercise.event;
        if(length(exercise)==1)
            patient.timeseries.exercise.time(1) = datetime(struct.patient.exercise.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.exercise.intensity(1) = str2double(struct.patient.exercise.event(1).Attributes.intensity);
            patient.timeseries.exercise.duration(1) = str2double(struct.patient.exercise.event(1).Attributes.duration);
        else
            for e = 1:length(exercise)
                patient.timeseries.exercise.time(e) = datetime(struct.patient.exercise.event{e}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
                patient.timeseries.exercise.intensity(e) = str2double(struct.patient.exercise.event{e}.Attributes.intensity);
                patient.timeseries.exercise.duration(e) = str2double(struct.patient.exercise.event{e}.Attributes.duration);
            end
        end
    else
        patient.timeseries.exercise.time(1) = datetime('','InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.exercise.intensity(1) = nan;
        patient.timeseries.exercise.duration(1) = nan;
    end
    disp('- OK. (14/19)');

    disp('- Parsing Basis Heart Rate data...');
    basis_heart_rate = struct.patient.basis_heart_rate.event;
    if(length(basis_heart_rate)==1)
        patient.timeseries.basis_heart_rate.time(1) = datetime(struct.patient.basis_heart_rate.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_heart_rate.value(1) = str2double(struct.patient.basis_heart_rate.event(1).Attributes.value);
    else
        for b = 1:length(basis_heart_rate)
            patient.timeseries.basis_heart_rate.time(b) = datetime(struct.patient.basis_heart_rate.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_heart_rate.value(b) = str2double(struct.patient.basis_heart_rate.event{b}.Attributes.value);
        end
    end
    disp('- OK. (15/19)');

    disp('- Parsing Basis GSR data...');
    basis_gsr = struct.patient.basis_gsr.event;
    if(length(basis_gsr)==1)
        patient.timeseries.basis_gsr.time(1) = datetime(struct.patient.basis_gsr.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_gsr.value(1) = str2double(struct.patient.basis_gsr.event(1).Attributes.value);
    else
        for b = 1:length(basis_gsr)
            patient.timeseries.basis_gsr.time(b) = datetime(struct.patient.basis_gsr.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_gsr.value(b) = str2double(struct.patient.basis_gsr.event{b}.Attributes.value);
        end
    end
    disp('- OK. (16/19)');

    disp('- Parsing Basis Skin Temperature data...');
    basis_skin_temperature = struct.patient.basis_skin_temperature.event;
    if(length(basis_skin_temperature)==1)
        patient.timeseries.basis_skin_temperature.time(1) = datetime(struct.patient.basis_skin_temperature.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_skin_temperature.value(1) = str2double(struct.patient.basis_skin_temperature.event(1).Attributes.value);
    else
        for b = 1:length(basis_skin_temperature)
            patient.timeseries.basis_skin_temperature.time(b) = datetime(struct.patient.basis_skin_temperature.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_skin_temperature.value(b) = str2double(struct.patient.basis_skin_temperature.event{b}.Attributes.value);
        end
    end
    disp('- OK. (17/19)');

    disp('- Parsing Basis Air Temperature data...');
    basis_air_temperature = struct.patient.basis_air_temperature.event;
    if(length(basis_air_temperature)==1)
        patient.timeseries.basis_air_temperature.time(1) = datetime(struct.patient.basis_air_temperature.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_air_temperature.value(1) = str2double(struct.patient.basis_air_temperature.event(1).Attributes.value);
    else
        for b = 1:length(basis_air_temperature)
            patient.timeseries.basis_air_temperature.time(b) = datetime(struct.patient.basis_air_temperature.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_air_temperature.value(b) = str2double(struct.patient.basis_air_temperature.event{b}.Attributes.value);
        end
    end
    disp('- OK. (18/19)');

    disp('- Parsing Basis Steps data...');
    basis_steps = struct.patient.basis_steps.event;
    if(length(basis_steps)==1)
        patient.timeseries.basis_steps.time(1) = datetime(struct.patient.basis_steps.event(1).Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
        patient.timeseries.basis_steps.value(1) = str2double(struct.patient.basis_steps.event(1).Attributes.value);
    else
        for b = 1:length(basis_steps)
            patient.timeseries.basis_steps.time(b) = datetime(struct.patient.basis_steps.event{b}.Attributes.ts,'InputFormat','dd-MM-uuuu HH:mm:ss');
            patient.timeseries.basis_steps.value(b) = str2double(struct.patient.basis_steps.event{b}.Attributes.value);
        end
    end
    disp('- OK. (19/19)');
    
    save([set '-' subj '-ws-' lower(set)],'patient')
    clear patient
end

