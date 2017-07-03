% octave file to investigate the widening gaussian projective field

W_nfs = 50
% Widening Factor
WF = 15
sigma = 3
E2 = 2.5

rshift = 5;
r = [1+rshift:50+rshift];

M_f =  W_nfs ./ (E2 .* log ((r/(2.*E2))+1));
figure(1)
plot (r, M_f);
xlabel('r');
ylabel('MagFactor(r)');

_sigma = WF.*sigma./M_f;
_SIGMA=repmat(_sigma, 50, 1)

figure(2)
plot (r, _sigma);
xlabel('r');
ylabel('_sigma(r)');

%normterm = 1./(power(_sigma,2).*2.*pi);
%NORMTERM = repmat(normterm, 50, 1);
normterm = 1./(power(sigma,2).*2.*pi);
NORMTERM = normterm;
figure(4)
plot (r, normterm);
title ('normterm(r)');

d = [1:50];
D = repmat (d, 50, 1)';

GAUSS = NORMTERM.*exp(-0.5.*power(D./_SIGMA,2));
figure(3)
surf(GAUSS)
xlabel('r')
ylabel('d')
ylim([1,15])
view([268 0.1])
