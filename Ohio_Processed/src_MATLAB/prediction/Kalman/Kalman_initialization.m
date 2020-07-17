function [X_0,P_0] = Kalman_initialization(model,P_initialization_mode)
% Sets initial conditions for Kalman filter and performs first prediction and filtering step.

%% MODEL DESCRIPTION:
% x(t+1) = A*x(t) + B*u(t) + K*e(t)
% y(t) = C*x(t) + D*u(t) + e(t)
A=model.A; B=model.B; C=model.C; D=model.D;
K=model.K;
R=model.NoiseVariance;
Q=K*R*K';
S=K*R;

%% X_0 (initial state)
X_0=zeros(size(A,1),1);

%% P_0
switch P_initialization_mode
    case 'infinite'
        % We set uncertainty to a high default value
        lambda=10000;
        P_0=lambda*eye(size(A,1));
    case 'Riccati'
        % Riccati equation solver
        % dare(A',C',Q,R,S)
        [P_0,~,~] = dare(A',C',Q,R,S);
%         [P_0,~,~] = dare((A-S*inv(R)*C)',C',Q,R,S);
    otherwise
        error('Invalid P_0 settings')
end

end