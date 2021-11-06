clc; clear all; close all;
%% global variables

% Constants
LightSpeed=299792458;                                                      % Speed of Light

% FMCW system variables
numADCSamples= 2048;                                                       % number of ADC samples per chirp
numADCBits=16 ;                                                            % numberof ADC bits per sample 
numRX= 4;                                                                  % number of receivers 
numLanes= 2;                                                               % number of lanes is always 2 
isReal= 0;                                                                 % set to 1 if real only data,0 if complex data 0
skip=0;
nChirps=255;                                                               % number of chirps in a frame
nFrames=128;                                                               % number of frames
samplingrate=2000*1000;                                                    % Samples per Second  
sweepslope=1.979*1e12;                                                     % Frequency slope in Hz/s
bandwidth=2.0270*1e9;                                                      % Calculated bandwidth in Hz

% range and doppler axis variables
rangeMax=((0.9*samplingrate*LightSpeed)/(2*sweepslope))/2;                 % Max distance measured
rangeResolution=((LightSpeed)/(2*bandwidth));                              % Range Resolution
stackFrames=4;                                                            % Number of Frames stacked to create a single Frame
nChirps=nChirps*stackFrames;                                               % number of chirps in a frame
nFrames=floor(nFrames/stackFrames);                                        % number of frames
Tc=2030e-6;
Tf=Tc*nChirps;
frequencyResolution=1/Tf;
frequencyMax=1/(2*Tc);

% Spectrogram variables 
windowSize=510;  %1020                                                            % number of points in a window for SFFT
zeroPadding=10;                                                            % set to a multiple of the datalength for the number of zeros you want 
overlap=0.7;                                                               % Percentage overlap set from 0  to 1
rangeBinSelect=13;                                                          % Range bin selected for SFFT
minRange=12;%12
maxRange=14;%14
sumData=true;
rangeCutOff=3;%2.1
heartRatepassband=[0.8,2];
breathRatepassband=[0.1,0.7];
% Reading Data variables
dataLength=numADCSamples*nChirps*numRX*numLanes;                           %Length of the data being read in at once
% fileName='D:\Radar\mmwave_studio_02_01_01_00\mmWaveStudio\PostProc\100Hz0.bin';
fileName='data\BreathLow\BreathingLow4_0.bin';

%Output Data pre-allocation
nWindows=floor((nChirps-windowSize)/(windowSize*(1-overlap)))+1;
spectrogram3D=zeros(windowSize+floor(zeroPadding*windowSize),nWindows,nFrames);
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
stackedSpectrogram=zeros(windowSize+floor(zeroPadding*windowSize),nWindows*nFrames);
nextWindow=0;

%% Processing 


for FrameIndex=1:nFrames
    nSamples=numADCSamples*nChirps*numRX*(FrameIndex-1)+1;
    if(FrameIndex==1)
        nSamples=0;
    end
    formula=(4*nSamples)+((-1)^(nSamples+1)) -5;
    data= readData(fileName,numADCSamples,numADCBits,numRX,numLanes,isReal,skip,dataLength,formula);
    rx1=data(1,:);
    if (FrameIndex==1)
        showgraph=true;
    else
        showgraph=false;
    end
    [breathRateSpectrogram,heartRateSpectrogram, spectrogram, dataMatrix, rangeFFT, dopplerFFT, rdMatrix]=processFrame(rx1,numADCSamples,nChirps,rangeResolution,rangeMax,windowSize,zeroPadding,overlap,rangeBinSelect,FrameIndex,showgraph,sumData,minRange,maxRange,frequencyResolution,frequencyMax,rangeCutOff,1/Tc,heartRatepassband,breathRatepassband);
    spectrogram3D(:,:,FrameIndex)=spectrogram;
    dataMatrix3D(:,:,FrameIndex)=dataMatrix;
    rangeFFT3D(:,:,FrameIndex)=rangeFFT;
    dopplerFFT3D(:,:,FrameIndex)=dopplerFFT;
    rdMatrix3D(:,:,FrameIndex)=rdMatrix;
    stackedSpectrogram(:,nextWindow+1:nextWindow+nWindows)=spectrogram;
    heartRatestackedSpectrogram(:,nextWindow+1:nextWindow+nWindows)=heartRateSpectrogram;
    breathRatestackedSpectrogram(:,nextWindow+1:nextWindow+nWindows)=breathRateSpectrogram;
    nextWindow=nextWindow+nWindows;
