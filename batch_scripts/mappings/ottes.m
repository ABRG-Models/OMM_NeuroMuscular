## Copyright (C) 2018 Seb James
##
##
## A visualisation of the Ottes et al 1984 mapping.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Author: Seb James <seb@seb-T460s>
## Created: 2018-03-07

% Use a 500x500 grid in Cartesian space
x = [-250:249]';
y = [-250:249]';

% Define lines and a circle
l1 = [x, x];
l2 = [x, -x];
l3 = [x, zeros(length(x),1)];
l4 = [zeros(length(x),1), y];

c1 = [ x, sqrt(250*250 - power(x,2)); x, -sqrt(250*250 - power(x,2)) ];

figure(1); clf;
plot(l1(:,1), l1(:,2), 'bo');
hold on;
plot(l2(:,1), l2(:,2), 'ko');
plot(l3(:,1), l3(:,2), 'go');
plot(l4(:,1), l4(:,2), 'mo');

plot (c1(:,1), c1(:,2), 'ro');

% Convert to r, phi
r =  sqrt(power(l1(:,1), 2) + power (l1(:,2), 2));
ph = atan2 (l1(:,2), l1(:,1));
l1_rphi = [r, ph ];

r =  sqrt(power(l2(:,1), 2) + power (l2(:,2), 2));
ph = atan2 (l2(:,2), l2(:,1));
l2_rphi = [r, ph ];

r =  sqrt(power(l3(:,1), 2) + power (l3(:,2), 2));
ph = atan2 (l3(:,2), l3(:,1));
l3_rphi = [r, ph ];

r =  sqrt(power(l4(:,1), 2) + power (l4(:,2), 2));
ph = atan2 (l4(:,2), l4(:,1));
l4_rphi = [r, ph ];

r =  sqrt(power(c1(:,1), 2) + power (c1(:,2), 2));
ph = atan2 (c1(:,2), c1(:,1));
c1_rphi = [r, ph ];

% A function process R,phi through Ottes' equations:
function [u,v] = ottes_doit (R, phi)
    A = 1;
    Bu = 1;
    Bv = 1;
    u = Bu.*log(sqrt(power(R,2) + A.*A + 2.*A.*R.*cos(phi))) - Bu.*log(A);
    v = Bv.*atan2 (R.*sin(phi), (R.*cos(phi)+A));
endfunction

[u_l1, v_l1] = ottes_doit (l1_rphi(:,1), l1_rphi(:,2));
[u_l2, v_l2] = ottes_doit (l2_rphi(:,1), l2_rphi(:,2));
[u_l3, v_l3] = ottes_doit (l3_rphi(:,1), l3_rphi(:,2));
[u_l4, v_l4] = ottes_doit (l4_rphi(:,1), l4_rphi(:,2));

[u_c1, v_c1] = ottes_doit (c1_rphi(:,1), c1_rphi(:,2));

figure(2); clf;
plot(u_l1, v_l1, 'bo-');
hold on;
plot(u_l2, v_l2, 'ko-');
plot(u_l3, v_l3, 'go-');
plot(u_l4, v_l4, 'mo-');

plot (u_c1, v_c1, 'ro-');
