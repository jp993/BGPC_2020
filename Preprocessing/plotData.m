function plotData(patID,version)

    load(fullfile(['Ohio' patID],['Ohio' patID version]))
    
    ax(1) = subplot(311);
    
    hp1(1) = plot(patient.Time,patient.CGM,'k-o','linewidth',2);
    hold on
    hp1(2) = plot(patient.Time,patient.SMBG,'r*','linewidth',3);
    plot([patient.Time(1) patient.Time(end)],[70 70],'m--','linewidth',2);
    plot([patient.Time(1) patient.Time(end)],'m--','linewidth',2);
    stem(patient.Time, 600*ones(1,length(patient.timeseries.hypo_event.time)),'o','linewidth',2,'color',[138,43,226]/255);
    hp1(3) = plot(patient.timeseries.hypo_event.time, zeros(1,length(patient.timeseries.hypo_event.time)),'o','linewidth',2,'color',[138,43,226]/255);
    stem(patient.timeseries.illness.time, 600*ones(1,length(patient.timeseries.illness.time)),'o','linewidth',2,'color',[255,69,0]/255);
    hp1(4) = plot(patient.timeseries.illness.time, zeros(1,length(patient.timeseries.illness.time)),'o','linewidth',2,'color',[255,69,0]/255);
    stem(patient.timeseries.stressors.time, 600*ones(1,length(patient.timeseries.stressors.time)),'o','linewidth',2,'color',[34,139,34]/255);
    hp1(5) = plot(patient.timeseries.stressors.time, zeros(1,length(patient.timeseries.stressors.time)),'o','linewidth',2,'color',[34,139,34]/255);

    grid on
    ylabel('Glucose [mg/dL]','FontWeight','bold','FontSize',18);
    legend(hp1,'CGM','SMBG','Self-rep. Hypo','Self-rep. Illness','Self-rep. Stress');
    title(['Patient Ohio' patID ' data'],'fontsize',20);
    hold off
    
