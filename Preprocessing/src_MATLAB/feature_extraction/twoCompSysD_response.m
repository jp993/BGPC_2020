function [IR,SR] = twoCompSysD_response(K, comp, varargin)
%
% From discrete two-compartmental system
%
%        state1      state2
%  ----> ( X1 ) ---> ( X2 ) --->
%  u(t)          K           K
%
% plot impulse response (IR) and step response (SR)
%
% my_input: input signal u(t)
% K: coefficient (see drawing)
% data_Ts: sampling time
% comp: {1,2} the compartment you want the response of
%


p = inputParser;
addOptional(p,'plot',0);
parse(p,varargin{:});
plot_flag=p.Results.plot;

%% define SS system
A=[1-K K; 0 1-K];
B=[0; 1];
D=0;

if comp == 1
    C = [1 0];
elseif comp == 2
    C = [0 1];
else
    error('fratello... DUE compartimenti')
end

Ts = 1;
sys = ss(A,B,C,D,Ts); % Ts=1

%% system response
sim_length = 9; % h
t = 0:Ts:sim_length*60;

SR = step(sys,t);
IR = impulse(sys,t);

%% plot
if plot_flag
    figure('Color','w','Name',sprintf('Compartment %g',comp))
    subplot(1,2,1)
    plot(t/60,IR)
    title('impulse response')
    xlabel('h')
    subplot(1,2,2)
    plot(t/60,SR)
    title('step response')
    xlabel('h')
end

end

