function [X_t1_t,Px_t1_t,Y_t1_t,Py_t1_t] = ...
    One_step_prediction(y_t,u_t,u_t1,X_t_t,P_t_t,R_t,model)
%
% NOTATION:
% -----------------------------------------------------------------------
% X_t_t: X(t|t)         % current state
% X_t1_t: X(t+1|t)      % 1 step prediction
%
% P_t_t: P(t|t)         % state covariance matrix
% P_t1_t: P(t+1|t)
%
% y_t: y(t)             % current measurement
%
% u_t: u(t)             % current input
% u_t1: u(t1)            % next input
%
% R_t: R(t)             % current R (measurement covariance matrix)
% -----------------------------------------------------------------------

%% MODEL DESCRIPTION:
% x(t+1) = A*x(t) + B*u(t) + K*e(t)
% y(t) = C*x(t) + D*u(t) + e(t)
A=model.A; B=model.B; C=model.C; D=model.D;
K=model.K;
R=model.NoiseVariance;
Q=K*R*K';
S=K*R;

%% Transform
Q_eq = Q - S*inv(R_t)*S';
A_eq = A - S*inv(R_t)*C;
B_eq = B - S*inv(R_t)*D;

%% 1 step prediction
% state: X(t+1|t)
X_t1_t = A_eq*X_t_t + B_eq*u_t' + S*inv(R_t)*y_t;
% state covariance: P(t+1|t)
Px_t1_t = A_eq*P_t_t*A_eq'+ Q_eq;
% prediction: Y(t+1|t)
Y_t1_t = C*X_t1_t + D*u_t1';
% measurement covariance: Py(t+1|t)
Py_t1_t = C*Px_t1_t*C' + R;

end
