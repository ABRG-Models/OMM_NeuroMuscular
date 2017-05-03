## Copyright (C) 2015 S. James
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

## Author: S. James <pc1ssj@node117.iceberg.shef.ac.uk>
## Created: 2015-10-12


figure(1)
clf
hold on;
counter = 1;
for lat_mean = lat_means'
    fmtstr = ['o-' num2str(counter)];
    plot (gap, lat_mean, fmtstr, 'linewidth', 2)
    counter = mod(counter + 1, 6);
end

legend (num2str(lums(1)), num2str(lums(2)),num2str(lums(3)),num2str(lums(4)),num2str(lums(5)),num2str(lums(6)));

xlabel('Gap (s)')
ylabel('Latency to first movement (ms)')
title('Latency vs. gap at different target luminances (1 to 4)')