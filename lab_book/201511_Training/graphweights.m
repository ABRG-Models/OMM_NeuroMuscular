% Load and show the weight maps

e50 = load_explicit_data ('explicitDataBinaryFile50.bin');
e50 = showdata(e50, 'Left (e50)', 50);

e52 = load_explicit_data ('explicitDataBinaryFile52.bin');
e52 = showdata(e52, 'Right (e52)', 52);

e53 = load_explicit_data ('explicitDataBinaryFile53.bin');
e53 = showdata(e53, 'Up (e53)', 53);

e54 = load_explicit_data ('explicitDataBinaryFile54.bin');
e54 = showdata(e54, 'Down (e54)', 54);

e57 = load_explicit_data ('explicitDataBinaryFile57.bin');
e57 = showdata(e57, 'Z+ (e57)', 57);

e58 = load_explicit_data ('explicitDataBinaryFile58.bin');
e58 = showdata(e58, 'Z- (e58)', 58);

% Last graph, all in one.
h_f = figure (100);

% Spacing for subaxes
sa_spc = 0.05;
sa_pad = 0.04;
sa_marg = 0.039;

h_e50 = subaxis (3,2,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e50 = showsubgraph (e50, 'Left', 50, h_e50);

h_e52 = subaxis (3,2,2, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e52 = showsubgraph (e52, 'Right', 52, h_e52);

h_e53 = subaxis (3,2,3, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e53 = showsubgraph (e53, 'Up', 53, h_e53);

h_e54 = subaxis (3,2,4, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e54 = showsubgraph (e54, 'Down', 54, h_e54);

h_e57 = subaxis (3,2,5, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e57 = showsubgraph (e57, 'Z+', 57, h_e57);

h_e58 = subaxis (3,2,6, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
e58 = showsubgraph (e58, 'Z-', 58, h_e58);

print (h_f, 'weightmaps.png', '-r300')