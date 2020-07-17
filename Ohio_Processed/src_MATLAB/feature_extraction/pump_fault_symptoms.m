function [ICOB,DCOB] = pump_fault_symptoms(IOB, COB, derivative)

% ICOB
K = 0.1;
ICOB = (IOB)./(COB+K);

% ratio between derivative and COB
K = 0.1;
DCOB = (derivative)./(COB+K);

%%
% figure
% plot(ICOB)

% figure
% hold on
% L(1) = plot(COB,'displayname','COB');
% L(2) = plot(IOB,'displayname','IOB');
% L(3) = plot(newIOB,'displayname','IOBxCR');
% L(4) = plot(basal_value,'displayname','basal');
% legend(L);

%%
end