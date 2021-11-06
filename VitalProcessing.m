%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: Contactless Vital Sign Monitoring using FMCW Radar
%Lead Researcher: Liam McEvoy (MCVLIA001)
%Supervisor: Stephen Paine
%
%
%
%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters

SOP_mode= 2;
baudrate= 921600;
uart_com_port = 7;
timeout= 1000;
wait=20;
strFilename = 'D:\\Radar\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\config.lua';
adc_data_path = '"D:\\Radar\\mmwave_studio_02_01_01_00\\mmWaveStudio\\PostProc\\';
datapath='D:\Radar\mmwave_studio_02_01_01_00\mmWaveStudio\PostProc\';
ext='.bin';
%% RSTD_Interface_Example.m
addpath(genpath('.\'))

% Initialize mmWaveStudio .NET connection
RSTD_DLL_Path = 'D:\Radar\mmwave_studio_02_01_01_00\mmWaveStudio\Clients\RtttNetClientController\RtttNetClientAPI.dll';

ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path);
if (ErrStatus ~= 30000)
	disp('Error inside Init_RSTD_Connection');
	return;
end

%Example Lua Command
rangeBinSelect=12;
rangeCutOff=2.1;
minRange=10;
maxRange=14;
configRadar(timeout,SOP_mode,uart_com_port,baudrate,strFilename);
captureString=input('Do you want to process data? (y/n):','s');
configString=input('Do you want to use default parameters? (y/n):','s');
if(strcmpi(configString,'y'))
    windowSize=4;                                                              % number of points in a window for SFFT
    zeroPadding=10;                                                            % set to a multiple of the datalength for the number of zeros you want 
    overlap=0.6;                                                               % Percentage overlap set from 0  to 1
    rangeBinSelect=12;  
    createVideo=true;
    limits=[0,120];
    spectrolimits=[0,2e5];
    filename='Body';
    minRange=7;
    maxRange=9;
    sumData=true;
    stackFrames=1;
else
    filename=input('Data and video filename:','s');
    windowSize=input('Input Window Size for Spectrogram:');
    zeroPadding=input('Input Zero Padding for Spectrogram:');
    overlap=input('Input overlap for Spectrogram:');
    sumData=input('Do you want to sum rangebins for spectrogram?(true/false)');
    if sumData
        minRange=input('Input minRange for Spectrogram:');
        maxRange=input('Input maxRange for Spectrogram:');
    else
        rangeBinSelect=input('Input range bin selected for Spectrogram:');
    end
    createVideo=input('Save Video:(true/false)');
    limits=input('Range Doppler limits:[min,max]');
    spectrolimits=input('Spectrogram limits:[min,max]');
    stackFrames=input('Input number of frames stacked to form a single frame');
end

inputString='HelloWorld';
count=0;
while(true)
    if(strcmpi(inputString,'n'))
        return;
    else
        filepath=strcat(adc_data_path,filename,num2str(count),ext,'"');
        file=strcat(datapath,filename,num2str(count),ext);
        title=strcat('Video\',filename,num2str(count));
        capture(filepath,timeout,wait);
        if (strcmpi(captureString,'y'))
            process(file,windowSize,zeroPadding,overlap,rangeBinSelect,title,createVideo,limits,spectrolimits,sumData,minRange,maxRange,stackFrames,rangeCutOff);
            reprocessCount=0;
            while(true)
            	reprocess=input('Do you want to reprocess with new parameters?(y/n)','s');
            	if (strcmpi(reprocess,'y'))
                	windowSize=input('Input Window Size for Spectrogram:');
                	zeroPadding=input('Input Zero Padding for Spectrogram:');
                	overlap=input('Input overlap for Spectrogram:');
                	sumData=input('Do you want to sum rangebins for spectrogram?(true/false)');
                	if sumData
                    	minRange=input('Input minRange for Spectrogram:');
                    	maxRange=input('Input maxRange for Spectrogram:');
                    else
                    	rangeBinSelect=input('Input range bin selected for Spectrogram:');
                    end
                	createVideo=input('Save Video:(true/false)');
                 	limits=input('Range Doppler limits:[min,max]');
                 	spectrolimits=input('Spectrogram limits:[min,max]');
                 	stackFrames=input('Input number of frames stacked to form a single frame');
                else
                	break;
                end
                title=strcat('Video\',filename,num2str(count),'_',num2str(reprocessCount));
                process(file,windowSize,zeroPadding,overlap,rangeBinSelect,title,createVideo,limits,spectrolimits,sumData,minRange,maxRange,stackFrames,rangeCutOff);
                reprocessCount=+reprocessCount;
            end 
        end
        count=count+1;
    end
	inputString=input('Do you want to continue? (y/n):','s');
end