%% Run it after preprocess

clear all
close all
clc

dbclear if error
subjs = {'559','563','570','575','588','591','540','544','552','567','584','596'};
set = 'Testing';
superpatient =[];
for s = 1:length(subjs)
  
    subj = subjs{s};
    load(fullfile(['Ohio' subj],['Ohio' subj '_' set '_preprocessed' ]));
    disp(['Processing patient Ohio' subj]);
    
    % SAVE
    
    writetable(timetable2table(patient), fullfile('data',['ohio' subj '_' set]));
    
end