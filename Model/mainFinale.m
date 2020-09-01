%-- Main Code: Glucose Predictive Algorithm --%

clc
clear all
close all
save_results=false;

addpath(genpath('myfunxxx'));

% Old subjects
%subj_vector=[559 563 570 575 588 591];
% New subjects
subj_vector = [540 544 552 567 584 596];

%% Parameters Set
PH=6;
num_iter=10;

% feature selection
selected_features={'CGM','slope','IOB'}; %'Amount last CHO','Time since last CHO','Amount/Time last CHO','COB','CHO'%,'exercise','exercise_ob_1st','exercise_ob_2nd','basis_steps'};
% selected_features={'CGM'};
ord.slope=1;
ord.acl=1;

% param
param.ph = PH;

% debug plots
plotPrediction=0;
plotFeaturesRank=0;

%% Optimize
% n1=optimizableVariable('n1',[1 10],'Type','integer');
% n2=optimizableVariable('n2',[1 10],'Type','integer');
% n3=optimizableVariable('n3',[1 10],'Type','integer');
% hl=optimizableVariable('hl',[1 3],'Type','integer');
% ord_cgm=optimizableVariable('ord_cgm',[1 24],'Type','integer');
% 
% vars=[n1,n2,n3,hl,ord_cgm];
% fun=@(x)optNet1(subj_vector,num_iter,param,ord,.7,PH,selected_features,...
%     x.n1,x.n2,x.n3,x.hl,x.ord_cgm);
% results=bayesopt(fun,vars,'Verbose',0,...
%     'AcquisitionFunctionName','expected-improvement-plus',...
%     'ExplorationRatio',.6,...
%     'NumSeedPoints',10);
% n1=results.XAtMinObjective.n1;
% n2=results.XAtMinObjective.n2;
% n3=results.XAtMinObjective.n3;
% hl=results.XAtMinObjective.hl;
% ord.cgm=results.XAtMinObjective.ord_cgm;

n1=5;
hl=1;
ord.cgm=16;
param.extrp = 0;

param.wind = ord.cgm;
% BGPC rule 2:
param.start_challenge = 12+1;

for subj = 1:length(subj_vector)

    %% Load dataset
    subj_id=subj_vector(subj);
    [Xtrain,Ytrain,timeYtrain,labels,train_patient_table]=load_patient(subj_id,'Training',param,ord);    
    [Xtest,Ytest,timeYtest,~,test_patient_table]=load_patient(subj_id,'Testing',param,ord);
    rawtimeY = load_raw_test(subj_id,param);
    
  
    %% Feature selection
    [Xtrain,labels_tmp]=feature_selection1(Xtrain,labels,selected_features);
    [Xtest]=feature_selection1(Xtest,labels,selected_features);
    labels=labels_tmp;
    
    %-- extrapolation --%
    if param.extrp
        Xtest = extrapolation(Xtest);
    end

    %% Standardization
    mu=nanmean([Xtrain Ytrain],1);
    sigma=nanstd([Xtrain Ytrain],1);

    Xtrain=(Xtrain-mu(1:end-1))./sigma(1:end-1);
    Xtest=(Xtest-mu(1:end-1))./sigma(1:end-1);   
    Ytrain=(Ytrain-mu(end))/sigma(end);
             
    for iter=1:num_iter        
        %% Train baseline net
        switch hl
            case 1
                net=feedforwardnet(n1);
            case 2
                net=feedforwardnet([n1 n2]);
            case 3
                net=feedforwardnet([n1 n2 n3]);
        end
        net.trainParam.max_fail=20;
        net.trainParam.showWindow = false;
        net=train(net,Xtrain',Ytrain');
        
        % train corrective model for all steps
        if iter == 1
