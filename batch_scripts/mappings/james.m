## Copyright (C) 2018 Seb James
##
##
## A visualisation of the James et al 2018 mapping. This is like Ottes,
## but with the 'A' parameter of that mapping set to approx. 0. and the
## 2ARcos(phi) term omitted.
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

% A function process x,y through the version of Ottes' equations
% used in our models:
function [u,v] = james_doit (x, y)
    Wnfs = 500;
    Wfov = 150;
    E2 = 0.25;
    Mf = Wnfs./(E2.*log(Wfov./(2.*E2) + 1))

    u = Mf.*E2 .* log( (1./E2) .* sqrt(x.*x + y.*y) + 1);
    v = Wnfs./(2.*pi) .* atan2 (y, x);

endfunction

[u_l1, v_l1] = james_doit (l1(:,1), l1(:,2));
[u_l2, v_l2] = james_doit (l2(:,1), l2(:,2));
[u_l3, v_l3] = james_doit (l3(:,1), l3(:,2));
[u_l4, v_l4] = james_doit (l4(:,1), l4(:,2));

[u_c1, v_c1] = james_doit (c1(:,1), c1(:,2));

figure(2); clf;
plot(u_l1, v_l1, 'bo-');
hold on;
plot(u_l2, v_l2, 'ko-');
plot(u_l3, v_l3, 'go-');
plot(u_l4, v_l4, 'mo-');

plot (u_c1, v_c1, 'ro-');
