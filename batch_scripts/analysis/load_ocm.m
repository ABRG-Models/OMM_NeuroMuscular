% A script to load in the relevant data from the SpineML output.
%
% This script is designed to load the data generated by experiment 0
% of the Oculomotor SpineML model.
%
% All the data is returned in a structure called model_data.
%
% Usually called something like this:
%
% model_data = load_ocm ('/home/seb/src/SpineML_2_BRAHMS/temp');
%
function model_data = load_ocm (output_base_path)

    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    model_log_path = [output_base_path '/log/'];
    model_run_path = [output_base_path '/run/'];

    % Load in activation state vars for SpineML/SpineCreator model
    [fef_add_noise, count] = load_sc_data ([model_log_path ...
                        'FEF_add_noise_out_log.bin'], 2500);
    [fef, count] = load_sc_data ([model_log_path ...
                        'FEF_out_log.bin'], 2500);
    [strd1, count] = load_sc_data ([model_log_path ...
                        'Str_D1_out_log.bin'], 2500);
    [strd2, count] = load_sc_data ([model_log_path ...
                        'Str_D2_out_log.bin'], 2500);
    [stn, count] = load_sc_data ([model_log_path ...
                        'STN_out_log.bin'], 2500);
    [snr, count] = load_sc_data ([model_log_path ...
                        'SNr_out_log.bin'], 2500);
    [gpe, count] = load_sc_data ([model_log_path ...
                        'GPe_out_log.bin'], 2500);

    [world, count] = load_sc_data ([model_log_path ...
                        'World_out_log.bin'], 2500);

    [ret1, count] = load_sc_data ([model_log_path ...
                        'Retina_1_out_log.bin'], 2500);
    [ret2, count] = load_sc_data ([model_log_path ...
                        'Retina_2_out_log.bin'], 2500);

    [scd, count] = load_sc_data ([model_log_path ...
                        'SC_deep_out_log.bin'], 2500);
    [scd_tt, count] = load_sc_data ([model_log_path ...
                        'SC_deep_to_SC_deep_Synapse_1_postsynapse_out_log.bin'], 2500);
    
    [scs, count] = load_sc_data ([model_log_path ...
                        'SC_sup_out_log.bin'], 2500);
    %    [scsm, count] = load_sc_data ([model_log_path ...
    %                        'SC_smoothing_a_log.bin'], 2500);
    [sca_in, count] = load_sc_data ([model_log_path ...
                        'SC_avg_in_copy_log.bin'], 2500);
    [sca, count] = load_sc_data ([model_log_path ...
                        'SC_avg_out_log.bin'], 2500);

    [thal, count] = load_sc_data ([model_log_path ...
                        'Thalamus_out_log.bin'], 2500);
                    
    [mirror, count] = load_sc_data ([model_log_path ...
                        'Mirror_out_log.bin'], 2500);
 
