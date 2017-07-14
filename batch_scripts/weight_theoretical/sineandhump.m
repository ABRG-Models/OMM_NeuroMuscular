% For 2 humps and a gaussian hill, work out the contributions to 2
% channels.

function sineandhump(sineshift, hillwidth, useTopHat=0)

% How much the weight maps are shifted wrt to one anther
%sineshift = 12
% Width of tophat or gaussian
%widthfactor = 4
% If 0, use gaussian
%useTopHat = 0

    zer=zeros(1,70);
    x2=[1:70];
    x=[1:70];
    z = sin( ( (x-1) .*pi ./ 18.75) );

    mask = find(x2<18.75+1);
    mask2 = find(x2>=18.75+1);
    curv1 = [z(mask),zer(mask2)];

    c1 = curv1';
    figure(5)
    clf;
    plot (x2,c1,'-b');
    hold on;

    c2 = circshift(c1, sineshift);
    c3 = circshift(c1, 2.*sineshift);
    plot (x,c2,'-g')
    plot (x,c3,'-m')
    %plot (x,c1.+c2.+c3,'--r')

    function th = tophat(offs, width)
        th=zeros(1,70);
        if(offs-floor(width/2) < 1) || (offs+floor(width/2) > 70)
            return
        end
        th(offs-floor(width/2):offs+floor(width/2)) = 0.2;
    end

    ups = [];
    rights = [];
    downs = [];
    eyes = [];
    for i = [floor(hillwidth/2):70]
        if useTopHat > 0
            hill1 = tophat(i,hillwidth)';
        else
            hill1 = normpdf(x, i, hillwidth/2.6)';
        end
        if (i == 15)
            plot (x,hill1, '-k')
        end

        ups = [ ups; sum(hill1 .* c1) ];
        rights = [ rights;  sum(hill1 .* c2) ];
        downs = [ downs;  sum(hill1 .* c3) ];
        eyes = [ eyes; i ];
    end
    legend('up weights','right weights','down weights','example hill')
    title('Weight maps');
    xlabel('phi')
    ylabel('weight')
    weightpath = ['weights_ss' num2str(sineshift) '_wf' num2str(hillwidth) '.png'];
    print(weightpath);

    % Now plot the signal which would be passed to the muscle channels
    figure(6)
    clf;
    plot (eyes, ups, 'b-');
    hold on;
    plot (eyes, rights, 'g-');
    plot (eyes, downs, 'm-');
    legend('up signal','right signal','down signal')
    xlabel('phi (centre of hill)');
    ylabel('signal to motoneuron channel')
    title('Motoneuron drive')

    mndfpath = ['motodrive_ss' num2str(sineshift) '_wf' num2str(hillwidth) '.png'];
    print(mndfpath);

end
