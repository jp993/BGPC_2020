function [X,labels]=feature_selection1(X,labels,selected_features)
% Feature selection iniziale, arbitraria, fatta un po' alla cazzo di cane
% come ci va a noi. Sono le feature con cui scegliamo di andare avanti.

features_idx=zeros(1,size(X,2));
for ii=1:length(selected_features)
    l=length(selected_features{ii});
    for j=1:length(labels)
        label_tmp=labels{j};
        features_idx(j)=features_idx(j)+...
            strcmp(selected_features{ii},label_tmp(1:min(l,length(label_tmp))));
        % Perché tutto sto bordeo? Perché così mi prendo su sia CGM che
        % CGM-1, CGM-2 etc etc in una botta sola. Tendenzialmente dovrebbe
        % valere per qualsiasi features sto discorso.
    end  
end
X=X(:,features_idx>0);
labels=labels(features_idx>0);