%             net=train(net,Xtrain',Ytrain');
            cgm_hat_train = [net(Xtrain')]';
            [Mdl_error, stats] = train_corrective_model(Ytrain, cgm_hat_train, train_patient_table, param);
        end

             
        %% Predict test set
        yhat = [net(Xtest')]';
        %-- Corrective Model --%
        [cgm_hat_correct] = corrective_step(Mdl_error, yhat, test_patient_table,train_patient_table, param, stats);
        
        cgm_hat_correct_tmp = cgm_hat_correct*sigma(end) + mu(end);
        cgm_hat_correct = cgm_hat_correct_tmp(1:end);
        yhat_tmp=yhat*sigma(end)+mu(end);
        yhat = yhat_tmp(1:end);

        % Saturation
        yhat(yhat>400)=400;
        yhat(yhat<40)=40;
        
        cgm_hat_correct(cgm_hat_correct>400)=400;
        cgm_hat_correct(cgm_hat_correct<40)=40;

        % Metrics
        %-- baseline net --%
        metric_subject_standard = GlucosePredictionMetrics(Ytest,yhat,PH);
        rmse_standard(iter) = metric_subject_standard(1);
        cod_standard(iter) = metric_subject_standard(2);
        delay_standard(iter) = metric_subject_standard(3);
        mae_standard(iter) = metric_subject_standard(end);
        
        %-- after correction --%
        metric_subject_correction = GlucosePredictionMetrics(Ytest,cgm_hat_correct,PH);
        rmse_correction(iter) = metric_subject_correction(1);
        cod_correction(iter) = metric_subject_correction(2);
        delay_correction(iter) = metric_subject_correction(3);
        mae_correction(iter) = metric_subject_correction(end);

        % Plot
        if plotPrediction
            %-- plot on retimed cgm --%
            figure
            plot(timeYtest,Ytest,'b')
            hold on
            plot(timeYtest,yhat,'--.r')
            hold on
            plot(timeYtest,cgm_hat_correct,'--.g')
            axis tight
            ylim([30 420])
            legend('Real CGM','Standard', 'Prediction')
        end
        
        %-- back to raw time --%
        idx_nan = find(isnan(Ytest)==1);
        cgm_hat_correct(idx_nan) = [];

        %-- for CGM only analysis --%
%         Ytest_fin = Ytest;
%         Ytest_fin(idx_nan) = [];
%         yhat(idx_nan) = [];

        %-- checo's db plot --%
%         figure, plot(rawtimeY,Ytest,'b',rawtimeY,cgm_hat_correct,'r');
        
        %-- save results --%
        TimeTable_tmp = timetable(rawtimeY',cgm_hat_correct,'VariableNames',{'Predicted_BG'});
        name_tmp = ['JCP_iter',num2str(iter),'_Ohio',num2str(subj_id),'_',num2str(5*PH)];
        writetimetable(TimeTable_tmp,[name_tmp,'.txt'],'Delimiter','space');
                
        %-- save CGM only results --%
%         TimeTable_tmp = timetable(rawtimeY',Ytest_fin,yhat,'VariableNames',{'CGM','Predicted_BG'});
%         name_tmp = ['CGMonly_iter',num2str(iter),'_Ohio',num2str(subj_id),'_',num2str(5*PH)];
%         writetimetable(TimeTable_tmp,[name_tmp,'.txt'],'Delimiter','space');
        

    end 
    
    % Display results
    disp(['Subject:',num2str(subj_id)])
    disp(['RMSE standard = ',num2str(mean(rmse_standard))]);
    disp(['RMSE corrected = ',num2str(mean(rmse_correction))]);
    
    rmse_total_mean(subj)=mean(rmse_standard);
    rmse_corrected_mean(subj)=mean(rmse_correction);
    
    mae_total_mean(subj) = mean(mae_standard);
    mae_corrected_mean(subj) = mean(mae_correction);
    
    rmse_fin_standard(subj,:) = [rmse_standard];
    cod_fin_standard(subj,:) = [cod_standard];
    delay_fin_standard(subj,:) = [delay_standard];
    mae_fin_standard(subj,:) = [mae_standard];
    
    rmse_fin_correction(subj,:) = [rmse_correction];
    cod_fin_correction(subj,:) = [cod_correction];
    delay_fin_correction(subj,:) = [delay_correction];
    mae_fin_correction(subj,:) = [mae_correction];
end

if save_results
    %-- correct --%
    save rmse_subj_iter rmse_fin_correction
    save cod_subj_iter cod_fin_correction
    save delay_subj_iter delay_fin_correction
    save mae_subj_iter mae_fin_correction

    %-- standard --%
    save rmse_subj_iter_standard rmse_fin_standard
    save cod_subj_iter_standard cod_fin_standard
    save delay_subj_iter_standard delay_fin_standard
    save mae_subj_iter_standard mae_fin_standard
end

disp('Mean overall RMSE:')
disp(['Standard = ',num2str(mean(rmse_total_mean))]);
disp(['Corrected = ',num2str(mean(rmse_corrected_mean))]);