%     ax(2) = subplot(312);
%     CHOBData.time = patient.timeseries.cho_intake.time(strcmp(patient.timeseries.cho_intake.type,'Breakfast'));
%     CHOBData.value = patient.timeseries.cho_intake.value(strcmp(patient.timeseries.cho_intake.type,'Breakfast'));
%     CHOLData.time = patient.timeseries.cho_intake.time(strcmp(patient.timeseries.cho_intake.type,'Lunch'));
%     CHOLData.value = patient.timeseries.cho_intake.value(strcmp(patient.timeseries.cho_intake.type,'Lunch'));
%     CHODData.time = patient.timeseries.cho_intake.time(strcmp(patient.timeseries.cho_intake.type,'Dinner'));
%     CHODData.value = patient.timeseries.cho_intake.value(strcmp(patient.timeseries.cho_intake.type,'Dinner'));
%     CHOSData.time = patient.timeseries.cho_intake.time(strcmp(patient.timeseries.cho_intake.type,'Snack'));
%     CHOSData.value = patient.timeseries.cho_intake.value(strcmp(patient.timeseries.cho_intake.type,'Snack'));
%     CHOHData.time = patient.timeseries.cho_intake.time(strcmp(patient.timeseries.cho_intake.type,'HypoCorrection'));
%     CHOHData.value = patient.timeseries.cho_intake.value(strcmp(patient.timeseries.cho_intake.type,'HypoCorrection'));
%     
%     BWZData.time = patient.timeseries.insulin_bolus.time_begin(find(patient.timeseries.insulin_bolus.bwz_carb_input));
%     BWZData.value = patient.timeseries.insulin_bolus.bwz_carb_input(find(patient.timeseries.insulin_bolus.bwz_carb_input));
%     
%     
%     hp2(1) = stem(CHOBData.time, CHOBData.value	,'^','linewidth',2,'color',[0,0,128]/255);
%     hold on;
%     hp2(2) = stem(CHOLData.time, CHOLData.value	,'^','linewidth',2,'color',[0,0,204]/255);
%     hp2(3) = stem(CHODData.time, CHODData.value	,'^','linewidth',2,'color',[65,105,225]/255);
%     hp2(4) = stem(CHOSData.time, CHOSData.value	,'^','linewidth',2,'color',[0,255,255]/255);
%     hp2(5) = stem(CHOHData.time, CHOHData.value	,'^','linewidth',2,'color',[175,238,238]/255);
%     hp2(6) = plot(BWZData.time, BWZData.value,'*','linewidth',3,'color',[0,255,0]/255);
%     grid on
%     ylabel('CHO [g]','FontWeight','bold','FontSize',18);
%     legend(hp2,'CHO (B)','CHO (L)','CHO (D)','CHO (S)','CHO (H)','BWZ Input');
%     hold off
%     
%     ax(3) = subplot(313);
%     
%     MealData.time = patient.timeseries.insulin_bolus.time_begin(find(patient.timeseries.insulin_bolus.bwz_carb_input));
%     MealData.value = patient.timeseries.insulin_bolus.value(find(patient.timeseries.insulin_bolus.bwz_carb_input));
%     CorrData.time = patient.timeseries.insulin_bolus.time_begin(find(patient.timeseries.insulin_bolus.bwz_carb_input==0));
%     CorrData.value = patient.timeseries.insulin_bolus.value(find(patient.timeseries.insulin_bolus.bwz_carb_input==0));
%     hp3(1) = stem(MealData.time,MealData.value,'^','linewidth',2,'color',[0,255,0]/255);
%     hold on
%     hp3(2) = stem(CorrData.time,CorrData.value,'^','linewidth',2,'color',[34,139,34]/255);
%     hp3(3) = stairs(patient.timeseries.basal_insulin.time,patient.timeseries.basal_insulin.value,'-','linewidth',3,'color',[0,0,0]/255);
%     legend(hp3,'Meal [U]','Correction [U]','Basal [U/h]');
%     ylabel('Insulin [U]','FontWeight','bold','FontSize',18);
%     xlabel('time [datetime]','FontWeight','bold','FontSize',18);
%     grid on
%     hold off
%     
%     linkaxes(ax,'x');
%     set(ax,'FontSize',15)
%     
%     figure
%     ax2(1) = subplot(311);
%     
%     hp21(1) = plot(patient.timeseries.CGM.time,patient.timeseries.CGM.value,'k-o','linewidth',2);
%     hold on
%     hp21(2) = plot(patient.timeseries.SMBG.time,patient.timeseries.SMBG.value,'r*','linewidth',3);
%     plot([patient.timeseries.CGM.time(1) patient.timeseries.CGM.time(end)],[70 70],'m--','linewidth',2);
%     plot([patient.timeseries.CGM.time(1) patient.timeseries.CGM.time(end)],[180 180],'m--','linewidth',2);
%     grid on
%     ylabel('Glucose [mg/dL]','FontWeight','bold','FontSize',18);
%     legend(hp21,'CGM','SMBG');
%     title(['Patient Ohio' patID ' data'],'fontsize',20);
%     hold off
%     
%     ax2(2) = subplot(312);
%     k = 1;
%     for i = 1:length(patient.timeseries.sleep.time_begin)
%         ts(k) = patient.timeseries.sleep.time_begin(i);
%         ts(k+1) = patient.timeseries.sleep.time_begin(i);
%         ts(k+2) = patient.timeseries.sleep.time_end(i);
%         ts(k+3) = patient.timeseries.sleep.time_end(i);
%         ys(k) = 0;
%         ys(k+1) = patient.timeseries.sleep.quality(i);
%         ys(k+2) = patient.timeseries.sleep.quality(i);
%         ys(k+3) = 0;
%         k = k+4;
%     end
%     k = 1;
%     for i = 1:length(patient.timeseries.work.time_begin)
%         tw(k) = patient.timeseries.work.time_begin(i);
%         tw(k+1) = patient.timeseries.work.time_begin(i);
%         tw(k+2) = patient.timeseries.work.time_end(i);
%         tw(k+3) = patient.timeseries.work.time_end(i);
%         yw(k) = 0;
%         yw(k+1) = patient.timeseries.work.intensity(i);
%         yw(k+2) = patient.timeseries.work.intensity(i);
%         yw(k+3) = 0;
%         k = k+4;
%     end
%     hp22(1) = area(ts,ys);
%     hold on;
%     hp22(2) = area(tw,yw);
%     ylabel('Daily life [.]','FontWeight','bold','FontSize',18);
%     legend(hp22,'Sleep','Work');
%     hold off
%     
%     ax2(3) = subplot(313);
%     
%     hp21(1) = plot(patient.timeseries.basis_skin_temperature.time,patient.timeseries.basis_skin_temperature.value,'linewidth',2,'color',[0,0,128]/255);
%     hold on
%     hp21(2) = plot(patient.timeseries.basis_air_temperature.time,patient.timeseries.basis_air_temperature.value,'linewidth',2,'color',[0,255,255]/255);
%     
%     grid on
%     ylabel('Temperature [°F]','FontWeight','bold','FontSize',18);
%     legend(hp21,'Skin temp.','Air temp.');
%     hold off
%     
%     linkaxes(ax2,'x');
%     set(ax2,'FontSize',15)
%     
%     figure
%     ax3(1) = subplot(5,1,1:2);
%     
%     hp31(1) = plot(patient.timeseries.CGM.time,patient.timeseries.CGM.value,'k-o','linewidth',2);
%     hold on
%     hp31(2) = plot(patient.timeseries.SMBG.time,patient.timeseries.SMBG.value,'r*','linewidth',3);
%     plot([patient.timeseries.CGM.time(1) patient.timeseries.CGM.time(end)],[70 70],'m--','linewidth',2);
%     plot([patient.timeseries.CGM.time(1) patient.timeseries.CGM.time(end)],[180 180],'m--','linewidth',2);
%     grid on
%     ylabel('Glucose [mg/dL]','FontWeight','bold','FontSize',18);
%     legend(hp31,'CGM','SMBG');
%     title(['Patient Ohio' patID ' data'],'fontsize',20);
%     hold off
%     
%     ax3(2) = subplot(5,1,3);
%     
%     exercise.ends = patient.timeseries.exercise.time + minutes(patient.timeseries.exercise.duration);
%     exercise.time = [patient.timeseries.exercise.time exercise.ends];
%     exercise.intensity = [patient.timeseries.exercise.intensity zeros(1,length(exercise.ends))];
%     [exercise.time idx] = sort(exercise.time);
%     exercise.intensity = exercise.intensity(idx);
%     k = 1;
%     for i = 1:length(patient.timeseries.exercise.time)
%         te(k) = patient.timeseries.exercise.time(i);
%         te(k+1) = patient.timeseries.exercise.time(i);
%         te(k+2) = patient.timeseries.exercise.time(i)+minutes(patient.timeseries.exercise.duration(i));
%         te(k+3) = patient.timeseries.exercise.time(i)+minutes(patient.timeseries.exercise.duration(i));
%         ye(k) = 0;
%         ye(k+1) = patient.timeseries.exercise.intensity(i);
%         ye(k+2) = patient.timeseries.exercise.intensity(i);
%         ye(k+3) = 0;
%         k = k+4;
%     end
%     
%     
%     hp32(1) = area(te,ye);
%    
%     ylabel('Exercise [.]','FontWeight','bold','FontSize',18);
%     legend(hp32,'Exercise');
%     hold off
%     
%     ax3(3) = subplot(5,1,4);
%     
%     hp33(1) = plot(patient.timeseries.basis_heart_rate.time,patient.timeseries.basis_heart_rate.value,'linewidth',2,'color',[34,139,34]/255);
%     
%     grid on
%     ylabel('Heart rate [BPM]','FontWeight','bold','FontSize',18);
%     legend(hp33,'Heart rate');
%     hold off
%     
%     ax3(4) = subplot(5,1,5);
%     
%     hp34(1) = plot(patient.timeseries.basis_steps.time,patient.timeseries.basis_steps.value,'linewidth',2,'color',[75,0,130]/255);
%     
%     grid on
%     ylabel('Steps [.]','FontWeight','bold','FontSize',18);
%     xlabel('time [datetime]','FontWeight','bold','FontSize',18);
%     legend(hp34,'Steps');
%     hold off
%     
%     linkaxes(ax3,'x');
%     set(ax3,'FontSize',15)
    
