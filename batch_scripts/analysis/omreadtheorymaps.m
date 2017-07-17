% Convenience scripts to load in the theory weight maps

et50 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile50.bin' );
et52 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile52.bin' );
et53 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile53.bin' );
et54 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile54.bin' );
et57 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile57.bin' );
et58 = load_explicit_data ('/home/seb/models/OMM_NeuroMuscular/batch_scripts/weight_theoretical/explicitDataBinaryFile58.bin' );

et50 = reshape (et50, 50, 50, []);
et52 = reshape (et52, 50, 50, []);
et53 = reshape (et53, 50, 50, []);
et54 = reshape (et54, 50, 50, []);
et57 = reshape (et57, 50, 50, []);
et58 = reshape (et58, 50, 50, []);

theorymaps = et50.+et52.+et53.+et54;
