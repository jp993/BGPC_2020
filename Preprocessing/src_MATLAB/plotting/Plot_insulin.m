function fh = Plot_insulin(t,basal,bolus,pie,scie,varargin)

p = inputParser;
addParameter(p,'fig_h',[],@isfigure);
addParameter(p,'label',[],@isnumeric);
parse(p,varargin{:});

fh=p.Results.fig_h;
label=p.Results.label;

%% figure settings
if isempty(fh)
    fh=figure('Color','w');
else
    fh=figure(fh,'Color','w');
end
my_line_width=1.5;

%% time
data_Ts = round(minutes(t(2)-t(1)));
% data_Ts = round(data_Ts*60*24);
my_time = datetime(datestr(t));

%% plot
hold on

label_ind=find(label);
% label
if ~isempty(label_ind)
    my_x=label_ind([1 end end 1]);
    f=fill(my_time(my_x),[40 40 400 400],'y');
    alpha(f,0.3);
end

plot(my_time,basal*60,'k','Linewidth',my_line_width)
plot(my_time,bolus*data_Ts,'b','Linewidth',my_line_width)
plot(my_time,pie,'r','Linewidth',my_line_width)
plot(my_time,scie,'g','Linewidth',my_line_width)
legend('basal (U/h)','bolus (U)','PIE (U)','SCIE (U)')

end


function OK = isfigure(h)
if strcmp(get(h,'type'),'figure')
    OK = 1;
else
    OK = 0;
end
end