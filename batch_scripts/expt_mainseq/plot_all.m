figure(100)
clf;

plot_mainseq_horz
plot_mainseq_vert
plot_mainseq_oblq

figure(100)
xlabel('Eccentricity')
ylabel('Duration (ms)')
legend('Horizontal','Vertical','Oblique')

% Output Dur/eccentricity for Veusz
output_veusz = 1
if output_veusz
    dur_ecc_v = [-rrv(:,1),rrv(:,15),rrv(:,16)];
    f = fopen (['results/dur_vs_ecc_vert.csv'], 'w');
    fprintf (f, 'Ecc,Dur,+-\n');
    dlmwrite (f, dur_ecc_v, '-append');
    fclose(f);

    dur_ecc_h = [-rrh(:,2),rrh(:,15),rrh(:,16)];
    f = fopen (['results/dur_vs_ecc_horz.csv'], 'w');
    fprintf (f, 'Ecc,Dur,+-\n');
    dlmwrite (f, dur_ecc_h, '-append');
    fclose(f);

    dur_ecc_o = [-targr,rro(:,15),rro(:,16)];
    f = fopen (['results/dur_vs_ecc_oblq.csv'], 'w');
    fprintf (f, 'Ecc,Dur,+-\n');
    dlmwrite (f, dur_ecc_o, '-append');
    fclose(f);
end
