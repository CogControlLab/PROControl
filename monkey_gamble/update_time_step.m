%% Update the time steps


elig_trace_jk = X_jk + 0.95*elig_trace_jk;
V_i = X_jk*U_ijk';      % Get the vector temporal prediction for this time step
S_i = D_j*W_S_ij;       % Get prediction of RO conjunctions

% 10/10/19 - for visualization over t
elig_trace_jk_t(t,:) = X_jk + 0.95*elig_trace_jk;   
V_i_t(t,:) =  X_jk*U_ijk';
S_i_t(t,:) = D_j*W_S_ij;

% Check for response occurrence
if (max(C_n)>threshold && response_flag==0) || (resp_sig && response_flag==0)
    %% then interpret the response
    response_flag = 1;   % We have a response!
    learn_flag = 1;     % and we should start learning something
    output = find(C_n==max(C_n));   % What response did we make?

    if length(output)==2 
        output = find(EV==max(EV));   % correction: if same C, assume choice is for higher EV option
        if length(output)==2
            output = randi(2);        % correction: if still same, randomly choose option
        end
    end     

    act_out(output) = 1;  % register which output actually occurred.
    reaction_time = t;             % keeps track of reaction time

        % 10/10/19 - for visualization
        response_flag_t(t) = 1;

end

% outcome is revealed after 750ms after decision (anticipatory period)
if response_flag && t==(reaction_time+outDelay_spec/dt)
    outcome_flag = 1;
    outcome_time = t;
end
if response_flag && outcome_flag %t>=(reaction_time+outDelay_spec/dt)
    obtained_outcome = gamble_results(output);
    unobtained_outcome = unobtained_outcomes(output);
    tok_idx = obtained_outcome + 3;
    act_idx_start = outN*(output-1) + (tok_idx-1)*(numbin-overlapbin) + 1;
    O_i(act_idx_start:act_idx_start+numbin-1) = activ;    % 12 possible outcomes
    idx_count = 0; % set count to 0 to indicate beginning of outcome presentation to model.  

    O_i_t(t,:) = O_i;
    count_t(t) = 0;
end

% outcomes are interpreted as lasting 20 model iterations (200ms)  
if idx_count < 20        
    r_i = O_i/div_r_i; 
    on = 1;
    r_i_t(t,:) = O_i/div_r_i; 
else
    r_i = O_i.*0;
    on = 0;
    r_i_t(t,:) = O_i.*0;    % 10/10/19
end

delta_i = r_i + gammaTD*V_i - prev_V_i;    % Get TD prediction error, delta (Eq.7)
U_ijk = U_ijk + alphaTD*delta_i'*prev_elig_trace;   % Update temporal prediction weights, U (Eq. 9)
U_ijk(U_ijk<0) = 0; % Rectify: no prediction weights under 0; 

% Divide signal into positive and negative components
omegaP = r_i*on - V_i; % Eq.15
omegaP_nonzero = omegaP + w_baseline; %7/7/15 JWB -- add a constant
omegaN = V_i - O_i*on;  % Eq.16

omegaP(omegaP<0) = 0;   % Rectify negative components
omegaN(omegaN<0) = 0;   
omegaP_nonzero(omegaP_nonzero<0) = 0;


    % for visualization
    delta_i_t(t,:) = r_i + gammaTD*V_i - prev_V_i;
    omegaP_time(t,:) = r_i*on - V_i;   
    omegaP_nonzero_time(t,:) = w_baseline + (r_i*on - V_i);
    omegaN_time(t,:) = w_baseline + V_i - r_i*on;
    % Rectify negative components
    omegaP_time(omegaP_time<0) = 0;
    omegaP_nonzero_time(omegaP_nonzero_time<0) = 0;
    omegaN_time(omegaN_time<0) = 0;


% Prepare for the next trial iteration
% calculate excitatory and inhibitory input to control units
P_i = sigact(S_i);
P_i_t(t,:) = P_i;
cont_sig_neg = -min([sum(P_i(1:outN)), sum(P_i(outN+1:end))]*W_F_ni + gamm, 0);
cont_sig_pos = max([sum(P_i(1:outN)), sum(P_i(outN+1:end))]*W_F_ni - gamm, 0);

E_i = rho*(D_j*W_C_ij + cont_sig_neg);        % net excitation to response units (Eq. 12)
I_i = psi*(C_n*W_I_ij) + phi*(cont_sig_pos);  % net inhibition to response units (Eq. 13)

% Update response unit activities 
C_n = C_n + (rate_param)*rate*dt*((1-C_n).*E_i-(C_n+0.05).*(I_i+1)) + randn(1,respN)*noise*sqrt(rate_param)*(noise_factor);   % (Eq. 11)
C_n(C_n<0) = 0;             % Rectify negative elements
omegaN_cat(:,t+1) = omegaN';
omegaP_cat(:,t+1) = omegaP';
omegaP_nonzero_cat(:,t+1) = omegaP_nonzero';    % revised model
C_n_t(t,:) = C_n;

% temporary debugging:
if 0
    tmp1 = size(omegaP_nonzero_cat) - size(omegaP_cat);
    if sum(tmp1.^2) > 0
        error('size mismatch in variables!'); 
    end
    tmp2 = size(omegaN_nonzero_cat) - size(omegaN_cat);
    if sum(tmp2.^2) > 0
        error('size mismatch in variables!'); 
    end
 end

% bookkeeping for TD model (t)
prev_V_i = V_i;
prev_X_jk = X_jk;
prev_elig_trace = elig_trace_jk;
idx_count = idx_count + 1;  
count_t(t+1) = count_t(t) + 1;
