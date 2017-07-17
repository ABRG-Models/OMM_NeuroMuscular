% Convenience scripts to load in the theory weight maps

ef50 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile50.bin' );
ef52 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile52.bin' );
ef53 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile53.bin' );
ef54 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile54.bin' );
ef57 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile57.bin' );
ef58 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_finding/best_weightmaps/explicitDataBinaryFile58.bin' );

ef50 = reshape (ef50, 50, 50, []);
ef52 = reshape (ef52, 50, 50, []);
ef53 = reshape (ef53, 50, 50, []);
ef54 = reshape (ef54, 50, 50, []);
ef57 = reshape (ef57, 50, 50, []);
ef58 = reshape (ef58, 50, 50, []);

foundmaps = ef50.+ef52.+ef53.+ef54;
foundmaps2 = ef50.+ef52.+ef53.+ef54.+ef57.+ef58;
