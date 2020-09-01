function fh = Plot_feats_TS(feats,varargin)

p = inputParser;
addOptional(p,'t',[]);
addParameter(p,'fig_h',[],@isfigure);
addParameter(p,'label',[],@isnumeric);
parse(p,varargin{:});

t=p.Results.t;
fh=p.Results.fig_h;
label=p.Results.label;

%% check input
if istable(feats)
    feats=table2struct(feats,'ToScalar',true);
end

%% figure settings
if isempty(fh)
    fh=figure('Color','w');
else
    fh=figure(fh,'Color','w');
end
my_lw=1.5; % line width setting

%% time
if ~isempty(t)
    my_time = datetime(datestr(t));
end

%% plot
hold on
isLabeled = (label > 0);
label_ind = find(label);
% label
if ~isempty(label_ind)
    my_x=label_ind([1 end end 1]);
    f=fill(my_time(my_x),[-2 -2 2 2],'y');
    alpha(f,0.3);
end

feats_list = fieldnames(feats);
N = length(feats_list);
for ind = 1:length(feats_list)
    feat = feats_list{ind};
    x = feats.(feat);
    % subplot the feature
    subplot(N,1,ind)
    if ~isempty(t)
        plot(my_time,x,'r-','LineWidth',my_lw);
        hold on
        x(isLabeled) = nan;
        plot(my_time, x, 'b-', 'LineWidth',my_lw);
    else
        l(ind) = plot(x,'LineWidth',my_lw);
    end
    ylabel(feat)
end

%% link axes
linkaxes(findobj(gcf,'type','axes'),'x');

end

function OK = isfigure(h)
if strcmp(get(h,'type'),'figure')
    OK = 1;
else
    OK = 0;
end
end