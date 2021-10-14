%% set_current_inp
% for human Risk Types study
% handles presentation of stimuli to the model

if t >=1 && t<active_chain_length  % if t is greater than the length of the delay chain, trial is over
    X_jk = X_jk.*0;     % reset delay_chain in order to cleanly insert new indices
    idx_stim = find(D_j_store~=0);
    X_jk(t+active_chain_length.*(idx_stim-1))= 1;                   
    D_j = D_j_store;    
else
    X_jk = X_jk.*0;   % shut off delay chain if it's past the limit
    D_j = 0.*D_j;     % stimuli are shut off
end

D_j_t(t,:) = D_j;