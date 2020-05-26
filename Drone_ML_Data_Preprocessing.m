
clc     % Clear Command Window
%clear   % Clear workspace

format long

%% Load log file from Mission Planner flight
%load('2020-03-07 23-41-25.bin-229874.mat');

%% Create timetable

% convert time column type from argument to time
barotime = seconds(BARO(:,2)); % conver time feature to actual time for timetable
barotime = barotime./1000000; % conver to actual seconds

ahr2time = seconds(AHR2(:,2)); 
ahr2time = ahr2time./1000000; 

arsptime = seconds(ARSP(:,2));
arsptime = arsptime./1000000;

%------------------------------------------------------------------------
% bring times to 0

mintime = min([barotime(1);ahr2time(1);arsptime(1)]); % get the minimum from all tables to avoid negatives

barotime = barotime - mintime; 
ahr2time = ahr2time - mintime; 
arsptime = arsptime - mintime; 
%------------------------------------------------------------------------
%create individual timetables
baroalt = BARO(:,3); % feature array
barotimetable = timetable(baroalt,'RowTimes',barotime); % create time table 

ahr2roll = AHR2(:,3); 
ahr2pitch = AHR2(:,4);
ahr2yaw = AHR2(:,5);
ahr2alt = AHR2(:,6);
ahr2timetable = timetable(ahr2roll,ahr2pitch,ahr2yaw,ahr2alt,'RowTimes',ahr2time);

arspspeed = ARSP(:,3);
arsptimetable = timetable(arspspeed,'RowTimes',arsptime);

%% synchronize timetables
sync = synchronize(barotimetable,ahr2timetable,arsptimetable,'regular','linear','TimeStep',milliseconds(50));

%% Use airspeed to remove rows that have no airspeed 

finaltable = sync;
toDelete = finaltable.arspspeed < .1;
finaltable(toDelete,:) = [];

% plot tables
figure;
stackedplot(sync)
figure;
stackedplot(finaltable)

