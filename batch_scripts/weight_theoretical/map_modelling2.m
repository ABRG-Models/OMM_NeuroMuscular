
% Modelling left map - double exponential. This is matched to
% left(15,:) where left is loaded with load_sbgmaps.m.
x=[1:50];
y1=exp(0.07.*(x-38));
y2=exp(0.4*(x-39.5));
y = y1+y2;

y3=exp(0.2*(x-39));

zlim_max=2.5;

figure(10);
plot (x,y1);
hold on;
plot (x,y2,'r');

% Single exp - either y1 or y2 etc.
% Double exp - use y = y1 + y2.
Y = repmat(y3,50,1);

% Do the sine part in higher precision first, to ensure symmetry
% (rather than having circ commands of 12 and 13). Use 500 pixels
% rather than 50.
%
% Here's half a sine wave.
sine_width = 1900;
zer=zeros(1,5000);
x2=[0:4999];
z = sin(x2.*pi./sine_width);
mask = find(x2<sine_width);
mask2 = find(x2>=sine_width);
curv1 = [z(mask),zer(mask2)]';
figure(5); clf;
plot (x2,curv1);
title ('single sine on 5000 wide space')
% Now rotate and shift these sines.

first_shift = -sine_width./2;
shift = 5000./4;

c1 = circshift(curv1, first_shift);
figure(60); clf; hold on;
plot (x2,c1,'b');

c2 = circshift(c1, shift);
plot (x2,c2,'r');

c3 = circshift(c2, shift);
plot (x2,c3,'g');

c4 = circshift(c3, shift);
plot (x2,c4,'k');
title('Shifted sines on 5000 wide space')

% Now down-sample
c1d = downsample(c1,100);
c2d = downsample(c2,100);
c3d = downsample(c3,100);
c4d = downsample(c4,100);

figure(70); clf; hold on;
plot (x, c1d, 'bo-');
plot (x, c2d, 'ro-');
plot (x, c3d, 'go-');
plot (x, c4d, 'ko-');
title('downsampled sines on usual 50 pixel space')'

C1 = repmat(c1d,1,50);
USHEET = C1.*Y;

C2 = repmat(c2d,1,50);
RSHEET = C2.*Y;

C3 = repmat(c3d,1,50);
DSHEET = C3.*Y;

C4 = repmat(c4d,1,50);
LSHEET = C4.*Y;

figure(1);
surf(LSHEET);
zlim([0 zlim_max]);
title('Left');
print('left.png');

figure(2);
surf(RSHEET);
zlim([0 zlim_max]);
title('Right');
print('right.png');

figure(3);
surf(USHEET);
zlim([0 zlim_max]);
title('Up');
print('up.png');

figure(4);
surf(DSHEET);
zlim([0 zlim_max]);
title('Down');
print('down.png');

figure(6); clf;
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
