% Load trajectory data
function [eyeRx, eyeRy, eyeRz, eyeTime] = load_traj (filepath)
  SS = csvread (filepath, 1 , 0);
  eyeRx = SS(:,8);
  eyeRy = SS(:,9);
  eyeRz = SS(:,10);
  eyeTime = SS(:,1);
  clear SS;
end
