% Applies simulated annealing algorithm to fit the curve specified in
% weight_surface_one to the data provided in datamap and
% datameans. The Objective function Parameters are passed in as op,
% and the algorithm parameters (temp, cooling rate etc) as
% algo_params.
%
% This was started with the intention of calling it from
% fit_curve_up, fit_curve_down, fit_curve_left etc, but I stopped
% using this approach once I had made the weight finding runs
% stable and developed a linear interpolation scheme for any
% missing points in the weight map.
%
function fitcurve (datamap, datameans, op, algo_params)

    % Full region for the surface; 50x50 grid
    r = 1:50;
    theta = 1:50;
    [R, THETA] = meshgrid (r, theta);


    %
    % Compute first iteration and goodness of fit. Note our curve for
    % fitting in in weight_surface_one.m. This isn't really necessary,
    % but I do it so that we can plot the mesh(v), then in the while
    % loop we can remove the mesh before replotting it.
    %

    v = weight_surface_one (R, THETA, op.a(op.ai), op.k(op.ki), op.b(op.bi), op.l(op.li), op.os(op.osi), op.wg(op.wgi));
    vfit = v;

    afiti = op.ai;
    kfiti = op.ki;
    bfiti = op.bi;
    lfiti = op.li;
    osfiti = op.osi;
    wgfiti = op.wgi;

    % Display the data on to of which the surface mesh will be displayed
    figure(1); hold off; sh = mesh (v); hold on;
    scatter3(datameans(:,2),datameans(:,1),datameans(:,3),'filled');
    zlim([min(datameans(:,3)),max(datameans(:,3))]);

    % goodness of fit for starting value
    gf = goodness_of_fit (datamap, v);

    % initialise lastgf (and bestgf)
    lastgf = gf;
    bestgf = gf;

    %
    % Start the algorithm.
    %

    finished = 0;
    count = 0;
    while finished == 0

        % Generate new numbers. Randomly select a param, then just
        % increment/decrement the params? Or randomly select a new value?
        paramnum = ceil(unifrnd(0,6)); % 1 to n

        % +/- rangesz./10:
        itershift = ceil(unifrnd(0,op.rangesz./10))-ceil(op.rangesz./20);
        switch paramnum
          case 1
            op.ai = shiftiter (op.ai, itershift, op.rangesz);
          case 2
            op.ki = shiftiter (op.ki, itershift, op.rangesz);
          case 3
            op.bi = shiftiter (op.bi, itershift, op.rangesz);
          case 4
            op.li = shiftiter (op.li, itershift, op.rangesz);
          case 5
            op.osi = shiftiter (op.osi, itershift, op.rangesz);
          case 6
            op.wgi = shiftiter (op.wgi, itershift, op.rangesz);
          otherwise
            display ('error!')
        end
        
        v = weight_surface_one (R, THETA, op.a(op.ai), op.k(op.ki), op.b(op.bi), op.l(op.li), op.os(op.osi), op.wg(op.wgi));    

        % Compute a number for goodness of fit:
        gf = goodness_of_fit (datamap, v);

        % The simulated annealing algorithm
        if gf < lastgf
            % accept this one for sure
            acc_prob = 1;
        else
            acc_prob = exp ((lastgf - gf)/algo_params.temp);
        end
        
        % Do we accept it?
        if acc_prob > unifrnd(0,1)
            if gf<2
                display (['accept gf=' num2str(gf) ' at temp ' ...
                          num2str(algo_params.temp)]);
                figure(1); delete(sh); sh = mesh (v);
                drawnow("expose");
            end
            % afiti and friends are the "currently accepted parameter iterators".
            afiti = op.ai;
            kfiti = op.ki;
            bfiti = op.bi;
            lfiti = op.li;
            osfiti = op.osi;
            wgfiti = op.wgi;
            vfit = v;
            lastgf = gf;
            if gf < bestgf
                bestgf = gf;
                % record the parameters of the best fit so we can see
                % them at the end of the algorithm
                abesti = afiti;
                kbesti = kfiti;
                bbesti = bfiti;
                lbesti = lfiti;
                osbesti = osfiti;
                wgbesti = wgfiti;
                vbest = vfit;
            end
        else
            % Don't accept it; revert the the currently accepted fit parameters
            op.ai = afiti;
            op.ki = kfiti;
            op.bi = bfiti;
            op.li = lfiti;
            op.osi = osfiti;
            op.wgi = wgfiti;
        end

        if gf < algo_params.fit_threshold
            finished = 1
        end

        if ~mod(count,10)
            algo_params.temp = algo_params.temp .* (1-algo_params.coolrate);
        end
        
        if algo_params.temp < algo_params.low_temp_threshold
            finished = 1;
        end
        
        count = count + 1;    

    end % while

    % Last, display!
    figure(1); hold off; mesh (vfit); hold on;
    scatter3(datameans(:,2),datameans(:,1),datameans(:,3),'filled');    
    title ('Final fit');
    display (['a=' num2str(op.a(afiti)) ', k=' num2str(op.k(kfiti)) ', b=' num2str(op.b(bfiti)) ...
              ', l=' num2str(op.l(lfiti)) ', os=' num2str(op.os(osfiti)) ', wg=' num2str(op.wg(wgfiti))]);
    if bestgf == gf
        display ('This was the best fit found!');
        figure(2); clf;
    else
        display (['Stopped as the temperature dropped to its final ' ...
                  'value'])
        display(['bestgf was ' num2str(bestgf) ', count was ' ...
                 num2str(count)]);
        figure(2); hold off; mesh (vbest); hold on;
        scatter3(datameans(:,2),datameans(:,1),datameans(:,3),'filled');    
        display (['best values: a=' num2str(op.a(abesti)) ', k=' num2str(op.k(kbesti))  ', b=' num2str(op.b(bbesti)) ...
                  ', l=' num2str(op.l(lbesti)) ', os=' num2str(op.os(osbesti)) ', wg=' num2str(op.wg(wgbesti))]);
        title ('Best (not final) fit');
    end

end
