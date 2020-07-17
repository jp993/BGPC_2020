function hasEnoughMeals = has_enough_meals(meal, time, min_meals_per_day)
% find out if there are enough meals

% how many days?
n_days = days(time(end) - time(1));

% how many meals?
n_meals = length(find(meal));

% are they enough?
if n_meals < n_days*min_meals_per_day
    hasEnoughMeals = 0;
else
    hasEnoughMeals = 1;
end
