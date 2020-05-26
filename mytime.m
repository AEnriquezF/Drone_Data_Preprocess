function [barot,ahr2t,arspt] = mytime (barotin,ahr2tin,arsptin)
% convert time column type from argument to time
barot = seconds(barotin); % conver time feature to actual time for timetable
barot = barot./1000000; % conver to actual seconds
ahr2t = seconds(ahr2tin); 
ahr2t = ahr2t./1000000; 
arspt = seconds(arsptin);
arspt = arspt./1000000;

% bring times to 0
mintime = min([barot(1);ahr2t(1);arspt(1)]); % get the minimum from all tables to avoid negatives
barot = barot - mintime; 
ahr2t = ahr2t - mintime; 
arspt = arspt - mintime;

end