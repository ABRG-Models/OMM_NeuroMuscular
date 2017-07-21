
% Modelling left map - double exponential. This is matched to
% left(15,:) where left is loaded with load_sbgmaps.m.
x=[1:50];
y1=exp(0.07.*(x-38));
y2=exp(0.4*(x-39.5));
y = y1+y2;

y3=exp(0.2*(x-39));

zlim_max=2.5;

figure(110);
plot (x,y1);
hold on;
plot (x,y2,'r');

% Single exp - either y1 or y2 etc.
% Double exp - use y = y1 + y2.
Y = repmat(y3,50,1);

% Do the sine part in higher precision first, to ensure symmetry
% (rather than having circ commands of 12 and 13). Use 5000 pixels
% rather than 50.
%
% Here's half a sine wave. Both at 1900 was my starting point.
sine_width1 = 1900; % Vertical. eyeRx
sine_width2 = 1900; % Horizontal. eyeRy

zer=zeros(1,5000);

x2=[0:4999];
z1 = sin(x2.*pi./sine_width1);
z2 = sin(x2.*pi./sine_width2);

mask1A = find(x2<sine_width1);
mask1AL = find(x2<sine_width1/2);
mask1AR = find(x2<sine_width1 & x2>=sine_width1/2);
mask1B = find(x2>=sine_width1);

mask2A = find(x2<sine_width2);
mask2AL = find(x2<sine_width2/2);
mask2AR = find(x2<sine_width2 & x2>=sine_width2/2);
mask2B = find(x2>=sine_width2);

maxpoint1 = sine_width1/2; % Peak of sine1
crosspoint1L = maxpoint1 - 5000/8;
crosspoint1R = maxpoint1 + 5000/8;
maxpoint2 = sine_width1/2;
crosspoint2L = maxpoint2- 5000/8;
crosspoint2R = maxpoint2 + 5000/8;

% Empirically determined suitable multiplier to give a -7,-7 saccade
m_at_crosspoint1 = 0.65; % Vert
m_at_crosspoint2 = 1.7;  % Horz


%
% ones as a multiplication function
%
onesmultfunc = ones(1,5000);

%
% Linear multiplier function
%

grad1L = (1-m_at_crosspoint1)./(maxpoint1 - crosspoint1L);
offs1L = 1-(grad1L.*maxpoint1);
grad1R = (1-m_at_crosspoint1)./(maxpoint1 - crosspoint1R);
offs1R = 1-(grad1R.*maxpoint1);
linmultfunc1L = (grad1L.*x2)+offs1L;
linmultfunc1R = (grad1R.*x2)+offs1R;

grad2L = (1-m_at_crosspoint2)./(maxpoint2 - crosspoint2L);
offs2L = 1-(grad2L.*maxpoint2);
grad2R = (1-m_at_crosspoint2)./(maxpoint2 - crosspoint2R);
offs2R = 1-(grad2R.*maxpoint2);
linmultfunc2L = (grad2L.*x2)+offs2L;
linmultfunc2R = (grad2R.*x2)+offs2R;

%
% Sigmoidal multiplier functions
%

k = 0.006;
sigoffs = 400;
sigmultfunc1L = 0.3 + (1 ./ (1.428 + exp(-k.*(x2.-sigoffs))));
% Normalise so that function is 1 at sine_width1/2:
sigmultfunc1L = sigmultfunc1L ./(sigmultfunc1L(sine_width1/2));
sigmultfunc1Latcross = 0.3 + (1 ./ (1.428 + exp(-k.*(crosspoint1L-sigoffs))))

k2 = 0.006;
sigoffs2 = 4700;
sigmultfunc2L = fliplr(1 + (1 ./ (1 + exp(-k2.*(x2.-sigoffs2)))));
sigmultfunc2L = sigmultfunc2L ./(sigmultfunc2L(sine_width2/2));
sigmultfunc2Latcross = sigmultfunc2L(crosspoint2L)


% Choose one of the above modifiers(ones, linear or sigmoidal):
multfunc1L = sigmultfunc1L; % sigmultfunc1L, linmultfunc1L or onesmultfunc;
multfunc2L = sigmultfunc2L; % sigmultfunc2L, linmultfunc2L or onesmultfunc;

% Flipping same for all functions:
multfunc1R = [fliplr(multfunc1L(mask1A)), zer(mask1B)];
multfunc2R = [fliplr(multfunc2L(mask2A)), zer(mask2B)];

z1L = z1.*multfunc1L;
z1R = z1.*multfunc1R;

z2L = z2.*multfunc2L;
z2R = z2.*multfunc2R;

curv1 = [z1L(mask1AL), z1R(mask1AR), zer(mask1B)]'; % Vertical. eyeRx
curv2 = [z2L(mask2AL), z2R(mask2AR), zer(mask2B)]'; % Horz

figure(105); clf;
plot (x2,curv1,'r');
hold on;
plot (x2,curv2, 'g');
plot (x2, multfunc1L, 'k')
plot (x2, multfunc2L, 'm')

title ('single sine(s) on 5000 wide space');
% Now rotate and shift these sines.

first_shift1 = -sine_width1./2;
first_shift2 = -sine_width2./2 + 5000./4;

shift = 5000./2;

c1 = circshift(curv1, first_shift1);
figure(160); clf; hold on;
plot (x2,c1,'b');

c3 = circshift(c1, shift);
plot (x2,c3,'g');


c2 = circshift(curv2, first_shift2);
plot (x2,c2,'r');

c4 = circshift(c2, shift);
plot (x2,c4,'k');
title('Shifted sines on 5000 wide space')

% Now down-sample
c1d = downsample(c1,100);
c2d = downsample(c2,100);
c3d = downsample(c3,100);
c4d = downsample(c4,100);

figure(170); clf; hold on;
plot (x, c1d, 'bo-');
plot (x, c2d, 'ro-');
plot (x, c3d, 'go-');
plot (x, c4d, 'ko-');
title('downsampled sines on usual 50 pixel space');
legend('U','L','D','R');

C1 = repmat(c1d,1,50);
USHEET = C1.*Y;

C2 = repmat(c2d,1,50);
RSHEET = C2.*Y;

C3 = repmat(c3d,1,50);
DSHEET = C3.*Y;

C4 = repmat(c4d,1,50);
LSHEET = C4.*Y;

% Set to 1 to print out pngs:
printmaps = 0

figure(101);
surf(LSHEET);
zlim([0 zlim_max]);
title('Left');
if printmaps
    print('left.png');
end

figure(102);
surf(RSHEET);
zlim([0 zlim_max]);
title('Right');
if printmaps
    print('right.png');
end

figure(103);
surf(USHEET);
zlim([0 zlim_max]);
title('Up');
if printmaps
    print('up.png');
end

figure(104);
surf(DSHEET);
zlim([0 zlim_max]);
title('Down');
if printmaps
    print('down.png');
end

figure(106); clf;
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
