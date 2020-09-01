function attachCRCFBW(patID,version)

    load(fullfile(['ABC' patID],['ABC' patID version]));
    
    BW = nan;
    CR = [];
    CF = nan;
    Gt = nan;
    therapy = "";
    basal = nan(1,1440/5);
    corrected = datevec(now);
    corrected(4:end) = 0;
    switch 'patID'
        case '4001'
            BW = 65;
            CRafter = [10,10,10];
            CRbefore = [10,10,10];
            CF = 18*3;
            therapy = "MDI";
            basal = ones(1,1440/5)*18/24; %U/h
        case '4002'
            BW = 82;
            CRafter = [2, 2, 1.5];
            CRbefore = [2, 2, 1.5];
            CF = 18*2;
            therapy = "MDI";
            basal = ones(1,1440/5)*15/24; %U/h
            basal((12*7+1):(12*19)) = 25/24; %Morning: 25 iu; Evening: 15 iu
        case '4003'
            BW = 73;
            CRafter = [7, 8, 7];
            CRbefore = [7, 8, 7];
            CF = 18*2;
            therapy = "MDI";
            basal = ones(1,1440/5)*20.5/24; %U/h
        case '4004' 
            BW = 91.2;
            CRbefore = [11, 13.5, 12]; %changed 29/01/16
            CRafter = [5, 5, 7];
            corrected(1) = 2016;
            corrected(2) = 1;
            corrected(3) = 29;
            CF = 18*2;
            therapy = "";
            basal = nan(1,1440/5); %NA
        case '4005' 
            BW = 78.6;
            CRbefore = [20, 20, 20];
            CRafter = [20, 20, 20];
            CF = 18*4;
            therapy = "MDI";
            basal = ones(1,1440/5)*12/24; %U/h
        case '4006' 
            BW = 76;
            CRafter = [8, 10, 9];
            CRbefore = [8, 10, 9];
            CF = 18*2.5;
            therapy = "MDI";
            basal = ones(1,1440/5)*16.675/24; %U/h
        case '4007' 
            BW = 93.3;
            CRafter = [5, 8, 9];
            CRbefore = [5, 8, 9];
            CF = 18*2;
            therapy = "MDI";
            basal = ones(1,1440/5)*22/24; %U/h
        case '4008' 
            BW = 49.9;
            CRafter = [10, 9, 10];
            CRbefore = [10, 9, 10];
            CF = 18*4;
            therapy = "MDI";
            basal = ones(1,1440/5)*10.5/24; %U/h
        case '4009' 
            BW = 57.2;
            CRafter = [20, 20, 20];
            CRbefore = [20, 20, 20];
            CF = 18*3.8;
            therapy = "MDI";
            basal = ones(1,1440/5)*9.55/24; %U/h
        case '4010' 
            BW = 89;
            CRafter = [8, 8, 8];
            CRbefore = [8, 8, 8];
            CF = 18*3;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(3*12)) = 0.6; %U/h
            basal((3*12+1):(9*12)) = 1.15; %U/h
            basal((9*12+1):(15*12)) = 0.6; %U/h
            basal((15*12+1):(18*12)) = 0.5; %U/h
            basal((18*12+1):end) = 0.8; %U/h
        case '4011' 
            BW = 105.9;
            CRafter = [6, 6, 6];
            CRbefore = [6, 6, 6];
            CF = 18*1.7;
            therapy = "MDI";
            basal = ones(1,1440/5)*33/24; %U/h
        case '4012' 
            BW = 65;
            CRafter = [10, 10, 10];
            CRbefore = [10, 10, 10];
            CF = 18*2.5;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(7*12)) = 0.7; %U/h
            basal((7*12+1):(11*12)) = 1; %U/h
            basal((11*12+1):(16*12)) = 0.875; %U/h
            basal((16*12+1):(21*12)) = 0.675; %U/h
            basal((21*12+1):end) = 0.5; %U/h
        case '4013' 
            BW = 65.5;
            CRbefore = [10, 9, 10]; %changed 24/02/16
            CRafter = [10, 12, 10];
            corrected(1) = 2016;
            corrected(2) = 2;
            corrected(3) = 24;
            CF = 18*10;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(2*12)) = 0.9; %U/h
            basal((2*12+1):(5*12)) = 0.8; %U/h
            basal((5*12+1):(8*12)) = 0.7; %U/h
            basal((8*12+1):(15*12)) = 0.8; %U/h
            basal((15*12+1):(22*12)) = 0.9; %U/h
            basal((22*12+1):end) = 0.8; %U/h
        case '4014' 
            BW = 86.1;
            CRbefore = [9, 9,9 ];
            CRafter = [9, 9,9 ];
            CF = 18*3;
            therapy = "MDI";
            basal = ones(1,1440/5)*16.025/24; %U/h
        case '4015' 
            BW = 71.2;
            CRafter = [5, 5, 5];
            CRbefore = [5, 5, 5];
            CF = nan; %NA
            therapy = "MDI";
            basal = ones(1,1440/5)*32/24; %U/h
        case '4016' 
            BW = 66.7;
            CRafter = [10, 8, 10];
            CRbefore = [10, 8, 10];
            CF = 18*4;
            therapy = "MDI";
            basal = ones(1,1440/5)*18.675/24; %U/h
        case '4017' 
            BW = 70.6;
            CRafter = [8.5, 8.5, 7.5];
            CRbefore = [8.5, 8.5, 7.5];
            CF = 18*4;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(6*12)) = 0.575; %U/h
            basal((6*12+1):(11*12)) = 0.950; %U/h
            basal((11*12+1):(13*12)) = 0.8; %U/h
            basal((13*12+1):(16*12)) = 0.575; %U/h
            basal((16*12+1):(20*12)) = 0.950; %U/h
            basal((20*12+1):end) = 0.875; %U/h
        case '4018' 
            BW = 76.6;
            CRafter = [6, 7, 7.3];
            CRbefore = [6, 7, 7.3];
            CF = 18*2.8;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(1*12)) = 0.44; %U/h
            basal((1*12+1):(2*12)) = 0.48; %U/h
            basal((2*12+1):(3*12)) = 0.55; %U/h
            basal((3*12+1):(4*12)) = 0.67; %U/h
            basal((4*12+1):(5*12)) = 0.69; %U/h
            basal((5*12+1):(6*12)) = 0.68; %U/h
            basal((6*12+1):(7*12)) = 0.66; %U/h
            basal((7*12+1):(8*12)) = 0.73; %U/h
            basal((8*12+1):(9*12)) = 0.9; %U/h
            basal((9*12+1):(10*12)) = 0.98; %U/h
            basal((10*12+1):(11*12)) = 0.68; %U/h
            basal((11*12+1):(12*12)) = 0.57; %U/h
            basal((12*12+1):(13*12)) = 0.48; %U/h
            basal((13*12+1):(14*12)) = 0.46; %U/h
            basal((14*12+1):(15*12)) = 0.4; %U/h
            basal((15*12+1):(16*12)) = 0.46; %U/h
            basal((16*12+1):(17*12)) = 0.55; %U/h
            basal((17*12+1):(18*12)) = 0.63; %U/h
            basal((18*12+1):(19*12)) = 0.67; %U/h
            basal((19*12+1):(20*12)) = 0.61; %U/h
            basal((20*12+1):(21*12)) = 0.55; %U/h
            basal((21*12+1):(22*12)) = 0.48; %U/h
            basal((22*12+1):(23*12)) = 0.46; %U/h
            basal((23*12+1):end) = 0.44; %U/h
        case '4019' 
            BW = 60.2;
            CR = [];
            CF = 18*5;
            therapy = "MDI";
            basal = ones(1,1440/5)*40/24; %U/h
        case '4020' 
            BW = 79;
            CRafter = [15, 15, 15];
            CRbefore = [6, 7, 7.3];
            CF = 18*5.9;
            therapy = "MDI";
            basal = ones(1,1440/5)*18.053/24; %U/h
        case '4021' 
            BW = 65.2;
            CR = [3, 3, 3];
            CF = 18*3;
            therapy = "MDI";
            basal = ones(1,1440/5)*15/24;
        case '4022' 
            BW = 92.3;
            CRafter = [10, 10, 10];
            CRbefore = [10, 10, 10];
            CF = 18*1.5;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(4*12)) = 1.4; %U/h
            basal((4*12+1):(5*12)) = 1.5; %U/h
            basal((5*12+1):(7*12)) = 1.6; %U/h
            basal((7*12+1):(16*12)) = 1.7; %U/h
            basal((16*12+1):end) = 1.9; %U/h
        case '4023' 
            BW = 87.6;
            CRafter = [5, 5, 6];
            CRbefore = [5, 5, 6];
            CF = 18*2;
            therapy = "CSII";
            basal = ones(1,1440/5); %U/h
            basal((1):(1*12)) = 1.28; %U/h
            basal((1*12+1):(2*12)) = 1.4; %U/h
            basal((2*12+1):(3*12)) = 1.57; %U/h
            basal((3*12+1):(4*12)) = 1.83; %U/h
            basal((4*12+1):(5*12)) = 2.13; %U/h
            basal((5*12+1):(6*12)) = 2.42; %U/h
            basal((6*12+1):(7*12)) = 2.37; %U/h
            basal((7*12+1):(8*12)) = 2.08; %U/h
            basal((8*12+1):(9*12)) = 1.76; %U/h
            basal((9*12+1):(10*12)) = 1.53; %U/h
            basal((10*12+1):(11*12)) = 1.42; %U/h
            basal((11*12+1):(12*12)) = 1.38; %U/h
            basal((12*12+1):(13*12)) = 1.36; %U/h
            basal((13*12+1):(14*12)) = 1.38; %U/h
            basal((14*12+1):(15*12)) = 1.45; %U/h
            basal((15*12+1):(16*12)) = 1.6; %U/h
            basal((16*12+1):(17*12)) = 1.81; %U/h
            basal((17*12+1):(18*12)) = 1,92; %U/h
            basal((18*12+1):(19*12)) = 1.86; %U/h
            basal((19*12+1):(20*12)) = 1.69; %U/h
            basal((20*12+1):(21*12)) = 1.53; %U/h
            basal((21*12+1):(22*12)) = 1.41; %U/h
            basal((22*12+1):(23*12)) = 1.32; %U/h
            basal((23*12+1):end) = 1.23; %U/h
        case '4024' 
            BW = 59.7;
            CRafter = [10, 10, 10];
            CRbefore = [10, 10, 10];
            CF = 18*3;
            therapy = "MDI";
            basal = ones(1,1440/5)*19.4/24;
        case '4025' 
            BW = 54.4;
            CRafter = [10, 10, 12];
            CRbefore = [10, 10, 12];
            CF = [18*3, 18*4]; %from 0 to 5, rest of the day
            therapy = "MDI";
            basal = ones(1,1440/5)*38/24;
        case '4026'    
            BW = 61.9;
            CRafter = [11, 17, 14];
            CRbefore = [11, 17, 14];
            CF = 18*4.5;
            therapy = "MDI";
            basal = ones(1,1440/5)*24.39/24;
        otherwise
            BW = nan;
            CR = [];
            CF = nan;
            therapy = "";
            basal = nan(1,1440/5);
    end
    
    
    %%Bolus: change name
    logBook.Bolus = logBook.Insulin;
    logBook.Insulin = [];
    
    %%Bolus label: change name
    logBook.BolusLabel = logBook.insulinLabel;
    logBook.insulinLabel = [];
    
    %%CHO label: change name
    logBook.ChoLabel = logBook.choLabel;
    logBook.choLabel = [];
    
    %%Basal
    logBook.Basal = repmat(basal',height(logBook)/288,1)
    
    patientInfo.therapy = therapy;
    
    
    save(fullfile(['ABC' patID],['ABC' patID '_final_withCRCFBW']),'CGM','logBook','patientInfo');
    
    
end