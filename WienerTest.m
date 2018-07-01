

%%%%% Noise Suppression using Wiener Filter and Calculation of STOI Values %%%%%%




%%
clc
clear

        %Select Clean and Noisy Speech Files to be Used

[CSFname,clFpath]=uigetfile('*.wav','Please Select the Clean Speech Audio File');
[NSFname,unFpath]=uigetfile('*.wav','Please Select the Noisy Speech Audio File');

prompt = 'Please input the desired initial silence duration of the noisy speech (in seconds): ';
x = input(prompt);
%% 


[YN, Fs] = audioread(NSFname);  %Extract Audio Information from Noisy Speech File


plot(YN);                    %Visualize Signal
soundsc(YN,Fs);             %Listen to Signal
pause(3.2)                      

%%

IS = x;           %Input Initial noise duration for Wiener Filter
YPR = WienerScalart96(YN, Fs, IS);   %Noise Supression of Noisy Speech
plot(YPR)           %Visualize Processed Signal
soundsc(YPR, Fs);   %Listen to Processed Signal


% Use code below if you want to save an audio file of the processed signal
       

%proc = 'processed.wav';      %Assign filename for processed speech signal
%%audiowrite(proc,YPR,Fs);    %Create audio file of processed speech signal

%%
[YC, Fs] = audioread(CSFname); %Extract Audio Information from Clean Speech File

diff = length(YC)-length(YPR);    %Calculate difference in samples between 
                                        %clean and processed speech signal
                                   
YCT = YC(1:end - diff ,:);    %Truncated Clean Speech Signal for STOI


%%


StoiN = stoi(YC, YN , Fs)    % calculates STOI for Unprocessed Noisy Speech Signal

StoiP = stoi(YCT, YPR , Fs)    % calculates STOI for Processed Speech Signal





