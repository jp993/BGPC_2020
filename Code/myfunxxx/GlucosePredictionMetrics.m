function eval_metrics = GlucosePredictionMetrics(cgm_double, yhat_double, PH)

Ts = 5;
quad_err = (cgm_double - yhat_double).^2;

% rmse
rmse = sqrt(nanmean(quad_err));

% cod
SSE = nansum(quad_err);
var_cgm = (cgm_double - nanmean(cgm_double)).^2;
SST = nansum(var_cgm);

cod = 100*(1-(SSE/SST));

% fit
fit = 100*(1-sqrt(SSE/SST));

% delay

N=length(cgm_double);
ph = PH;
% count=0;
for j = 0:ph
    
    for i = 1:N-ph-j
        indx = i+ph+j;
        dif(i) = (yhat_double(indx)-cgm_double(i+ph))^2;
    end
    count = nansum(dif);
    delay_tmp(j+1) = (1/(N-ph+1))*count;
    count = 0;
    
end

[~,d] = min(delay_tmp);
delay = d-1; % caused by we are using j+1 as index

% MAE
abs_err = abs(cgm_double - yhat_double);
mae = nansum(abs_err)/length(abs_err);

eval_metrics = [rmse, cod, Ts*delay, fit, mae];