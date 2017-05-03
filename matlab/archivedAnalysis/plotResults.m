
clear all 
close all
clc


A = load_ocm('/fastdata/pc1abx/oculomotor')

fig = figure(1);clf; set(gcf,'units','normalized','outerposition', [ 0 0.4 0.7 0.5]);

for i = 1:20:600;
    
    subplot(2,5,1); 
    A.world(1,1,:) = 0;     A.world(1,2,:) = 1;
    imagesc(A.world(:,:,i));
    colormap('hot')
    zlim([0 1]);
    title([num2str(i) 'world']);
    
    
    subplot(2,5,2); 
        A.mirror(1,1,:) = 0;     A.mirror(1,2,:) = 1;
    imagesc(A.mirror(:,:,i));
    title('mirror');
    zlim([0 1]); 
    
    subplot(2,5,3); 
        A.fef(1,1,:) = 0;     A.fef(1,2,:) = 1;
imagesc(A.fef(:,:,i));
    title('FEF');
    zlim([0 1]);
    
    subplot(2,5,4); 
        A.strd2(1,1,:) = 0;     A.strd2(1,2,:) = 1;
imagesc(A.strd2(:,:,i));
    title('D2 striatum');
    zlim([0 1]);
     colormap('hot')

    subplot(2,5,5); 
        A.strd1(1,1,:) = 0;     A.strd1(1,2,:) = 1;
imagesc(A.strd1(:,:,i));
    title('D1 Striatum');
    zlim([0 1]);
      colormap('hot')
  
    % Row 2 
 
    subplot(2,5,6); 
        A.stn(1,1,:) = 0;     A.stn(1,2,:) = 1;
h = imagesc(A.stn(:,:,i));
    zlim([0 1]);
    title('STN');
     colormap('hot')
   
    
    subplot(2,5,7); 
        A.gpe(1,1,:) = 0;     A.gpe(1,2,:) = 1;
imagesc(A.gpe(:,:,i));
    title('GPe');
    zlim([0 1]); 
      colormap('hot')
  
    subplot(2,5,8); 
        A.snr(1,1,:) = 0;     A.snr(1,2,:) = 1;
imagesc(A.snr(:,:,i));
    title('SNr');
    zlim([0 1]);
        colormap('hot')

    subplot(2,5,9); 
        A.scd(1,1,:) = 0;     A.scd(1,2,:) = 1;
imagesc(A.scd(:,:,i));
    title('SCd');
    zlim([0 1]);
    colormap('hot')

     subplot(2,5,10); 
        A.thal(1,1,:) = 0;     A.thal(1,2,:) = 1;
imagesc(A.thal(:,:,i));
    title('Thalamus');
    zlim([0 1]);   
        colormap('hot')

    waitforbuttonpress; 
end