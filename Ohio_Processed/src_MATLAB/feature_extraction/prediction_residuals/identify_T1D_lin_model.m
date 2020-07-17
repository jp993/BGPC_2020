function [my_model, preprocesser] = identify_T1D_lin_model(t, CGM, insulin, meal, CR, OL_basal, varargin)
% Identify linear model using CGM, insulin and meal info

n_days = floor(days(t(end)-t(1)));

p = inputParser;
addParameter(p,'train_days',n_days,@isnumeric)
addParameter(p,'delay',[45 15],@isnumeric)
addParameter(p,'model_type','armax')
addParameter(p,'model_order',[])
parse(p,varargin{:})
train_days = p.Results.train_days;
delay = p.Results.delay;
model_type = p.Results.model_type;

% sampling time
Ts = minutes(t(2)-t(1));

% train and test divide
TT = timetable(t, CGM, insulin, meal, CR, OL_basal);
train_range = timerange(TT.t(1), TT.t(1)+days(train_days)+seconds(1));
train_data = TT(train_range, :);
% test_range = timerange(TT.t(1)+days(train_days)+minutes(1), TT.t(end)+seconds(1));
% test_data = TT(test_range, :);

% find out if there are enough meals
minimum_meals_per_day = 2.5;
n_days = train_data.t(end) - train_data.t(1);
n_meals = length(find(train_data.meal));
if n_meals < n_days*minimum_meals_per_day
    use_meals = 0;
else
    use_meals = 1;
end

% preprocess data
preprocesser = T1D_preprocess('input_transf', use_meals);
[Y_train, I_train, M_train] = preprocesser.fit_transform(train_data.CGM, train_data.insulin, train_data.meal, train_data.CR, train_data.OL_basal);

% make iddata
proc_data = iddata(Y_train, [I_train, M_train], Ts);
proc_data.TimeUnit = 'minutes';

% solve missing values
if isnan(proc_data)
    warning off
    proc_data = misdata(proc_data);
    warning on
end

% identify models
initial_condition = 'z';
delay = delay/Ts;
my_model = my_lin_model_(proc_data, model_type, ...
    'model_order',[],'InitialCondition',initial_condition,'delay',delay);

% figure
% impulse(my_model)

end


%%
function model = my_lin_model_(my_data, model_type, varargin)
%
% identify a linear model with Prediction Error Method (PEM) or State-Space method
% (N4SID)
%
% my_data: iddata
% model_type: {'arx','armax','bj','pem'}
%
% orders: (...) TODO

N_inputs = size(my_data.InputData,2);

p = inputParser;
addParameter(p,'InitialCondition','e',@ischar)
addParameter(p,'delay',zeros(1,N_inputs),@isnumeric)
addParameter(p,'model_order',[])
parse(p,varargin{:})
initial_condition = p.Results.InitialCondition;
delay = p.Results.delay;
model_order = p.Results.model_order;

if isempty(model_order)
    switch model_type
        case 'arx'
            model_order = 9;
        case 'armax'
            model_order = 7;
        case 'bj'
            model_order = 5;
        case 'pem'
            model_order = 7;
    end
end

if length(delay) ~= N_inputs
    error('Delay values must match number of inputs')
end

% identification per model type
switch model_type
    case 'arx'
        opt = arxOptions('InitialCondition', initial_condition);
        orders = ar_arma_bj_order(model_order, N_inputs, delay, 'arx');
        model = arx(my_data, orders, opt);
    case 'armax'
        opt = armaxOptions('InitialCondition', initial_condition);
        orders = ar_arma_bj_order(model_order, N_inputs, delay, 'armax');
        model = armax(my_data, orders, opt);
    case 'bj'
        opt = bjOptions('InitialCondition', initial_condition);
        orders = ar_arma_bj_order(model_order, N_inputs, delay, 'bj');
        model = bj(my_data, orders, opt);
    case 'pem'
        options = n4sidOptions('InitialState',initial_condition);
        tmp_model = n4sid(my_data,model_order,'InputDelay',delay,options);
        opt_pem = ssestOptions('InitialState',initial_condition);
        model = pem(tmp_model,my_data,opt_pem);
    otherwise
        error('allowed models: arx, armax, bj, pem')
end
% convert to idss
model = idss(model);
end

function orders = ar_arma_bj_order(N, N_inputs, delay, model_type)
switch model_type
    case 'arx'
        orders = N*ones(1,(N_inputs+1));
        orders(1) = orders(1)+1;
    case 'armax'
        orders = N*ones(1,(N_inputs+2));
        orders([1 end]) = orders([1 end]) + 1;
    case 'bj'
        orders = N*ones(1,(2*N_inputs + 2));
        orders(N_inputs+1:end) = orders(N_inputs+1:end)+1;
end
orders = [orders delay];
end



