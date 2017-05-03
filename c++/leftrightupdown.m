load ef_cort_sheet_origin.dat 

load ef_cort_sheet_posX.dat 
load ef_cort_sheet_negX.dat 
load ef_cort_sheet_posY.dat 
load ef_cort_sheet_negY.dat 

onX    = ef_cort_sheet_origin .+ ef_cort_sheet_posX;
negOnX = ef_cort_sheet_origin .+ ef_cort_sheet_negX;
negOnY = ef_cort_sheet_origin .+ ef_cort_sheet_negY;
onY    = ef_cort_sheet_origin .+ ef_cort_sheet_posY;

figure (6)
surf (onX)
title ('Pos X - UP')
xlabel ('col encodes r');
ylabel ('row encodes theta');

figure (7)
surf (negOnX)
title ('Neg X - DOWN')
xlabel ('col encodes r');
ylabel ('row encodes theta');

figure (8)
surf (negOnY)
title ('Neg Y - RIGHT')
xlabel ('col encodes r');
ylabel ('row encodes theta');

figure (9)
surf (onY)
title ('Pos Y - LEFT')
xlabel ('col encodes r');
ylabel ('row encodes theta');

