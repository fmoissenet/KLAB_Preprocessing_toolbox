% Author       : G. Grouvel
%                Kinesiology Laboratory (K-LAB) - CURIC
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : To be defined
% Reference    : To be defined
% Date         : September 2022
% -------------------------------------------------------------------------
% Description  : Main routine used to launch the C3D files pre-processing
%                toolbox
% -------------------------------------------------------------------------
% Dependencies : Pre-process Toolbox (F. Moissenet)
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% INIT THE WORKSPACE 
% -------------------------------------------------------------------------
clearvars;
close all;
clc;
tic;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
Folder.code_path = 'C:\Users\grouvel\OneDrive - unige.ch\Documents\DOCTORAT\CODES\1_PROCESS_C3D\PREPROCESSING_TOOLBOX';
Folder.data      = 'E:\RECHERCHE\VESTIBULAIRE\DATA\1_GAIT\DATA_GAIT_SANS_IMPLANT\DATA_PROCESSED\2_SAUVEGARDE';
txtFile          = 'userCommands_vestibulaire.txt';
addpath(genpath(Folder.code_path));

cd(Folder.data);
Files = dir('*.c3d');

temp = [];
for p = 1:size(Files,1)
    if ~contains(Files(p).name,'grf_calibration')
        name = char(Files(p).name);
        temp = [temp;cellstr(name(1:11))];
    end
end
temp = unique(temp);

a = 1;
for i = 1:size(temp,1)
    for j = 1:size(Files,1)
        if contains(Files(j).name,temp(i))
            c3dFiles(a) = Files(j);
            a           = a+1;
        end
    end
    Patient_ID       = temp{i}(1:11);
    Session_ID       = ''; % 'No Session' defined
    Session_date     = c3dFiles(1).name(13:20);
    Session_protocol = '';
    %
    c3dFiles = permute(c3dFiles,[2,1]);
    MAIN_Preprocessing_toolbox(Patient_ID,Session_ID,Session_date,Session_protocol,Folder.code_path,Folder.data,txtFile,c3dFiles);
    a = 1;
    clear c3dFiles;
end

toc;