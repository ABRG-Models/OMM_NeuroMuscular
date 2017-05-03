%
% A script to consume the output of the Oculomotor BG-only model.
%
% This script is tied to the Experiment 
%
% It reads these files from your SpineML_2_BRAHMS temp directory
% (or wherever your experiment output has gone):
%
% /home/seb/src/SpineML_2_BRAHMS/temp/GPe_out_log.bin
% /home/seb/src/SpineML_2_BRAHMS/temp/SNr_a_log.bin
% /home/seb/src/SpineML_2_BRAHMS/temp/SNr_in_log.bin
% /home/seb/src/SpineML_2_BRAHMS/temp/SNr_out_log.bin
% /home/seb/src/SpineML_2_BRAHMS/temp/STN_out_log.bin
% /home/seb/src/SpineML_2_BRAHMS/temp/Str_D1_out_log.bin
%

clear;
close all;

spineml2brahms_path = '/home/seb/src/SpineML_2_BRAHMS/temp/';

expt_files = {'FEF_out_log.bin';
              'Retina_2_out_log.bin';
              'GPe_out_log.bin';
              'SC_deep_out_log.bin';
              'SC_sup_out_log.bin';
              'SNr_out_log.bin';
              'Thalamus_out_log.bin';
              'STN_out_log.bin';
              'Str_D1_out_log.bin'};

% Analyse each of the above files in turn:

for i = 1:size(expt_files,1);
    
    analyse_file (expt_files{i}, 2500);
end
