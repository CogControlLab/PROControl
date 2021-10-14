%% get_current_trial: set up conditions for current trial

D_j = zeros(1,stimN);   % incoming task stimuli input; 'this_inp'
D_j_t = zeros(trial_length/dt,stimN);    % 10/10/19 - for visualization

left = 1;                       % Left bar is indexed by '1'
right = 2;                      % Right bar is indexed by '2'
outProbs = zeros(2,2);          % Outcome Probilities: top,bottom X left,right
tokens = -ones(2,2);            % token values (initialized with negative values for the while loop below)
EV = zeros(1,2);                % stores Expected Values [left, right]
Var = zeros(1,2);               % stores Variance [left, right]
is_gamble = zeros(1,2);         % indicates whether each bar is gamble('1') or safe('0')
probvals = [0.1, 0.3, 0.5, 0.7, 0.9];  % top outcome probabilities; see Materials & Methods (p.17)

% Left & Right bar config
while sum(is_gamble)==0                     % both bars should not be safe at once
%     disp('both safe options: reconfiguring gamble bars')
    for side = [left, right]
        tokens(:,side) = -ones(2,1);
        while max(tokens(:,side))<0         % there should always be a possibility of a (trivial) win
%             disp('no trivial win; reconfiguring the gamble bar')
            if rand < 0.8                       % 80 percent are gamble options
                is_gamble(side) = 1;      
                tmp = randperm(6) - 3;          % pick random token value (out of 6 choices)
                tokens(:,side) = tmp(1:2)';     
                tmp = randperm(5);              % pick a random pval (out of 5 choices)
                outProbs(1,side) = probvals(tmp(1));           
                outProbs(2,side) = 1 - outProbs(1,side);    % set the other probability to the complement
                EV(side) = sum(outProbs(:,side).*tokens(:,side));
                Var(side) = var(tokens(:,side),outProbs(:,side));
            else                                % 20 percent are safe options
                is_gamble(side) = 0;
                outProbs(1,side) = 1.0;         % entirely red(+0) or blue(+1)
                outProbs(2,side) = 0;
                tmp = randperm(2) - 1;          % pick random token value (either '+0' or '+1')  
                tokens(:,side) = [tmp(1); NaN]; % unseen choice in safe option appears as 'NaN'
                EV(side) = tokens(1,side);
                Var(side) = 0;
            end
        end
    end
end

% Set input stimuli D_j
activ = [0.13, 0.4, 0.8, 1.0, 0.8, 0.4, 0.13];  % 7 bins

for side = [left, right] 
    if is_gamble(side)==0            % If the bar was safe,
        tok_idx = tokens(1,side) + 3;
        act_idx_start = outN*(side-1) + overlapbin + tok_idx*(numbin-overlapbin);
        D_j(act_idx_start:act_idx_start+numbin-1) = activ;    % Set input to the model
                
    elseif is_gamble(side)==1                   % If the bar was a gamble,            
        for numtok = 1:2
            tok_idx = tokens(numtok,side) + 3;
            act_idx_start = outN*(side-1) + (tok_idx-1)*(numbin-overlapbin) + 1;
            D_j(act_idx_start:act_idx_start+numbin-1) = D_j(act_idx_start:act_idx_start+numbin-1) + activ*outProbs(numtok,side);
        end
    end
end

EV_diff = EV(1) - EV(2);        % EV difference = EV(left)-EV(right);
Var_diff = Var(1) - Var(2);

% Gamble initiation: prespecified gamble results (the model gets either outcome)
gamble_prob = rand;
gamble_results = zeros(1,2);
p_outcomes = zeros(1,2);
unobtained_outcomes = zeros(1,2);
for side = [left, right]
    if is_gamble(side)==0            % If chosen bar was safe,
        gamble_results(side) = EV(side);
        unobtained_outcomes(side) = NaN;       % safe option has no unobtained token
        p_outcomes(side) = 1.0;                % probability is 1
        trial_win = NaN;                        % safe choice: neither won or lost
    elseif is_gamble(side)==1                   % If chosen bar was gamble,
        if gamble_prob < outProbs(1,side)            % initiate gamble
            gamble_results(side) = tokens(1,side);   % top outcome is selected
            p_outcomes(side) = outProbs(1,side);
        else
            gamble_results(side) = tokens(2,side);   % bottom outcome is selected
            unobtained_outcomes(side) = tokens(1,side);
            p_outcomes(side) = outProbs(2,side);
        end
    end
end

D_j_store = D_j;    % save for later usage

% initialize variables at the beginning of each trial (for TD model)
V_i = zeros(1, respN*outN);     % initial TD prediction at the beginning of a trial
prev_V_i = zeros(size(V_i));    % last TD prediction
prev_X_jk = X_jk;               % delay chain for recently visited states
elig_trace_jk = zeros(size(X_jk));  % eligibility trace; initially set to zero
                                    % = zeros(1, active_chain_length*stimN);                    
prev_elig_trace = elig_trace_jk;

response_flag = 0;      % Has a response been generated? (not yet)
outcome_flag = 0;       % Has an outcome been generated? (not yet)
O_i = zeros(1, respN*outN); % observed r-o conjunction (none yet);  %     O_i = 0*O_i;
end_flag = 0;           % flag for ending stimulus presentation (not yet)
learn_flag = 0;         % flag for learning on the first step a R-O conjunction is observed (not yet)
idx_count = 100;        % outcomes are only presented to the model if count is < 20
                        % when a new outcome is observed (interpret_response.m), count is set to 0.  
                        % This variable increments +1 on each model iteration.
Y = 0;                  % valence; intially set to zero (no outcomes observed yet, so no valence)
act_out = zeros(1,respN);   % response unit activity
out_sig = zeros(1,respN);   % 12/2/19: outcome revealed if above threshold

C_n = 0*C_n;  % reset control signal for every new trial

    % added for visualization over t
    V_i_t = zeros(trial_length/dt, respN*outN);
    elig_trace_jk_t = zeros(trial_length/dt, active_chain_length*stimN);     
    response_flag_t = zeros(trial_length/dt, 1);
    O_i_t = zeros(trial_length/dt, respN*outN); 
    end_flag_t = zeros(trial_length/dt, 1);
    count_t = zeros(trial_length/dt,1); count_t(1) = 100;
    act_out_t = zeros(trial_length/dt,respN);
    out_sig_t = zeros(trial_length/dt, 1); 