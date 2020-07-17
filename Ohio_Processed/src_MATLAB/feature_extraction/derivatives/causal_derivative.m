function der = causal_derivative(y, sampling_time, varargin)

p = inputParser;
addOptional(p,'tau',100,@isnumeric);
addParameter(p,'burnin',0,@isnumeric);
parse(p,varargin{:});

tau = p.Results.tau;
burn_in_samples = p.Results.burnin;

%% derivative calculation
my_tf = c2d(tf([1 0],[tau 1]),sampling_time);

if any(isnan(y))
    % interpolate nan portions if less long than a threshold value
    nan_th = 60; % min
    %%%%%%%%%%% COMMENTATO DA GIACOMO: interpolo gia' prima
    %[short_nan] = find_nan_islands(y, nan_th/sampling_time);
    %y(short_nan) = interp1(find(~isnan(y)), y(~isnan(y)), short_nan);
    %%%%%%%%%%%
    %     y(short_nan) = pchip(find(~isnan(y)), y(~isnan(y)), short_nan);
    
    % recalculate long nan portions
    [short_nan, long_nan, nan_start, nan_end] = find_nan_islands(y, nan_th/sampling_time);
    
    % piece-wise derivative (avoid nan portions)
    burnin_length = nan_th/sampling_time;
    der = nan(size(y));
    for k = 1:length(nan_start)+1
        
        if k == 1
            portion = 1:nan_start(k)-1;
        elseif k == length(nan_start)+1
            portion = nan_end(end)+1:length(y);
        else
            portion = nan_end(k-1)+1:nan_start(k)-1;
        end
        % calculate derivative
        x = lsim(my_tf, y(portion));
        % remove burnin
        if length(portion) < burnin_length
            x(1:end) = nan;
        else
            x(1:burnin_length) = nan;
        end
        der(portion) = x;
    end
    
%     debug_debug(y, der)
    
else
    % no nan portions are present
    der = lsim(my_tf, y);
end

% remove burnin portion
der(1:burn_in_samples) = 0;

end

function debug_debug(y, der)

t = 1:length(y);
figure
subplot(2,1,1)
plot(t, y)
hold on
plot([t(isnan(y)); t(isnan(y))],[min(y); max(y)],'r')
xlim([1 length(y)])
subplot(2,1,2)
plot(t, der)
xlim([1 length(y)])

end