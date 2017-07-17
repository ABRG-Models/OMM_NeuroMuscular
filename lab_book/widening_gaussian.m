% octave file to investigate the widening gaussian projective field
% This is then implemented in the model as the WideningGaussian
% python connection script.

% The neural field size - never changes in this model, so this is
% not a parameter.
W_nfs = 50

%
% The following will be parameters to the WideningGaussian script
%
% The sigma constant from which sigma(r) is computed
sigma = 25
% E2 participates in the magnification factor. In practice this is
% not changed, but it's still included as a param.
E2 = 2.5
% An r shift - required in the Python script due to indexing from 0
_rshift = 1;
% A normalisation power
normpower = 1.4;

r = [1+_rshift:50+_rshift];


M_f =  W_nfs ./ (E2 .* log (((r)/(2.*E2))+1));

rshift = 5; % Past the foveal region
M_f(1:rshift) = M_f(rshift);

figure(1)
plot (r, M_f);
xlabel('r');
ylabel('MagFactor(r)');
title ('MagFactor');

_sigma = sigma./M_f;
_SIGMA=repmat(_sigma, 50, 1);

figure(2)
plot (r, _sigma);
xlabel('r');
ylabel('(underscore)sigma(r)');
title('sigma(r)');

d = [1:50];
D = repmat (d, 50, 1)';

% This gives good normalisation.
normterm = 1./power(_sigma,normpower);

figure(4)
plot (r, normterm);
title ('normterm(r)');


GAUSS = normterm.*exp(-0.5.*power(D./_SIGMA,2));
figure(3)
surf(GAUSS)
xlabel('r')
ylabel('d')
ylim([1,15])
view([268 0.1])


figure(5);
plot (r, sum(GAUSS, 1));
title('Sum of GAUSS surface (figure 3) along d axis')
ylim([0 1.25])