% Like write_step_luminance but with additional params to allow gap
% and step paradigms.
%
% params are:
%
% params.fixWidthX
% params.fixWidthY
% params.fixLuminance
% params.fixOn
% params.fixOff
% params.targetThetaX
% params.targetThetaY
% params.targetLuminance
% params.targetOn
% params.targetOff
%
function success = write_single_luminance_with_fix (file_path, params)
    lum_file = fopen (file_path, 'w');
    if lum_file == -1
        display ('Failed to open luminances.json file for writing.');
        success = 0;
        return
    end
    fprintf (lum_file, ['{"luminances":[' ...
                        '{"shape":"square","thetaX":0,' ...
                        '"thetaY":0,"widthThetaX":%d,"widthThetaY":%d,' ...
                        '"luminance":%f,"timeOn":%f,"timeOff":%f},' ...
                        '{"shape":"square","thetaX":%d,' ...
                        '"thetaY":%d,"widthThetaX":%d,"widthThetaY":%d,' ...
                        '"luminance":%f,"timeOn":%f,"timeOff":%f}]}'], ...
             params.fixWidthX, params.fixWidthY, ...
             params.fixLuminance, params.fixOn, params.fixOff, ...
             params.targetThetaX, params.targetThetaY, ...
             params.targetWidthX, params.targetWidthY, ...
             params.targetLuminance, params.targetOn, params.targetOff);
    fclose (lum_file);
    success = 1;
end
