function directories = setup_model_output_directories (out_dir_prefix)
%% An improvement of setup_model_directories with an additional argument.

    output_dir = ['/fastdata/co1ssj/' out_dir_prefix];
    output_model_dir = [output_dir '/model'];
    output_run_dir = [output_dir '/run/'];
    output_log_dir = [output_dir '/log/'];

    directories = struct ('root', output_dir, ...
                          'model', output_model_dir, ...
                          'run', output_run_dir, ...
                          'log', output_log_dir ...
    );

end
