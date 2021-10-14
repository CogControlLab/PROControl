% Prediction of Response-Outcome Control model
%     Copyright 2021 Jae Hyung Woo
%   
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.        

%%% This file should be called from "main.m"

%% load parameters from behavioral fit

load('behavioral_fit_params.mat');

%% Select task to simulate

curr_dir = pwd;
eval(['cd ' task]);
%% model_spec: call script with model and experiment specifications

model_spec;                                    
%% data_structs: call script to set up data structures for Task

data_structs;  
%% Start trial loop

for n = 1:trialN
    % notify at every n-th trials
    if (mod(n, 10)==0)
        disp(['Trial Number:   ' num2str(n) '/' num2str(trialN)]);
    end

    %% get_current_trial: set up conditions for current trial
    get_current_trial;
       
    %% loop over the current trial time
    for t = 1:trial_length/dt
        
        % set_current_inp: handles presentation of stimuli to the model
        set_current_inp;
        
        % Update the time steps
        update_time_step;
        
    end
    
    %% End of each trial: recrod activities % trial data
    
    store_data;
    
    % begin next iteration of the trial
end

avg_reaction_times = mean(bin_reaction_times);
disp(['Average RT = ',num2str(avg_reaction_times)]);

%% Recreate certain figures 


