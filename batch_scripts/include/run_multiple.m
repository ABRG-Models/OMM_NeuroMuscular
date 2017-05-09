%% Run the model n times for a given target
%% and collect the output angle each time. Use run_simulation_multi()
%%
%% Author: Seb James.

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if isOctave
    page_screen_output(0);
    page_output_immediately(1);
end
addpath ('./include');

% The input model. Hardcoded. Luminances therein are left alone.
model_dir = '/home/co1ssj/OMM_NeuroMuscular/Model1';

num_par_runs = 6;

output_dirs = setup_model_output_directories ('ocmot_multi');
[ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_multi ...
    (model_dir, output_dirs, num_par_runs, 1);
