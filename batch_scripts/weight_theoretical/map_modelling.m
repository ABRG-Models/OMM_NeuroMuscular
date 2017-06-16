
% Modelling left map - double exponential. This is matched to
% left(15,:) where left is loaded with load_sbgmaps.m.
x=[1:50];
y1=exp(0.07.*(x-38));
y2=exp(0.4*(x-39.5));
y = y1+y2;

zlim_max=2.5;

figure(10);
plot (x,y1);
hold on;
plot (x,y2,'r');

% Single exp - either y1 or y2.
% Double exp - use y = y1 + y2.
Y = repmat(y,50,1);

% Here's half a sine wave.
zer=zeros(1,50);
x2=[1:50];
z = sin((x-1).*pi./12.5);
mask = find(x2<12.5);
mask2 = find(x2>=12.5);
curv1 = [z(mask),zer(mask2)];
figure(5)
plot (x2,curv1);

CURV1 = flipud(repmat(curv1',1,50));
% Attain starting position
C1 = circshift(CURV1, 7);

USHEET = C1.*Y;

C1 = circshift(C1, 12);
RSHEET = C1.*Y;

C1 = circshift(C1, 13);
DSHEET = C1.*Y;

C1 = circshift(C1, 12);
LSHEET = C1.*Y;

figure(1);
surf(LSHEET);
zlim([0 zlim_max]);
title('Left');

figure(2);
surf(RSHEET);
zlim([0 zlim_max]);
title('Right');

figure(3);
surf(USHEET);
zlim([0 zlim_max]);
title('Up');

figure(4);
surf(DSHEET);
zlim([0 zlim_max]);
title('Down');

figure(6);
surf(USHEET.+DSHEET.+LSHEET.+RSHEET);
zlim([0 zlim_max]);
title('All');

write_neural_sheet(flipud(LSHEET), 'explicitDataBinaryFile50.bin');
write_neural_sheet(flipud(RSHEET), 'explicitDataBinaryFile52.bin');

write_neural_sheet(flipud(USHEET), 'explicitDataBinaryFile53.bin');
write_neural_sheet(flipud(DSHEET), 'explicitDataBinaryFile54.bin');

% From centroiding results, Up/Down seem to be 10 times larger than zminus/zplus:
write_neural_sheet(0.1.*flipud(USHEET), 'explicitDataBinaryFile58.bin');
write_neural_sheet(0.1.*flipud(DSHEET), 'explicitDataBinaryFile57.bin');
