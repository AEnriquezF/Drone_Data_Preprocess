
clc     % Clear Command Window
clear   % Clear workspace

%% read data files
matfiles = dir('*.mat') ;

%% weight inputs in same order as files are being read without decimals
WeightValues = [95;285;475;665;855;1045;1235;1425;1615;1805;1995;2185;...
    2375;2565;2755;2945;3135;3325];

TimeStep = 50;

for i = 1:length(matfiles) 
    filename = matfiles(i).name ;
    load(filename) ; 

%% Subtract features from data
% time variables
barotin = BARO(:,2);
ahr2tin = AHR2(:,2);
arsptin = ARSP (:,2);

% feature variables
baroalt = BARO(:,3); % feature array
ahr2roll = AHR2(:,3); 
ahr2pitch = AHR2(:,4);
ahr2yaw = AHR2(:,5);
ahr2alt = AHR2(:,6)./1000;
arspspeed = ARSP(:,3);

%% Create time variables for timetables stariting at 0 seconds
[barot,ahr2t,arspt] = mytime(barotin,ahr2tin,arsptin); 

%% create individual timetables
[barott,ahr2tt,arsptt] = mytimetable(barot,ahr2t,...
    arspt,baroalt,ahr2roll,ahr2pitch,ahr2yaw,ahr2alt,arspspeed);

%% synchronize timetables

sync = synchronize(barott,ahr2tt,arsptt,...
    'regular','linear','TimeStep',milliseconds(TimeStep));
%sync = retime(sync,'regular','linear','TimeStep',milliseconds(TimeStep));


%% Use airspeed to remove rows that have no airspeed 
[finaltable] = myfinaltable(sync);

%% restart tablet at 0 seconds again

NewTime = finaltable.Time;
finaltable.Time = NewTime - NewTime(1);

%% Write final table
filename = sprintf('%d.csv',WeightValues(i));
writetimetable(finaltable,filename,'delimiter','space');

% % plot tables
% figure;
% stackedplot(sync)
% figure;
% stackedplot(finaltable)

%% Get table length

LastTimes(i) = max(finaltable.Time);  
LastTimes = LastTimes';               
     
end

% longest run from 0
[maxdur, idx] = max(LastTimes);         

% time variable for longest run
%SameTimes = seconds(0:(TimeStep/1000):seconds(maxdur));
%SameTimes = SameTimes';

%% Generate new files of same length with the longest run duration


LongestRunFile = append(string(WeightValues(idx)),'.csv');

% Read Longest Run Table
    TLong = readtable(LongestRunFile);
    TLong.Var1 = seconds(TLong.Var1);
    TLong = removevars(TLong,{'Var3','Var4','Var5','Var6','Var7','Var8'});
    
% Create timetable for longest run
    TTLong = table2timetable(TLong,'RowTimes','Var1');
    
   csvfiles = dir('*.csv') ; 
   
for m = 1:length(csvfiles) 
    filenamecsv = csvfiles(m).name ;
    
    %% Read each table
    T = readtable(filenamecsv);
    T.Var1 = seconds(T.Var1);
   
    %% Create each timetable
    TT = table2timetable(T,'RowTimes','Var1');
    
    %% Syncronize tables to longest run table
    FinalTT = synchronize(TTLong,TT,'regular','previous',...
    'TimeStep',milliseconds(TimeStep));

%% Write final table

writetimetable(FinalTT,filenamecsv,'delimiter','space');

end

%% concatenate tables

% Read First Final Table
    FinalFirst = readtable(csvfiles(1).name);
  
    %FinalFirst = removevars(FinalFirst,{'Var2'});

    Concatenate = FinalFirst;
for n = 2:length(csvfiles) 
    filenameFinalcsv = csvfiles(n).name ;
    
    %% Read all tables
    TFinal = readtable(filenameFinalcsv);
   
    Concatenate = vertcat(Concatenate,TFinal);
    
end
Concatenate = removevars(Concatenate,{'Var2','Var3','Var4'});
Concatenate = renamevars(Concatenate,{'Var1','Var5','Var6','Var7','Var8','Var9','Var10'},...
    {'Timestep','baroalt','roll','pitch','yaw','alt','airsp'});

%% Add Weights

% Enter Weights

for q = 1:length(csvfiles)
    WeightValues(q) = sscanf(csvfiles(q).name,'%f')/100;
end



for p = 1:length(WeightValues)
    
    fromW = (ceil(seconds(maxdur)/0.05)+1)*(p-1)+1;
    toW = (ceil(seconds(maxdur)/0.05)+1)*p;
    Weights(fromW:toW) = WeightValues(p);
end

Weights = Weights';

% Add weights column to Concatenated table
Concatenate.Weights = Weights; 
