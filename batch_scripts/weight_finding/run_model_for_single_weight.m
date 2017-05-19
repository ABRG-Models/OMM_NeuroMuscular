addpath ('./include');

targetThetaY = -10;
weight = 0.47;

num_parallel = 8; % How many times to run

% The input model. Hardcoded.
orig_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model1'];
% This codes makes a copy here:
model_dir = '/fastdata/' getenv('USER') '/input_models/';
cmd = ['mkdir -p ' model_dir];
system (cmd);
model_dir = [model_dir 'OculomotorT' num2str(targetThetaY)];
cmd = ['rm -rf ' model_dir];
system (cmd);
cmd = ['cp -Ra ' orig_model_dir ' ' model_dir];
system (cmd);

% Write luminances.json into model dir:
if (write_single_luminance ([model_dir '/luminances.json'], targetThetaY)) < 1
    return
end

counter = 1;
output_dirs = setup_model_directories (targetThetaY, counter);

if targetThetaY < 0
    % Saccade to right
    weightsBinaryFile = '/explicitDataBinaryFile53.bin';
else
    % Saccade to left
    weightsBinaryFile = '/explicitDataBinaryFile52.bin';
end

% With centroids we can always write a plane weight.
write_plane_weights ([model_dir weightsBinaryFile], weight);

display ('Running...');
[ eyeRyAvg, eyeRySD ] = run_simulation_multi (model_dir, output_dirs, num_parallel);
