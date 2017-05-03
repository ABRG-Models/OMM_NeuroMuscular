%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create world, window and remapping
% 10/04/2014

clear all; clc;  close all

% Don't addpath in a script - makes it un-portable. Much better to put
% paths in your matlab/octave configuration.
% Make sure that the SpineCreator networkserver oct/mex files are
% in your path.
% addpath /home/seb/src/SpineCreator/networkserver/matlab

% Create world and visual field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neural_fieldsize = 50;          % Size of neural field.  Assumed to be square array

focal_point = [160 ;160];   % Focal point.  This vector has to come from spineCreator and is the

window_size = 150; % size of visual field in pixels

% world is 300x300, rather than 50x50, as will be sent to the experiment in
% SpineCreator. Here, we make two target frames.
target1 = make_target (215, 155, 10, 10);
target2 = make_target (175, 125, 10, 10);

% Create remapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% What's E2, and why is it 2.5?
E2 = 2.5;
% this parameter has an unknown value **** ASK ALEX COPE ****
% perhaps set such that the number of rows (max(D)) :=> number
% of rows in field of view ie. 150 => Mf = 1/((E2/D)*log(1+ E/E2)) ==> Mf 4.8651
Mf = neural_fieldsize/(E2*log(((window_size/2)/E2)+1))

% We want to find out... where in the visual field does a particular
% neuron's inputs come from? ....
R = all_grid_coordinates (neural_fieldsize);

% vectorised calculations of locations of x and y in x-y plane of visual
% field from where the neuron at location R receives its inputs
locx = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*cos(R(:,1).*2.*pi./neural_fieldsize);
locy = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*sin(R(:,1).*2.*pi./neural_fieldsize);

% plot

showfigures = 0;
if showfigures == 1
    figure(1); clf; hold on;
    imagesc(target1)
    axis tight
    scatter(locx+focal_point(1),locy+focal_point(2),8,'w','filled')
    plot(focal_point(1),focal_point(2),'xk')
    title('Whole world. White dots are receptive field of each of the 2500 neurons')
    imagesc(target2)
    scatter(locx+focal_point(1),locy+focal_point(2),8,'w','filled')
    plot(focal_point(1),focal_point(2),'xk')
end

% We then want to find out what the value of the luminance is at that
% particular location.

% This is "relevant pixels from the target1 300x300 frame"
relevantPixels = [round(locx+focal_point(1)) round(locy+focal_point(2))];

% L1 and L2 are the target frames, in SpineCreator "sheet" mode.
L1 = zeros(1,neural_fieldsize^2);
L2 = L1;
for i = 1:neural_fieldsize^2
    % 2nd column comes first because columns gives x coord, rows gives y.
    L1(i) = target1 (relevantPixels(i,2), relevantPixels(i,1));
    L2(i) = target2 (relevantPixels(i,2), relevantPixels(i,1));

    if L1(i) > 0.3
        % This line to display the index of active neurons.
        formatStr = 'Index of an early active input neuron: %d(matlab), %d(SpineCreator)';
        display (sprintf(formatStr, i, i-1));
    end

    if L2(i) > 0.3
        % This line to display the index of active neurons.
        formatStr = 'Index of a late active input neuron: %d(matlab), %d(SpineCreator)';
        display (sprintf(formatStr, i, i-1));
    end
end

% Transpose the matrices
L1 = L1';
L2 = L2';

% A combined state, both targets visible:
L1L2 = L1 + L2;

%size(L) % 2500 1.
%LONE=L(:,1);
%szLONE = size(LONE)

% Create an "Off state" - a neural_fieldsize sized frame containing 0.01 in
% every element.
Loff = 0.01+zeros(neural_fieldsize^2,1);

% replicate Loff 100 times for the "off series" 0 to 0.1s
Loff = repmat(Loff,[1,100]);
%szLoff = size(Loff)

% replicate L 50 times for the first "on" series , where L1 is on by
% itself.
L1 = repmat(L1,[1,50]);

% Now L1 and L2 are on for a further 100 frames
L1L2 = repmat(L1L2,[1,100]);

% Finally, L2 is on for another 50 frames
L2 = repmat(L2,[1,50]);

% Join 'em
L1 = [Loff, L1, L1L2, L2];

szL1 = size(L1) % 2500 300

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot to check its working OK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if showfigures == 1
    color = linspace(1,0,length(locx));

    figure(2); clf
    subplot(1,2,1);hold on
    scatter(locx, locy, L1(:,1).*100, color, 'filled')

    axis tight square
    title('Locations in 150x150 visual field')

    subplot(1,2,2)
    scatter(R(:,1), R(:,2), L1(:,1).*100, color, 'filled')
    axis tight square
    title('Corresponding locations in 50x50 neural array')
end

% We now need to pass these luminance values to SpineCreator
[R, F, T, Sd1, S, GPe, GPi, SCd, SCs]  = worldDataMaker1_sn_run(L1); %

% Plot results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% N = 0.3/1e-3;
% figure(3); clf; hold on
%
% for ploti=1:N
%     subplot(2,2,1); hold on
%     plot(Sd1(ploti,:));ylim([0 1]);
%     title('D1Str')
%
%     subplot(2,2,2); hold on
%     plot(S(ploti,:));ylim([0 1]);
%     title('STN')
%
%     subplot(2,2,3); hold on
%     plot(GPe(ploti,:));ylim([0 1]);
%     title('GPe')
%
%     subplot(2,2,4); hold on
%     plot(GPi(ploti,:));ylim([0 1]);
%     title('GPi')
% end
%
% figure(4); clf; hold on
%
% for ploti=1:4
%     subplot(2,2,1); hold on
%     plot(Sd1(ploti,:),'r');ylim([0 1]);
%     title('D1Str')
%
%     subplot(2,2,2); hold on
%     plot(S(ploti,:),'r');ylim([0 1]);
%     title('STN')
%
%     subplot(2,2,3); hold on
%     plot(GPe(ploti,:),'r');ylim([0 1]);
%     title('GPe')
%
%     subplot(2,2,4); hold on
%     plot(GPi(ploti,:),'r');ylim([0 1]);
%     title('GPi')
% end
