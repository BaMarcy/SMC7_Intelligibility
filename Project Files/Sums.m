%% Summation of enhanced audio files with a reference unenhanced file
%   for evaluation of intelligibility with the STOI test.
% Script by Nikos Menoudakis, SMC7, University of Aalborg

%% Just a Reminder to switch to the script directory

% The message box
h1=msgbox({'See that the script execution directory';
    '     is included in your Matlab path!'},'Attention!');
uiwait(h1);     % Wait until OK is pressed


%% Tidy up and Initialize.

clearvars;
close all;
pause(2);
stoiMx=[];

% Check this section, it must change...
% a=exist('SummedFiles','dir'); % Check if previous summings folder exists
% if a==7                 % If yes...
%     rmdir SummedFiles s;% ...remove it. (The s forces removal.)
% end

mkdir SummedFiles;  % Create a directory for the new files:


%% First load the files to be summed. 
% Using the "uigetfile" command. Store file names and paths.

[clFname,clFpath]=uigetfile('*.wav','Please Select the CLEAN Audio File');
[unFname,unFpath]=uigetfile('*.wav','Please Select the UNPROCESSED Audio File');
[prFname,prFpath]=uigetfile('*.wav','Please Select the ENHANCED Audio File');


%% Strip the ".wav" extension to Prepare for Renaming:

prFnm=prFname(1:end-4);
unFnm=unFname(1:end-4);


%% Input the Summing Percentage of the Unprocessed audio file

% https://se.mathworks.com/help/matlab/ref/inputdlg.html

prompt={'Input % Noisy Signal min','Input % Noisy Signal max'};
defaults={'1','50'};
percIn=inputdlg(prompt,'Mix%',1,defaults);
perc=str2double(percIn);
percLo=perc(1,1); percHi=perc(2,1);

% Input Values Check
% if percHi>100
%     percHi=100;
% elseif percHi<0
%     percHi=0;
% end
% if percLo>100
%     percLo=100;
% elseif percLo<0
%     percLo=0;
% end
% if percHi<percLo
%     percHi=perLo;
% end

percLoS=num2str(percLo);    % else it does not work with the names. Must check it?...
percHiS=num2str(percHi);    % else it does not work with the names. Must check it?...

% Convert rates100 to rates1
% percLo1=percLo/100;
% percHi1=percHi/100;


%% Create text file name for the STOI values

txtFlNm=strcat('stoivals_',prFnm,'+',percLoS,'-',percHiS,'%unpr');
% fileID=fopen(txtFlNm,'a');

%% Copy the source files into the script Dir.

% https://se.mathworks.com/help/matlab/ref/pwd.html    :CurrentDir
% https://se.mathworks.com/help/matlab/ref/strcmp.html :StringCompare
% help: copyfile(SOURCE) attempts to copy SOURCE to the current directory.

if strcmp(unFpath(:,1:(end-1)),pwd)==0
    copyfile(strcat(unFpath,unFname));  % If unpr file is not @ script dir, copy there
end

if strcmp(prFpath(:,1:(end-1)),pwd)==0
    copyfile(strcat(prFpath,prFname));  % If prsd file is not @ script dir, copy there
end


%% Read the audio files

[unpr,fs]=audioread(unFname); % Read unpr samples and audio sampling freq.
prsd=audioread(prFname);  %Read processed audio samples
[cleanx,cleany] = audioread(clFname); %clean speech import

%% Determine sample sizes of the audio files and their difference.
%  This part is for overcoming the change to the size of the enhanced audio files.

szun=size(unpr,1);  % The sample size of the unprocessed file.
szpr=size(prsd,1); % The sample size of the processed file.


%% Prepare the length of the processed files for the summation...
%  ...by making them equal sized. (OBS! TRUNCATE ENDSAMPLES)
%  This works in conjunction with previous section.

unpr=unpr(1:min(szun,szpr),:);
prsd=prsd(1:min(szun,szpr),:);  
cleanx = cleanx(1:min(szun,szpr),:);

%% Perform the summation AND NORMALIZE back to the source max.

% sumMx=[];   % Empty Matrix for the mix values???
% stoiMx=[];  % Empty Matrix for the STOI values
steps=percHi-percLo+1;

stoiMx=zeros(steps,2);

hwait=waitbar(0,'Computing, Please Wait...');

for s=percLo:percHi
    
sum=(prsd*(1-s/100)+unpr*s/100);

% sumMx=[sumMx sum];  % The Summed Files Matrix


%% Write the New audio File

% The summed file name:
% sumFlNam=strcat(prFnm,'+',percLoS,'-',percHiS,'%unpr_SUM.wav');
sumFlNm=strcat(prFnm,'+',num2str(s),'%unpr_SUM.wav');

cd SummedFiles ;    % Go to the Sum Dir
audiowrite(sumFlNm,sum,fs);    % Write the s-th audio file
cd ../ ;  % Return to the script directory (OneUp-MacCompatible)


%% Do STOI and output results


stoival=stoi(cleanx,sum,fs);  % x=prsd,  y=sum
stoivalS=num2str(stoival);
% stoiMx=[stoiMx;[s,stoival]];    % The Matrix with the STOI values
stoiMx(s,:)=[s,stoival];  % Record the values to the STOI Matrix


%% Display a Waitbar

waitbar(s/steps)

%% End of the iterations

end
close(hwait);

%% Write STOI vale to the txt file

disp('The STOI values are: ');disp(stoiMx);

%formatSpec='Mix %s has STOI: ',stoiMx)

%fprintf(fileID,,'double');  % FIX THIS

scatter(stoiMx(:,1),stoiMx(:,2))
xlabel('Percent of added UPS');
ylabel('STOI values');
title('Summation STOI sp30 car');

%%



%%

% End Message:
% h=msgbox({'The summed file is in the "SummedFiles" folder in the script directory' ; 'Intelligibillity results are the following:';stS1,stoivalS1;stS2,stoivalS2;stS3,stoivalS3},'Ready!');
h=msgbox({'The summed file is in the "SummedFiles" folder in the script directory' 'The STOI values are in the Command Window'},'Ready!');
% uiwait(h);
% 'There is also a copy placed in your source files directory:' ; unFpath
%clearvars;