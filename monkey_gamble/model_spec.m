%% model_spec: call script with model and experiment specifications
% **** variables here are universal over all trials ****

% set model parameters (Table S1)
param_WC_slope = 0.3;
param_WC_const = -0.5;
param_WF_const1 = -1.3;
param_WF_const2 = 0.2;
gamm = 0;
rate_param = 0.04;
noise_factor = 0.25;

disp('params:')
params = [param_WC_slope, param_WC_const, param_WF_const1, param_WF_const2];
disp(params);

w_baseline = 1;
div_r_i = 20;

dt = 0.01;              % timestep = 10ms
trial_length = 2.5;       % = 2sec
outDelay_spec = 0.75;   % outcome is delayed for 750ms after choice
maxResp_time = 1.5;     % maximum response time that can be waited until

% experiment parameters
trialN = 5000;          % number of trials in an experiment
trainN = 0;            % number of training sets 
outN = 7+5+5+5+5+5;    % total number of potential feedback signs: [-2,-1,0,1,2,3], 7 bins per each & 2 overlapping
    numbin = 7;       % 7 bins per token
    overlapbin = 2;   % 2 bins overlap among adjacent tokens
respN = 2;             % total number of potential responses: left & right
stimN = outN*respN;    % total number of potential stimuli: all six token colors * number of sides

% bins for bookkeeping of each trial results
obtained_outcome_array = zeros(1,trialN);   % what's the obtained token?
unobtained_outcome_array = zeros(1,trialN); % the other (unobtained) token within the chosen bar
p_outcome_array = zeros(1,trialN);          % probability of the obtained token
trial_win_array = zeros(1,trialN);          % did we get a larger token?
EV_diff_array = zeros(1,trialN);            % EV(left)-EV(right)
Var_diff_array = zeros(1,trialN);           % Var(left)-Var(right)
SP_diff_array = zeros(1,trialN);

% Model parameters: Temporal Difference model
alphaTD = 0.1;        % learning rate for TD Model
gammaTD = 0.95;       % discount rate for TD model
active_chain_length = 200;   % total number of timesteps a temporal representation of a stimulus is active. (2sec)
X_jk = zeros(1, active_chain_length*stimN);       % delay chain used for TD model, X_jk(t)

threshold = x(1);   % threshold for response units; =0.3131
alpha_ROs = x(2);    % learning rate for updating R-O probabilities; =0.0115
rho = x(3);         % multiplier for dynamic response units excitation (E_i,t)
phi = x(4);         % multiplier for dynamic response inhibition (W^I_ij)
psi = x(5);         % multiplier for learned, top-down control from predicted r-o (W^F_ij)
noise = x(6);       % variance of response unit noise
rate = x(7);        % multiplicative factor \beta for activity in response unit
lscale = 1;

% Set up weight matrices and various indices
W_C_ij = zeros(stimN, respN);   % stimuli to response (Control) units:
W_C_ij(1:outN,1) = (-1+[1:outN])./(outN-1)*param_WC_slope + param_WC_const;  % hardwired weights from task
W_C_ij(outN+1:end,2) = W_C_ij(1:outN,1);
W_I_ij = zeros(respN);       % mutual inhibition of response weights
W_I_ij(1,2) = 1;
W_I_ij(2,1) = 1;
W_S_ij = eye(stimN, respN*outN);      % identity matrix for 'trained' monkeys
U_ijk = zeros(stimN, stimN*active_chain_length);   % stimulus to temporal prediction weights    
W_F_ni = zeros(respN, respN);
W_F_ni(:,1) = [param_WF_const1; param_WF_const2];
W_F_ni(:,2) = [param_WF_const2; param_WF_const1];
C_n = zeros(1, respN);      % activity of response units, C_i(t); 1-by-1 vector

% for visualization over t
X_jk_t = zeros(trial_length/dt, active_chain_length*stimN);
C_n_t = zeros(trial_length/dt, respN);
delta_i_t = zeros(trial_length/dt,stimN);