function [moving_mean,moving_var,moving_kurtosis,moving_skew] = moving_stats(X,n,varargin)
% Moving window based statistics
% X: input signal
% n: length of the moving window in samples
%

p = inputParser;
addOptional(p,'foo',[]);
parse(p,varargin{:});
foo = p.Results.foo;

% initialize output
moving_mean = zeros(size(X)) * mean(X);
moving_var = ones(size(X)) * var(X);
moving_kurtosis = zeros(size(X)) * kurtosis(X);
moving_skew = ones(size(X)) * skewness(X);

% for k = n+1:length(X)
%     % samples inside moving window
%     A = X(k-n:k);
%     % calculate stats
%     moving_mean(k) = mean(A);
%     moving_kurtosis(k) = kurtosis(A);
%     moving_skew(k) = skewness(A);
% end


m = mean(X);
sd = std(X);

for k = n+1:length(X)
    % samples inside moving window
    A = X(k-n:k);
    
    moving_mean(k) = mean(A - m);
    moving_var(k) = mean(A - m)^2 / sd^2;
    moving_skew(k) = mean(A - m)^3 / sd^3;
    moving_kurtosis(k) = mean(A - m)^4 / sd^4;
end


end