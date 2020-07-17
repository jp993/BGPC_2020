function [dataset,dataset_subsample] = make_feats_dataset(feats,label,t)
%
%
%

%
% 1: pre-fault portion (fault in act but CGM too low)
% 2: fault portion
% -1: post-fault portion (will be removed to avoid misleading data)
%
feats{label==-1,:} = NaN;
simple_label = zeros(size(label));

% TODO: it would be ideal to remove portion labeled with 1
% for now we cannot do that because if CGM goes above 120 during
% delay phase we lose continuity on the label

% simple_label(label == 2) = 1;
% simple_label(label == 1) = 1;
simple_label(label > 0) = 1;

dataset = [feats table(t,'VariableNames',{'time'}) table(simple_label,'VariableNames',{'label'})];


%% Make an arbirtary subset of data

data_ratio = 10; % between non-fault and fault data

fault_data = dataset(boolean(dataset.label),:);
ok_data = dataset(~boolean(dataset.label),:);

rng('default')
rng(1)
ok_data_subsample = datasample(ok_data,height(fault_data)*data_ratio);

dataset_subsample = [fault_data; ok_data_subsample];
dataset_subsample = sortrows(dataset_subsample,{'time'});
% =========================================================



end


