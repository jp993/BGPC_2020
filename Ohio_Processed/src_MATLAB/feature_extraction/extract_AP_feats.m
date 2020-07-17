function feats = extract_AP_feats(CGM,basal,bolus,meal,CR,CF,OL_basal,Ts,hasEnoughMeals)
%
% Extract a feature set from available signals in artificial pancreas
% Returns feature-set in form of multivariate time-series. (matlab table)
%
%
% INPUT
% CGM: Continuous Glucose Monitoring [mg/dL]
% basal: basal insulin infusion ratio [U/h]
% bolus: bolus insulin infusion ratio [U/h]
% meal: consumed meals ratio [g/min]
% CR: insulin to carbohydrates ratio
% OL_basal: Open-Loop basal infusion ratio [U/h]
% Ts: sampling time (minutes)
%
% OUTPUT
% feats: table
%
% OPTIONAL ARGUMENT:
% 'normalize': {'minmax','zscore'}
%

%% correct meals if missing
if ~hasEnoughMeals
    meal = bolus/60*Ts.*CR;
end

%% CGM based features
% metrics from threshold value
[delta180, AAC180, t_h180, ~] = CGMth_based(CGM, 180);
[delta250, AAC250, t_h250, ~] = CGMth_based(CGM, 250);
% use this for RCA
[~, ~, ~, isHyper] = CGMth_based(CGM, 120);
% linear trend
TW = 2; % hours
lin_slope = moving_slope(CGM, TW, Ts);
% derivative
burn_in_hours = 3;
N = floor(burn_in_hours*60/Ts);
der = causal_derivative(CGM,Ts,'burnin',N);
% moving window stats
TW = 6; % hours
n = round(TW * 60 / Ts);
[moving_mean,moving_var,moving_kurtosis,moving_skew] = moving_stats(CGM,n);

%% Insulin estimation

% estimation using 1st and 2nd order filters
K = 0.02;
% x0 = [basal(1); basal(1)]*60;
% x0 = [1; 1]*mean(basal)/60;
x0 = [0; 0];
[pie, scie] = twoCompSysD((basal+bolus)/60, K, Ts, x0);

% IOB as in literature
IOB = IOB_calculation((basal+bolus)/60, Ts);
IOB_basal = IOB_calculation(OL_basal/60, Ts);

% burn-in values for IOB
burn_in_hours = 3;
burn_in_samples = floor(burn_in_hours*60/Ts);
IOB_basal(1:burn_in_samples) = mean(IOB_basal); % burn-in value of basal is the mean value
IOB(1:burn_in_samples) = IOB_basal(1:burn_in_samples); % burn-in value is basal value

%% Carbs estimation
% estimation using 1st and 2nd order filters
K = 0.02;
[pcho,cob] = twoCompSysD(meal,K,Ts);
% COB as in literature
COB_mode = 'fast';
COB = COB_calculation(meal, COB_mode, Ts);

%% features designed for pump faults (Meneghetti et al.) -----------
% rescale using CR
newIOB = (IOB - IOB_basal) .* CR;
[icob, dcob] = pump_fault_symptoms(newIOB, COB, der);

%% control actions

% find correction boluses
TMAX = 90; % min
isCorrection = find_correction_bolus(meal, bolus, TMAX, Ts);
% ic = basal;
ic = basal - OL_basal;

correction_bolus = bolus;
correction_bolus(~isCorrection) = 0;
ic_w_bolus = ic + correction_bolus;

[ic_PE,~] = twoCompSysD(ic_w_bolus/60, 0.02, Ts, [0 0]);
ic_OB = IOB_calculation(ic_w_bolus/60, Ts);

%% Howsmon et al.
LW = 24; % h
SW = 1; % h
K = 0.02;
[GFM, IFM, CGMslope] = howsmon_features(CGM, (basal+bolus)/60, K, LW, SW, Ts);

%% cross-correlation between CGM and PIE
TW = 6; % hours
n = round(TW * 60 / Ts);
[cgmXpie_corr, cgmXpie_lag] = movingxcorr(CGM,pie,n,'scaleopt','coeff');
[cgmXpcho_corr, cgmXpcho_lag] = movingxcorr(CGM,pcho,n,'scaleopt','coeff');

%% normalize carbs and insulin using therapy values
COB = COB./CR;
pcho = pcho./CR;
IOB = IOB./CF;
pie = pie./CF;
ic = ic./CF;
ic_PE = ic_PE./CF;
ic_OB = ic_OB./CF;

%%
% -------------------------------------------------------------------------
% select features
% -------------------------------------------------------------------------
feats.cgm = CGM;
feats.der = der;
feats.slope = lin_slope;
feats.t_h180 = t_h180;
feats.t_h250 = t_h250;
% feats.AAC180 = AAC180;
% feats.AAC250 = AAC250;

% feats.cob = cob;
feats.pce = pcho;
feats.COB = COB;

% feats.scie = scie;
feats.pie = pie;
feats.IOB = IOB;
feats.ic = ic;
feats.ic_pe = ic_PE;
feats.ic_OB = ic_OB;
feats.ic_w_bolus = ic_w_bolus;

feats.icob = icob;
feats.dcob = dcob;

feats.gfm = GFM;
feats.ifm = IFM;

feats.gxi = cgmXpie_corr;
feats.gxc = cgmXpcho_corr;

feats.isHyper = isHyper;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% make dataset
feats = struct2table(feats);


end
