function fh = Plot_feats_scatter(feats,label,varargin)

p = inputParser;
addParameter(p,'fig_h',[],@isfigure);
parse(p,varargin{:});

fh=p.Results.fig_h;

%% check input
if isstruct(feats)
    feats=struct2table(feats);
end

%% figure settings
if isempty(fh)
    fh=figure('Color','w');
else
    fh=figure(fh,'Color','w');
end


%% plot
col='rb';
mySymbol='x.';

feats_mat=table2array(feats);
names=fieldnames(table2struct(feats));

mySize=6;
doLegend='off';
dispOpt='grpbars'; % none | hist | stairs | grpbars
gplotmatrix(feats_mat,[],[label ~label],...
    col,mySymbol,mySize,doLegend,dispOpt,names)

end

function OK = isfigure(h)
if strcmp(get(h,'type'),'figure')
    OK = 1;
else
    OK = 0;
end
end