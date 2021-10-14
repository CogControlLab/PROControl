% This is the master file -- change the settings in this file and run it
clearvars

%Change the following as desired:
tasknum = 0;    %0 = monkey_gamble; 1=human risk types;



%%% Do not change anything below:
switch tasknum
    case 0
        task = 'monkey_gamble';
        proControl_model;
    case 1
        task = 'human_risktypes';
        proControl_model;
end



