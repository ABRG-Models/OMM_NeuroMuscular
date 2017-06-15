%%
%% Loads the SCA_avg to LLBN weight maps.
%%
%% Assumes which explicitDataBinaryFiles these are.
%%
%% [left, right, up, down] = load_sbgmaps (model_path)
%%
function [left, right, up, down, zplus, zminus] = load_sbgmaps (model_path)
    left = load_neural_sheet([model_path '/explicitDataBinaryFile50.bin']);
    left = flipud(reshape (left, 50, 50, []));
    figure(50);
    surf(left);
    title('left e50');

    right = load_neural_sheet([model_path '/explicitDataBinaryFile52.bin']);
    right = flipud(reshape (right, 50, 50, []));
    figure(52);
    surf(right);
    title('right e52');

    up = load_neural_sheet([model_path '/explicitDataBinaryFile53.bin']);
    up = flipud(reshape (up, 50, 50, []));
    figure(53);
    surf(up);
    title('up e53');

    down = load_neural_sheet([model_path '/explicitDataBinaryFile54.bin']);
    down = flipud(reshape (down, 50, 50, []));
    figure(54);
    surf(down);
    title('down e54');

    zplus = load_neural_sheet([model_path '/explicitDataBinaryFile57.bin']);
    zplus = flipud(reshape (zplus, 50, 50, []));
    figure(57);
    surf(zplus);
    title('zplus e57');

    zminus = load_neural_sheet([model_path '/explicitDataBinaryFile58.bin']);
    zminus = flipud(reshape (zminus, 50, 50, []));
    figure(58);
    surf(zminus);
    title('zminus e58');
end
