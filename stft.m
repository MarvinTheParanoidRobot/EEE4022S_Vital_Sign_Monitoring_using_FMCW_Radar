function [spectrogram]=stft(data,windowSize,zeroPadding,overlap)
    nWindows=floor((length(data)-windowSize)/(windowSize*(1-overlap)))+1; %Number of windows required for the stft
    zeroPad=zeros(1,floor(zeroPadding*windowSize));	% Creates an array of zeros a size multiple of the data length for zero padding
    spectrogram =zeros(windowSize+length(zeroPad),nWindows);
    nextWindow=0;
    
    for n=1:nWindows
        tempData = data(nextWindow+1:nextWindow+windowSize);
        paddedData=[(tempData),zeroPad];
        spectrogram(:,n)=fftshift(fft(paddedData));
        nextWindow=nextWindow+floor(windowSize*(1-overlap));
    end
end
    