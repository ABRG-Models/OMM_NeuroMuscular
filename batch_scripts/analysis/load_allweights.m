% Load weight maps, and then graph them.

% Load the data
load_justdata

% Up
figure(53); scatter3(e53means(:,1),e53means(:,2),e53means(:,3),'filled'); ...
    title('explicitDataBinaryFile53.bin - UP'); zlim([0,6]);
figure(153); surf (e53map); zlim([0,6]);

% Left
figure(50); scatter3(e50means(:,1), e50means(:,2), e50means(:,3),'filled'); ...
    title('explicitDataBinaryFile50.bin - LEFT'); zlim([0,6]);
figure(150); surf (e50map); zlim([0,6]);

% Right
figure(52); scatter3(e52means(:,1), e52means(:,2), e52means(:,3),'filled'); ...
    title('explicitDataBinaryFile52.bin - RIGHT'); zlim([0,6]);
figure(152); surf (e52map); zlim([0,6]);

% Down
figure(54); scatter3(e54means(:,1), e54means(:,2), e54means(:,3),'filled'); ...
    title('explicitDataBinaryFile54.bin - DOWN'); zlim([0,6]);
figure(154); surf (e54map); zlim([0,6]);

% Z minus
figure(57); scatter3(e57means(:,1), e57means(:,2), e57means(:,3),'filled'); ...
    title('explicitDataBinaryFile57.bin - Z-'); zlim([0,0.5]);
figure(157); surf (e57map); zlim([0,0.5]);

% Z plus
figure(58); scatter3(e58means(:,1), e58means(:,2), e58means(:,3),'filled'); ...
    title('explicitDataBinaryFile58.bin - Z+'); zlim([0,0.5]);
figure(158); surf (e58map); zlim([0,0.5]);
