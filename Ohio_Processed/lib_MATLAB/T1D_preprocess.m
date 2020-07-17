classdef T1D_preprocess < handle
    % Preprocessing of patient data for model identification, using specified method
    %
    % preprocess_method:
    % 'mean_scale':         subtract mean
    % 'input_transf':       transforms insulin using CR
    %
    % use_meals: use meals data or not
    
    properties
        preprocess_method
        CGM_mean
        insulin_mean
        meal_mean
        
        use_meals
    end
    
    methods
        
        function obj = T1D_preprocess(preprocess_method, use_meals)
            obj.preprocess_method = preprocess_method;
            obj.use_meals = use_meals;
        end
        
        function fit(obj, CGM, insulin, meal)
            % save mean for CGM and meals
            obj.CGM_mean = get_mean(CGM);
            obj.meal_mean = get_mean(meal);
            % custom preprocess method for insulin
            switch obj.preprocess_method
                case 'mean_scale'
                    obj.insulin_mean = get_mean(insulin);
                case 'input_transf'
                    obj.insulin_mean = 0;
            end
        end
        
        function [Y, I, M] = fit_transform(obj, CGM, insulin, meal, CR, nominal_insulin)
            obj.fit(CGM, insulin, meal);
            [Y, I, M] = obj.transform(CGM, insulin, meal, CR, nominal_insulin);
        end
        
        function [Y, I, M] = transform(obj, CGM, insulin, meal, CR, nominal_insulin)
            if ~obj.use_meals
                meal = zeros(size(meal));
            end
            Y = CGM - obj.CGM_mean;
            M = meal - obj.meal_mean;
            switch obj.preprocess_method
                case 'mean_scale'
                    I = insulin - obj.insulin_mean;
                case 'input_transf'
                    I = insulin - nominal_insulin + (meal./CR);
            end
        end
        
    end
    
end

function m = get_mean(y)
if any(isnan(y))
    m = nanmean(y);
else
    m = mean(y);
end
end