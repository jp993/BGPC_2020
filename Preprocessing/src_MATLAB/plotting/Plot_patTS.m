function fh = Plot_patTS(pat_data,varargin)

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
data_Ts = round(minutes(pat_data.time(2)-pat_data.time(1)));
data_Ts=round(data_Ts*60*24);
my_time=datetime(datestr(pat_data.time));

%% data
CGM=pat_data.CGM;
basal=pat_data.basal;
bolus=pat_data.bolus;
meal=pat_data.meal;

%% plot CGM
label_ind=find(label);
subplot(311)
hold on
% fault
if ~isempty(label_ind)
    my_x=label_ind([1 end end 1]);
    f=fill(my_time(my_x),[40 40 400 400],'y');
    alpha(f,0.3);
end
% CGM
plot(my_time,CGM,'b','Linewidth',my_line_width)
% settings
ylim([40 400]);
ylabel('CGM [mg/dL]');
if ~isempty(label_ind)
    legend('label','CGM')
else
    %
end

%% plot insulin
subplot(312)
hold on
plot(my_time,basal*60,'k','Linewidth',my_line_width)
plot(my_time,bolus*data_Ts,'b','Linewidth',my_line_width)
legend('basal (U/h)','bolus (U)')
ylabel('insulin [U/min]')

%% plot meal
subplot(313)
hold on
plot(my_time,meal*data_Ts,'r','Linewidth',my_line_width)
ylabel('meal [g]')

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