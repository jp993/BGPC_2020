function [moving_corr,moving_lag] = movingxcorr(X,Y,n,varargin)
% Moving cross-correlation (uses moving window)
% X, Y: input signals
% n: length of the moving window in samples
%

p = inputParser;
addOptional(p,'scaleopt',[]);
parse(p,varargin{:});
scaleopt = p.Results.scaleopt; % results are scaled using xcorr options

% normalize values
X = normalize(X,'range',[-1 1]);
Y = normalize(Y,'range',[-1 1]);

% initialize output
moving_corr = ones(size(X));
moving_lag = zeros(size(X));

for k = n+1:length(X)
    
    % samples inside moving window
    A = X(k-n:k);
    B = Y(k-n:k);
    
    % calculate cross correlation and lag
    if ~isempty(scaleopt)
        [acor, lag] = xcorr(A,B,scaleopt);
    else
        [acor, lag] = xcorr(A,B);
    end
    [max_lag,I] = max(abs(acor));
    moving_corr(k) = max_lag;
    moving_lag(k) = lag(I);
end