% Render a double step experiment for the paper?

need_reload = 0
if need_reload
    A3 = load_ocm('/home/seb/src/SpineML_2_BRAHMS/temp/E1_0.3gap');
    A4 = load_ocm('/home/seb/src/SpineML_2_BRAHMS/temp/E1_0.4gap');
end

% Best viewing angle for the surfaces
viewx=90; viewy=90;

% max limit for colour map
zmax = 25;

%text (0, 0, ['Time = ' num2str(t) ' ms']);

% Spacing for subaxes
sa_spc = 0.03;
sa_pad = 0.03;
sa_pad_mid = 0.04;
sa_pad_2d = 0.03;
sa_marg = 0.08;
sa_marg_mid = 0.13;
sa_marg_sideout = 0.1;

% Your favoured line width and marker size:
lw = 2;
ms = 20;

% Main fontsize
fs1 = 38;

targxtxt = 'Target X (\deg)';
targytxt = 'Target Y (\deg)';


h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1050, 2100, 1300]);

t1=520;
t2=530;
t3=540;
pop = 'fef';

hax(1) = subaxis (2,3,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(1), A3, pop, t1);
title(hax(1), ['Popn: ' pop ' at ' num2str(t1) ' ms (30 ms pres)']);

hax(2) = subaxis (2,3,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(2), A3, pop, t2);
title(hax(2), ['Popn: ' pop ' at ' num2str(t2) ' ms (30 ms pres)']);

hax(3) = subaxis (2,3,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(3), A3, pop, t3);
title(hax(3), ['Popn: ' pop ' at ' num2str(t3) ' ms (30 ms pres)']);

hax(4) = subaxis (2,3,4, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(4), A4, pop, t1);
title(hax(4), ['Popn: ' pop ' at ' num2str(t1) ' 40 ms pres']);

hax(5) = subaxis (2,3,5, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(5), A4, pop, t2);
title(hax(5), ['Popn: ' pop ' at ' num2str(t2) ' 40 ms pres']);

hax(6) = subaxis (2,3,6, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

omsurf_ax(hax(6), A4, pop, t3);
title(hax(6), ['Popn: ' pop ' at ' num2str(t3) ' 40 ms pres']);
