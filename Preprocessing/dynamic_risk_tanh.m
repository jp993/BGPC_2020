function [SR,DR] =dynamic_risk_tanh(glucose,glucose_derivative,d,offset,aalpha)

% Function for the calculation of static risk and dynamic risk.
% INPUT:
% glucose: vector of glucose samples [mg/dl]
% glucose_derivative: derivative of glucose [mg/dl/min]
% d: parameter of dynamic risk function related to maximum amplification of static risk (suggested value d=3.5)
% offset: parameter of dynamic risk function related to maximum dumping (suggested value offset=0.75)
% aalpha: parameter of dynamic risk function related to derivative dependent amplification (suggested value aalpha=5, original value aaplha=3)
% OUTPUT:
% SR: static risk
% DR: dynamic risk

%%  Calculation of static risk (SR)

SR = zeros(length(glucose),1);

%Parameters of Kovatchev's risk function
alpha = 1.084;      
beta = 5.381;       
gamma = 1.509;

rl = zeros(length(glucose),1);      
rh = zeros(length(glucose),1);

for i=1:length(glucose)
    f = gamma*(((log(glucose(i)))^alpha)-beta);
    if f<0
        rl(i,1) = 10*(f^2);
    elseif f>0
        rh(i,1) = 10*(f^2);
    end
end

SR(:,1) = rh-rl;

%% Calculation of the modulation factor

modulation_factor=ones(length(glucose),1);

%Parameters of dynamic risk function
ddelta=(d-offset)/2;
bbeta=ddelta+offset;
ggamma=atanh((1-bbeta)/ddelta);

dr_over_dg(:,1) = 10*gamma^2*2*alpha*(log(glucose).^(2*alpha-1)-beta*log(glucose).^(alpha-1))./glucose;
modulation_factor=ddelta*tanh(aalpha*dr_over_dg.*glucose_derivative+ggamma)+bbeta;
       
%% Calculation of dynamic risk (DR)

DR=SR.*modulation_factor;