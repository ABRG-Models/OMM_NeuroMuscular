%
% Build weight maps for saccadic burst generator.
%
% This version has an approximate "hill sized" gap between opposing
% axes, so that when a pure right movement is coded, no up or down
% activity is registered. This is unlike the results of Arai et al
% 1994 or Tabareau et al, 2007, whose maps will, for a hill of
% finite, non-zero size, excite some equal, and opposing up and
% down signal for a right or leftwards saccade.
%

% For TModel0, build pure sine+exp maps, like Tabareau et al, but
% leave a gap between opposing weight maps of width about 5 or 6
% pixels.
%
% For TModel1, apply the sigmoidal transform
%
% For TModel2, apply a sigmoidal transform, but with differing
% parameters because the hill of activity is about 12 to 15 pixels
% wide, rather than 5 to 6.
%

modeltype = 'TModel3' % TModel0, TModel1 or TModel2 or indeed TModel3
                      % (like 0 but with joining sines) or TModel4
                      % (like 2 but with joining sines)

% Modelling left map - double exponential. This is matched to
% left(15,:) where left is loaded with load_sbgmaps.m.
x=[1:50];

% Single exp - either y1, y2, y3 etc.
% Double exp - use y = y1 + y2.
if strcmp(modeltype, 'TModel2')
    %y = exp(0.1*(x-39));
    y0=(1./1451).*exp(0.07.*x); % Single exponential
    y1=(1./1950).*exp(0.05.*x); % Small eccentricity
    y2=(1./6000).*exp(0.1.*x); % Larger eccentricity

    yh = y0; % y0 is great for horizontal saccades

    y3=(1./14000).*exp(0.12.*x); % Works for vertical saccades

    yv=y3;

elseif strcmp(modeltype, 'TModel4')
    yh=(1./1451).*exp(0.07.*x);
    yv=(1./14000).*exp(0.12.*x);

elseif strcmp (modeltype, 'TModel3')
    % TModel3 starting point should be similar to TModel0, but I've
    % changed the weights for SC_Deep to SCavg and SC_avg to LLBNs
    % to unity.
    %ycmp = 0.0009.*exp(0.19.*x);
    yh = 0.0012.*exp(0.19.*x);
    yv = 0.005.*exp(0.2.*x);

    figure(110); clf;
    plot (x,yh,'b');
    hold on;
    plot (x,yv,'r');
    %plot (x,ycmp,'k');
    xlim([18 40]);
    ylim([0 5]);
    legend('yh','yv')
    omsetgrid([1,0]);

else % TModel0
    yh = exp(0.2*(x-39)); % 1/2441 exp (0.2x)
    yv = exp(0.2*(x-39));
end

% A parameter for graphing
zlim_max=2.5;

% Do the sine part in higher precision first, to ensure symmetry
% (rather than having circ commands of 12 and 13). Use 5000 pixels
% rather than 50.
%
% Here's half a sine wave. Both at 1900 was my starting point.
if strcmp (modeltype, 'TModel2')
    sine_width1 = 1100; % Vertical. eyeRx
    sine_width2 = 1100; % Horizontal. eyeRy
elseif strcmp (modeltype, 'TModel1')
    sine_width1 = 1900; % Vertical. eyeRx
    sine_width2 = 1900; % Horizontal. eyeRy
elseif strcmp (modeltype, 'TModel3') || strcmp (modeltype, 'TModel4')
    sine_width1 = 5000/2;
    sine_width2 = sine_width1;
else
    sine_width1 = 1700; % Vertical. eyeRx. To suit HOA 9 px wide at
                        % -6 degrees.
    sine_width2 = 1700; % Horizontal. eyeRy
end

% Create Y from yh and yv.
YH = repmat(yh,50,1);
YV = repmat(yv,50,1);

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
if crosspoint2L > 0
    sigmultfunc2Latcross = sigmultfunc2L(crosspoint2L)
end
%
% WG Sigmoidal multiplier functions
%

