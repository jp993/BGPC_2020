function X = test_corrective_features(patient,param,stats)

ord = param.wind;
ph = param.ph;
flag = stats.is_flag;

%-- pool of feature --%
cgm = patient.CGM;
Xcgm = prepNN(cgm,ord,ph);
d_cgm = Xcgm(:,2:end) - Xcgm(:,1:end-1);

cob = patient.COB;
Xcob = prepNN(cob,ord,ph);
d_cob = Xcob(:,2:end) - Xcob(:,1:end-1);

work = patient.work;
Xwork = prepNN(work,ord,ph);
d_work = Xwork(:,end) - Xwork(:,end-1);


skin_tmp = patient.basis_skin_temperature;
Xsk = prepNN(skin_tmp, ord, ph);
d_skin = Xsk(:,2:end)-Xsk(:,1:end-1);

sleep_level = patient.sleep;
Xsleep = prepNN(sleep_level,ord,ph);
d_sleep = Xsleep(:,end) - Xsleep(:,end-1);

b_ins = patient.pie;
Xins = prepNN(b_ins,ord,ph);
d_ins = Xins(:,2:end)-Xins(:,1:end-1);

% check if heart rate exist
is_hr = strcmp('basis_heart_rate',patient.Properties.VariableNames);
if is_hr(is_hr==1) == 1
    hr = patient.basis_heart_rate;
    Xhr = prepNN(hr,ord,ph);
    d_hr = Xhr(:,2:end)-Xhr(:,1:end-1);
    
    X = [d_cgm, d_cob, d_skin, d_ins, d_hr, d_work, d_sleep];
    
else
    % take acceleration
    ac = patient.acceleration;
    Xac = prepNN(ac,ord,ph);
    d_ac = Xac(:,2:end)-Xac(:,1:end-1);
    
%     nan_ac = length(find(isnan(ac)==1));
    if flag
        X = [d_cgm, d_cob, d_skin, d_ins, d_ac, d_work, d_sleep];
    else
        X = [d_cgm, d_cob, d_skin, d_ins, d_work, d_sleep];
    end
end