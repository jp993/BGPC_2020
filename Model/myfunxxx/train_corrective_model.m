function [Mdl_error, out_struct] = train_corrective_model(cgm, cgm_hat, patient, param)
%-- input --%
% cgm: Nx1
% cgm_hat: Nx1;
% patient: table
% param: it must contain 2 fields: param.ph, param.wind

db_plot = 0;
max_feat = 35;

er = (cgm - cgm_hat);
    
[X flag]= corrective_features(patient,param);
Y = er;
 
%-- feature ranking --%
disp('-- Feature Selection --');
if param.ph == 6
    [idx, weights] = relieff(X, Y, 10); 
else
    [idx, weights] = relieff(X, Y, 30); 
end

disp('...done');

if db_plot == 1
    assed = [1:1:size(X,2)];
    figure, bar(assed,weights(idx))
    xlabel('Predictor rank')
    ylabel('Predictor importance weight')
end

best_features_idx = idx(1:max_feat);
 
X = X(:,best_features_idx);
%-- extrapolation --%
if param.extrp
    X = extrapolation(X);
end
%-- normalization --%
mu = nanmean(X);
sig = nanstd(X);
X = (X - mu)./sig;
mu_y = nanmean(Y);
sig_y = nanstd(Y);
Y = (Y - mu_y)/sig_y;

%     t = templateTree('Reproducible',true); 'Learners',t,
disp('-- Model Training --');
%-- bayesian optimization --%    
Mdl = fitrensemble(X,Y,'OptimizeHyperparameters','auto',...
'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
'expected-improvement-plus','HoldOut',0.4,...
'ShowPlots',0,'Verbose',0,'UseParallel',false));

disp('...done');

% train over the entire training set
fin_method = Mdl.Method;

if strcmp(fin_method,'LSBoost') == 1
    fin_trees = Mdl.HyperparameterOptimizationResults.bestPoint.NumLearningCycles;
    fin_LR = Mdl.HyperparameterOptimizationResults.bestPoint.LearnRate;
    fin_leaves = Mdl.HyperparameterOptimizationResults.bestPoint.MinLeafSize;
    t = templateTree('MinLeafSize',fin_leaves);
    Mdl_fin = fitrensemble(X,Y,'Learners',t,'Method',fin_method,'NumLearningCycles',fin_trees,...
    'LearnRate',fin_LR);
else
    fin_trees = Mdl.HyperparameterOptimizationResults.bestPoint.NumLearningCycles;
    fin_leaves = Mdl.HyperparameterOptimizationResults.bestPoint.MinLeafSize;
    t = templateTree('MinLeafSize',fin_leaves);
    Mdl_fin = fitrensemble(X,Y,'Learners',t,'Method',fin_method,'NumLearningCycles',fin_trees);
end

%-- function output --%
Mdl_error = Mdl_fin;
out_struct.idx_feature_set = best_features_idx;
out_struct.MU_x = mu;
out_struct.SIG_x = sig;
out_struct.MU_y = mu_y;
out_struct.SIG_y = sig_y;
out_struct.Xtrain = X.*sig + mu;
out_struct.is_flag = flag;
end