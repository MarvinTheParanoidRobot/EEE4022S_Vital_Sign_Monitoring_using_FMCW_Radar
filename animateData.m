function animateData(title,rdMatrix3D,spectrogram3D,createVideo,nChirps,numADCSamples,nFrames,rangeResolution,rangeMax,limits,spectrolimits,frequencyResolution,frequencyMax,rangeCutOff)
    if createVideo
        writerObj = VideoWriter(title);
        open(writerObj);
    end
    range=0:rangeResolution:rangeMax;
    rangeIndex=ceil(rangeCutOff/rangeResolution);
    slowTime=linspace(frequencyMax,-frequencyMax,nChirps);
    figure('Name','Range-Doppler animation','Position',[0 0 1000 800]);
    for k=1:nFrames
        subplot(2,1,1);
        imagesc(range(1:rangeIndex),slowTime,20*log10(abs(rdMatrix3D(1:end,floor(numADCSamples/2)+1:(floor(numADCSamples/2)+rangeIndex),k))));
        xlabel('range (m)');
        ylabel('Frequency in Hz');
        colorbar;
        caxis(limits);
        
        subplot(2,1,2);
        imagesc(abs(spectrogram3D(:,:,k)).^2);
        colorbar;
        caxis(spectrolimits);
        drawnow
        if createVideo
            frame = getframe(gcf);
            writeVideo(writerObj,frame);
        end
    end
    
    
    if createVideo
        close(writerObj);
    end
end