%     [cogcontfef, count] = load_sc_data ([model_log_path ...
%                         'CogCont_outFEF_log.bin'], 2500);       
%                     
%     [cogcontmirror, count] = load_sc_data ([model_log_path ...
%                         'CogCont_outMirror_log.bin'], 2500);
                    
                    
    [r2_to_r1, count] = load_sc_data ([model_log_path ...
                        'Retina_2_to_Retina_1_Synapse_0_postsynapse_out_log.bin'], 2500);
                    
    [w_to_r1, count] = load_sc_data ([model_log_path ...
                        'World_to_Retina_1_Synapse_0_postsynapse_out_log.bin'], 2500);

    % Saccade generator, left
    [opn, count] = load_sc_data ([model_log_path 'OPN_a_log.bin'], 1);
    [llbn_l, count] = load_sc_data ([model_log_path 'LLBN_left_a_log.bin'], 1);
    %[llbn_in, count] = load_sc_data ([model_log_path ...
    %                    'SC_deep_output_to_LLBN_left_Synapse_0_postsynapse_out_log.bin'], 1);
    llbn_in = 0;
    [ebn, count] = load_sc_data ([model_log_path 'EBN_left_a_log.bin'],1);
    [ibn, count] = load_sc_data ([model_log_path 'IBN_left_a_log.bin'], 1);
    %[ibn2scd, count] = load_sc_data ([model_log_path 'IBN_left_to_SC_deep_Synapse_0_postsynapse_out_log.bin'], 1);
    [tn, count] = load_sc_data ([model_log_path 'TN_left_a_log.bin'], 1);
    [mn, count] = load_sc_data ([model_log_path 'MN_left_a_log.bin'], 1);

    % Saccade generator, right
    [llbn_r, count] = load_sc_data ([model_log_path 'LLBN_right_a_log.bin'], 1);
    llbn_in_r = 0;
    %[llbn_in_r, count] = load_sc_data ([model_log_path ...
    %                    'SC_deep_output_to_LLBN_right_Synapse_0_postsynapse_out_log.bin'], 1);
    [llbn_u, count] = load_sc_data ([model_log_path 'LLBN_up_a_log.bin'], 1);
    [llbn_d, count] = load_sc_data ([model_log_path 'LLBN_down_a_log.bin'], 1);
    [llbn_zp, count] = load_sc_data ([model_log_path 'LLBN_zplus_a_log.bin'], 1);
    [llbn_zm, count] = load_sc_data ([model_log_path 'LLBN_zminus_a_log.bin'], 1);

    
    [ebn_r, count] = load_sc_data ([model_log_path 'EBN_right_a_log.bin'],1);
    [ibn_r, count] = load_sc_data ([model_log_path 'IBN_right_a_log.bin'], 1);
    [tn_r, count] = load_sc_data ([model_log_path 'TN_right_a_log.bin'], 1);
    [mn_r, count] = load_sc_data ([model_log_path 'MN_right_a_log.bin'], 1);

    r2_to_r1 = reshape (r2_to_r1, 50, 50, []);
    w_to_r1 = reshape (w_to_r1, 50, 50, []);
    fef_add_noise = reshape (fef_add_noise, 50, 50, []);
    fef = reshape (fef, 50, 50, []);
    strd1 = reshape (strd1, 50, 50, []);
    strd2 = reshape (strd2, 50, 50, []);
    stn = reshape (stn, 50, 50, []);
    snr = reshape (snr, 50, 50, []);
    gpe = reshape (gpe, 50, 50, []);
    ret1 = reshape (ret1, 50, 50, []);
    ret2 = reshape (ret2, 50, 50, []);
    world = reshape (world, 50, 50, []);
    scd = reshape (scd, 50, 50, []);
    scd_tt = reshape (scd_tt, 50, 50, []);
    sca_in = reshape (sca_in, 50, 50, []);
    scs = reshape (scs, 50, 50, []);
    sca = reshape (sca, 50, 50, []);
    thal = reshape (thal, 50, 50, []);
    mirror = reshape (mirror, 50, 50, []);
%     cogcontfef = reshape (cogcontfef, 50, 50, []);
%     cogcontmirror = reshape (cogcontmirror, 50, 50, []);

    % Eye rotations
    SS = csvread ([model_run_path 'saccsim_side.log'], 1 , 0);
    eyeRx = SS(:,8);
    eyeRy = SS(:,9);
    eyeRz = SS(:,10);
    eyeTime = SS(:,1);
    clear SS;
    %eyeRx = 0;
    %eyeRy = 0;
    %eyeRz = 0;
    %eyeTime = 0;

    % Now build up the structure to return.
    keySet = {'r2_to_r1', 'w_to_r1', 'fef_add_noise', 'fef', 'strd1', ...
              'strd2', 'stn', 'snr', 'gpe', 'ret1', 'ret2', 'world', ...
              'scd', 'scd_tt', 'sca_in', 'scs', 'sca', ...
              'thal', 'eyeRx', 'eyeRy', 'eyeRz', ...
              'eyeTime', 'opn', 'llbn_l', 'llbn_in', 'ebn', 'tn', 'mn', 'ibn', ...
              'llbn_r', 'llbn_in_r', 'llbn_u', 'llbn_d', 'llbn_zp', ...
              'llbn_zm', 'ebn_r', 'tn_r', 'mn_r', 'ibn_r','mirror'}; % ,'cogcontfef', 'cogcontmirror'
    valueSet = {r2_to_r1, w_to_r1, fef_add_noise, fef, strd1, strd2, ...
                stn, snr, gpe, ret1, ret2, world, scd, scd_tt, sca_in, scs, sca, ...
                thal, ...
                eyeRx, eyeRy, eyeRz, eyeTime, opn, llbn_l, llbn_in, ebn, tn, ...
                mn, ibn, llbn_r, llbn_in_r, llbn_u, llbn_d, llbn_zp, llbn_zm, ebn_r, tn_r, mn_r, ibn_r, mirror}; %, cogcontfef, cogcontmirror
    model_data = struct();
    for i = 1:numel (keySet)
        model_data.(keySet{i}) = valueSet{i};
    end 

end