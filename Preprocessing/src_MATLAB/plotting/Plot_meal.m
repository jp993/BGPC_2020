function fh = Plot_meal(t,meal,pcho,cob,varargin)

p = inputParser;
addParameter(p,'fig_h',[],@isfigure);
addParameter(p,'label',[],@isnumeric);
parse(p,varargin{:});

fh=p.Results.fig_h;
label=p.Results.label;

%% figure settings
if isempty(fh)
    fh=figure;
else
    fh=figure(fh);
end
my_line_width=1.5;

%% time
data_Ts = minutes(t(2)-t(1));
my_time = datetime(datestr(t));

%% plot
hold on

label_ind = find(label);
% label
if ~isempty(label_ind)
    my_x=label_ind([1 end end 1]);
    f = fill(my_time(my_x),[40 40 400 400],'y');
    alpha(f,0.3);
end

hold on
plot(my_time,meal*data_Ts,'b','Linewidth',my_line_width)
plot(my_time,pcho,'r','Linewidth',my_line_width)
plot(my_time,cob,'g','Linewidth',my_line_width)
legend('meal (g)','PCHO (g)','COB (g)')

end


function OK = isfigure(h)
if strcmp(get(h,'type'),'figure')
    OK = 1;
else
    OK = 0;
end
end