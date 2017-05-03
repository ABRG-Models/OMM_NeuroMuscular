%% Used by sacc_vs_luminance.sh. Runs the model num_par_runs times
%% for a given lumval.
%%
%% Usage:
%%
%%   sacc_vs_luminance (targetThetaX, targetThetaY, num_par_runs,
%%                      lumval)
%%
function sacc_vs_luminance (targetThetaX, targetThetaY, num_par_runs, lumval)

    page_screen_output(0);
    page_output_immediately(1);

    cleanup = 0;
    use_insigneo = 1;
    model_dir = '/home/pc1ssj/abrg_local/Oculomotor';

    write_single_luminance ([model_dir '/luminances.json'], targetThetaX, targetThetaY, lumval);

    output_dirs = setup_model_directories ([targetThetaX, targetThetaY], lumval);
    [ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_multi (model_dir, output_dirs, num_par_runs, use_insigneo, cleanup);

    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval)];
    resdatname = strrep (resdatname, '.', '_');

    vs = [lumval, eyeRyAvg, eyeRySD];
    result = struct();
    result.(resdatname) = vs;

    save (resname, 'result');

end