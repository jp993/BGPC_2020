function X = prepNN(signal,ord,ph)
X = zeros(length(signal)-ord-ph+1,ord);
for k = ord:length(signal)-ph
    X(k-ord+1,:) = signal(k-ord+1:k);
end
