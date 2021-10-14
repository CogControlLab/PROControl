% Give "outcomes" of response (immediate feedback) and response-outcome
% conjunctions (delayed feedback)

 % specify theta parameter here
% risk_learn_param = 3;
    

theta = 1;      % else the default is 1 (no modulation to O_i)

% set valence, using double negative sign: positive if unrewarding, negative if rewarding
% magnitude of valence is also proportional to the token obtained 

% 6/30/20 Edit:
% Y ~ (actual - worst_possible)/(max_obtainable - worst_possible) in
% [0,1], but rescale to [1, -.1] or other bounds as needed, also log
% transform the values etc.
current_tok = [sign(tokens).*log(abs(tokens)+2), sign(ST)*log(abs(ST)+2)];
outcome_log = sign(obtainable(output))*log(abs(obtainable(output))+2);
Y = (outcome_log-min(current_tok))/(max(current_tok)-min(current_tok));
Y = -(2*Y - 1)/Y_won_div;  % normalized into [-0.1, +0.1] [-0.1, 1]

if obtainable(output)<0
    theta = risk_learn_param;
    Y = Y*Y_won_div/Y_lost_div;
end
if output==2; Y = Y*Y_won_div/Y_ST_div; end

% if obtainable(output)>0     % if positive (won) token, less control for won value
%     Y = -log(obtainable(output)+2)/log(32)/Y_won_div;  % default rate: -0.1 for token=30
% % elseif obtainable(output)==0
% %     Y = 0;
% else                        % if negative (lost) token, more control
%     Y = log(abs(obtainable(output))+2)/log(32)/Y_lost_div;   % default rate: +1 for token=-30
%     
%     theta = risk_learn_param;   % if the token is lost, increase theta
% end
% if output==2 && obtainable(output)>0; Y = Y/Y_ST_norm;    end     % if ST+ chosen, minimal Valence
%                 Y_t(t) = Y; 


% Y is proporitonal to relative_outcome = actual - max_obtainable
% Or Y ~ (actual - worst_possible)/(max_obtainable - worst_possible) in
% [0,1], but rescale to [1, -.1] or other bounds as needed, also log
% transform the values etc.