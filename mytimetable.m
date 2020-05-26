function [baro,ahr2,arsp] = mytimetable(bt,ahr2t,arspt,ba,r,p,y,aa,as)

baro = timetable(ba,'RowTimes',bt); % create time table 
ahr2 = timetable(r,p,y,aa,'RowTimes',ahr2t);
arsp = timetable(as,'RowTimes',arspt);

end 