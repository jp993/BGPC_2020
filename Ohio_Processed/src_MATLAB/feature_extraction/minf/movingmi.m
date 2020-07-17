function out_mi = movingmi(X,Y,n)

out_mi = zeros(size(X));

for k = n+1:length(X)
    
    A = X(k-n:k);
    B = Y(k-n:k);
    
    MI = mi(A,B);
    
    out_mi(k) = MI;
end