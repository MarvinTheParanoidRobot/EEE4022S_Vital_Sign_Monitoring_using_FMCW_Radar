function[data]= readData(fileName,numADCSamples,numADCBits,numRX,numLanes,isReal,skip,dataLength,OFFSET)

%% readfile
% read binary file
fid = fopen(fileName,'r');
fseek(fid, OFFSET, 'bof');
adcData = fread(fid,dataLength,'int16',skip);
% if 12 or 14 bits ADC per samplecompensatefor sign extension 
if numADCBits~= 16
    l_max= 2^(numADCBits-1)-1;
    adcData(adcData> l_max)= adcData(adcData> l_max)- 2^numADCBits;
end
fclose(fid);
fileSize= size(adcData,1);
% realdatareshape,filesize= numADCSamples*numChirps
if isReal
    numChirps= fileSize/numADCSamples/numRX;
    %disp(numChirps);
    LVDS= zeros(1,fileSize);
    %create column for each chirp
    LVDS= reshape(adcData,numADCSamples*numRX,numChirps);
    %each row is data from one chirp
    LVDS= LVDS.';
else
    % for complexdata
    % filesize= 2 * numADCSamples*numChirps
    numChirps= fileSize/2/numADCSamples/numRX;
    %disp(numChirps);
    LVDS= zeros(1,fileSize/2);
    %combine real and imaginary part in to complex data
    %read in file:2I is followed by 2Q 
    counter= 1;
    for i=1:4:fileSize-1
        LVDS(1,counter)= adcData(i)+ sqrt(-1)*adcData(i+2);
        LVDS(1,counter+1)= adcData(i+1)+sqrt(-1)*adcData(i+3);
        counter= counter+ 2;
    end% create column for each chirp 
    LVDS= reshape(LVDS,numADCSamples*numRX,numChirps);%each row is data from one chirp 
    LVDS= LVDS.';
end
%organize data per RX 
adcData= zeros(numRX,numChirps*numADCSamples);
for row = 1:numRX
    for i = 1:numChirps
        adcData(row,(i-1)*numADCSamples+1:i*numADCSamples)= LVDS(i,(row-1)*numADCSamples+1:row*numADCSamples);
    end
end
% return receiver data
data= adcData;
end