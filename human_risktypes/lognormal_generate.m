% generates normal distribution on the log-scaled token values,
% with mean centered on the obtained token value

% output is vector of unit activation levels, 
% with specified gap values among units
% e.g., if unitgap = 1, then units are [...,-3,-2,-1,0,1,2,3, ... ]

function [activated,activities] = lognormal_generate(m,unitgap)
    v = 2;          % log(m+v)
    stdv = 0.4;
    bound = 1.5;
    x_log = [log(abs(m)+v)-bound:0.1:log(abs(m)+v)+bound];
    y_log = normpdf(x_log,log(abs(m)+v),stdv);   
    if m<0; x_log = -x_log; end
    a = ceil(min(x_log)/unitgap)*unitgap; 
    b = floor(max(x_log)/unitgap)*unitgap; 
    activated = [a:unitgap:b];  % activated unit number
    
    % optional figure: sample activation
%     figure(1); clf; ax = gca;
%     subplot(1,2,2);
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.3 1 .6]);
%     plot(x_log,y_log/max(y_log)); hold on; grid on;
%     xlabel('log-scaled units');
    
    % (don't comment this block)
    activities = zeros(1,length(activated));    % activity sum bin
%     sqr = 0;
    for i = 1:length(activated)
        c = activated(i);
        if m==0
            c_y = normpdf(c,log(abs(m)+v),stdv)/normpdf(abs(m),abs(m),stdv);
        else
            c_y = normpdf(c,sign(m)*log(abs(m)+v),stdv)/normpdf(abs(m),abs(m),stdv);
        end
        activities(i) = c_y;
%         sqr = sqr + sqrt(c_y);
%         % for optional figure
%         scatter(c,c_y,200,'r','filled'); hold on
%         scatter(c,sqrt(c_y),200,'g'); hold on
    end
    
    % optional figure: transformation back to original scale
%     title(['sum(activity) = ',num2str(sum(activities))]);
%     subplot(1,2,1);
%     x_m = exp(x_log)-2;
%     if m<0; x_log = -x_log; x_m = -[exp(x_log)-2]; end
%     plot(x_m,y_log/max(y_log)); hold on; grid on;
% %     axis([m-150,m+150,0,1]); 
%     xlabel('token values');
%     title(['outcome = ',num2str(m),' \Rightarrow log(|',num2str(m),'|+2) = ',num2str(log(abs(m)+2),3)]);
%     disp([num2str(m),' : ',num2str(sum(activities)),', squared sum = ',num2str(sqr)]);
end


