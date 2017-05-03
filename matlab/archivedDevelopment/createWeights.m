% create SCdeep - llbn weights

clear all 
close all 
clc

wl = zeros(50,50);
wr = zeros(50,50);

wr(12,:) = linspace(0,1,50);
wr(13,:) = linspace(0,1,50);
wl(37,:) = linspace(0,1,50);
wl(38,:) = linspace(0,1,50);

wl(:,1:14) = 0;
wr(:,1:5) = 0;

window_size = 150;
E2 = 2.5;
nfs = 50;
Mf = nfs/(E2*log(((window_size/2)/E2)+1));

% need to find D for which E is 5, 10 and 15 degrees
E = [5 10 15];
D = Mf.*E2.*log(1+(E./E2));

% Hand manipulate weights
wl(37,12:20) = 0.10; % 0.8
wl(37,20:26) = 0.11;   % 0.12
wl(37,27:35) = 0.3;  % 0.3
wl(37,35:end) = 0;

wl(38,:) = wl(37,:);

wr(12,:) = wl(37,:);
wr(13,:) = wl(37,:);

figure(1); clf; hold on
imagesc(wl);
title(' left weights')
plot(D,[37 37 37],'xk')

figure(2); clf; hold on
%plot(1:50,wl(37,:))
stem(D,wl(37,round(D)))
%title('weights left at 5 ,10 and 15 degrees')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(3);
d = 10:30
y =  0.1+0.25./(1+exp(-d+27));
%y(d<10) = [];
%y(d>30) = [];

%d(d<10) = [];
%d(d>30) = [];

plot(d,y,'r','lineWidth',2)
xlim([0 50]);
xlabel('Column number in SC deep neural sheet')
ylabel('Connection strength');

wl(37,:) = y;
wl(38,:) = y;
wr(12,:) = y;
wr(13,:) = y;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wl = reshape(wl,50*50,1);
wr = reshape(wr,50*50,1);

csvwrite('ScLlbnWeightsLeft.csv',wl);
csvwrite('ScLlbnWeightsRight.csv',wr);

input('rtn to exit','s')
