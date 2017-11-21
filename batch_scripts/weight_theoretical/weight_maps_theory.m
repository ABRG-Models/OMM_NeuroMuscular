%
% Build weight maps for paper illustration.
%
%

% Modelling left map - double exponential. This is matched to
% left(15,:) where left is loaded with load_sbgmaps.m.
x=[1:50];

yh=0.004*exp(0.11.*x);
yv=0.004*exp(0.11.*x);

figure(110); clf;
plot (x,yh,'b');
hold on;
%plot (x,yhcmp,'b--');
%plot (x,yhcmp2,'b..');
plot (x,yv,'r');
%plot (x,yvcmp,'r--');
xlim([18 40]);
%ylim([0 5]);
legend('yh','yv')
omsetgrid([1,0]);

% A parameter for graphing
zlim_max=1;

% Do the sine part in higher precision first, to ensure symmetry
% (rather than having circ commands of 12 and 13). Use 5000 pixels
% rather than 50.
%
% Here's half a sine wave. Both at 1900 was my starting point.
sine_width1 = 5000/2;
sine_width2 = sine_width1;

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

onesmultfunc = ones(1,5000);
multfunc1L = onesmultfunc; % sigmultfunc1L, linmultfunc1L or onesmultfunc;
multfunc2L = onesmultfunc; % sigmultfunc2L, linmultfunc2L or onesmultfunc;

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

figure(201);
surf(LSHEET);
zlim([0 zlim_max]);
title('Left');
omsetgrid([1,1]);
if printmaps
    print('left.png');
end

figure(202);
surf(RSHEET);
zlim([0 zlim_max]);
title('Right');
omsetgrid([2,1]);
if printmaps
    print('right.png');
end

figure(203);
surf(USHEET);
zlim([0 zlim_max]);
title('Up');
omsetgrid([3,1]);
if printmaps
    print('up.png');
end

figure(204);
surf(DSHEET);
zlim([0 zlim_max]);
title('Down');
omsetgrid([4,1]);
if printmaps
    print('down.png');
end

figure(208); clf;
surf(DSHEET);
hold on;
surf(LSHEET);
zlim([0 zlim_max]);
view([0,90])
title('Left and down');
omsetgrid([4,2]);

%
%
%
% For the paper
h_f = figure (300); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1000, 2100, 1400]);

% Best viewing angle for the surfaces
viewx=320; viewy=32;

% Spacing for subaxes
sa_spc = 0.03;
sa_pad = 0.03;
sa_pad_mid = 0.04;
sa_pad_2d = 0.03;
sa_marg = 0.08;
sa_marg_mid = 0.1;
sa_marg_sideout = 0.1;

% Your favoured line width and marker size:
lw = 2;
ms = 20;

% Main fontsize
fs1 = 32;

zmax = 1;
%
% Utility functions
%

function offsetxlabel (h)
    xpos = get(h, 'position');
    xpos(2) = xpos(2)+2;
    halfwidth = 2.5;
    xpos(1) = xpos(1)-halfwidth;
    set(h, 'position', xpos);
end

function offsetylabel (h)
    xpos = get(h, 'position');
    xpos(1) = xpos(2)+2.2;
    halfwidth = 2.5;
    %xpos(1) = xpos(1)-halfwidth;
    set(h, 'position', xpos);
end

function offsetzlabel (h)
    xpos = get(h, 'position');
    xpos(1) = xpos(1)-3;
    halfwidth = 0.03;
    xpos(3) = xpos(3)+halfwidth;
    set(h, 'position', xpos);
end

function setaxprops (h, fs)
    set(h, 'fontsize', fs);
end

targxtxt = 'r';
targytxt = '\phi';

% LEFT
hax(1) = subaxis (2,2,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (LSHEET);
setaxprops (hax(1), fs1);

hxl(1)=xlabel(targxtxt, 'fontsize', fs1);
hyl(1)=ylabel(targytxt, 'fontsize', fs1);
%hzl(1)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(1));

%title (['a) Left'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% DOWN
hax(2) = subaxis (2,2,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);


surf (DSHEET);
setaxprops (hax(2), fs1);

hxl(2)=xlabel(targxtxt, 'fontsize', fs1);
hyl(2)=ylabel(targytxt, 'fontsize', fs1);

%title (['b) Down'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% BOTH
hax(6) = subaxis (2,2,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (LSHEET);
hold on;
surf (DSHEET);
setaxprops (hax(6), fs1);

hxl(6)=xlabel(targxtxt, 'fontsize', fs1);
hyl(6)=ylabel(targytxt, 'fontsize', fs1);
%hzl(6)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(6));

view([0 90]);
zlim([0 zmax]);
