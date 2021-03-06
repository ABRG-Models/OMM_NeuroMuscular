% Open a file, shape the data to 0-255 per pixel so that it's ready
% for movie making.

% Expects 50x50 format data, as generated by the Oculomotor model.

logDir = '/home/seb/analysis/oculomotor/log/';
population = 'SC_deep';

% Load
data = load_sc_data (char([logDir population '_out_log.bin']), 2500);

% Scale and convert to uint8
data = uint8(data.*256);

% Save
fid = fopen (char([logDir population '_out_uint8.bin']), 'w')
fwrite (fid, data, 'uint8');

% Then at the cmd line
system (char(['mkdir -p ' logDir population]));
system (char(['split -b 2500 ' logDir population '_out_uint8.bin ' ...
                    logDir population '/frame_']));
system (char(['convert -depth 8 -size 50x50 gray:' logDir population ...
              '/frame_* ' logDir population '/frame.jpg']));
% If you want to make it bigger (optional):
system (char(['mogrify -resize 240x240 ' logDir population '/frame*.jpg']));
% make the movie. rate of 50 fps requested. -y means overwrite
% without asking.
system (char(['avconv -y -f image2 -r 50 -i ' logDir population '/frame-%d.jpg ' ...
              logDir population '.mpg']));
