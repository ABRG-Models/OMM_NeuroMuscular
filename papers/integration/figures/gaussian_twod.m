% Plot a 2d gaussian in 3d
N = 2.0;
x=linspace(-N, N, 50);
y=x;
[X,Y]=meshgrid(x,y);
function offsetzlabel (h)
    xpos = get(h, 'position');
    xpos(1) = xpos(1)-0.2; % Out
    halfwidth = 0.0; % up/down
    xpos(3) = xpos(3)+halfwidth;
    set(h, 'position', xpos);
end

figure(1)
clf

z=(2/sqrt(2*pi).*exp(-(X.^2/2)-(Y.^2/2)));
z(z<=0.2) = 0;
%size(zz);
%size(zzz);
colormap('autumn')
surf(X,Y,z);
%shading interp
%axis tight

ax=gca
set(ax, 'fontsize', fs1)
axpos=get(ax,'position');
axpos=[axpos(1)+0.08,axpos(2)+0.05,axpos(3),axpos(4)];
set(ax, 'position', axpos)

fs1=32

xlabel('d (x)', 'fontsize', fs1)
ylabel('d (y)', 'fontsize', fs1)
h = zlabel('weight', 'fontsize', fs1)

offsetzlabel(h);