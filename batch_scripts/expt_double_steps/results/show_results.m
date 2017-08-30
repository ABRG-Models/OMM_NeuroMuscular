%
% Load, and show the results of the double step experiments.
%

% small ecc. lum. only
[smX, smY, smZ, smt] = load_traj ('./1_targ1_ss.log');
[smX_2, smY_2, smZ_2, smt_2] = load_traj ('./2_targ1_ss.log');
[smX_3, smY_3, smZ_3, smt_3] = load_traj ('./3_targ1_ss.log');
[smX_4, smY_4, smZ_4, smt_4] = load_traj ('./4_targ1_ss.log');
[smX_5, smY_5, smZ_5, smt_5] = load_traj ('./5_targ1_ss.log');

% Large eccentricity luminance comes on t before small ecc. lum.
[lg1X, lg1Y, lg1Z, lg1t] = load_traj ('./1_largesmall_0.01_saccsim_side.log');
[lg3X, lg3Y, lg3Z, lg3t] = load_traj ('./1_largesmall_0.03_saccsim_side.log');
[lg4X, lg4Y, lg4Z, lg4t] = load_traj ('./1_largesmall_0.04_saccsim_side.log');
[lg7X, lg7Y, lg7Z, lg7t] = load_traj ('./1_largesmall_0.07_saccsim_side.log');
[lg12X, lg12Y, lg12Z, lg12t] = load_traj ('./1_largesmall_0.12_saccsim_side.log');

% large ecc. lum. only
[lgX, lgY, lgZ, lgt] = load_traj ('./1_targ2_ss.log');
[lgX_2, lgY_2, lgZ_2, lgt_2] = load_traj ('./2_targ2_ss.log');
[lgX_3, lgY_3, lgZ_3, lgt_3] = load_traj ('./3_targ2_ss.log');
[lgX_4, lgY_4, lgZ_4, lgt_4] = load_traj ('./4_targ2_ss.log');
[lgX_5, lgY_5, lgZ_5, lgt_5] = load_traj ('./5_targ2_ss.log');

% mean and sd
lgX_all = [lgX,lgX_2,lgX_3,lgX_4,lgX_5]';
lgX_all_mn = mean(lgX_all)';
lgY_all = [lgY,lgY_2,lgY_3,lgY_4,lgY_5]';
lgY_all_mn = mean(lgY_all)';
lgY_all_sd = std(lgY_all)';
lgZ_all = [lgZ,lgZ_2,lgZ_3,lgZ_4,lgZ_5]';
lgZ_all_mn = mean(lgZ_all)';

smX_all = [smX,smX_2,smX_3,smX_4,smX_5]';
smX_all_mn = mean(smX_all)';
smY_all = [smY,smY_2,smY_3,smY_4,smY_5]';
smY_all_mn = mean(smY_all)';
smZ_all = [smZ,smZ_2,smZ_3,smZ_4,smZ_5]';
smZ_all_mn = mean(smZ_all)';


% Small eccentricity luminance comes on t before large ecc. lum.
[sm3X, sm3Y, sm3Z, sm3t] = load_traj ('./1_smalllarge_0.03_saccsim_side.log');
[sm1X, sm1Y, sm1Z, sm1t] = load_traj ('./1_smalllarge_0.01_saccsim_side.log');
[sm4X, sm4Y, sm4Z, sm4t] = load_traj ('./1_smalllarge_0.04_saccsim_side.log');
[sm7X, sm7Y, sm7Z, sm7t] = load_traj ('./1_smalllarge_0.07_saccsim_side.log');
[sm12X, sm12Y, sm12Z, sm12t] = load_traj ('./1_smalllarge_0.12_saccsim_side.log');

[sm3X_2, sm3Y_2, sm3Z_2, sm3t_2] = load_traj ('./2_smalllarge_0.03_saccsim_side.log');
[sm3X_3, sm3Y_3, sm3Z_3, sm3t_3] = load_traj ('./3_smalllarge_0.03_saccsim_side.log');
[sm3X_4 sm3Y_4 sm3Z_4 sm3t_4] = load_traj ('./4_smalllarge_0.03_saccsim_side.log');
[sm3X_5 sm3Y_5 sm3Z_5 sm3t_5] = load_traj ('./5_smalllarge_0.03_saccsim_side.log');
% Collect data for mean/sd
sm3Y_all = [sm3Y, sm3Y_2, sm3Y_3, sm3Y_4, sm3Y_5]';
sm3Y_all_mn = mean(sm3Y_all)';
sm3Y_all_sd = std(sm3Y_all)';

[sm4X_2, sm4Y_2, sm4Z_2, sm4t_2] = load_traj ('./2_smalllarge_0.04_saccsim_side.log');
[sm4X_3, sm4Y_3, sm4Z_3, sm4t_3] = load_traj ('./3_smalllarge_0.04_saccsim_side.log');
[sm4X_4 sm4Y_4 sm4Z_4 sm4t_4] = load_traj ('./4_smalllarge_0.04_saccsim_side.log');
[sm4X_5 sm4Y_5 sm4Z_5 sm4t_5] = load_traj ('./5_smalllarge_0.04_saccsim_side.log');
% Collect data for mean/sd
sm4Y_all = [sm4Y, sm4Y_2, sm4Y_3, sm4Y_4, sm4Y_5]';
sm4Y_all_mn = mean(sm4Y_all)';
sm4Y_all_sd = std(sm4Y_all)';

