function [breathRateSpectrogram,heartRateSpectrogram, spectrogram, dataMatrix, rangeFFT, dopplerFFT, rdMatrix]=processFrame(data,numADCSamples,nChirps,rangeResolution,rangeMax,windowSize,zeroPadding,overlap,rangeBinSelect,FrameIndex,showgraph,sumData,minRange,maxRange,frequencyResolution,frequencyMax,rangeCutOff,fs,heartRatepassband,breathRatepassband)
    sample=1:numADCSamples;
    chirpData=data(1:numADCSamples);
    chirpAxis=1:nChirps;
    fftData=fft(data(1:numADCSamples));

    dataMatrix=reshape(data,[numADCSamples,nChirps]).';
    heartRateFilterDataMatrix=bandpass(reshape(data,[numADCSamples,nChirps]).',heartRatepassband,fs,'ImpulseResponse','iir','Steepness',0.95);
    breathRateFilterDataMatrix=bandpass(reshape(data,[numADCSamples,nChirps]).',breathRatepassband,fs,'ImpulseResponse','iir','Steepness',0.95);
    rangeFFT=fftshift(fft(dataMatrix,[],2));
    unshiftedrangeFFT=fft(dataMatrix,[],2);
    breathRateFilterrangeFFT=fft(breathRateFilterDataMatrix,[],2);
    heartRateFilterrangeFFT=fft(heartRateFilterDataMatrix,[],2);
    range=0:rangeResolution:rangeMax;                                                               
    slowTime=linspace(frequencyMax,-frequencyMax,nChirps);
    rangeIndex=ceil(rangeCutOff/rangeResolution);
    dopplerFFT=fftshift(fft(dataMatrix,[],1));
  
    rdMatrix=fftshift(fft(unshiftedrangeFFT,[],1));
    if sumData
        sumRange=sum(unshiftedrangeFFT(:,minRange:maxRange),2);
        heartRatefiltersumRange=sum(heartRateFilterrangeFFT(:,minRange:maxRange),2);
        breathRatefiltersumRange=sum(breathRateFilterrangeFFT(:,minRange:maxRange),2);
        heartRateSpectrogram=stft(heartRatefiltersumRange',windowSize,zeroPadding,overlap);
        breathRateSpectrogram=stft(breathRatefiltersumRange',windowSize,zeroPadding,overlap);
        spectrogram = stft(sumRange',windowSize,zeroPadding,overlap);
    else
       
        heartRateSpectrogram=stft(heartRateFilterrangeFFT(:,rangeBinSelect).',windowSize,zeroPadding,overlap);
        breathRateSpectrogram=stft(breathRateFilterrangeFFT(:,rangeBinSelect).',windowSize,zeroPadding,overlap);
        spectrogram = stft(unshiftedrangeFFT(:,rangeBinSelect).',windowSize,zeroPadding,overlap);
    end
    if showgraph
        TitleName=strcat('Frame ',num2str(FrameIndex),' Data');
        figure('Name',TitleName,'Position',[0 0 1000 800]);

        subplot(3,2,1)
        plot(sample,abs(chirpData));
        xlabel('Sample');
        ylabel('absolute of chirp 1 data');
        title('Chirp 1 of Frame');
        grid on

        subplot(3,2,2)
        plot(sample,10*log10(abs(fftData)));
        xlabel('Sample');
        ylabel('FFT of chirp 1 data');
        title('FFT Chirp 1 of Frame');
        grid on


        subplot(3,2,3);
        imagesc(range(1:rangeIndex),chirpAxis,20*log10(abs(rangeFFT(1:end,floor(numADCSamples/2)+1:(floor(numADCSamples/2)+1+rangeIndex)))));
        xlabel('range (m)');
        ylabel('Number of Chirps');
        title('Range FFT of Frame Data');
        colorbar;

        subplot(3,2,4);
        imagesc(sample,slowTime,20*log10(abs(dopplerFFT)));
        xlabel('sample ');
        ylabel('Frequency in (Hz)');
        title('Doppler FFT of Frame Data');
        colorbar;

        subplot(3,2,5);
        imagesc(range(1:rangeIndex),slowTime,20*log10(abs(rdMatrix(1:end,floor(numADCSamples/2)+1:floor(numADCSamples/2)+1+rangeIndex))));
        xlabel('range (m)');
        ylabel('Frequency in (Hz)');
        title('Range Doppler FFT of Frame Data');
        colorbar;

        subplot(3,2,6);
        imagesc(abs(spectrogram));
       
        title('Spectrogram of Frame Data');
        colorbar;
    end
end