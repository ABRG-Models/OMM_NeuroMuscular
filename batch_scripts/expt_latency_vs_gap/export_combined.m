% Export the combined data to Veuz-friendly csv files.

counter = 1;
for lat_mean = lat_means'
    csvwrite (['combined-targ_lum' num2str(lums(counter)) '.csv'], ...
              [gap' lat_mean lat_sds(counter,:)']);
    counter = counter + 1;
end
