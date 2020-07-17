function action = getExerciseAction(time,exercise)
    
    action = zeros(length(time),1);
    tau = 50;
    for t = 1:length(time)
        
        idxEvents = find(exercise(1:t));
        for e = 1:length(idxEvents)
            idx = idxEvents(e);
            action(t) = action(t) + exercise(idx)*exp( - minutes(time(t)-time(idx)) / tau); 
        end
        
    end

end