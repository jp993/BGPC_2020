function [train_data, test_data] = iddata_split(my_data, time, train_days, test_days)
%
% Divide dataset into training and testing set
%
% my_dataset: cell array of iddata (time unit must be expressed in days)
%


% time
my_time = datenum(time);
% normalize time from starting day
my_time = my_time - my_time(1);
% total days
tot_days = my_time(end) - my_time(1);
% check if there are enough days as required
if train_days+test_days > floor(tot_days)
    error('Dataset length (%g days) is shorter than required days (%g+%g)',tot_days,train_days,test_days)
end
% training portion
[~,train_end_ind] = min(abs(my_time-train_days));
train_time_length = my_time(train_end_ind);
if train_days-train_time_length > 1/24 % shorter for more than 1 hour
    warning('training portion is shorter than required')
end
% testing portion
if test_days>0
    test_time_start = my_time(train_end_ind+1);
    test_time_length = tot_days-test_time_start;
    if test_days-test_time_length>1/24 % shorter for more than 1 hour
        warning('testing portion is shorter than required')
    end
else
    test_time_length = 0;
end
% check total length
if tot_days - (train_time_length+test_time_length) > 1/24
    warning('Dataset is longer than required, placing extra portion in testing set')
end
% save training and testing data
train_data = my_data(1:train_end_ind,:,:);
try
    test_data = my_data(train_end_ind+1:end,:,:);
catch outOfBounds
    test_data = [];
end

% train_data.SamplingInstants = datenum(time(1:train_end_ind));
% train_data.TimeUnit = 'days';
% 
% test_data.SamplingInstants = datenum(time(train_end_ind+1:end));
% test_data.TimeUnit = 'days';

end
