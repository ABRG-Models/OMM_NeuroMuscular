% The Foveal mask

% The neural field size - never changes in this model, so this is
% not a parameter.
W_nfs = 50;

% E2 participates in the magnification factor.
E2 = 2.5

r = [1:50]; % 1-50 range here.

M_f = 4.87

sh = 12 % shift

E = E2 .* exp(r./(M_f.*E2)) - E2;

res = 1./(1 + exp(2.*(sh-E)));

res2 = 1./(1 + exp(2.*(sh-r)));

figure(1)
plot (r, E, 'r');
title('E')

figure(2)
plot (r,res,'b');
hold on;
plot (r,res2,'k');
title('res')