k = 0.006;
sigoffs = 400;
WGsigmultfunc1L = 0.3 + (1 ./ (1.428 + exp(-k.*(x2.-sigoffs))));
% Normalise so that function is 1 at sine_width1/2:
WGsigmultfunc1L = WGsigmultfunc1L ./(WGsigmultfunc1L(sine_width1/2));
WGsigmultfunc1Latcross = 0.3 + (1 ./ (1.428 + exp(-k.*(crosspoint1L-sigoffs))))

k2 = 0.006;
sigoffs2 = 4700;
WGsigmultfunc2L = fliplr(1 + (1 ./ (1 + exp(-k2.*(x2.-sigoffs2)))));
WGsigmultfunc2L = WGsigmultfunc2L ./(WGsigmultfunc2L(sine_width2/2));
if crosspoint2L > 0
    WGsigmultfunc2Latcross = WGsigmultfunc2L(crosspoint2L)
end


% Choose one of the above modifiers(ones, linear or sigmoidal):
if strcmp (modeltype, 'TModel0') || strcmp (modeltype, 'TModel2') || strcmp (modeltype, 'TModel3') || strcmp (modeltype, 'TModel4')
    multfunc1L = onesmultfunc; % sigmultfunc1L, linmultfunc1L or onesmultfunc;
    multfunc2L = onesmultfunc; % sigmultfunc2L, linmultfunc2L or onesmultfunc;
else
    multfunc1L = sigmultfunc1L; % sigmultfunc1L, linmultfunc1L or onesmultfunc;
    multfunc2L = sigmultfunc2L; % sigmultfunc2L, linmultfunc2L or onesmultfunc;
end

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
omsetgrid([2,0]);

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
omsetgrid([3,0]);

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
omsetgrid([4,0]);
C1 = repmat(c1d,1,50);
USHEET = C1.*YV;

C2 = repmat(c2d,1,50);
RSHEET = C2.*YH;

C3 = repmat(c3d,1,50);
DSHEET = C3.*YV;

C4 = repmat(c4d,1,50);
LSHEET = C4.*YH;

% Set to 1 to print out pngs:
printmaps = 0

figure(101);
surf(LSHEET);
zlim([0 zlim_max]);
title('Left');
omsetgrid([1,1]);
if printmaps
    print('left.png');
end

figure(102);
surf(RSHEET);
zlim([0 zlim_max]);
title('Right');
omsetgrid([2,1]);
if printmaps
    print('right.png');
end

figure(103);
surf(USHEET);
zlim([0 zlim_max]);
title('Up');
omsetgrid([3,1]);
if printmaps
    print('up.png');
end

figure(104);
surf(DSHEET);
zlim([0 zlim_max]);
title('Down');
omsetgrid([4,1]);
if printmaps
    print('down.png');
end

figure(106); clf;
surf(USHEET.+DSHEET.+LSHEET.+RSHEET);
zlim([0 zlim_max]);
title('All');
omsetgrid([4,2]);

mkdir (modeltype);
write_neural_sheet(flipud(LSHEET), [modeltype '/explicitDataBinaryFile50.bin']);
write_neural_sheet(flipud(RSHEET), [modeltype '/explicitDataBinaryFile52.bin']);

write_neural_sheet(flipud(USHEET), [modeltype '/explicitDataBinaryFile53.bin']);
write_neural_sheet(flipud(DSHEET), [modeltype '/explicitDataBinaryFile54.bin']);

% From centroiding results, Up/Down seem to be 10 times larger than
% zminus/zplus:
if strcmp(modeltype, 'TModel3')
    write_neural_sheet(1.7.*flipud(USHEET), [modeltype '/explicitDataBinaryFile58.bin']);
    write_neural_sheet(1.7.*flipud(DSHEET), [modeltype '/explicitDataBinaryFile57.bin']);
else
    write_neural_sheet(0.1.*flipud(USHEET), [modeltype '/explicitDataBinaryFile58.bin']);
    write_neural_sheet(0.1.*flipud(DSHEET), [modeltype '/explicitDataBinaryFile57.bin']);
end
