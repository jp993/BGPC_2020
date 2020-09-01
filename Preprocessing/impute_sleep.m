function sleep = impute_sleep(patient)
    for i = 1:288:length(patient.Time)
        first_day = datevec(patient.Time(i));
        second_day = datevec(patient.Time(i)+day(1));
        first_day(4) = 23;
        second_day(4) = 23;
        second_day(4) = 5;
        second_day(5) = 0;
        first_day(5) = 0;

        first_day = datetime(first_day);
        second_day = datetime(second_day);
        idx_first = find(patient.Time == first_day);
        if(isempty(idx_first))
            idx_first = 1;
        end
        idx_second = find(patient.Time == second_day);
        if(isempty(idx_second))
            idx_second = length(patient.Time);
        end

        if(sum(patient.sleep(idx_first:idx_second)) == 0)
            patient.sleep(idx_first:idx_second) = 1;
        end
    end
    
    sleep = patient.sleep;
end