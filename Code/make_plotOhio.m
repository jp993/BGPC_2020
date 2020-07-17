function p = make_plotOhio(num_sub, PH, max_iter)

addpath(genpath('CGMonlyResults'));
main_net_flag = 1;
load cho544


if PH == 30
    addpath(genpath('30minPredictions'));
    name_end = '_30';
else
    addpath(genpath('60minPredictions'));
    name_end = '_60';
end

cgm_only_filename = 'CGMonly_';
cgm_JCP_filename = 'JCP_';
 
for i = 1:max_iter
    
    %-- CGM only table --%
    cgm_only_filename_tmp = [cgm_only_filename,'iter',num2str(i),'_Ohio',num2str(num_sub),name_end];
    CGM_only_table = table2timetable(readtable(cgm_only_filename_tmp));
    
    time = CGM_only_table.Time;
    y_test = CGM_only_table.CGM;
    yhat_cgm_only = CGM_only_table.Predicted_BG;
    
%     %-- main net --%
%     cgm_JCP_filename_tmp = [cgm_JCP_filename,'iter',num2str(i),'_Ohio',num2str(num_sub),name_end];
%     JCP_table = table2timetable(readtable(cgm_JCP_filename_tmp));
%     yhat_JCP = JCP_table.Predicted_BG;
%     
    %-- JCP algorithm table --%
    cgm_JCP_filename_tmp = [cgm_JCP_filename,'iter',num2str(i),'_Ohio',num2str(num_sub),name_end];
    JCP_table = table2timetable(readtable(cgm_JCP_filename_tmp));
    yhat_JCP = JCP_table.Predicted_BG;
    
    %-- da abbellire --%
    figure,
    p1 = subplot(4,4,[1:12]);
    plot(time,y_test,'b'), hold on, plot(time,yhat_cgm_only,'--.r'),...
        plot(time,yhat_JCP,'--.g'), axis tight, ylim([30 420])
    legend('Real CGM','CGM only', 'JCP')
    title(['Ohio',num2str(num_sub),', ',num2str(name_end(2:end)),'-minute prediction'])
    hold off
    p2 = subplot(4,4,[13:16]);
    stem(time,cho544);
    linkaxes([p1,p2],'x')
end

