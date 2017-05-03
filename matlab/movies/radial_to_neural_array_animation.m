%
% Create world, window and remapping and make a movie of it.
%

clear all; clc;  close all

% Create world and visual field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfs = 50;          % Size of neural field.  Assumed to be square array

fp = [160 ;160];   % Focal point.  This vector has to come from spineCreator and is the 

window_size = 150; % size of visual field in pixels

E2 = 2.5;
Mf = nfs/(E2*log(((window_size/2)/E2)+1));   % this parameter has an unknown value **** ASK ALEX COPE **** perhaps set such that the number of rows (max(D)) :=> number of rows in field of view ie. 150 => Mf = 1/((E2/D)*log(1+ E/E2)) ==> Mf 4.8651
D = 1:50;  

% parameters for the movie. Modify these to get different kinds of movie.
target_size = 10;  % size of saccade target in pixels
targetx_start = 155;
targety_start = 155;
xmovefn = 'sin';
xmoveamp = 25;
ymovefn = 'cos';
ymoveamp = 15;
avifilename = sprintf ('movies/start%d%d-x%s%d-y%s%d.avi', targetx_start, targety_start, xmovefn, xmoveamp, ymovefn, ymoveamp);
mfilename = sprintf ('movies/start%d%d-x%s%d-y%s%d.mat', targetx_start, targety_start, xmovefn, xmoveamp, ymovefn, ymoveamp);
caption = sprintf ('Start at %d %d x moves as %s amp. %d y moves as %s amp. %d', targetx_start, targety_start, xmovefn, xmoveamp, ymovefn, ymoveamp);

SIN=sin(0:2*pi/150:2*pi);
COS=cos(0:2*pi/150:2*pi);
SAW=[ 0:1/37:1 1:-1/37:-1 -1+1/37:1/37:0 ];


% how many frames will we run (150 is full movie)?
numframes = 150;

% Pre-allocate the MOV container.
MOV(numframes) = struct('cdata',[],'colormap',[]);

for frame = 1:numframes % should be 150
    
if strcmp (xmovefn,  'saw')
    targetx = targetx_start+round(xmoveamp*SAW(frame));
elseif strcmp (xmovefn,  'sin')
    targetx = targetx_start+round(xmoveamp*SIN(frame));
elseif strcmp (xmovefn,  'cos')
    targetx = targetx_start+round(xmoveamp*COS(frame));
else
    targetx = targetx_start;     % Location of target as indicies of the world array. 155,155 for centre.
end

if strcmp (ymovefn,  'saw')
    targety = targety_start+round(ymoveamp*SAW(frame));
elseif strcmp (ymovefn,  'sin')
    targety = targety_start+round(ymoveamp*SIN(frame));
elseif strcmp (ymovefn,  'cos')
    targety = targety_start+round(ymoveamp*COS(frame));
else
    targety = targety_start;
end

targetx = targetx:targetx+target_size;      % Create indices of target location
targety = targety:targety+target_size;

world = 0.01+zeros(300,300);                % Create world array of low luminance pixels

world(targety,targetx) = 1;                 % Create luminous spot at target location

H = fspecial('gaussian',[2,2],0.5);         % Apply a 2 pixel sigma=0.5 gaussian blur to the image
world = imfilter(world,H);                  % This is now the input mask/filter

% Create remapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

E = E2.*(-1+exp(D./(Mf.*E2)));

% We want to find out... where in the visual field does a particular
% neuron's inputs come from? ....  

R = nchoosek(1:nfs,2);                  % create grid of positions of each neuron i.e. locations on the 50x50 grid
R = [R;R(:,[2 1]);[(1:nfs)' (1:nfs)']]; % add on the mirrored locations... and the diagonal elements.

[s,I] = sort(R(:,2));                   % This code is useful for the visulaisation but is not needed when communicating with spineCreator
R = R(I,:);

locx = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*cos(R(:,1).*2.*pi./nfs);  % vectorised calculation of location of x in x-y plane of visual field from where the neuron at location R receives its inputs
locy = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*sin(R(:,1).*2.*pi./nfs);  % vectorised calculation of location of y in x-y plane of visual field from where the neuron at location R receives its inputs

% plot
 
%figure(1); hold on; 
%imagesc(world)
%axis tight
%scatter(locx+fp(1),locy+fp(2),8,'w','filled')
%plot(fp(1),fp(2),'xk')
%title('Whole world.White dots are receptive field of each of the 2500 neurons')

% We then want to find out what the value of the luminance is at that
% particular location.

relevantPixels = [round(locx+fp(1)) round(locy+fp(2))];

L = zeros(1,nfs^2);
for i = 1:nfs^2 
    L(i) = world(relevantPixels(i,2), relevantPixels(i,1)); % 2nd column comes first because columns gives x coordinate, rows gives y coordinate.
end
L = L';

N = 0.3/1e-3;

L = repmat(L,[1,300]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot to check its working OK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
color = linspace(1,0,length(locx));

fig = figure(2);
clf (fig);
colordef(fig, 'none'); % For complete control of colours.
whitebg (fig, 'black');
set(fig, 'Position', [100, 100, 640, 320]);

splots = tight_subplot (1, 2, 0.05, 0.1, 0.05);

text(1,1,caption)

% Whole figure caption?
% Makes flashes on each redraw
% suptitle (caption);

% Retinal map
scatter(splots(1), locx, locy, L(:,1).*100, color, 'filled')
%axis tight square
title (splots(1), '150x150 Visual field');
%set (splots, 'XTick', [], 'YTick', []);

% Cortical map
scatter(splots(2), R(:,1), R(:,2), L(:,1).*100, color, 'filled')
%axis tight square
title(splots(2),'50x50 Neural array')

set (splots, 'XTick', [], 'YTick', []);
set (splots, 'Box', 'on');

MOV(frame) = getframe(fig);

end

% We'll have the movie 3 times:
M = [ MOV MOV MOV ];

% We'll save a copy of the data:
save (mfilename, 'MOV');

% And lastly save it to avi:
movie2avi (M, avifilename);
