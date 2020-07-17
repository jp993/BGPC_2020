function [pred_res, pred] = get_pres(my_model,my_data,t,PH,burn_in)
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