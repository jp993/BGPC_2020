function [positive_delta_from_th, AUC_above_th, time_above_th, isAbove_th] = CGMth_based(CGM, CGMth)
% Calculates CGM threshold-based features
%
% CGM: Continuous Glucose Measurement (mg/dL)
% CGMth: threshold value (mg/dL)
% 
% positive_delta_from_th: positive difference wrt threshold value
% AUC_above_th: cumulative sum (AUC) of time spent aboven threshold value
% isAbove_th: portions above treshold value

% portions above
isAbove_th = (CGM > CGMth)*1;

% positive difference
positive_delta_from_th = CGM;
positive_delta_from_th(positive_delta_from_th < CGMth)  = 0;
positive_delta_from_th = positive_delta_from_th - CGMth;

% AUC
AUC_above_th = zeros(length(CGM),1);
time_above_th = zeros(length(CGM),1);
for k = 2:length(CGM)
    if CGM(k) > CGMth
        time_above_th(k) = time_above_th(k-1) + 1;
        y = CGM(k) - CGMth;
        AUC_above_th(k) = AUC_above_th(k-1) + y;
    else
        time_above_th(k) = 0;
        AUC_above_th(k) = 0;
    end
end

end