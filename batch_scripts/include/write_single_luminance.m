% An experiment standard (cross, 6, 2) single luminance of magnitude
% 1.8 occuring at targetThetaX,targetThetaY, occurring 0.12 seconds
% into experiment. From 0 to 0.12 s a fixation luminance of magnitude
% 0.5 (but same shape & size) exists at (0,0)
function success = write_single_luminance (file_path, targetThetaX, targetThetaY, lumval)
    lum_file = fopen (file_path, 'w');
    if lum_file == -1
        display ('Failed to open luminances.json file for writing.');
        success = 0;
        return
    end

    % Hard-coded parameters
    step_time = 0.18; % was 0.12
    fix_lum = 0.5;

    fprintf (lum_file, ['{"luminances":[' ...
                        '{"shape":"cross","thetaX":0,' ...
                        '"thetaY":0,"widthThetaX":6,"widthThetaY":2,' ...
                        '"luminance":%.2f,"timeOn":0,"timeOff":%.2f},' ...
                        '{"shape":"cross","thetaX":%d,' ...
                        '"thetaY":%d,"widthThetaX":6,"widthThetaY":2,' ...
                        '"luminance":%.2f,"timeOn":%.2f,"timeOff":2}]}'], ...
             fix_lum, step_time, targetThetaX, targetThetaY, lumval, step_time);
    fclose (lum_file);
    success = 1;
end
