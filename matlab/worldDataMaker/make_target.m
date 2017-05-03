function [ target_frame ] = make_target (target_locns, target_size, target_luminance)
%MAKE_TARGET Create a saccade target in world at location x, y.
% Returns a 300 by 300 world view frame, containing target(s), of size
% target_size located at (x,y) = target_locns(:,1), target_locns(:,2),
% with Gaussian blur applied (blur parameters are hardcoded into this
% function).

% FINISH ME to allow for passing in >1 target.
    target_locns

    targetx_indices = target_locns(1)-target_size/2:target_locns(1)+target_size/2 % Create indices of target location
    targety_indices = target_locns(2)-target_size/2:target_locns(2)+target_size/2;

    targetx_indices
    
    target_frame = 0.01+zeros(300,300);    % Create background array of low luminance pixels

    % For each targetx/targety:
    sz=size(targetx_indices)
    for idx=1:sz(1)
        display('set brightspot...');
        targetx(idx)
        targety(idx)

        % Create luminous spot at target location:
        target_frame(targetx(idx),targety(idx)) = target_luminance; 
    end

    H = fspecial('gaussian',[2,2],0.5);      % Apply a 2 pixel sigma=0.5 gaussian blur to the image
    target_frame = imfilter(target_frame,H); % This is now the input mask/filter
end
