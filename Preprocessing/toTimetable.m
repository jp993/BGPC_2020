%% Run it after merge sets

clear all
close all
clc

dbclear if error
subjs = {'559','563','570','575','588','591'};
subjsV2 = {'540','544','552','567','584','596'};
set = 'Testing';
for s = 1:length(subjs)
    
    
    subj = subjs{s};
    load(fullfile(['Ohio' subj],['Ohio' subj '_' set]));
    disp(['Processing patient Ohio' subj]);
    
    % +++++++++++++++++++++++++++ METADATA ++++++++++++++++++++++++++++++++
    metadata = patient.meta;
    
    % +++++++++++++++++++++++++++ CGM +++++++++++++++++++++++++++++++++++++
    CGM = timetable(patient.timeseries.CGM.value','VariableNames',{'CGM'},'RowTimes',patient.timeseries.CGM.time');
    %Solve possible duplicates
    CGM.Time = dateshift(CGM.Time, 'start', 'minute', 'nearest');
    CGM.Time.Minute = round(CGM.Time.Minute/5)*5;
    CGM = retime(CGM, unique(CGM.Time),'mean');
    CGM = retime(CGM,'regular','TimeStep',minutes(5));
    
    % +++++++++++++++++++++++++++ SMBG ++++++++++++++++++++++++++++++++++++
    SMBG = timetable(patient.timeseries.SMBG.value','VariableNames',{'SMBG'},'RowTimes',patient.timeseries.SMBG.time');
    %Solve possible duplicates
    SMBG.Time = dateshift(SMBG.Time, 'start', 'minute', 'nearest');
    SMBG = retime(SMBG, unique(CGM.Time),'mean');
    
    %syncronize SMBG
    data = synchronize(CGM,SMBG);
    
    % +++++++++++++++++++++++++++ basal_insulin +++++++++++++++++++++++++++
    basal_insulin = timetable(patient.timeseries.basal_insulin.value','VariableNames',{'basal_insulin'},'RowTimes',patient.timeseries.basal_insulin.time');
    basal_insulin0 = basal_insulin.basal_insulin(1);
    %Solve possible duplicates
    basal_insulin.Time = dateshift(basal_insulin.Time, 'start', 'minute', 'nearest');
    basal_insulin = retime(basal_insulin, unique(CGM.Time),'mean');
    
    %Handle first entry (if nan it has to be set to the first available
    %value
    if(isnan(basal_insulin.basal_insulin(1)))
        basal_insulin.basal_insulin(1) = basal_insulin0;
    end
    
    %Handle nans
    temp_basal_value = basal_insulin.basal_insulin(1);
    for i = 2:height(data)
        if(isnan(basal_insulin.basal_insulin(i)))
            basal_insulin.basal_insulin(i) = temp_basal_value;
        else
            temp_basal_value = basal_insulin.basal_insulin(i);
        end
    end
    
    %Convert to U/min
    basal_insulin.basal_insulin = basal_insulin.basal_insulin/60;
    
    
    %Correct for temp_basal
    time_begin = dateshift(patient.timeseries.temp_basal.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.temp_basal.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    for t = 1:length(time_begin)
        idx_b = find(basal_insulin.Time == time_begin(t));
        idx_e = find(basal_insulin.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            basal_insulin.basal_insulin(1:idx_e) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
        if(~isempty(idx_b) && isempty(idx_e))
            basal_insulin.basal_insulin(idx_b:end) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            basal_insulin.basal_insulin(idx_b:idx_e) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
    end
        
    %syncronize basal_insulin
    data = synchronize(data,basal_insulin);
    
    % +++++++++++++++++++++++++++ insulin_bolus +++++++++++++++++++++++++++
    normal_insulin_bolus_value = [];
    normal_insulin_bolus_time = [];
    normal_insulin_bolus_bwz = []; %Comment For v2
    square_insulin_bolus_value = [];
    square_insulin_bolus_time = [];
    square_insulin_bolus_bwz = []; %Comment For v2
    for i = 1:length(patient.timeseries.insulin_bolus.time_begin)
        if(patient.timeseries.insulin_bolus.type{i} == "normal" ||  patient.timeseries.insulin_bolus.type{i} == "normal dual")
            normal_insulin_bolus_value = [normal_insulin_bolus_value patient.timeseries.insulin_bolus.value(i)/5]; %/5 to convert it to U/min
            normal_insulin_bolus_time = [normal_insulin_bolus_time patient.timeseries.insulin_bolus.time_begin(i)];
            normal_insulin_bolus_bwz = [normal_insulin_bolus_bwz patient.timeseries.insulin_bolus.bwz_carb_input(i)/5]; %/5 to convert it to g/min
        else
            wave_duration = minutes(patient.timeseries.insulin_bolus.time_end(i)-patient.timeseries.insulin_bolus.time_begin(i));
            square_insulin_bolus_value = [square_insulin_bolus_value patient.timeseries.insulin_bolus.value(i)/(wave_duration) 0]; %/wave_duration to convert it to U/min and added an event for practical purposes
            square_insulin_bolus_time = [square_insulin_bolus_time patient.timeseries.insulin_bolus.time_begin(i) patient.timeseries.insulin_bolus.time_end(i)];
            square_insulin_bolus_bwz = [square_insulin_bolus_bwz patient.timeseries.insulin_bolus.bwz_carb_input(i)/5 0]; %/5 to convert it to g/min
        end
    end
    
    normal_insulin_bolus = timetable(normal_insulin_bolus_value', normal_insulin_bolus_bwz','VariableNames',{'normal_bolus_insulin','normal_bwz_input'},'RowTimes',normal_insulin_bolus_time');
    if(~isempty(square_insulin_bolus_time))
        square_insulin_bolus = timetable(square_insulin_bolus_value', square_insulin_bolus_bwz','VariableNames',{'bolus_insulin','bwz_input'},'RowTimes',square_insulin_bolus_time');
    end
    %normal_insulin_bolus = timetable(normal_insulin_bolus_value','VariableNames',{'normal_bolus_insulin'},'RowTimes',normal_insulin_bolus_time'); %Decomment For v2
    %square_insulin_bolus = timetable(square_insulin_bolus_value','VariableNames',{'bolus_insulin'},'RowTimes',square_insulin_bolus_time'); %Decomment For v2
     
    %Solve possible duplicates
    normal_insulin_bolus.Time = dateshift(normal_insulin_bolus.Time, 'start', 'minute', 'nearest');
    normal_insulin_bolus = retime(normal_insulin_bolus, unique(CGM.Time),'mean');
    if(~isempty(square_insulin_bolus_time))
        square_insulin_bolus.Time = dateshift(square_insulin_bolus.Time, 'start', 'minute', 'nearest');
        square_insulin_bolus = retime(square_insulin_bolus, unique(CGM.Time),'mean');
    end
    
    %Handle nans
    normal_insulin_bolus.normal_bolus_insulin(isnan(normal_insulin_bolus.normal_bolus_insulin)) = 0;
    normal_insulin_bolus.normal_bwz_input(isnan(normal_insulin_bolus.normal_bwz_input)) = 0;
    
    %syncronize normal_insulin_bolus
    data = synchronize(data,normal_insulin_bolus);
    
    %Handle nans
    if(~isempty(square_insulin_bolus_time))
        flag = 0;
        for i = 1:height(data)
            if(square_insulin_bolus.bolus_insulin(i)>0)
                temp_bolus_value = square_insulin_bolus.bolus_insulin(i);
                flag = 1;
                %basal_insulin.basal_insulin(i) = temp_bolus_value;
            else
                if(isnan(square_insulin_bolus.bolus_insulin(i)) && flag)
                    square_insulin_bolus.bolus_insulin(i) = temp_bolus_value;
                end
                if(square_insulin_bolus.bolus_insulin(i) == 0)
                    flag = 0;
                end
            end
        end
        
        square_insulin_bolus.bolus_insulin(isnan(square_insulin_bolus.bolus_insulin)) = 0;
        square_insulin_bolus.bwz_input(isnan(square_insulin_bolus.bwz_input)) = 0;
        
        %syncronize square_insulin_bolus
        data = synchronize(data,square_insulin_bolus);
    end
    
    %Sum the total bolus insulin and drop the other column
    if(~isempty(square_insulin_bolus_time))
        data.bolus_insulin = data.bolus_insulin + data.normal_bolus_insulin;
        data.bwz_input = data.normal_bwz_input + data.bwz_input;
    else
        data.bolus_insulin = data.normal_bolus_insulin;
        data.bwz_input = data.normal_bwz_input;
    end
    data.normal_bolus_insulin = [];
    data.normal_bwz_input = [];
    
    
    % +++++++++++++++++++++++++++ meal_intake +++++++++++++++++++++++++++++
    CHO = timetable(patient.timeseries.cho_intake.value','VariableNames',{'CHO'},'RowTimes',patient.timeseries.cho_intake.time');

    CHO.Time = dateshift(CHO.Time, 'start', 'minute', 'nearest');
    CHO.Time.Minute = round(CHO.Time.Minute/5)*5;
    
    
    %Handle types
    types = [];
    CHOtype = timetable(patient.timeseries.cho_intake.type','VariableNames',{'CHO_type'},'RowTimes',patient.timeseries.cho_intake.time');
    CHOtype.Time.Minute = round(CHOtype.Time.Minute/5)*5;
    
    CHO = synchronize(CHO,CHOtype);
    %CHO = retime(CHO,unique(CGM.Time));
    
    CHO.CHO = CHO.CHO/5; %/5 to convert it to g/min
    CHO.CHO(isnan(CHO.CHO))  =0;
     
    %syncronize CHO
    data = synchronize(data,CHO);
    %Adapt
    idx_b = find(~isnan(data.CGM),1,'first');
    idx_e = find(~isnan(data.CGM),1,'last');
    data = data(idx_b:idx_e,:);
    
    %Fill nans
    data.CHO(isnan(data.CHO)) = 0;
    
    % +++++++++++++++++++++++++++ sleep +++++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.sleep.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.sleep.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.sleep = zeros(height(data),1);
    data.sleep_quality = nan(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.sleep(1:idx_e) = 1;
            data.sleep_quality(1:idx_e) = patient.timeseries.sleep.quality(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.sleep(idx_b:end) = 1;
            data.sleep_quality(idx_b:end) = patient.timeseries.sleep.quality(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.sleep(idx_b:idx_e) = 1;
            data.sleep_quality(idx_b:idx_e) = patient.timeseries.sleep.quality(t);
        end
    end
    
    % +++++++++++++++++++++++++++ basis_sleep +++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.basis_sleep.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.basis_sleep.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.basis_sleep = zeros(height(data),1);
    data.basis_sleep_quality = nan(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.basis_sleep(1:idx_e) = 1;
            data.basis_sleep_quality(1:idx_e) = patient.timeseries.basis_sleep.quality(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.basis_sleep(idx_b:end) = 1;
            data.basis_sleep_quality(idx_b:end) = patient.timeseries.basis_sleep.quality(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.basis_sleep(idx_b:idx_e) = 1;
            data.basis_sleep_quality(idx_b:idx_e) = patient.timeseries.basis_sleep.quality(t);
        end
    end
    
    % +++++++++++++++++++++++++++ work ++++++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.work.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.work.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.work = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.work(1:idx_e) = patient.timeseries.work.intensity(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.work(idx_b:end) = patient.timeseries.work.intensity(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.work(idx_b:idx_e) = patient.timeseries.work.intensity(t);
        end
    end
    
    % +++++++++++++++++++++++++++ stressors +++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.stressors.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.stressors = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.stressors(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ hypo_event ++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.hypo_event.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.hypo_event = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.hypo_event(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ illness +++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.illness.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.illness = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.illness(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ exercise ++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.exercise.time,'start','minute','nearest');
    time_end = time_begin + minutes(patient.timeseries.exercise.duration);
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.exercise = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.exercise(1:idx_e) = patient.timeseries.exercise.intensity(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.exercise(idx_b:end) = patient.timeseries.exercise.intensity(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.exercise(idx_b:idx_e) = patient.timeseries.exercise.intensity(t);
        end
    end
    
    % +++++++++++++++++++++++++++ basis_heart_rate ++++++++++++++++++++++++
    basis_heart_rate = timetable(patient.timeseries.basis_heart_rate.value','VariableNames',{'basis_heart_rate'},'RowTimes',patient.timeseries.basis_heart_rate.time');
    %Solve possible duplicates
    basis_heart_rate.Time = dateshift(basis_heart_rate.Time, 'start', 'minute', 'nearest');
    basis_heart_rate = retime(basis_heart_rate, unique(CGM.Time),'mean');
    
    %syncronize basis_heart_rate
    data = synchronize(data,basis_heart_rate);
    
    % +++++++++++++++++++++++++++ basis_gsr +++++++++++++++++++++++++++++++
    basis_gsr = timetable(patient.timeseries.basis_gsr.value','VariableNames',{'basis_gsr'},'RowTimes',patient.timeseries.basis_gsr.time');
    %Solve possible duplicates
    basis_gsr.Time = dateshift(basis_gsr.Time, 'start', 'minute', 'nearest');
    basis_gsr = retime(basis_gsr, unique(CGM.Time),'mean');
    
    %syncronize basis_gsr
    data = synchronize(data,basis_gsr);
    
    % +++++++++++++++++++++++++++ basis_skin_temperature ++++++++++++++++++
    basis_skin_temperature = timetable(patient.timeseries.basis_skin_temperature.value','VariableNames',{'basis_skin_temperature'},'RowTimes',patient.timeseries.basis_skin_temperature.time');
    %Solve possible duplicates
    basis_skin_temperature.Time = dateshift(basis_skin_temperature.Time, 'start', 'minute', 'nearest');
    basis_skin_temperature = retime(basis_skin_temperature, unique(CGM.Time),'mean');
    
    %Remove temperatures = 0 F
    basis_skin_temperature.basis_skin_temperature(basis_skin_temperature.basis_skin_temperature == 0) = nan;
    
    %Convert it to Celsius
    basis_skin_temperature.basis_skin_temperature = (basis_skin_temperature.basis_skin_temperature - 32)/1.8;
    
    %syncronize basis_skin_temperature
    data = synchronize(data,basis_skin_temperature);
    
    % +++++++++++++++++++++++++++ basis_air_temperature +++++++++++++++++++
    basis_air_temperature = timetable(patient.timeseries.basis_air_temperature.value','VariableNames',{'basis_air_temperature'},'RowTimes',patient.timeseries.basis_air_temperature.time');
    %Solve possible duplicates
    basis_air_temperature.Time = dateshift(basis_air_temperature.Time, 'start', 'minute', 'nearest');
    basis_air_temperature = retime(basis_air_temperature, unique(CGM.Time),'mean');
    
    %Remove temperatures = 0 F
    basis_air_temperature.basis_air_temperature(basis_air_temperature.basis_air_temperature == 0) = nan;
    
    %Convert it to Celsius
    basis_air_temperature.basis_air_temperature = (basis_air_temperature.basis_air_temperature - 32)/1.8;
    
    %syncronize basis_air_temperature
    data = synchronize(data,basis_air_temperature);
    
    % +++++++++++++++++++++++++++ basis_steps +++++++++++++++++++++++++++++
    basis_steps = timetable(patient.timeseries.basis_steps.value','VariableNames',{'basis_steps'},'RowTimes',patient.timeseries.basis_steps.time');
    %Solve possible duplicates
    basis_steps.Time = dateshift(basis_steps.Time, 'start', 'minute', 'nearest');
    basis_steps = retime(basis_steps, unique(CGM.Time),'mean');
    
    %Correct units of measurements 
    basis_steps.basis_steps = basis_steps.basis_steps/5;
    
    %syncronize basis_steps
    data = synchronize(data,basis_steps);
    
    %Units of measurement
    data.Properties.VariableUnits = {'mg/dL','mg/dL','U/min','U/min','g/min','g/min/','-','-','-','-','-','-','-','-','-','-','beat/min','S','C','C','step/min'};
    % SAVE
    patient = data;
    save(fullfile(['Ohio' subj],['Ohio' subj '_' set '_timetable']),'patient','metadata');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for s = 1:length(subjsV2)
%for s = 1:1
    subj = subjsV2{s};
    load(fullfile(['Ohio' subj ],['Ohio' subj '_' set]));
    disp(['Processing patient Ohio' subj]);
    
    % +++++++++++++++++++++++++++ METADATA ++++++++++++++++++++++++++++++++
    metadata = patient.meta;
    
    % +++++++++++++++++++++++++++ CGM +++++++++++++++++++++++++++++++++++++
    CGM = timetable(patient.timeseries.CGM.value','VariableNames',{'CGM'},'RowTimes',patient.timeseries.CGM.time');
    %Solve possible duplicates
    CGM.Time = dateshift(CGM.Time, 'start', 'minute', 'nearest');
    CGM.Time.Minute = round(CGM.Time.Minute/5)*5;
    CGM = retime(CGM, unique(CGM.Time),'mean');
    CGM = retime(CGM,'regular','TimeStep',minutes(5));
    
    % +++++++++++++++++++++++++++ SMBG ++++++++++++++++++++++++++++++++++++
    SMBG = timetable(patient.timeseries.SMBG.value','VariableNames',{'SMBG'},'RowTimes',patient.timeseries.SMBG.time');
    %Solve possible duplicates
    SMBG.Time = dateshift(SMBG.Time, 'start', 'minute', 'nearest');
    SMBG = retime(SMBG, unique(CGM.Time),'mean');
    
    %syncronize SMBG
    data = synchronize(CGM,SMBG);
    
    % +++++++++++++++++++++++++++ basal_insulin +++++++++++++++++++++++++++
    basal_insulin = timetable(patient.timeseries.basal_insulin.value','VariableNames',{'basal_insulin'},'RowTimes',patient.timeseries.basal_insulin.time');
    basal_insulin0 = basal_insulin.basal_insulin(1);
    %Solve possible duplicates
    basal_insulin.Time = dateshift(basal_insulin.Time, 'start', 'minute', 'nearest');
    basal_insulin = retime(basal_insulin, unique(CGM.Time),'mean');
    
    %Handle first entry (if nan it has to be set to the first available
    %value
    if(isnan(basal_insulin.basal_insulin(1)))
        basal_insulin.basal_insulin(1) = basal_insulin0;
    end
    
    %Handle nans
    temp_basal_value = basal_insulin.basal_insulin(1);
    for i = 2:height(data)
        if(isnan(basal_insulin.basal_insulin(i)))
            basal_insulin.basal_insulin(i) = temp_basal_value;
        else
            temp_basal_value = basal_insulin.basal_insulin(i);
        end
    end
    
    %Convert to U/min
    basal_insulin.basal_insulin = basal_insulin.basal_insulin/60;
    
    
    %Correct for temp_basal
    time_begin = dateshift(patient.timeseries.temp_basal.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.temp_basal.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    for t = 1:length(time_begin)
        idx_b = find(basal_insulin.Time == time_begin(t));
        idx_e = find(basal_insulin.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            basal_insulin.basal_insulin(1:idx_e) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
        if(~isempty(idx_b) && isempty(idx_e))
            basal_insulin.basal_insulin(idx_b:end) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            basal_insulin.basal_insulin(idx_b:idx_e) = patient.timeseries.temp_basal.value(t)/60; %/60 to convert to U/min
        end
    end
        
    %syncronize basal_insulin
    data = synchronize(data,basal_insulin);
    
    % +++++++++++++++++++++++++++ insulin_bolus +++++++++++++++++++++++++++
    normal_insulin_bolus_value = [];
    normal_insulin_bolus_time = [];
    square_insulin_bolus_value = [];
    square_insulin_bolus_time = [];
    for i = 1:length(patient.timeseries.insulin_bolus.time_begin)
        if(patient.timeseries.insulin_bolus.type{i} == "normal" ||  patient.timeseries.insulin_bolus.type{i} == "normal dual")
            normal_insulin_bolus_value = [normal_insulin_bolus_value patient.timeseries.insulin_bolus.value(i)/5]; %/5 to convert it to U/min
            normal_insulin_bolus_time = [normal_insulin_bolus_time patient.timeseries.insulin_bolus.time_begin(i)];
        else
            wave_duration = minutes(patient.timeseries.insulin_bolus.time_end(i)-patient.timeseries.insulin_bolus.time_begin(i));
            square_insulin_bolus_value = [square_insulin_bolus_value patient.timeseries.insulin_bolus.value(i)/(wave_duration) 0]; %/wave_duration to convert it to U/min and added an event for practical purposes
            square_insulin_bolus_time = [square_insulin_bolus_time patient.timeseries.insulin_bolus.time_begin(i) patient.timeseries.insulin_bolus.time_end(i)];
        end
    end
    
    normal_insulin_bolus = timetable(normal_insulin_bolus_value','VariableNames',{'normal_bolus_insulin'},'RowTimes',normal_insulin_bolus_time');
    if(~isempty(square_insulin_bolus_time))
        square_insulin_bolus = timetable(square_insulin_bolus_value','VariableNames',{'bolus_insulin'},'RowTimes',square_insulin_bolus_time');
    end
     
    %Solve possible duplicates
    normal_insulin_bolus.Time = dateshift(normal_insulin_bolus.Time, 'start', 'minute', 'nearest');
    normal_insulin_bolus = retime(normal_insulin_bolus, unique(CGM.Time),'mean');
    if(~isempty(square_insulin_bolus_time))
        square_insulin_bolus.Time = dateshift(square_insulin_bolus.Time, 'start', 'minute', 'nearest');
        square_insulin_bolus = retime(square_insulin_bolus, unique(CGM.Time),'mean');
    end
    
    %Handle nans
    normal_insulin_bolus.normal_bolus_insulin(isnan(normal_insulin_bolus.normal_bolus_insulin)) = 0;
    
    %syncronize normal_insulin_bolus
    data = synchronize(data,normal_insulin_bolus);
    
    %Handle nans
    if(~isempty(square_insulin_bolus_time))
        flag = 0;
        for i = 1:height(data)
            if(square_insulin_bolus.bolus_insulin(i)>0)
                temp_bolus_value = square_insulin_bolus.bolus_insulin(i);
                flag = 1;
                %basal_insulin.basal_insulin(i) = temp_bolus_value;
            else
                if(isnan(square_insulin_bolus.bolus_insulin(i)) && flag)
                    square_insulin_bolus.bolus_insulin(i) = temp_bolus_value;
                end
                if(square_insulin_bolus.bolus_insulin(i) == 0)
                    flag = 0;
                end
            end
        end
        
        square_insulin_bolus.bolus_insulin(isnan(square_insulin_bolus.bolus_insulin)) = 0;
        
        %syncronize square_insulin_bolus
        data = synchronize(data,square_insulin_bolus);
    end
    
    %Sum the total bolus insulin and drop the other column
    if(~isempty(square_insulin_bolus_time))
        data.bolus_insulin = data.bolus_insulin + data.normal_bolus_insulin;
    else
        data.bolus_insulin = data.normal_bolus_insulin;
    end
    data.normal_bolus_insulin = [];
    
    
    % +++++++++++++++++++++++++++ meal_intake +++++++++++++++++++++++++++++
    CHO = timetable(patient.timeseries.cho_intake.value','VariableNames',{'CHO'},'RowTimes',patient.timeseries.cho_intake.time');

    CHO.Time = dateshift(CHO.Time, 'start', 'minute', 'nearest');
    CHO.Time.Minute = round(CHO.Time.Minute/5)*5;
    
    
    %Handle types
    types = [];
    CHOtype = timetable(patient.timeseries.cho_intake.type','VariableNames',{'CHO_type'},'RowTimes',patient.timeseries.cho_intake.time');
    CHOtype.Time.Minute = round(CHOtype.Time.Minute/5)*5;
    
    CHO = synchronize(CHO,CHOtype);
    %CHO = retime(CHO,unique(CGM.Time));
    
    CHO.CHO = CHO.CHO/5; %/5 to convert it to g/min
    CHO.CHO(isnan(CHO.CHO))  =0;
    %syncronize CHO
    data = synchronize(data,CHO);
    
    %Adapt
    idx_b = find(~isnan(data.CGM),1,'first');
    idx_e = find(~isnan(data.CGM),1,'last');
    data = data(idx_b:idx_e,:);
    
    %Fill nans
    data.CHO(isnan(data.CHO)) = 0;
    
    
    % +++++++++++++++++++++++++++ sleep +++++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.sleep.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.sleep.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.sleep = zeros(height(data),1);
    data.sleep_quality = nan(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.sleep(1:idx_e) = 1;
            data.sleep_quality(1:idx_e) = patient.timeseries.sleep.quality(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.sleep(idx_b:end) = 1;
            data.sleep_quality(idx_b:end) = patient.timeseries.sleep.quality(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.sleep(idx_b:idx_e) = 1;
            data.sleep_quality(idx_b:idx_e) = patient.timeseries.sleep.quality(t);
        end
    end
    
    % +++++++++++++++++++++++++++ basis_sleep +++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.basis_sleep.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.basis_sleep.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.basis_sleep = zeros(height(data),1);
    data.basis_sleep_quality = nan(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.basis_sleep(1:idx_e) = 1;
            data.basis_sleep_quality(1:idx_e) = patient.timeseries.basis_sleep.quality(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.basis_sleep(idx_b:end) = 1;
            data.basis_sleep_quality(idx_b:end) = patient.timeseries.basis_sleep.quality(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.basis_sleep(idx_b:idx_e) = 1;
            data.basis_sleep_quality(idx_b:idx_e) = patient.timeseries.basis_sleep.quality(t);
        end
    end
    
    % +++++++++++++++++++++++++++ work ++++++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.work.time_begin,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end = dateshift(patient.timeseries.work.time_end,'start','minute','nearest');
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.work = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.work(1:idx_e) = patient.timeseries.work.intensity(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.work(idx_b:end) = patient.timeseries.work.intensity(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.work(idx_b:idx_e) = patient.timeseries.work.intensity(t);
        end
    end
    
    % +++++++++++++++++++++++++++ stressors +++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.stressors.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.stressors = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.stressors(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ hypo_event ++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.hypo_event.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.hypo_event = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.hypo_event(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ illness +++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.illness.time,'start','minute','nearest');
    time_begin.Minute = round(time_begin.Minute/5)*5;
    
    data.illness = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx = find(data.Time == time_begin(t));
        if(~isempty(idx))
            data.illness(idx_b) = 1;
        end
    end
    
    % +++++++++++++++++++++++++++ exercise ++++++++++++++++++++++++++++++++
    time_begin = dateshift(patient.timeseries.exercise.time,'start','minute','nearest');
    time_end = time_begin + minutes(patient.timeseries.exercise.duration);
    time_begin.Minute = round(time_begin.Minute/5)*5;
    time_end.Minute = round(time_end.Minute/5)*5;
    
    data.exercise = zeros(height(data),1);
    for t = 1:length(time_begin)
        idx_b = find(data.Time == time_begin(t));
        idx_e = find(data.Time == time_end(t));
        if(isempty(idx_b) && ~isempty(idx_e))
            data.exercise(1:idx_e) = patient.timeseries.exercise.intensity(t);
        end
        if(~isempty(idx_b) && isempty(idx_e))
            data.exercise(idx_b:end) = patient.timeseries.exercise.intensity(t);
        end
        if(~isempty(idx_b) && ~isempty(idx_e))
            data.exercise(idx_b:idx_e) = patient.timeseries.exercise.intensity(t);
        end
    end
    
    % +++++++++++++++++++++++++++ basis_gsr +++++++++++++++++++++++++++++++
    basis_gsr = timetable(patient.timeseries.basis_gsr.value','VariableNames',{'basis_gsr'},'RowTimes',patient.timeseries.basis_gsr.time');
    %Solve possible duplicates
    basis_gsr.Time = dateshift(basis_gsr.Time, 'start', 'minute', 'nearest');
    basis_gsr = retime(basis_gsr, unique(CGM.Time),'mean');
    
    %syncronize basis_gsr
    data = synchronize(data,basis_gsr);
    
    % +++++++++++++++++++++++++++ basis_skin_temperature ++++++++++++++++++
    basis_skin_temperature = timetable(patient.timeseries.basis_skin_temperature.value','VariableNames',{'basis_skin_temperature'},'RowTimes',patient.timeseries.basis_skin_temperature.time');
    %Solve possible duplicates
    basis_skin_temperature.Time = dateshift(basis_skin_temperature.Time, 'start', 'minute', 'nearest');
    basis_skin_temperature = retime(basis_skin_temperature, unique(CGM.Time),'mean');
    
    %Remove temperatures = 0 F
    basis_skin_temperature.basis_skin_temperature(basis_skin_temperature.basis_skin_temperature == 0) = nan;
    
    %Convert it to Celsius
    basis_skin_temperature.basis_skin_temperature = (basis_skin_temperature.basis_skin_temperature - 32)/1.8;
    
    %syncronize basis_skin_temperature
    data = synchronize(data,basis_skin_temperature);
    
    % +++++++++++++++++++++++++++ acceleration ++++++++++++++++++++++++++++
    acceleration = timetable(patient.timeseries.acceleration.value','VariableNames',{'acceleration'},'RowTimes',patient.timeseries.acceleration.time');
    %Solve possible duplicates
    acceleration.Time = dateshift(acceleration.Time, 'start', 'minute', 'nearest');
    acceleration = retime(acceleration, unique(CGM.Time),'mean');
    
    %syncronize acceleration
    data = synchronize(data,acceleration);
    
    %Units of measurement
    data.Properties.VariableUnits = {'mg/dL','mg/dL','U/min','U/min','g/min','-','-','-','-','-','-','-','-','-','-','S','C','unknown'};
    
    % SAVE
    patient = data;
    save(fullfile(['Ohio' subj],['Ohio' subj '_' set '_timetable']),'patient','metadata');
    
end

