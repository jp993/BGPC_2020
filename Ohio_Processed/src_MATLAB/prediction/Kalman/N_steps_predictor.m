function [prediction,SD] = N_steps_predictor(X_t1_t,P_t1_t,Y_t1_t,Py_t1_t,input,n_steps,model)
%
% Predicts N-steps_ahead using model
% x(t+1) = A*x(t) + B*u(t)
% y(t) = C*x(t) + D*u(t)
%
% NOTATION:
% -------------------------------------------------------------------------
% Model state
% X_t1_t: X(t+1|t)
% X_tk_t: X(t+k|t)
% X_tk1_t: X(t+k+1|t)
%
% State covariance
% Px_t1_t: Px(t+1|t)
% Px_tk_t: Px(t+k|t)
% Px_tk1_t: Px(t+k+1|t)
%
% Measurement
% Y_t1_t: y(t+1|t)
% Y_tk_t: y(t+k|t)
% Y_tk1_t: y(t+k+1|t)
%
% Measurement covariance
% Py_t1_t: Py(t+1|t)
% Py_tk_t: Py(t+k|t)
% Py_tk1_t: Py(t+k+1|t)
% -------------------------------------------------------------------------

% initialization
prediction=zeros(n_steps,1);
SD=zeros(n_steps,1);

% first prediction was already made
X_tk_t=X_t1_t; % X(t+1|t)
P_tk_t=P_t1_t; % P(t+1|t)

prediction(1,:)=Y_t1_t;
SD(1,:)=sqrt(diag(Py_t1_t));

% for each of the (N-1) prediction steps remaining
for PH=1:n_steps-1
    
    % CURRENT TIME: (t+1) + PH
    % my_input has inputs from t+2 until t+N
    
    u_tk=input(PH,:);
    u_tk1=input(PH+1,:);
    
    [X_tk1_t,P_tk1_t,Y_tk1_t,Py_tk1_t] = Iterative_prediction_step(X_tk_t,P_tk_t,u_tk,u_tk1,model);

    % store prediction and SD
    prediction(PH+1)=Y_tk1_t;
    SD(PH+1)=sqrt(diag(Py_tk1_t));
    
    % iterative update
    X_tk_t=X_tk1_t;
    P_tk_t=P_tk1_t;
    
end

end

function [X_tk1_t,Px_tk1_t,Y_tk1_t,Py_tk1_t] = Iterative_prediction_step(X_tk_t,Px_tk_t,u_tk,u_tk1,model)
%
% Makes a 1-step prediction for iterative N-step prediction

A=model.A; B=model.B; C=model.C; D=model.D;
R=model.NoiseVariance;
K=model.K;
Q=K*R*K';
S=K*R;

% state prediction
X_tk1_t = A*X_tk_t + B*u_tk';
% measurement prediction
Y_tk1_t = C*X_tk1_t + D*u_tk1';
% state covariance prediction
Px_tk1_t = A*Px_tk_t*A' + Q;
% measurement covariance prediction
Py_tk1_t = C*Px_tk1_t*C' + R;

end