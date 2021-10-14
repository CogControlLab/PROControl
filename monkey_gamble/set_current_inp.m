%% set_current_inp.m 
% handles presentation of stimuli to the model

if t >=1 && t<=active_chain_length  % if t is greater than the length of the delay chain, trial is over
    X_jk = X_jk.*0;     % reset delay_chain in order to cleanly insert new indices
    idx_stim = find(D_j_store~=0);
    X_jk(t+active_chain_length.*(idx_stim-1))= 1;                   
    D_j = D_j_store; 

    % for visualization
    X_jk_t(t,:) = X_jk.*0;
    X_jk_t(t,t+active_chain_length.*(idx_stim-1))= 1;
    D_j_t(t,:) = D_j;
else
    X_jk = X_jk.*0;   % shut off delay chain if it's past the limit
    D_j = 0.*D_j;     % stimuli are shut off
    
    % for visualization
    X_jk_t(t,:) = X_jk.*0;
    D_j_t(t,:) = D_j;
end

if t>maxResp_time/dt % force reveal of outcome X ms after choice
    resp_sig = 1;
    resp_sig_t(t) = resp_sig;
else
    resp_sig = 0;
    resp_sig_t(t) = resp_sig;
end                           