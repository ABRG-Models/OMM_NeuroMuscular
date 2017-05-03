% % Plot results of a model run. Data should have been stored into
% files by SpineCreator/SpineML_2_BRAHMS.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%spineml2brahms_workdir = '/home/seb/analysis/oculomotor/';
spineml2brahms_workdir = '/fastdata/pc1ssj/oculomotor/';
movFlag = 0;
% Size of neural field.  Assumed to be square array Needs to be same as the
% one in worldDataMaker.m
nfs = 50;

% These data sets are from the OM model, and have 2500 neurons per population.
[ R, ~ ] = load_sc_data ([spineml2brahms_workdir, '/log/Retina_2_out_log.bin'], 2500);
[ SCd, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/SC_deep_out_log.bin'], 2500);
[ STR, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/Str_D1_out_log.bin'], 2500);
[ STN, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/STN_out_log.bin'], 2500);
[ SNr, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/SNr_out_log.bin'], 2500);
[ FEF, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/FEF_out_log.bin'], 2500);
[ Thalamus, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/Thalamus_out_log.bin'], 2500);
[ SCs, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/SC_sup_out_log.bin'], 2500);

% These are the saccade generator model and have 1 neuron per population.
[ LLBN, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/LLBN_left_a_log.bin'], 1);
[ EBN, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/EBN_left_a_log.bin'], 1);
[ TN, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/TN_left_a_log.bin'], 1);
[ MN, ~ ] = load_sc_data ([spineml2brahms_workdir '/log/MN_left_a_log.bin'], 1);

movieMaker (movFlag, nfs, R, SCd, STR, STN, SNr, FEF, Thalamus, SCs, LLBN, EBN, TN, MN)
