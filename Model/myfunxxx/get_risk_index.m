function [BGRI, LBGI, HBGI] = get_risk_index(BG)

    alpha = 1.084;
    beta = 5.381;
    gamma = 1.509;
    
    % Standard risk function
    f_BG=gamma*((log(BG).^alpha)-beta);
    
    % Standard risk function
    r_BG=10*(f_BG.^2);
    
    n=size(BG,1);   %numero di righe di BG
    
    % LBGI (Low Blood Glucose Index)
    rl_BG=sum(r_BG(f_BG<0));
    LBGI=rl_BG/n;
    
    % HBGI (High Blood Glucose Index)
    rh_BG=sum(r_BG(f_BG>0));
    HBGI=rh_BG/n;
    
    % BGRI (Blood Glucose Risk Index)
    BGRI=LBGI+HBGI;
    
end