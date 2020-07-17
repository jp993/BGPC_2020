function [X1,X2] = twoCompSysD(my_input,K,data_Ts,varargin)
%
% Discrete two-compartmental system
%
% my beautiful drawing below:
%
%        state1      state2
%  ----> ( X1 ) ---> ( X2 ) --->
%  u(t)          K           K
%
%

p = inputParser;
addOptional(p,'x0',[],@isnumeric);
parse(p,varargin{:});
x0=p.Results.x0;

%% ZOH resample (data_Ts -> 1min)
if data_Ts ~= 1
    % new time vector
    time_Ts=0:data_Ts:length(my_input)*data_Ts-1;
    time_1min = linspace(time_Ts(1),time_Ts(end),length(time_Ts)*(data_Ts/1));
    time_1min=time_1min(:);
    % resample with zero-order hold
    input_Ts1 = zoh(time_Ts,my_input,time_1min);
else
    input_Ts1=my_input;
end

%% define SS system
A=[1-K K; 0 1-K];
B=[0; 1];
C=[1 0];
D=0;
sys=ss(A,B,C,D,1); % Ts=1

%% filter
% time vector
t_Ts1=[0:1:length(input_Ts1)-1]; % [min]

% filtering
if ~isempty(x0)
    [y,t,x]=lsim(sys,input_Ts1,t_Ts1,x0);
else
    [y,t,x]=lsim(sys,input_Ts1,t_Ts1);
end

X1=x(:,1);
X2=x(:,2);

%% output
% resample 1min -> Ts
X1 = X1(1:data_Ts:end);
X2 = X2(1:data_Ts:end);

end

