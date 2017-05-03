% Inputs: Activity value matricies from all neurons and all time points.
% 
% function displays the activity of all neurons at the last time step of
% the simulation, for the chosen nuclei.

nfs = 50;

r = R(:,end);
r(1)=0; r(2)=1;
r = reshape(r,nfs,nfs);

scd = SCd(:,end);
scd(1)=0; scd(2)=1;
scd = reshape(scd,nfs,nfs);

str = STR(:,end);
str(1)=0; str(2)=1;
str = reshape(str,nfs,nfs);

stn = STN(:,end);
stn(1)=0; stn(2)=1;
stn = reshape(stn,nfs,nfs);

fef = FEF(:,end);
fef(1)=0; fef(2)=1;
fef = reshape(fef,nfs,nfs);

gpi = GPi(:,end);
gpi(1)=0; gpi(2)=1;
gpi = reshape(gpi,nfs,nfs);

tha = Thalamus(:,end);
tha(1)=0; tha(2)=1;
tha = reshape(tha,nfs,nfs);


figure('units','normalized','outerposition',[0 0 1 1])

subplot(2,4,1)
imagesc(r); 
title('retina');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,2)
imagesc(fef); 
title('FEF');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,3)
imagesc(tha); 
title('thalamus');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,4)
imagesc(str); 
title('striatum d1');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,5)
imagesc(stn); 
title('STN');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,6)
imagesc(gpi); 
title('GPi');
set(gcf,'colormap',hot)
axis tight square

subplot(2,4,7)
imagesc(scd); 
title('SC deep');
set(gcf,'colormap',hot)
axis tight square