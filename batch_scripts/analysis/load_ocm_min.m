% This is a minimum version of load_ocm.m to load data from a weight
% training run (experiment 2, which logs from fewer populations).
function model_data = load_ocm_min (output_base_path)

    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    model_log_path = [output_base_path '/log/'];
    model_run_path = [output_base_path '/run/'];

    % Load in activation state vars for SpineML/SpineCreator model
    [scd, count] = load_sc_data ([model_log_path ...
                        'SC_deep_out_log.bin'], 2500);
    
    [sca, count] = load_sc_data ([model_log_path ...
                        'SC_avg_out_log.bin'], 2500);

    [llbn_l, count] = load_sc_data ([model_log_path 'LLBN_left_a_log.bin'], 1);
    [llbn_r, count] = load_sc_data ([model_log_path 'LLBN_right_a_log.bin'], 1);
    [llbn_u, count] = load_sc_data ([model_log_path 'LLBN_up_a_log.bin'], 1);
    [llbn_d, count] = load_sc_data ([model_log_path 'LLBN_down_a_log.bin'], 1);
    %[llbn_zp, count] = load_sc_data ([model_log_path 'LLBN_zplus_a_log.bin'], 1);
    %[llbn_zm, count] = load_sc_data ([model_log_path 'LLBN_zminus_a_log.bin'], 1);

    scd = reshape (scd, 50, 50, []);
    sca = reshape (sca, 50, 50, []);

    % Eye rotations
    SS = csvread ([model_run_path 'saccsim_side.log'], 1 , 0);
    eyeRx = SS(:,8);
    eyeRy = SS(:,9);
    eyeRz = SS(:,10);
    eyeTime = SS(:,1);
    clear SS;

    % Now build up the structure to return.
    keySet = {'scd', 'sca', ...
              'eyeRx', 'eyeRy', 'eyeRz', 'eyeTime', ...
              'llbn_l', 'llbn_r', 'llbn_u', 'llbn_d'}; %, 'llbn_zp', 'llbn_zm'};
    valueSet = {scd, sca, ...
                eyeRx, eyeRy, eyeRz, eyeTime, ...
                llbn_l, llbn_r, llbn_u, llbn_d}; %, llbn_zp, llbn_zm};
    model_data = struct();
    for i = 1:numel (keySet)
        model_data.(keySet{i}) = valueSet{i};
    end 

end