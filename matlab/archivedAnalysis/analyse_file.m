function [data] = analyse_file (file_path, num_neurons)
% analyse_file Analyse a single file from the Oculomotor model BG experiment.

% Note: load_sc_file is found in SpineCreator/analysis_utils/matlab
% There are 2500 neurons per population in the Oculomotor BG expt.

% FIXME: Can get num_neurons and num_timesteps from the xml file
% associated with the bin file.
    
%clear
%file_path='Str_D1_out_log.bin';
%num_neurons = 3;

fprintf ('analyse_file: Processing %s\n',file_path);

[data, count] = load_sc_data (file_path, num_neurons);
num_timesteps = count/num_neurons;

% We have the data. Its size is 2500 x 300. We want to know
% which of the 2500 rows has any significant changes. To this end,
% compute the integral/sum of the row, and see which ones are far away
% from the mean integral. This assumes we have mostly low activity,
% with some small regions of activity.

% Here, we sum on the second dimension, to sum along the 300 ms
% time series.
sums = sum (data, 2);

% Statistics on the integrals. We want to show those which deviate
% from the mean integral, because we have many self-similar traces.
maxsum = max(sums)
meansum = mean(sums)
sd = std(sums)

% Our indexes of interest are those for which the sum is some
% distance from the mean sum.
reasonable_distance_from_mean = 2*sd % Needs to be dynamic.
absdiffs = abs (sums - meansum);
%absdiffs(1:5)
indexes = find (absdiffs>reasonable_distance_from_mean);
si = size(indexes);
shown_graphs = si(1); % Number of graphs showing.

% indexes is now a list of the indexes into data which contain
% something interesting. Can now plot these. On one graph?
if shown_graphs > 0
    fprintf ('Plotting %d graphs/%d traces\n', shown_graphs, num_neurons);
    fig = figure;
    h = plot (1:num_timesteps, data(indexes,:));
    hold on;
    plot(1:num_timesteps, data(1,:),'.r');
    h = title (file_path);
    set (h, 'interpreter', 'none');
else
    fprintf ('Plotting no graphs (from %d traces)\n', num_neurons);
end

end
