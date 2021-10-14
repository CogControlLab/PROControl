%% data_structs: call script to set up data structures for Task
% **** variables here are universal over all trials ****
    
% for recording trial stats
Var = zeros(trialN,1);
PLoss = zeros(trialN,1);
MaxLoss = zeros(trialN,1);
ST_values = zeros(trialN,1);
totalP_choice = zeros(trialN,1);
totalP_gamb = zeros(trialN,1);
totalS_choice = zeros(trialN,1);
reaction_times = zeros(trialN,1);
valences = zeros(trialN,1);
WF_history = zeros(trialN,2);

% for each gamble data
gambdata = cell(1,5);
ST_record = cell(1,5); 
for g = 1:5
    gambdata{g}.RT = zeros(blockN,1);     % reaction times
    gambdata{g}.chosen = zeros(blockN,1); % '1' for gamble, '2' for ST
    gambdata{g}.obtained = zeros(blockN,1); % obtained token value
    gambdata{g}.ST = zeros(blockN,1);     % SureThing value
    gambdata{g}.Var = zeros(blockN,1);    % should be constant for the same gamble
    gambdata{g}.PLoss = zeros(blockN,1);
    gambdata{g}.MaxLoss = zeros(blockN,1);
    gambdata{g}.Y = zeros(blockN,1);      % updated valence at the trial end
    gambdata{g}.S_choice = zeros(blockN,1); % total S activity during choice
    gambdata{g}.P_choice = zeros(blockN,1); % total S^P activity during choice

    ST_record{g} = zeros(blockN+1,1);   % plus 1 for the loop; will not use the last index
    ST_record{g}(1) = ST_init;          % setting equal initial values across all gambles
end
    