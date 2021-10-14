%% get_current_trial: set up conditions for current trial
% for Fukunaga18 Risk Types study

block = ceil(n/5);  % trial block number
gambleOption = mod(n,5);      % specify gamble options (1 through 5)
if gambleOption==0
    gambleOption = 5; 
end   % gambles 1-5 are presented in a consecutive order


D_j = zeros(1,stimN);                  % incoming task stimuli input; 'this_inp'

% Pie charts config:
% Gamble pie:
tokens = options(gambleOption).tokens;     
outProbs = options(gambleOption).outProbs;

% Edit 5/20/20: use stimlus-to-control weights instead of fitted subject data
ST = ST_record{gambleOption}(block);    % Edit 6/11/20: use staircase algorithm for each gamble

%% Pie selection

% Gamble initiation
% if exist('seed','var'); rng('shuffle'); end
gambleProb = rand;  rand_bins(n) = gambleProb; %disp(['rand=',num2str(gambleProb)]);
if gambleProb < outProbs(1)     
    selected = 1;       %  outcome1: loss
elseif outProbs(1)<=gambleProb && gambleProb<outProbs(1)+outProbs(2)
    selected = 2;       % the outcome2: win
else %1-outProbs(3)<=gambleProb 
   selected = 3;        % outcome3: base 
end

obtainable = [tokens(selected), ST];    % will be chosen between these two later

%% Set incoming stimuli values

% stimuli from Gamble pie: D_j(1:stimN/2)
% for i=1:3
%     [activated,activities]=lognormal_generate(tokens(i),unitgap);
%     D_Gamb = zeros(1,unitN);     % temporary bin for adding up all activities
%     D_Gamb(ismember(units,activated)) = activities*outProbs(i);
%     D_j(1:unitN) = D_j(1:unitN) + D_Gamb;
% end
% Use preloaded D_Gamb values
D_j(1:unitN) = D_Gamb{gambleOption};

% stimuli from SureThing pie: D_j(stimN/2+1:end)
[activated,activities]=lognormal_generate(ST,unitgap);
D_ST = zeros(1,unitN);     % temporary bin for adding up all activities
D_ST(ismember(units,activated)) = activities*1;    % multiply by '1' probability
D_j(unitN+1:stimN) = D_j(unitN+1:stimN) + D_ST;

% After adding up activities, apply sublinear activation filter:
% 6/17/20 edit: apply signal function only for the control loop

D_j_store = D_j;    % save for later usage
%% initialize variables at the beginning of each trial (for TD model)
V_i = zeros(1, respN*outN);     % initial TD prediction at the beginning of a trial
prev_V_i = zeros(size(V_i));    % last TD prediction
prev_X_jk = X_jk;               % delay chain for recently visited states
elig_trace_jk = zeros(size(X_jk));  % eligibility trace; initially set to zero
                                    % = zeros(1, active_chain_length*stimN);                    
prev_elig_trace = elig_trace_jk;

response_flag = 0;      % Has a response been generated? (not yet)
reaction_time = 0;
O_i = zeros(1, respN*outN); % observed r-o conjunction (none yet);  %     O_i = 0*O_i;
end_flag = 0;      % flag for ending stimulus presentation (not yet)
learn_flag = 0;    % flag for learning on the first step a R-O conjunction is observed (not yet)
idx_count = 100;     % outcomes are only presented to the model if this is < 20
                     % when a new outcome is observed (interpret_response.m), count is set to 0.  
                     % This variable increments +1 on each model iteration.
Y = 0;      % valence; intially set to zero (no outcomes observed yet, so no valence)
act_out = zeros(1,respN);   % response unit activity

% 2/16/20 fix: % reset control signal for every trial
C_n = 0*C_n;    

info_shown = 0;

% keep track of trial stats of interest
Var(n) = Vars(gambleOption);
PLoss(n) = PLosss(gambleOption);
MaxLoss(n) = MaxLosss(gambleOption);
ST_values(n) = ST;  % ST of the given simulation trial

gambdata{gambleOption}.Var(block) = Var(n);
gambdata{gambleOption}.PLoss(block) = PLoss(n);
gambdata{gambleOption}.MaxLoss(block) = MaxLoss(n);
gambdata{gambleOption}.ST(block) = ST;

