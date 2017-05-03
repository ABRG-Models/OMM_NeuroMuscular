% Load and show the weight maps

e50 = load_explicit_data ('explicitDataBinaryFile50.bin');
showdata(e50, 'Left', 50);

e52 = load_explicit_data ('explicitDataBinaryFile52.bin');
showdata(e52, 'Right', 52);

e53 = load_explicit_data ('explicitDataBinaryFile53.bin');
showdata(e53, 'Up', 53);

e54 = load_explicit_data ('explicitDataBinaryFile54.bin');
showdata(e54, 'Down', 54);

e57 = load_explicit_data ('explicitDataBinaryFile57.bin');
showdata(e57, 'Z+', 57);

e58 = load_explicit_data ('explicitDataBinaryFile58.bin');
showdata(e58, 'Z-', 58);
