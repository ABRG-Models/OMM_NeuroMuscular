% nsurf - plot a neural surface from the model, scaling the phi axis
% so that it runs from 0 to 360 degrees. r could also be scaled,
% but I've left that commented out.
function nsurf (neural_sheet)

    phideg = pixtophidegrees([1:50]);

    % You can scale r to show it in degrees:
    %rdeg = pixtordegrees([1:50]);
    %surf (rdeg,phideg,neural_sheet);
    %xlabel('r (deg)');

    % Or leave it as 1:50:
    surf ([1:50],phideg,neural_sheet);
    xlabel('r');

    ylabel('phi (deg, 0=U, 90=L)')
    set(gca,'YTick',0:90:360);
end
