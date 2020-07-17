function isCorrection = find_correction_bolus(meal, bolus, TMAX, Ts)
%
% meal: array with meals
% bolus: array with insulin bolus
% TMAX: maximum time from last meal to be correction (mins)
% Ts: sampling time (mins)

isMeal = (meal > 0);
isBolus = (bolus > 0);
isBolusWithoutMeal = (isMeal - isBolus) == -1;

% calculate time from last meal in every bolus without a meal
t_from_last_meal = zeros(length(bolus), 1);
meal_pos = find(isMeal);
correction_pos = find(isBolusWithoutMeal);
for j = correction_pos(:)'
    % time from all meals
    dist_from_meals = j - meal_pos;
    dist_from_meals = dist_from_meals(dist_from_meals>=0); % remove future meals
    % time from the closest meal
    x = min(dist_from_meals);
    if isempty(x)
        x = 0;
    end
    t_from_last_meal(j,1) = x * Ts;
end

% is a corrective bolus if it's at least TMAX min away from last meal
isCorrection = (t_from_last_meal >= TMAX)*1;



