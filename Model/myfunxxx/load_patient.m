function [X,Y,timeY,labels,timetable]=load_patient(subj,set,param,ord)

PH=param.ph;
start=param.wind;
start_bgpc = param.start_challenge;

filename=['..\Ohio_Processed\Ohio',num2str(subj),'\Ohio',num2str(subj),'_',set,'_preprocessed'];
load(filename,'patient');

timetable=patient;
labels=patient.Properties.VariableNames;
X=patient{start:(end-PH),:};

%-- porcaio made by checo per risolvere problema dei campioni da predirre

if strcmp(set,'Testing')
    
    X = [];
    patient_test = patient;
    Y=patient_test{start_bgpc:end,1};
    timeY=patient_test.Time(start_bgpc:end);

    %-- concatenate last train samples to first test samples --%
    filename=['..\Ohio_Processed\Ohio',num2str(subj),'\Ohio',num2str(subj),'_','Training','_preprocessed'];
    load(filename,'patient');
    X=[patient{start:end,:};patient_test{1:end-PH,:}];
    
    %-- trick to find the right starting values --%
    start_time = timeY(1);
    Time_concat = [patient.Time((start + PH):end,1); patient_test.Time];
    start_idx = find(Time_concat == start_time);
    
    %-- feature --%
    CGM = [patient.CGM; patient_test.CGM(1:end-PH)];
        
    slope_CGM = [patient.slope; patient_test.slope(1:end-PH)];
    
    %-- make regressors input matrix --%

    [X_tmp,labels_tmp]=prova_prepNN(CGM,ord.cgm,start,'CGM');
    X_tmp(X_tmp>=400)=NaN;
    X_tmp(X_tmp<=40)=NaN;
    X=[X,X_tmp];
    labels=[labels,labels_tmp];
    

    [X_tmp,labels_tmp]=prova_prepNN(slope_CGM,ord.slope,start,'slope');
    X=[X,X_tmp];
    labels=[labels,labels_tmp];

    %-- risk indeces --%
    for ii=start:length(CGM)
        [BGRI(ii-start+1),LBGI(ii-start+1),HBGI(ii-start+1)]=get_risk_index(CGM((ii-start+1):ii));
    end
    X=[X,BGRI',LBGI',HBGI'];
    labels=[labels,{'BGRI'},{'LBGI'},{'HBGI'}];

    %-- CHO-related features --% 
    CHO=[patient.CHO(start:end); patient_test.CHO(1:end-PH)];
    t_last_cho=zeros(size(CHO));
    a_last_cho=zeros(size(CHO));
    aot_last_cho=zeros(size(CHO));
    for ii=1:length(CHO)
        cho_tmp=CHO(1:ii);
        last=find(cho_tmp,1,'last');
        if ~isempty(last)
            t_last_cho(ii)=ii-last;
            a_last_cho(ii)=cho_tmp(last);
            aot_last_cho(ii)=a_last_cho(ii)/(t_last_cho(ii)+1);
        else
            t_last_cho(ii)=NaN;
            a_last_cho(ii)=NaN;
            aot_last_cho(ii)=NaN;
        end
    end
    X=[X,t_last_cho,a_last_cho,aot_last_cho];
    labels=[labels,{'Time since last CHO'},{'Amount last CHO'},{'Amount/Time last CHO'}];
    
    
    XX = X;
    clear X
    X = XX(start_idx:end,:);
    
else
    Y=patient{(start + PH):end,1};
    timeY=patient.Time((start + PH):end);
    %% Include CGM-related features
    % past CGM
    CGM=patient.CGM(1:(end-PH));
    [X_tmp,labels_tmp]=prova_prepNN(CGM,ord.cgm,start,'CGM');
    X_tmp(X_tmp>=400)=NaN;
    X_tmp(X_tmp<=40)=NaN;
    X=[X,X_tmp];
    labels=[labels,labels_tmp];

    % slope
    slope_CGM=patient.slope(1:(end-PH));
    [X_tmp,labels_tmp]=prova_prepNN(slope_CGM,ord.slope,start,'slope');
    X=[X,X_tmp];
    labels=[labels,labels_tmp];

    % risk indeces
    for ii=start:length(CGM)
        [BGRI(ii-start+1),LBGI(ii-start+1),HBGI(ii-start+1)]=get_risk_index(CGM((ii-start+1):ii));
    end
    X=[X,BGRI',LBGI',HBGI'];
    labels=[labels,{'BGRI'},{'LBGI'},{'HBGI'}];

    %% Include CHO-related features 
    CHO=patient.CHO(start:(end-PH));
    t_last_cho=zeros(size(CHO));
    a_last_cho=zeros(size(CHO));
    aot_last_cho=zeros(size(CHO));
    for ii=1:length(CHO)
        cho_tmp=CHO(1:ii);
        last=find(cho_tmp,1,'last');
        if ~isempty(last)
            t_last_cho(ii)=ii-last;
            a_last_cho(ii)=cho_tmp(last);
            aot_last_cho(ii)=a_last_cho(ii)/(t_last_cho(ii)+1);
        else
            t_last_cho(ii)=NaN;
            a_last_cho(ii)=NaN;
            aot_last_cho(ii)=NaN;
        end
    end
    X=[X,t_last_cho,a_last_cho,aot_last_cho];
    labels=[labels,{'Time since last CHO'},{'Amount last CHO'},{'Amount/Time last CHO'}];

    % %% Include acceleration-related features
    % acl=patient.acceleration(1:(end-PH));
    % [X_tmp,labels_tmp]=prova_prepNN(acl,ord.acl,start,'acceleration');
    % X=[X,X_tmp];
    % labels=[labels,labels_tmp];

    
end


%Y(Y==400)=NaN;
%Y(Y==40)=NaN;


