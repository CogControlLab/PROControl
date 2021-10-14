%% Store data: at the end of each trial record S_i activities
% human risk types study

valences(n) = Y;            % store Y at trial ends
WF_history(n,:) = W_F_ni;
totalP_choice(n) = sum(sum(P_i_t(1:reaction_time,:)))/reaction_time;
totalP_gamb(n) = sum(sum(P_gamble_t(1:reaction_time,:)))/reaction_time;
totalS_choice(n) = sum(sum(S_i_t(1:reaction_time,:)))/reaction_time;
reaction_times(n) = reaction_time;
gambdata{gambleOption}.RT(block) = reaction_time;
gambdata{gambleOption}.Y(block) = Y;
gambdata{gambleOption}.obtained(block) = obtained_outcome_array(n);

gambdata{gambleOption}.S_choice(block) = totalS_choice(n);
gambdata{gambleOption}.P_choice(block) = totalP_choice(n);

% Staircase algorithm: 
% if gamble chosen (output==1), increase ST by a step
% if ST chosen (output==2), decrease ST by step
ST_record{gambleOption}(block+1) = ST + sign(1.5-output)*stair_size; % + randn; 