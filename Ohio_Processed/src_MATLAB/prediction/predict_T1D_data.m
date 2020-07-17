function [pred, pres] = predict_T1D_data(CGM, insulin, meal, CR, nominal_insulin, my_model, preprocesser, PH, Ts)

% apply same preprocessing
[Y, I, M] = preprocesser.transform(CGM, insulin, meal, CR, nominal_insulin);

% make iddata
proc_data = iddata(Y, [I, M], Ts);
proc_data.TimeUnit = my_model.TimeUnit;
if isnan(proc_data)
    warning off
    proc_data = misdata(proc_data);
    warning on
end

% get predictions
pred = zeros(length(CGM),length(PH));
for n = 1:length(PH)
    % predict
    pred_data = predict(my_model, proc_data, PH(n), predictOptions('InitialCondition','z'));
    p = pred_data.OutputData;
    % remove nan portions
    p(isnan(Y)) = nan;
    % store in matrix
    pred(:,n) = p;
end

% prediction residuals
y = proc_data.OutputData;
y(isnan(Y)) = nan;
pres = y - pred;

%burn-in stuff
burn_in_samples = round(8*60/5);
pres(1:burn_in_samples,:) = 0;

end



function debug_debug(Y, proc_data)

t = 1:length(Y);
y =  proc_data.OutputData;
figure
plot(t, y, 'r')
hold on
plot(t, Y)

end