%     
%     ax(4) = subplot(514);
%     hp4(1) = plot(patient.timeseries.basis_steps.time,patient.timeseries.basis_steps.value,'o-','linewidth',2,'color',[255,69,0]/255);
%     hold on;
%     %hp4(2) = stem(Ex1Data.Time, Ex1Data.Exercise,'^','linewidth',2,'color',[255,140,0]/255);
%     %hp4(3) = stem(Ex2Data.Time, Ex2Data.Exercise,'^','linewidth',2,'color',[255,175,0]/255);
%     %hp4(4) = stem(Ex3Data.Time, Ex3Data.Exercise,'^','linewidth',2,'color',[255,225,0]/255);
%     grid on
%     ylabel('Exercise [.]','FontWeight','bold','FontSize',18);
%     legend(hp4,'Steps');
%     hold off
%     ax(5) = subplot(515);
%     hp5(1) = plot(patient.timeseries.basis_heart_rate.time,patient.timeseries.basis_heart_rate.value,'-o','linewidth',2,'color',[75,0,130]/255);
%     grid on;
%     ylabel('Heart rate [bpm]','FontWeight','bold','FontSize',18);
%     xlabel('time [datetime]','FontWeight','bold','FontSize',18);
% %     Alc0Data = logBook(logBook.Alcohol==0,:);
% %     Alc1Data = logBook(logBook.Alcohol==1,:);
% %     Alc2Data = logBook(logBook.Alcohol==2,:);
% %     Alc3Data = logBook(logBook.Alcohol==3,:);
% %     hp5(1) = stem(Alc0Data.Time, Alc0Data.Alcohol,'^','linewidth',2,'color',[75,0,130]/255);
% %     hold on;
% %     hp5(2) = stem(Alc1Data.Time, Alc1Data.Alcohol,'^','linewidth',2,'color',[138,43,226]/255);
% %     hp5(3) = stem(Alc2Data.Time, Alc2Data.Alcohol,'^','linewidth',2,'color',[255,0,255]/255);
% %     hp5(4) = stem(Alc3Data.Time, Alc3Data.Alcohol,'^','linewidth',2,'color',[238,130,238]/255);
% %     grid on
% %     ylabel('Alcohol [.]','FontWeight','bold','FontSize',18);
% %     xlabel('time [datetime]','FontWeight','bold','FontSize',18);
% %     legend(hp5,'Alcohol = 0','Alcohol = 1','Alcohol = 2','Alcohol = 3');
% %     hold off
% 
%     linkaxes(ax,'x');
%     set(ax,'FontSize',15)
end