end

Videotitle='Video\BreathingLow4_0';
createVideo=true;
limits=[0,120];
spectrolimits=[0,3e9];

animateData(Videotitle,rdMatrix3D,spectrogram3D,createVideo,nChirps,numADCSamples,nFrames,rangeResolution,rangeMax,limits,spectrolimits,frequencyResolution,frequencyMax,rangeCutOff);

nWindows=floor((nChirps-windowSize)/(windowSize*(1-overlap)))+1;
spectrogramTime=Tc*ceil(windowSize/2):Tc*windowSize*(1-overlap):Tc*windowSize*(1-overlap)*nFrames*nWindows+Tc*windowSize*(1-overlap);
spectrogramSlowTime=linspace(frequencyMax,-frequencyMax,windowSize+windowSize*zeroPadding);

figure('Name','Data Spectrogram');
subplot(3,1,1);

imagesc(spectrogramTime,spectrogramSlowTime,20*log10(abs(stackedSpectrogram)));
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;
title('Spectrogram');

subplot(3,1,2);

imagesc(spectrogramTime,spectrogramSlowTime,20*log10(abs(heartRatestackedSpectrogram)));
 title('Heart Rate Spectrogram');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

subplot(3,1,3);

imagesc(spectrogramTime,spectrogramSlowTime,20*log10(abs(breathRatestackedSpectrogram)));
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;
title('Breath Rate Spectrogram');
% colormap(bone);
%  caxis([0,120]);
 saveas(gcf,'BreathingLow4_0.fig');

[minValueBreath,minIndexBreath] = min(abs(spectrogramSlowTime-breathRatepassband(1)));
if(spectrogramSlowTime(minIndexBreath)<breathRatepassband(1))
    minIndexBreath=minIndexBreath-1;
end
[minValueBreath,maxIndexBreath] = min(abs(spectrogramSlowTime-breathRatepassband(2)));
if(spectrogramSlowTime(maxIndexBreath)>breathRatepassband(2))
    maxIndexBreath=maxIndexBreath+1;
end
[minValueBreath,minnegIndexBreath] = min(abs(spectrogramSlowTime+breathRatepassband(1)));
if(spectrogramSlowTime(minnegIndexBreath)>-breathRatepassband(1))
    minnegIndexBreath=minnegIndexBreath+1;
end
[minValueBreath,maxnegIndexBreath] = min(abs(spectrogramSlowTime+breathRatepassband(2)));
if(spectrogramSlowTime(maxnegIndexBreath)<-breathRatepassband(2))
    maxnegIndexBreath=maxnegIndexBreath-1;
end


[minValueHeart,minIndexHeart] = min(abs(spectrogramSlowTime-heartRatepassband(1)));
if(spectrogramSlowTime(minIndexHeart)<heartRatepassband(1))
    minIndexHeart=minIndexHeart-1;
end
[minValueHeart,maxIndexHeart] = min(abs(spectrogramSlowTime-heartRatepassband(2)));
if(spectrogramSlowTime(maxIndexHeart)>heartRatepassband(2))
    maxIndexHeart=maxIndexHeart+1;
end
[minValueHeart,minnegIndexHeart] = min(abs(spectrogramSlowTime+heartRatepassband(1)));
if(spectrogramSlowTime(minnegIndexBreath)>-heartRatepassband(1))
    minnegIndexBreath=minnegIndexBreath+1;
end
[minValueHeart,maxnegIndexHeart] = min(abs(spectrogramSlowTime+heartRatepassband(2)));
if(spectrogramSlowTime(maxnegIndexHeart)<-heartRatepassband(2))
    maxnegIndexHeart=maxnegIndexHeart-1;
end

FilteredSpectrogramBreath=[breathRatestackedSpectrogram(maxIndexBreath:minIndexBreath,:);breathRatestackedSpectrogram(minnegIndexBreath:maxnegIndexBreath,:)];
FilteredSpectrogramSlowTimeBreath=[spectrogramSlowTime(maxIndexBreath:minIndexBreath),spectrogramSlowTime(minnegIndexBreath:maxnegIndexBreath)];

