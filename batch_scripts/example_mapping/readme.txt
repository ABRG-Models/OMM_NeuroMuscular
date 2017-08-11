The worldframe view of the luminances is generated using
worldtest_mapping.cpp and worldtest_mapping.m. Then create the FEF
frames by running the model with the luminances.json file in this
directory, TModel4, expt 0 *but with a property change to ensure the
eye doesn't move* (the -p option below):

cd path/to/SpineML_2_BRAHMS

./convert_script_s2b -m path/to/OMM_NeuroMuscular/TModel4 -e0 \
-o temp/TModel4 -p "SC_deep2 to SC_avg Synapse 0 weight_update:w:0"

Then view the model in the usual way, with omview, to find suitable
frames and save these off.

cd path/to/SpineML_2_BRAHMS/temp/TModel4
octave
>> A=load_ocm('.');
>> figure(1)
>> surf(A.fef(:,:,280))
>> figure(2)
>> surf(A.fef_add_noise(:,:,280))
>> fef_frame = A.fef(:,:,280);
>> fef_add_noise_frame = A.fef_add_noise(:,:,280);
>> world_frame = A.world(:,:,280);
>> save('modelframes.oct','fef_frame','fef_add_noise_frame','world_frame');

The file modelframes.oct is stored in this directory, and along with
the .dat files from worldtest_mapping.m, form the input to graphmapping.m
