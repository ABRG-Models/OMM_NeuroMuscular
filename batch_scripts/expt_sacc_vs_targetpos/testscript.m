run_index = 6

model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model1'];
thepath = ['/fastdata/' getenv('USER') '/oculomotorRX0RY7_0.8_' num2str(run_index)];
output_dirs = setup_model_directories ([0, 7], 0.8)
peaktime = find_peaktime ([output_dirs.root '_' num2str(run_index)])

A=load_ocm_min(thepath);

endsacc_x = find_saccade_end (A.eyeRx, peaktime);
endsacc_y = find_saccade_end (A.eyeRy, peaktime);
endsacc = round((endsacc_x + endsacc_y) ./ 2)

[allc_x, allc_y, alla, allb, sca, scd] = find_saccade_location (output_dirs, 1, [],[],[],[]);
alla
allb
allc_x
allc_y
