function [final] =  myfinaltable(sync)

final = sync;
toDelete = final.as < .05;
final(toDelete,:) = [];


end