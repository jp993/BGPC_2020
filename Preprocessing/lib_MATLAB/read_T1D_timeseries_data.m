function [t,data_Ts,CGM,basal,bolus,meal,CR,CF,OL_basal,label] = read_T1D_timeseries_data(pat_data,fault_scenario)

% check input
check_input(pat_data);

% time
t = pat_data.time;
data_Ts = round(minutes(t(2)-t(1)));

% data
CGM = pat_data.CGM;
basal = pat_data.basal;
bolus = pat_data.bolus;
meal = pat_data.meal;
CR = pat_data.CR;
CF = pat_data.CF;
OL_basal = pat_data.insulin_basal_value;

switch fault_scenario
    case 'basal'
        label = pat_data.fault_basal;
        label = boolean(label)*1;
        
    case 'pump'
        label = pat_data.fault_pump;
        label = boolean(label)*1;
        
    case 'announcement'
        duration_hours = 3;
        duration = duration_hours*60/data_Ts;
        
        x = pat_data.missed_announcement;
        pos = find(x,1,'first');
        
        label = zeros(size(x));
        label(pos:pos+duration) = 1;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_input(input_data)

if ~isa(input_data,'table')
    error('Input must be a table')
end

input_data = table2struct(input_data,'ToScalar',true);

required_fields = {'time','CGM','basal','bolus','meal'};
for ind = 1:length(required_fields)
    f = required_fields{ind};
    if ~isfield(input_data,f)
        error(['Missing field: ' f]);
    end
end

end