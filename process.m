function process(fileName,windowSize,zeroPadding,overlap,rangeBinSelect,title,createVideo,limits,spectrolimits,sumData,minRange,maxRange,stackFrames,rangeCutOff)
close all;
%% global variables
disp("Process Started");
% Constants
LightSpeed=299792458;                                                      % Speed of Light

% FMCW system variables
numADCSamples= 2048;                                                       % number of ADC samples per chirp
numADCBits= 16;                                                            % numberof ADC bits per sample 
numRX= 4;                                                                  % number of receivers 
numLanes= 2;                                                               % number of lanes is always 2 
isReal= 0;                                                                 % set to 1 if real only data,0 if complex data 0
skip=0;
nChirps=255*stackFrames;                                                   % number of chirps in a frame
nFrames=floor(16/stackFrames);                                             % number of frames
samplingrate=2000*1000;                                                    % Samples per Second  
sweepslope=1.979*1e12;                                                     % Frequency slope in Hz/s
bandwidth=2.0270*1e9;                                                      % Calculated bandwidth in Hz
centerWavelength=77.26525*1e9;
Tc=2030e-6;
Tf=Tc*nChirps;

% range and doppler axis variables
rangeMax=((0.9*samplingrate*LightSpeed)/(2*sweepslope))/2;                 % Max distance measured
rangeResolution=((LightSpeed)/(2*bandwidth));                              % Range Resolution
frequencyResolution=1/Tf;
frequencyMax=1/(2*Tc);
% Reading Data variables
dataLength=numADCSamples*nChirps*stackFrames*numLanes*numRX;


%Output Data pre-allocation
nWindows=floor((nChirps-windowSize)/(windowSize*(1-overlap)))+1;
spectrogram3D=zeros(windowSize+floor(zeroPadding*nChirps),nWindows,nFrames);
dataMatrix3D=zeros(nChirps,numADCSamples,nFrames);
rangeFFT3D=zeros(nChirps,numADCSamples,nFrames);
dopplerFFT3D=zeros(nChirps,numADCSamples,nFrames);
rdMatrix3D=zeros(nChirps,numADCSamples,nFrames);
spectrogram=zeros(windowSize+floor(zeroPadding*nChirps),nWindows);
dataMatrix=zeros(nChirps,numADCSamples);
rangeFFT=zeros(nChirps,numADCSamples);
dopplerFFT=zeros(nChirps,numADCSamples);
rdMatrix=zeros(nChirps,numADCSamples);
rx1=zeros(1,numADCSamples*nChirps);

%% Processing 
passband=8;

for FrameIndex=1:nFrames
    nSamples=numADCSamples*nChirps*numRX*(FrameIndex-1)+1;
    if(FrameIndex==1)
        nSamples=0;
    end
    formula=(4*nSamples)+((-1)^(nSamples+1)) -5;
    data= readData(fileName,numADCSamples,numADCBits,numRX,numLanes,isReal,skip,dataLength,formula);
    rx1=data(1,:);
    showgraph=false;
    [filteredSpectrogram, spectrogram, dataMatrix, rangeFFT, dopplerFFT, rdMatrix]=processFrame(rx1,numADCSamples,nChirps,rangeResolution,rangeMax,windowSize,zeroPadding,overlap,rangeBinSelect,FrameIndex,showgraph,sumData,minRange,maxRange,frequencyResolution,frequencyMax,rangeCutOff,1/Tc,passband);
    spectrogram3D(:,:,FrameIndex)=spectrogram;
    dataMatrix3D(:,:,FrameIndex)=dataMatrix;
    rangeFFT3D(:,:,FrameIndex)=rangeFFT;
    dopplerFFT3D(:,:,FrameIndex)=dopplerFFT;
    rdMatrix3D(:,:,FrameIndex)=rdMatrix;
    

end

animateData(title,rdMatrix3D,spectrogram3D,createVideo,nChirps,numADCSamples,nFrames,rangeResolution,rangeMax,limits,spectrolimits,frequencyResolution,frequencyMax,rangeCutOff);

disp("Process Complete");

end