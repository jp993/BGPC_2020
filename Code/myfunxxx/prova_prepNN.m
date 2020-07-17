function [X,labels]=prova_prepNN(signal,ord,start,label)
X=[];
labels=[];
for ii=1:ord-1
    X=[X,signal((start-ii):(end-ii))];
    name=[label,'-',num2str(ii)];
    labels=[labels {name}];
end