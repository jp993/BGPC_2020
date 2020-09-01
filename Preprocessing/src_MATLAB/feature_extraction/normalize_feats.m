function [normalized_feats] = normalize_feats(all_feats, group_by, method)
% normalize features using specified method ('minmax' or 'zscore')
%
% group_by = 'subject':
% use values observed in each subject
%
% group_by = 'population':
% use values observed in the population
%



switch group_by
    
    case 'population'
        
        disp('Normalizing features using population values...')
        
        % pack into one table
        T = table();
        ID = [];
        for subj_n = 1:length(all_feats)
            feats = all_feats{subj_n};
            ID = [ID; subj_n*ones(height(feats),1)];
            T = [T; feats];
        end
        
        % do normalization using all observed values in the population
        T_normalized = normalize_(T,method);
        T_normalized.ID = ID;
        
        % unpack
        for subj_n = 1:length(all_feats)
            feats_ = T_normalized(T_normalized.ID==subj_n,:);
            feats_.ID=[];
            normalized_feats{subj_n} = feats_;
        end
        
    case 'subject'
        
        disp('Normalizing features using individual subject values...')
        
        for subj_n = 1:length(all_feats)
            feats = all_feats{subj_n};
            % do normalization using values from the subject
            normalized_feats{subj_n} = normalize_(feats,method);
        end
        
    case 'none'
        disp('Normalization skipped...')
        normalized_feats = all_feats;
end

end



function feats = normalize_(feats,method)
% normalize each column of a table using specified method
% supported method: {'minmax','zscore'}

feats_list = feats.Properties.VariableNames;
% feats_list = fieldnames(table2struct(feats));

switch method
    
    case 'minmax'
        my_range=[0 1];
        for ind=1:length(feats_list)
            feat=feats_list{ind};
            feats.(feat)=normalize(feats.(feat),'range',my_range);
        end
        
    case 'zscore'
        for ind=1:length(feats_list)
            feat=feats_list{ind};
            feats.(feat)=normalize(feats.(feat));
        end
        
end

end
