% Show the error of the model from the weightproving.log file.

alldata = dlmread ('weightproving_mod.log');

RotX=alldata(:,1);
RotY=alldata(:,2);

AvX=alldata(:,4);
AvY=alldata(:,6);
Err = sqrt (power(AvX-RotX, 2) + power (AvY-RotY, 2));

% No colour
scatter3(AvX,AvY,Err,4,'filled');

% With colour
%scatter3(AvX,AvY,Err,4,Err,'filled');