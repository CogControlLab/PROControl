%% Sub-additive signal function

function y = sigact(x)
    for i = 1:length(x)
        % inv sigmoid for 0.42
        y(i) = -1/14*log(1/[x(i)]-1)+0.45;      
        y(y<0) = 0; 
        if y(i)>0.4298; y(i) = x(i); end
    end    
end
