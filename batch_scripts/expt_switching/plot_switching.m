fileid='TX0TY-10T2X0T2Y0';
[x1,y1,z1,t1] = load_traj(['results/1_' fileid '_saccsim_side.log']);
[x2,y2,z2,t2] = load_traj(['results/2_' fileid '_saccsim_side.log']);
[x3,y3,z3,t3] = load_traj(['results/3_' fileid '_saccsim_side.log']);

mn1l = load_sc_data (['results/1_' fileid '_MN_left_a_logrep.xml']);
mn1r = load_sc_data (['results/1_' fileid '_MN_right_a_logrep.xml']);

figure(1); clf;
plot (t1,y1);
hold on;
plot (t2,y2, 'r');
plot (t3,y3, 'k');
legend('Run 1','Run 2','Run 3');

figure(2); clf;
plot (mn1l);
hold on;
plot (mn1r,'r');
legend('MN left','MN right');
