function   movieMaker(movFlag, nfs, R, SCd, STR, STN, GPi, FEF, Thalamus,SCs, LLBN, EBN, TN, MN)

        dt = 0.5e-3;
        T = 0.6;
        tvec = 0:dt:T;
        trnk = 1000;
       
        R = R(:,1:trnk);
        SCd = SCd(:,1:trnk);
        STR = STR(:,1:trnk);
        STN = STN (:,1:trnk);
        GPi = GPi(:,1:trnk);
        FEF = FEF(:,1:trnk);
        Thalamus = Thalamus(:,1:trnk);
        SCs = SCs(:,1:trnk);
        LLBN = LLBN(1:trnk);
        EBN = EBN(1:trnk);
        TN = TN(1:trnk);
        MN = MN(1:trnk);
        tvec = tvec(1:trnk);
        
% h = uicontrol('style','slider','position',...
% 	[10 50 20 300],'Min',0subplot(3,4,1)
figure(5); clf

subplot(3,4,1)
plot(R(2181,:));
title('retina');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,2)
plot(FEF(2181,:));
title('FEF');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,3)
plot(Thalamus(2181,:));
title('thalamus');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,4)
plot(STR(2181,:));
title('striatum d1');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,5)
plot(STN(2181,:));
title('STN');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,6)
plot(GPi(2181,:));
title('GPi');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,7)
plot(SCd(2181,:));
title('SC deep');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,8)
plot(SCs(2181,:));
title('SC sup');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,9)
plot(LLBN);
title('LLBN');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,10)
plot(EBN);
title('EBN');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,11)
plot(TN);
title('TN');
set(gcf,'colormap',hot)
axis tight square

subplot(3,4,12)
plot(MN);
title('MN');
set(gcf,'colormap',hot)
axis tight square

% index 2181 is active when target is [117 117] and FP is [150 150]
%  colordef(fig,'none');
%  whitebg(fig,'white');
 
%  set(gcf,'units','normalized','outerposition',[0 0 1 1]);



names= {'Retina','FEF','Thalamus','D1 Striatum','STN','GPi','SC deep','SC sup'};

movFlag = 1;
c = 0;

if movFlag == 1;
    
    for i = 1:3:size(FEF,2);
        c = c+1;
        
        fig = figure(135);clf
        set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        colordef(fig,'none');
        whitebg(fig,'white');        
        h = tight_subplot(3,4,0.045,0.05,0.05);

%         for j = 1:length(names)
%             heatPlot(nfs,inputname(j+2),h,j,names{j})
%         end

        r = R(:,i);
        r(1)=0; r(2)=1;
        r = reshape(r,nfs,nfs);
        
        scd = SCd(:,i);
        scd(1)=0; scd(2)=1;
        scd = reshape(scd,nfs,nfs);
        
        scs = SCs(:,i);
        scs(1)=0; scs(2)=1;
        scs = reshape(scs,nfs,nfs);
        
        str = STR(:,i);
        str(1)=0; str(2)=1;
        str = reshape(str,nfs,nfs);
        
        stn = STN(:,i);
        stn(1)=0; stn(2)=1;
        stn = reshape(stn,nfs,nfs);
        
        fef = FEF(:,i);
        fef(1)=0; fef(2)=1;
        fef = reshape(fef,nfs,nfs);
        
        gpi = GPi(:,i);
        gpi(1)=0; gpi(2)=1;
        gpi = reshape(gpi,nfs,nfs);
        
        tha = Thalamus(:,i);
        tha(1)=0; tha(2)=1;
        tha = reshape(tha,nfs,nfs);
        
        
        imagesc(r,'Parent',h(1));
        title(h(1),'Retina');
        set(gcf,'colormap',hot);
        axis (h(1), 'tight', 'square', 'off')
        
        imagesc(fef,'Parent',h(2));
        title(h(2),'FEF');
        set(gcf,'colormap',hot)
        axis (h(2), 'tight', 'square', 'off')
        
        
        imagesc(tha,'Parent',h(3));
        title(h(3),'Thalamus');
        set(gcf,'colormap',hot)
        axis (h(3), 'tight', 'square', 'off')
        
        
        imagesc(str,'Parent',h(4));
        title(h(4),'D1 Striatum');
        set(gcf,'colormap',hot)
        axis (h(4), 'tight', 'square', 'off')
        
        
        imagesc(stn,'Parent',h(5));
        title(h(5),'STN');
        set(gcf,'colormap',hot)
        axis (h(5), 'tight', 'square', 'off')
        
        
        imagesc(gpi,'Parent',h(6));
        title(h(6),'GPi');
        set(gcf,'colormap',hot)
        axis (h(6), 'tight', 'square', 'off')
        
        
        imagesc(scd,'Parent',h(8));
        axis (h(8), 'tight', 'square', 'off')
        set(gcf,'colormap',hot)
        title(h(8),'SC deep')
        
        imagesc(scs,'Parent',h(7));
        title(h(7),'SC sup');
        set(gcf,'colormap',hot)
        axis (h(7), 'tight', 'square', 'off')
        
        imagesc(scd,'Parent',h(8));
        axis (h(8), 'tight', 'square', 'off')
        set(gcf,'colormap',hot)
        title(h(8),'SC deep')        
        
        %%%%%%%%%%%%%

        plot(h(9),tvec(1:i),LLBN(1:i),'.w','MarkerSize',18);
        title(h(9),'LLBN');
        set(h(9),'Color','k','YTickLabels',[])

       
        
        plot(h(10),tvec(1:i),EBN(1:i),'.w','MarkerSize',18);
        title(h(10),'EBN');
        set(h(10),'Color','k','YTickLabels',[])

        
        plot(h(11),tvec(1:i),TN(1:i),'.w','MarkerSize',18);
        title(h(11),'TN');
        set(h(11),'Color','k','YTickLabels',[])

        
        plot(h(12),tvec(1:i),MN(1:i),'.w','MarkerSize',18);
        title(h(12),'MN');
        set(h(12),'Color','k','YTickLabels',[])

        axis(h(9:12),[0 0.5 0 1],'square');
        set(findall(h,'type','text'),'FontSize',15,'fontWeight','bold')
        
        M(c) = getframe(fig);
        pause(0.3);
        
    end
    
    save filmWithSG M
%     close all
    [h, w, p] = size(M(1).cdata);  % use 1st frame to get dimensions
    hf = figure;
    % resize figure based on frame's w x h, and place at (150, 150)
    set(hf, 'position', [150 150 w h]);
    axis off
    movie(hf,M);
    mplay(M)
%     movie2avi(M,'AVIfilm')

end

end