FilteredSpectrogramHeart=[heartRatestackedSpectrogram(maxIndexHeart:minIndexHeart,:);heartRatestackedSpectrogram(minnegIndexHeart:maxnegIndexHeart,:)];
FilteredSpectrogramSlowTimeHeart=[spectrogramSlowTime(maxIndexHeart:minIndexHeart),spectrogramSlowTime(minnegIndexHeart:maxnegIndexHeart)];
figure();
subplot(2,1,1);
imagesc(abs(FilteredSpectrogramBreath));
title("Spectrogram showing only Breath Frequencies");
subplot(2,1,2);
imagesc(abs(FilteredSpectrogramHeart));
title("Spectrogram showing only Heart Frequencies");
[valsHeart, indHeart] = max(20*log10(abs(FilteredSpectrogramHeart)),[],1);
[valsBreath, indBreath] = max(20*log10(abs(FilteredSpectrogramBreath)),[],1);
figure();
subplot(2,1,1)
plot(valsBreath);
title("Magnitudes of Breath for each time window");
subplot(2,1,2)
plot(valsHeart);
title("Magnitudes of Heart for each time window");
[valueBreath, indicesBreath] = max(valsBreath,[],2);
[valueHeart, indicesHeart] = max(valsHeart,[],2);
threshholdBreath=25;
threshholdHeart=25;
countBreath=0;
countHeart=0;
sumBreath=0;
sumHeart=0;
breath=[];
heart=[];
for i=1:length(indHeart)
    if(valsBreath(i)>=(valueBreath-threshholdBreath))
%         disp(abs(FilteredSpectrogramSlowTimeBreath(indBreath(i))*60));
%         disp(i);
        countBreath=countBreath+1;
        sumBreath=sumBreath+abs(FilteredSpectrogramSlowTimeBreath(indBreath(i))*60);
    end    
    if(valsHeart(i)>=(valueHeart-threshholdHeart))
%         disp(abs(FilteredSpectrogramSlowTimeHeart(indHeart(i))*60));
%         disp(i);
        countHeart=countHeart+1;
        sumHeart=sumHeart+abs(FilteredSpectrogramSlowTimeHeart(indHeart(i))*60);
    end    
    breath=[breath;FilteredSpectrogramSlowTimeBreath(indBreath(i))*60];
    heart=[heart;FilteredSpectrogramSlowTimeHeart(indHeart(i))*60];
end
AvgBreath=sumBreath/countBreath;
AvgHeart=sumHeart/countHeart;
disp(strcat('Breath Rate:',num2str(AvgBreath)));
disp(strcat('Heart Rate:',num2str(AvgHeart)));
disp("Complete");
figure();
subplot(2,1,1)
plot(breath);
title("Breath Rates (Bpm)");
subplot(2,1,2)
plot(heart);
title("Heart Rates (Bpm)");
figure();
imagesc(real(dataMatrix3D(:,:,1)));
figure();
imagesc(angle(dataMatrix3D(:,:,1)));
figure();
imagesc(abs(dataMatrix3D(:,:,1)));
title("Reshaped Data");
ylabel("Chirp Index Number")
xlabel("Sample Index Number")
figure();
range=0:rangeResolution:rangeMax;
slowTime=linspace(frequencyMax,-frequencyMax,nChirps);
imagesc(range,slowTime,20*log10(abs(rdMatrix3D(1:end,floor(numADCSamples/2)+1:end,1))));
xlabel('range (m)');
ylabel('Frequency in Hz');
colorbar;
title("Range-Doppler Map")
figure();
range=0:rangeResolution:rangeMax;
rangeIndex=ceil(rangeCutOff/rangeResolution);
chirpAxis=1:nChirps;
imagesc(range,chirpAxis,20*log10(abs(rangeFFT3D(1:end,floor(numADCSamples/2)+1:end,1))));
xlabel('range (m)');
ylabel('Number of Chirps');
title('Range FFT of Frame Data');
colorbar;
