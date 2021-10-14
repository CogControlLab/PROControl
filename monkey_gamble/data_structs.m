%% data_structs: call script to set up data structures for Task
% variables here are universal over all trials

omegaN_cat = zeros(outN.*respN, trial_length./dt);
omegaP_cat = zeros(outN.*respN, trial_length./dt);
omegaP_nonzero_cat = omegaP_cat;    % revised model

obtained_omegaN = [];
unobtained_omegaN = [];
obtained_omegaP = [];
unobtained_omegaP = [];
obtained_omegaP_nonzero = [];     % revised model
unobtained_omegaP_nonzero = [];

avg_omegaN_t = zeros(outN.*respN, trial_length./dt)';
avg_omegaP_t = zeros(outN.*respN, trial_length./dt)';
avg_omegaP_nonzero_t = zeros(outN.*respN, trial_length./dt)';
bin_reaction_times = [];
bin_outcome_times = [];
avg_V_i_t = zeros(outN.*respN, trial_length./dt)';

% record trial stats
EVs = zeros(trialN,1);
VARs = zeros(trialN,1);
RPEs = zeros(trialN,1);
maxWins = zeros(trialN,1);
minWins = zeros(trialN,1);
probLoss = zeros(trialN,1);
Entropies = zeros(trialN,1);
totalSpikesN_by_trial = zeros(trialN,outN.*respN);
totalSpikesP_by_trial = zeros(trialN,outN.*respN);
chosen_options = zeros(trialN,1);   % 1 = left, 2 = right
chose_gamble_bar = nan(trialN,1);

