function [fault_snippet,non_fault_snippets] = make_snippets(feats, label, time, Nsamples, varargin)

simple_label = boolean(label)*1;

%% ========== save fault snippet =====================

% make table
portion = (label > 0);
F = feats(portion,:); % features
T = table(time(portion),'VariableNames',{'time'}); % time
L = table(simple_label(portion),'VariableNames',{'label'}); % label

fault_snippet = [F T L];
% ======================================================================


%% Non fault snippets

% available samples are in the portions where the label is 0
available = find(label == 0);

% find beginning and ending indices of each snippet
snip_start = available(1:Nsamples:end);
snip_end = available(Nsamples:Nsamples:end);
% (correction if not exact multiple)
if length(snip_start) > length(snip_end)
    snip_end = [snip_end; available(end)];
end

% use table for storing indices
X = table(snip_start, snip_end,snip_end-snip_start,'VariableNames',{'START','END','length'});
X.ok = (X.length >= Nsamples-1);
X(~X.ok,:) = [];

% save each snippet (skip first)
for ind = 2:height(X)
    interval = [X.START(ind):X.END(ind)];
    
    tmp_F = feats(interval,:); % features
    tmp_T = table(time(interval,:),'VariableNames',{'time'}); % time
    tmp_L = table(simple_label(interval,:),'VariableNames',{'label'}); % label
    
    non_fault_snippets{ind,1} = [tmp_F tmp_T tmp_L];
end

% remove empty cells
non_fault_snippets(cellfun(@isempty,non_fault_snippets)) = [];

end