figure(1); clf; hold on;

%plot (sm3t, -sm3Y, 'b')
%plot (sm3t, -sm3Y_2, 'b')
%plot (sm3t, -sm3Y_3, 'b')
%plot (sm3t, -sm3Y_4, 'b')
%plot (sm3t, -sm3Y_5, 'b')
plot (sm3t(1:1000), -sm3Y_all_mn(1:1000), 'b-')
plot (sm3t(1:1000), -(sm3Y_all_mn(1:1000)+1.*sm3Y_all_sd(1:1000)), 'b--')
plot (sm3t(1:1000), -(sm3Y_all_mn(1:1000)-1.*sm3Y_all_sd(1:1000)), 'b--')

%plot (lgt, -lgY, 'g')
%plot (lgt_2, -lgY_2, 'g')
%plot (lgt_3, -lgY_3, 'g')
%plot (lgt_4, -lgY_4, 'g')
%plot (lgt_5, -lgY_5, 'g')
plot (lgt(1:1000), -lgY_all_mn(1:1000), 'g-')
plot (lgt(1:1000), -(lgY_all_mn(1:1000)+1.*lgY_all_sd(1:1000)), 'g--')
plot (lgt(1:1000), -(lgY_all_mn(1:1000)-1.*lgY_all_sd(1:1000)), 'g--')

%plot (sm4t, -sm4Y, 'r')
%plot (sm4t, -sm4Y_2, 'r')
%plot (sm4t, -sm4Y_3, 'r')
%plot (sm4t, -sm4Y_4, 'r')
%plot (sm4t, -sm4Y_5, 'r')
plot (sm4t(1:1000), -sm4Y_all_mn(1:1000), 'r-')
plot (sm4t(1:1000), -(sm4Y_all_mn(1:1000)+1.*sm4Y_all_sd(1:1000)), 'r--')
plot (sm4t(1:1000), -(sm4Y_all_mn(1:1000)-1.*sm4Y_all_sd(1:1000)), 'r--')

title('scatter')

% Save those numbers out for veusz
outdata = [sm3t(1:1000), sm3Y_all_mn(1:1000), sm3Y_all_mn(1:1000)+sm3Y_all_sd(1:1000), sm3Y_all_mn(1:1000)-sm3Y_all_sd(1:1000)];
f = fopen (['./sm3t.csv'], 'w');
fprintf (f, 't,eyeRy,eyeRyUpper,eyeRyLower\n');
dlmwrite (f, outdata, '-append');
fclose(f);

outdata = [sm4t(1:1000), sm4Y_all_mn(1:1000), sm4Y_all_mn(1:1000)+sm4Y_all_sd(1:1000), sm4Y_all_mn(1:1000)-sm4Y_all_sd(1:1000)];
f = fopen (['./sm4t.csv'], 'w');
fprintf (f, 't,eyeRy,eyeRyUpper,eyeRyLower\n');
dlmwrite (f, outdata, '-append');
fclose(f);

outdata = [lgt(1:1000), lgY_all_mn(1:1000), lgY_all_mn(1:1000)+lgY_all_sd(1:1000), lgY_all_mn(1:1000)-lgY_all_sd(1:1000)];
f = fopen (['./lgt.csv'], 'w');
fprintf (f, 't,eyeRy,eyeRyUpper,eyeRyLower\n');
dlmwrite (f, outdata, '-append');
fclose(f);


figure(2); clf; hold on;
plot (smt, -smY, 'b')
plot (lg3t, -lg3Y, 'b--')
plot (lg4t, -lg4Y, 'b..')
plot ([0.4,0.4],[0,14],'k')
plot ([0.41,0.41],[0,14],'k--')
plot ([0.43,0.43],[0,14],'k--')
plot ([0.44,0.44],[0,14],'k--')
plot ([0.47,0.47],[0,14],'k--')
legend(['8\deg target only';'12\deg precedes 8\deg by 0.03s';'12\deg precedes 8\deg by 0.04s'])

figure(20); clf; hold on;
plot (-smY, smX, 'b')
plot (-lg3Y, lg3X, 'b--')
plot (-lg4Y, lg4X, 'b..')
legend(['8\deg target only';'12\deg precedes 8\deg by 0.03s';'12\deg precedes 8\deg by 0.04s'])

figure(3); clf; hold on;
plot (lgt, -lgY, 'r')
plot (sm3t, -sm3Y, 'r--')
plot (sm4t, -sm4Y, 'r..')
plot (sm1t, -sm1Y, 'm--')
plot (sm7t, -sm7Y, 'm..')
plot (sm12t, -sm12Y, 'g--')
plot ([0.4,0.4],[0,14],'k')
plot ([0.43,0.43],[0,14],'k--')
plot ([0.44,0.44],[0,14],'k--')
legend(['12\deg target only';'8\deg precedes 12\deg by 0.03s';'8\deg precedes 12\deg by 0.04s';'8\deg precedes 12\deg by 0.01s';'8\deg precedes 12\deg by 0.07s'])


figure(30); clf; hold on;
plot (-lgY, lgX, 'g')
plot (-sm3Y, sm3X, 'b--')
plot (-sm4Y, sm4X, 'r..')
legend(['12\deg target only';'8\deg precedes 12\deg by 0.03s';'8\deg precedes 12\deg by 0.04s'])
