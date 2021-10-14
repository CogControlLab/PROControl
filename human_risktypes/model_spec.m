%% model_spec: call script with model and experiment specifications
% Human fMRI Risk Types study
% **** variables here are universal over all trials ****

% set model parameters (Eq. S10, S11, Table S2)
i1 = 0.206; 
s1 = 0.0;
i2 = -0.1; 
s2 = 0.427;
theta = 1;
gamm = 1.79;        % K in Table S2
WF_bound = 0.30;
Y_won_div = 100;    
Y_ST_div = Y_won_div;
Y_lost_div = 36;

% Specifications of Gamble Options (Table S1): order of tokens is [max(loss), max(win), base]
gamble1.outProbs = [.1 .1 .8];  % baseline
gamble1.tokens = [-30, 90, 30];
gamble2.outProbs = [.1 .1 .8];  % control p(loss)
gamble2.tokens = [-65, 125, 30]; 
gamble3.outProbs = [.25 .25 .5];  % control var
gamble3.tokens = [-8, 68, 30]; 
gamble4.outProbs = [.25 .25 .5];  % control max(loss)
gamble4.tokens = [-30, 90, 30];
gamble5.outProbs = [.13 .05 .82];  % orthogonalization
gamble5.tokens = [-23, 660, 0];
options = [gamble1, gamble2, gamble3, gamble4, gamble5]; % struct array
possOutcomes = [-65,-30,-23,-8,0,30,68,90,125,660];

load('D_gambles.mat');  % preloaded D_j for five gambles
Vars = [720,1805,722,1800,20948];
PLosss = [0.1,0.1,0.25,0.25,0.13];
MaxLosss = [-30,-65,-8,-30,-22];
ST_init = 30;     % initialize starting ST value


dt = 0.01;          % timestep = 10ms
trial_length = 5;   % unit in seconds
outDelay_spec = 2;    % outcome is delayed for "at least" 2000ms after choice
maxResp_time = 2.0;   % maximum response time that can be waited until


% experiment parameters
trialN = 5*60;         % number of trials in an experiment
blockN = trialN/5;              % number of trials fore each gamble
trainN = 5*10;         % number of training sets 
unitgap = 0.5;                  % size of discrete units representing logscale
units = [-5.5:unitgap:7.5];       % discrete unit bins
unitN = length(units);  % number of total units
stimN = 2*unitN;                  % multiply two for Gamble & ST
respN = 2;                        % choice between Gamble & SureThing
outN = unitN;             % total number of potential feedback signs: # of possilbe outcomes
stair_size = 2;         % step size for staircase controller algorithm 

% bookkeeping of each trial record
obtained_outcome_array = zeros(1,trialN);   % what's the obtained token?
unobtained_outcome_array = zeros(2,trialN); % the other (unobtained) token within the chosen bar
rand_bins = zeros(1,trialN);
p_outcome_array = zeros(1,trialN);          % probability of the obtained token
trial_win_array = zeros(1,trialN);          % did we get a larger token?
chosen_option = zeros(1,trialN);            % did the model choose gamble(1) or ST(2)?

% Model parameters: Temporal Difference model
alphaTD = 0.1;        % learning rate for TD Model
gammaTD = 0.95;       % discount rate for TD model
active_chain_length = 350;   % total number of timesteps a temporal representation of a stimulus is active. (2sec)
X_jk = zeros(1, active_chain_length*stimN);       % delay chain used for TD model, X_jk(t)

threshold = x(1);   % threshold for response units; =0.3131
alpha_ROs = x(2);    % learning rate for updating R-O probabilities; =0.0115
rho = x(3);         % multiplier for dynamic response units excitation (E_i,t)
phi = x(4);         % multiplier for dynamic response inhibition (W^I_nn)
psi = x(5);         % multiplier for learned, top-down control from predicted r-o (W^F_ij)
noise = x(6);       % variance of response unit noise
rate = x(7);        % multiplicative factor \beta for activity in response unit
lscale = 1;

% Set up weight matrices and various indices
W_C_nj = zeros(stimN, respN);   % stimuli-to-response (Control) weights
                                % hardwired weights from task: proporitonal to token value
% linear
W_C_nj(1:unitN,1) = i1+ s1*[1:unitN]'/unitN ;  % Gamble-to-GambleChoice weights (linear)
W_C_nj(unitN+1:stimN,2) = i2+ s2*[1:unitN]'/unitN;  % different ST-to-ST weights	
W_I_nn = zeros(respN);                          % mutual inhibition of response weights
W_I_nn(1,2) = 1;
W_I_nn(2,1) = 1;
W_S_ij = eye(stimN, respN*outN);     % stimulus to response-outcome predictions, W^S_ij(t)    
U_ijk = zeros(stimN, stimN*active_chain_length);   % stimulus to temporal prediction weights    
W_F_ni = zeros(1, respN);   learning_on = 1; % top-down control weights, W^F_ik(t)
C_n = zeros(1, respN);               % activity of response units, C_n(t); 1-by-1 vector

% For visualization over t
P_i_t = zeros(trial_length/dt,stimN);
S_i_t = zeros(trial_length/dt,stimN);

% additional parameters
wP_baseline = 1;
outcome_last = 20;   % outcomes are interpreted as lasting 20 model iterations (200ms)
