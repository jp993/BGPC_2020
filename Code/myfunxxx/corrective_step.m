function [cgm_hat_correct] = corrective_step(Mdl, cgm_hat, patient_test, patient_train, param, stats)

%-- input --%
% cgm_hat: Nx1;
% patient: table
% param: it must contain 2 fields: param.ph, param.wind
% stats: it's a structure containing:
%             stats.idx_feature_set
%             stats.MU_x
%             stats.SIG_x
%             stats.MU_y
%             stats.SIG_y

patient = [patient_train; patient_test];
best_features_idx = stats.idx_feature_set;
mu_x = stats.MU_x;
sig_x = stats.SIG_x;

mu_y = stats.MU_y;
sig_y = stats.SIG_y;

X = test_corrective_features(patient,param,stats);
X = X(end-length(cgm_hat)+1:end,best_features_idx);

% %-- predicting all the test set for t > 60 min --%
% n_y = length(cgm_hat);
% n_x = size(X,1);
% if n_y > n_x
%     n_t = (n_y - n_x);
%     X = [stats.Xtrain(end-n_t+1:end,:); X];
% end

%-- normalization --%
X = (X - mu_x)./sig_x;

%-- error prediction --%
c = predict(Mdl,X);
c = c*sig_y + mu_y;

%-- output --%
cgm_hat_correct = cgm_hat + c;
idxNaN = find(isnan(cgm_hat_correct)==1);
cgm_hat_correct(idxNaN) = cgm_hat(idxNaN);

end