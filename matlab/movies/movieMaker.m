function movieMaker (movFlag, nfs, R, SCd, STR, STN, SNr, FEF, Thalamus, SCs, LLBN, EBN, TN, MN)

    dt = 0.5e-3;
    T = 0.3;
    tvec = 0:dt:T;
    trnk = 600;
    
    R = R(:,1:trnk);
    SCd = SCd(:,1:trnk);
    STR = STR(:,1:trnk);
    STN = STN (:,1:trnk);
    SNr = SNr(:,1:trnk);
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

    movieMakerSubplot ('retina', R, 1);
    movieMakerSubplot ('FEF', FEF, 2);
    movieMakerSubplot ('Thalamus', Thalamus, 3);
    movieMakerSubplot ('Striatum D1', STR, 4);
    movieMakerSubplot ('STN', STN, 5);
    movieMakerSubplot ('SNr', SNr, 6);
    movieMakerSubplot ('SC deep', SCd, 7);
    movieMakerSubplot ('SC sup', SCs, 8);
    movieMakerSubplot ('LLBN', LLBN, 9);
    movieMakerSubplot ('EBN', EBN, 10);
    movieMakerSubplot ('TN', TN, 11);
    movieMakerSubplot ('MN', MN, 12);

    % index 2181 is active when target is [117 117] and FP is [150 150]
    %  colordef(fig,'none');
    %  whitebg(fig,'white');
    %  set(gcf,'units','normalized','outerposition',[0 0 1 1]);

    names = {'Retina','FEF','Thalamus','D1 Striatum','STN','SNr','SC deep','SC sup'};
    movFlag = 1;
    c = 0;

    if movFlag == 1;
        
        for i = 1:3:size(FEF,2);
            c = c+1;
            
            fig = figure(135);clf
            set(gcf,'units','normalized','outerposition',[0 0 1 1]);
            colordef(fig,'none');
            whitebg(fig,'white');        
            h = tight_subplot (3, 4, 0.045, 0.05, 0.05);

            %scd = SCd(:,i);
            %scd(1)=0; scd(2)=1;
            %scd = reshape(scd,nfs,nfs);
            r = movieMakerReshape (R(:,i), nfs);
            scd = movieMakerReshape (SCd(:,i), nfs);
            scs = movieMakerReshape (SCs(:,i), nfs);
            str = movieMakerReshape (STR(:,i), nfs);
            stn = movieMakerReshape (STN(:,i), nfs);
            fef = movieMakerReshape (FEF(:,i), nfs);
            gpi = movieMakerReshape (SNr(:,i), nfs);
            tha = movieMakerReshape (Thalamus(:,i), nfs);

            movieMakerImagesc (h(1), r, 'Retina');
            movieMakerImagesc (h(2), fef, 'FEF');
            movieMakerImagesc (h(3), tha, 'Thalamus');
            movieMakerImagesc (h(4), str, 'D1 Striatum');
            movieMakerImagesc (h(5), stn, 'STN');
            movieMakerImagesc (h(6), gpi, 'SNr');
            movieMakerImagesc (h(8), scd, 'SC deep');
            movieMakerImagesc (h(7), scs, 'SC sup');
            
            movieMakerGraph (h(9), tvec(1:i), LLBN(1:i), 'LLBN');
            movieMakerGraph (h(10), tvec(1:i), EBN(1:i), 'EBN');
            movieMakerGraph (h(11), tvec(1:i), TN(1:i), 'TN');
            movieMakerGraph (h(12), tvec(1:i), MN(1:i), 'MN');
            axis (h(9:12), [0 0.5 0 1], 'square');
            set (findall (h, 'type', 'text'), 'FontSize', 15, 'fontWeight', 'bold')
            M(c) = getframe (fig);
            pause (0.3);
        end
        
        save ('movies/filmWithSG.mat', 'M');
        %     close all
        [h, w, ~] = size (M(1).cdata);  % use 1st frame to get dimensions
        hf = figure;
        % resize figure based on frame's w x h, and place at (150, 150)
        set (hf, 'position', [150 150 w h]);
        axis off
        movie (hf, M);
        implay (M)
        % movie2avi(M,'AVIfilm')
    end
end
