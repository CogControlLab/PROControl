%% Update the time steps

elig_trace_jk = X_jk + 0.95*elig_trace_jk;
V_i = X_jk*U_ijk';      % Get the vector temporal prediction for this time step
S_i = D_j*W_S_ij;       % Get prediction of RO conjunctions  
S_i(S_i<0) = 0;

% for visualization over t
S_i_t(t,:) = S_i;

% Check for response occurrence
if C_n(1)~=C_n(2) && max(C_n)>threshold && response_flag==0
    %% then interpret the response
    response_flag = 1;              % We have a response!
    info_shown = 1;
    output = find(C_n==max(C_n));   % What response did we make?     [G=1 ST=2]
    chosen_option(n) = output;
    gambdata{gambleOption}.chosen(block) = output;
    act_out(output) = 1;            % register which output actually occurred
    reaction_time = t;              % keeps track of reaction time
    outcome_time = reaction_time + outDelay_spec/dt ;   % outcome delayed for 2000ms
    obtained_outcome_array(n) = obtainable(output);     % store obtained outcome
    output_array(n) = output;

end

% force choice if the control doesn't go over threshold
if t>maxResp_time/dt && response_flag==0
    response_flag = 1;            % We have a response!
    info_shown = 1;
    output = find(C_n==max(C_n)); % What response did we make?     [G=1 ST=2]
    if length(output)==2
       output = randperm(2,1);
    end
    chosen_option(n) = output;
    gambdata{gambleOption}.chosen(block) = output;
    act_out(output) = 1;  % register which output actually occurred
    reaction_time = t;             % keeps track of reaction time
    outcome_time = reaction_time + outDelay_spec/dt ;   % outcome delayed for 2000ms
    obtained_outcome_array(n) = obtainable(output); % store obtained outcome
end

% Reveal outcome 2000ms after choice response
if response_flag
    if t>outcome_time
        learn_flag = 1;     % and we should start learning something
        reveal_sig = 1;
        % specify outcome
        if output==1        % Gamble chosen
            [activated,activities] = lognormal_generate(tokens(selected),unitgap);
            O_gamb = zeros(1,unitN);
            O_gamb(ismember(units,activated)) = activities*1; % multiply by '1' instead of Probs
            O_i(1:unitN) = O_gamb;              
        elseif output==2    % ST chosen
            O_i(unitN+1:stimN) = (D_ST);   % use stored D_ST value
        end
        idx_count = 0; % set count to 0 to indicate beginning of outcome presentation to model.

        % give feedback: set valence and risk_learn parameter 'theta'
        current_tok = [sign(tokens).*log(abs(tokens)+2), sign(ST)*log(abs(ST)+2)];
        outcome_log = sign(obtainable(output))*log(abs(obtainable(output))+2);
        Y = (outcome_log-min(current_tok))/(max(current_tok)-min(current_tok));
        Y = -(2*Y - 1)/Y_won_div;  % normalized into [-0.1, +0.1] [-0.1, 1]

if obtainable(output)<0
    Y = Y*Y_won_div/Y_lost_div;
end
if output==2; Y = Y*Y_won_div/Y_ST_div; end
        

    else    % no reveal if 2sec has not yet passed
        reveal_sig = 0;
    end
end

% outcomes are interpreted as lasting 20 model iterations (200ms)  
if idx_count < outcome_last        
    r_i = O_i/outcome_last;
    on = 1;
else
    r_i = O_i.*0;
    on = 0;
end

% Get TD prediction error, delta (Eq.7)
delta_i = r_i + gammaTD*V_i - prev_V_i;   
U_ijk = U_ijk + alphaTD*delta_i'*prev_elig_trace;   % Update temporal prediction weights, U (Eq. 9)
U_ijk(U_ijk<0) = 0;         % Rectify: no prediction weights under 0

% Divide signal into positive and negative components
omegaP = r_i*on - V_i; % Eq.15
omegaP_nonzero = omegaP + wP_baseline; %7/7/15 JWB -- add a constant
omegaN = V_i - O_i*on;  % Eq.16
% Rectify negative components
omegaP(omegaP<0) = 0;   
omegaN(omegaN<0) = 0;   
omegaP_nonzero(omegaP_nonzero<0) = 0;

% Update adjustable weights in the model
if learn_flag*learning_on
    W_F_ni = W_F_ni + 0.01*(act_out'*1)'*Y;     % W_F_learning law
    W_F_ni(W_F_ni>WF_bound) = WF_bound;
    W_F_ni(W_F_ni<-WF_bound) = -WF_bound;
    learn_flag = 0; % shut off learning when update is done 
end

% Prepare for the next trial iteration
% calculate excitatory and inhibitory input to control units
P_i = sigact(S_i);
    % for visualization over t
    P_i_t(t,:) = P_i;
    P_gamble_mean = mean(P_i(1:outN));
    P_gamble_t(t,:) = P_gamble_mean;

cont_sig_neg = -min(sum(P_i)*W_F_ni + gamm, 0);
cont_sig_pos = max(sum(P_i)*W_F_ni - gamm, 0);


E_n = rho*(D_j*W_C_nj + cont_sig_neg);             % net excitation to response units (Eq. 2, PRO-Control model)
I_n = psi*(C_n*W_I_nn) + phi*(cont_sig_pos);  % net inhibition to response units (Eq. 13)

% Update response unit activities 
if exist('seed','var'); rng(seed*10000+n*1000+t); end     % set unique random seed for every trial & time point
C_n = C_n + rate*dt*((1-C_n).*E_n-(C_n+0.05).*(I_n+1)) + randn(1,respN)*noise;   % (Eq. 11)
C_n(C_n<0) = 0; % Rectify negative elements

% bookkeeping for TD model (t)
prev_V_i = V_i;
prev_X_jk = X_jk;
prev_elig_trace = elig_trace_jk;
idx_count = idx_count + 1;  

% for visualization
C_n_t(t,:) = C_n;
E_n_t(t,:) = E_n;
I_n_t(t,:) = I_n;
