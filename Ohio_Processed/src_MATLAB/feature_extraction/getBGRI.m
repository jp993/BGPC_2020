function [BGRI, LBGI, HBGI] = getBGRI(BG)
% BGRI

alfa = 1.509;
beta = 1.084;
gamma = 5.381;

% simmetrization of BG variations
f_BG = alfa.*((log(BG).^beta) - gamma ); 
f_BG = real(f_BG);
r_BG = 10.*(f_BG.^2); % vettore di 541 elementi
n_campioni = size(BG,1); % numero di righe di BG

%% --> low blood glucose index (LBGI)
rl_BG = sum(r_BG(f_BG<0));
LBGI_cgm = rl_BG/n_campioni;
% secondo paper Fabris & Breton: match di LBGIcgm con LBGIsmbg (non necessario per HBGI!)
LBGI = LBGI_cgm*1.0199+0.6521; 

%% --> high blood glucose index (HBGI)
rh_BG = sum(r_BG(f_BG>0));
HBGI = rh_BG/n_campioni ;

%% --> Blood Glucose Risk Index (BGRI)
BGRI = LBGI+HBGI;

end