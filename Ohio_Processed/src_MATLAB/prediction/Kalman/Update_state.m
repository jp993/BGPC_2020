function [X_smart_t1_t1,P_smart_t1_t1,X_backup_t1_t1,P_backup_t1_t1,R_t1,FD_status,debug] = ...
    Update_state(y_t1,u_t1,X_canon_t1_t,P_canon_t1_t,X_smart_t1_t,P_smart_t1_t,R,found_a_fault,FD_status,FD_settings,model)

%% Canonical update
[X_backup_t1_t1,P_backup_t1_t1,debug] = Kalman_filtering_step(u_t1,y_t1,X_canon_t1_t,P_canon_t1_t,R,model);

%% Algorithm update

if found_a_fault
    
    % =================================== WE JUST FOUND A FAULT =============================================
    
    % increase fault counter
    FD_status.fault_counter=FD_status.fault_counter+1;
    
    % DO WE STILL TRUST OUR PREDICTION? (fault counter > N ?)
    too_many_consecutive_faults=(FD_status.fault_counter > FD_settings.n_faulty_samples_th);
    
    if too_many_consecutive_faults
        % ===================== WE DON'T TRUST OUR MODEL PREDICTION ANYMORE =========================
        % We put trust back on our measurements
        R_t1=R;
        % Reset fault counter
        FD_status.fault_counter=0;
        % Mark a reset event
        FD_status.filter_white_flag=1;
        
        % FILTERING STEP: restart filter using backup
        X_smart_t1_t1=X_backup_t1_t1;
        P_smart_t1_t1=P_backup_t1_t1;
    else
        % ========================= WE STILL TRUST OUR MODEL PREDICTION =========================
        % We don't trust our measurements
        R_t1=R*100000;
        
        % FILTERING STEP: we use R(t)
        [X_smart_t1_t1,P_smart_t1_t1,debug] = Kalman_filtering_step(u_t1,y_t1,X_smart_t1_t,P_smart_t1_t,R_t1,model);
    end
    
else
    % ============================== NO FAULT ENCOUNTERED ====================================================
    % We trust our measurements
    R_t1=R;
    
    % Reset fault counter
    FD_status.fault_counter=0;
    
    % FILTERING STEP: we use R normal
    [X_smart_t1_t1,P_smart_t1_t1,debug] = Kalman_filtering_step(u_t1,y_t1,X_smart_t1_t,P_smart_t1_t,R,model);
end

end

