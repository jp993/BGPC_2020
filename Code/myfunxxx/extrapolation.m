function Extrap_X = extrapolation(X)

Extrap_X = X;

for i = 1:size(X,2)
    xq = [1:size(X,1)]';
    v = X(:,i);
    idx_nan = find(isnan(v)==1);
    x = xq;
    x(idx_nan) = [];
    v(idx_nan) = [];
    Extrap_X(:,i) = interp1(x,v,xq,'linear','extrap');
end