function success = write_single_luminance (file_path, targetThetaX, targetThetaY)
    lum_file = fopen (file_path, 'w');
    if lum_file == -1
        display ('Failed to open luminances.json file for writing.');
        success = 0;
        return
    end
    fprintf (lum_file, ['{"luminances":[' ...
                        '{"shape":"cross","thetaX":%d,' ...
                        '"thetaY":%d,"widthThetaX":6,"widthThetaY":2,' ...
                        '"luminance":0.2,"timeOn":0.12,"timeOff":0.6}]}'], ...
             targetThetaX, targetThetaY);
    fclose (lum_file);
    success = 1;
end
