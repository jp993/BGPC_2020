function [dq,sCGM,dq_sCGM,arrow,filtered_dq] = derivativeland(CGM,data_Ts,plot_flag)

%% time
time=0:data_Ts:(length(CGM)-1)*data_Ts;

%% derivative fun begins

% causal derivative
burn_in_hours = 3;
N = floor(burn_in_hours*60/data_Ts);
causal_der = causal_derivative(CGM,data_Ts,'burnin',N);

% difference quotient (dq)
dq = [0; diff(CGM)/data_Ts];

% smoothing CGM using savitzky-golay (non-causal)
sCGM = sgsmooth(CGM,45,5);

% dq of smoothed CGM
dq_sCGM = [0; diff(sCGM/data_Ts)];

% martina lowpass of dq
num=[0.325 0.325 0.25 0.1];
den=[1 0 0 0 0];
martina_lowpass = tf(num,den,data_Ts);
% filtered_dq = lsim(martina_lowpass,dq);
filtered_dq = [];

% CGM arrov
% arrow = arrowtrend(filtered_dq);
arrow = [];

% linear fit of slope
lin_slope1h = moving_slope(CGM, 1, data_Ts);
lin_slope2h = moving_slope(CGM, 2, data_Ts);
lin_slope3h = moving_slope(CGM, 3, data_Ts);

%% plot

if plot_flag
    figure('Color','w')
    t=datenum(time/60/24)+1;
    t=datetime(t,'ConvertFrom','datenum');
    
    ax(1)=subplot(2,1,1);
    hold on
    plot(t,CGM)
%     plot(t,sCGM)
%     legend('CGM','CGM (S-G)')
    grid on; grid minor;
    ylabel('mg/dL')
    title('CGM')
    
    ax(2)=subplot(2,1,2);
    hold on
    plot(t,zeros(size(causal_der)),'k','LineWidth',2)
    l = [];
    l(end+1) = plot(t,causal_der,'DisplayName','causal');
%     l(end+1) = plot(t,dq_sCGM,'DisplayName','dq of smoothed');
%     l(end+1) = plot(t,filtered_dq,'DisplayName','martina');
%     l(end+1) = plot(t,dq,'DisplayName','dq');
%     l(end+1) = stairs(t,arrow,'g','LineWidth',2,'DisplayName','arrow');
    l(end+1) = plot(t,lin_slope1h,'DisplayName','slope1h');
%     l(end+1) = plot(t,lin_slope2h,'DisplayName','slope2h');
%     l(end+1) = plot(t,lin_slope3h,'DisplayName','slope3h');
    
    grid on; grid minor;
    ylabel('mg/dL/min')
    title('derivative')
    
    legend(l)
    linkaxes(ax,'x')
    
end