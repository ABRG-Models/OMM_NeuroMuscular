%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create world, window and remapping for the Oculomotor model input.
% 10/04/2014, to 17/09/2014
%
% This code requires access to spinemlnet mex or oct files found in
% SpineCreator/networkserver/matlab/; a function from
% SpineCreator/analysis_utils/matlab and matlab code from
% abrg_local/Oculomotor/matlab. Add these to your octave/matlab path.
%

clear all; clc; close all

% Create world and visual field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ftDelay = -20e-3;    % delay in seconds between the disappearance of
                     % the fixation point and the appearance of the
                     % target.  Negative value implies an
                     % OVERLAP. Zero value implies a STEP.

dt  = 0.5e-3;        % size of spineCreator solver timestep

T = 0.3;             % Length of simulation

Tstim = 70e-3;       % Time of target onset (seconds)

nfs = 50;            % Size of neural field.  Assumed to be square
                     % array

background = 0.0;   % background luminance

fp = [150 ;150];     % Focal point.  This vector has to come fromspineCreator and is the
   
luminance = 0.5;

target_size = 4;     % size of target in pixels

% Create indices of target location
fixatex = fp(1)-target_size/2:fp(1)+target_size/2;
fixatey = fp(2)-target_size/2:fp(2)+target_size/2;

window_size = 150;   % size of visual field in pixels

% Location of centre of target as indicies of the 300x300 world array
targetX = str2num(getenv('XLOC'));
targetY = 150; % str2num(getenv("YLOC"));

% Create indices of target location
targetx = targetX-target_size/2:targetX+target_size/2;
targety = targetY-target_size/2:targetY+target_size/2;

% Create world array of low luminance pixels
worldBlank = background+zeros(300,300);

% Create target image
worldTarget = worldBlank;
% Create luminous spot at target location
worldTarget(targety,targetx) =  luminance;
% Apply a 2 pixel sigma=0.5 gaussian blur to the image
H = fspecial('gaussian',[2,2],0.5);
worldTarget = imfilter(worldTarget,H);

% Create fixation image
worldFixate = worldBlank;
% Create luminous spot at fixation location
worldFixate(fixatey,fixatex) = luminance;
% Apply the same blur to this image
worldFixate = imfilter(worldFixate,H);

% Create fixation image
worldBoth = worldBlank;

% Create luminous spot at fixation and target locations
worldBoth(fixatey,fixatex) = luminance;
worldBoth(targety,targetx) = luminance;

worldBoth = imfilter(worldBoth,H);

% Create remapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

E2 = 2.5;

% this parameter has an unknown value **** ASK ALEX COPE **** perhaps
% set such that the number of rows (max(D)) :=> number of rows in
% field of view ie. 150 => Mf = 1/((E2/D)*log(1+ E/E2)) ==> Mf 4.8651
Mf = nfs/(E2*log(((window_size/2)/E2)+1));

D = 1:50;   

E = E2.*(-1+exp(D./(Mf.*E2)));

% We want to find out... where in the visual field does a particular
% neuron's inputs come from? ....

% create grid of positions of each neuron i.e. locations on the 50x50
% grid
R = nchoosek(1:nfs,2);
% add on the mirrored locations... and the diagonal elements.
R = [R;R(:,[2 1]);[(1:nfs)' (1:nfs)']];

% This code is useful for the visulaisation but is not needed when
% communicating with spineCreator
[s,I] = sort(R(:,2));
R = R(I,:);
[s,I] = sort(R(:,1));
R = R(I,:);

% vectorised calculation of location of x and y in x-y plane of visual
% field from where the neuron at location R receives its inputs
locx = E2.*(-1+exp(R(:,1)./(Mf.*E2))).*sin(R(:,2).*2.*pi./nfs);
locy = E2.*(-1+exp(R(:,1)./(Mf.*E2))).*cos(R(:,2).*2.*pi./nfs);

%% plot
%figure(1); clf; hold on; 
%imagesc(worldBoth)
%axis tight
%scatter(locx+fp(1),locy+fp(2),8,'w','filled')
%plot(fp(1),fp(2),'xk')
%title('Whole world.White dots are receptive field of each of the 2500 neurons')

% We then want to find out what the value of the luminance is at that
% particular location.

relevantPixels = [round(locx+fp(1)) round(locy+fp(2))]; % [x y] coordinates

Ltarget = zeros(nfs^2,1);
Lfixate = zeros(nfs^2,1);
Lboth   = zeros(nfs^2,1);
Lneither= zeros(nfs^2,1);

for i = 1:nfs^2 
    % 2nd column comes first because columns gives x coordinate, rows
    % gives y coordinate.
    Ltarget(i) = worldTarget(relevantPixels(i,2), relevantPixels(i,1));
    Lfixate(i) = worldFixate(relevantPixels(i,2), relevantPixels(i,1));
    Lboth(i)   = worldBoth  (relevantPixels(i,2), relevantPixels(i,1));
    Lneither(i)= worldBlank (relevantPixels(i,2), relevantPixels(i,1));
end

Ntotal   = T/dt;
Nfixate  = Tstim/dt; 
% number of timesteps for which both tartget and fixation are ON.
Noverlap = ftDelay/dt;

if Noverlap < 0       % OVERLAP CASE
    % 100ms of blank world before the target appears for the next 200ms.
    L = [repmat(Lfixate,[1,Nfixate-abs(Noverlap)]) repmat(Lboth,[1,abs(Noverlap)]) repmat(Ltarget,[1,Ntotal-Nfixate])];

elseif Noverlap == 0  % STEP CASE
    
    L = [repmat(Lfixate,[1,Nfixate])  repmat(Ltarget,[1,Ntotal-Nfixate])];
    
elseif Noverlap > 0   % DELAY CASE
    % 100ms of blank world before the target appears for the next 200ms.
    L = [repmat(Lfixate,[1,Nfixate]) repmat(Lneither,[1,Noverlap]) repmat(Ltarget,[1,Ntotal-Nfixate-abs(Noverlap)])];
else
    error('badly stated Delay term');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot to check its working OK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%color = linspace(1,0,length(locx));

%figure(2); clf
%subplot(1,2,1);hold on
%These scatter plots are very slow on octave, so I commented them out.
%scatter(locx, locy, Ltarget(:,1).*30, color, 'filled')

%axis tight square
%title('Locations in 150x150 visual field')

% subplot(1,2,2)
%scatter(R(:,1), R(:,2), Ltarget(:,1).*30, color, 'filled')
%b = reshape(Ltarget,nfs,nfs);
%imagesc(b);
%axis tight square
%title('Corresponding locations in 50x50 neural array')

%x = reshape(Lboth,nfs,nfs);
%figure(3); clf
%imagesc(x);


% We now need to pass these luminance values to SpineCreator:
 worldDataMaker_sn_run(L);
