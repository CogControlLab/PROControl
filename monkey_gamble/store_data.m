% Store data and trial stats

bin_reaction_times = [bin_reaction_times, reaction_time];
bin_outcome_times = [bin_outcome_times, outcome_time];

%     disp(reaction_time+", "+outcome_time);
avg_V_i_t = avg_V_i_t + V_i_t;

totalSpikesN_by_trial(n,:) = sum(omegaN_time(reaction_time:reaction_time+outDelay_spec/dt-1,:),1);
totalSpikesP_by_trial(n,:) = sum(omegaP_nonzero_time(reaction_time:reaction_time+outDelay_spec/dt-1,:),1);

EV_diff_array(n) = EV_diff;
Var_diff_array(n) = Var_diff;
SP_diff_array(n) = sum(P_i(1:outN))-sum(P_i(outN+1:end));
EVs(n) = EV(output);
RPEs(n) = obtained_outcome - EV(output);
maxWins(n) = max(obtained_outcome, unobtained_outcome);
minWins(n) = min(obtained_outcome, unobtained_outcome);
possLoss(n) = -min(tokens(:,output));
if min(tokens(:,output))>0
    possLoss(n) = 0;
end
if sum(tokens(:,output)<0)==0
    probLoss(n) = 0;
else
    probLoss(n) = outProbs(tokens(:,output)<0,output);
end
VARs(n) = tokens(:,output)'.^2 * outProbs(:,output) - EV(output)^2;
Entropies(n) = outProbs(:,output)' * -log2(outProbs(:,output));
if is_gamble(output)==0
    VARs(n) = 0;   % if safe gamble (no uncertainty), variance is zero
    Entropies(n) = 0;   % entropy is also zero
end
chosen_options(n) = output;
chose_gamble_bar(n) = is_gamble(output);