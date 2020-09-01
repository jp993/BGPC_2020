function new_label = adjust_label(label,data_Ts,CGM,post_duration,CGMth)
%
% Sets labels as follows:
%
% 1: pre-fault portion (fault in act but CGM too low)
% 2: fault portion
% -1: post-fault portion (will be removed to avoid misleading data)
%

% make copy
new_label = label;

% convert all non-zero values to 1
new_label = boolean(new_label)*1;

% pre-fault portion is labeled 1, visible fault portion is labeled 2
% (visible fault portion is distinguished using CGM value)
if 0
    new_label(CGM>CGMth & new_label~=0) = 2;
end


% post-fault portion is labeled with -1
Nsamples_post = post_duration*60/data_Ts;
fault_end = find(new_label>0,1,'last');
new_label(fault_end+1:fault_end+Nsamples_post) = -1;


end