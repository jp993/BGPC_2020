function [X_t1_t1,P_t1_t1,debug] = ...
    Kalman_filtering_step(u_t1,y_t1,X_t1_t,P_t1_t,R_t1,model)
%
% Filtering step equations for Kalman filter
% For reference see page 290 Picci
%
% -------------------------------------------------------------------------
%
% NOTATION:
%
% Model state
% X_t1_t: X(t+1|t)
% X_t1_t1: X(t+1|t+1)
%
% State covariance
% Px_t1_t: Px(t+1|t)
% Px_t1_t: Px(t+1|t+1)
%
% Input
% u_t1: u(t+1)
%
% Measurement
% Y_t1: y(t+1)
%
% Measurement covariance
% Py_t1_t: Py(t+1|t)
% Py_t1_t1: Py(t+1|t+1)
%
% -------------------------------------------------------------------------

C=model.C;
D=model.D;

% Prediction residual
e_t1 = y_t1 - C*X_t1_t - D*u_t1'; % e(t+1)

debug.e_t=e_t1;

% Innovation process variance
Lambda_t1 = C*P_t1_t*C' + R_t1; % Lambda(t+1)

% Filter gain matrix
L_t1 = P_t1_t*C'*inv(Lambda_t1); % L(t+1)

% X(t+1|t+1)
X_t1_t1 = X_t1_t + L_t1*e_t1;

% P(t+1|t+1)
P_t1_t1 = P_t1_t - P_t1_t*C'*inv(Lambda_t1)*C*P_t1_t;

end