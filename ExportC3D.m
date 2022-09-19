% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : December 2021
% -------------------------------------------------------------------------
% Description  : This routine aims to export C3D files with updated data.
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : - Biomechanical Toolkit (BTK): https://github.com/Biomechanical-ToolKit/BTKCore
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function ExportC3D(Patient_ID,Session_ID,Session_date,Session_protocol,Folder,Trial,Processing,Units,event,marker,emg,force,grf,rename_files,MD_removed)

% Set new C3D file
% btkFile = btkNewAcquisition();
% btkSetFrequency(btkFile,Trial.fmarker);
% btkSetFrameNumber(btkFile,Trial.n1);
% btkSetPointsUnit(btkFile,'marker',Units.output);
% btkSetAnalogSampleNumberPerFrame(btkFile,ceil(Trial.fanalog/Trial.fmarker));
btkFile = btkCloneAcquisition(Trial.btk);
btkSetPointsUnit(btkFile,'marker',Units.output);
% CLEAR MD ACCORDING TO PROCESS PERFORMED
if grf || force || emg
    btkClearAnalogs(btkFile);
end
btkClearAnalysis(btkFile);
if marker
    btkClearPoints(btkFile);
end
if grf
    btkRemoveMetaData(btkFile,'FORCE_PLATFORM');
end
% CLEAR MD ACCORDING TO CHOICE (txt file)
for i = 1:size(MD_removed,1)
    btkRemoveMetaData(btkFile,MD_removed{i});
end

% Append events
if event == 1
    if ~isempty(Trial.Event)
        for i = 1:size(Trial.Event,2)
            for j = 1:size(Trial.Event(i).value,2)
                Event = Trial.Event(i).value(1,j)/Trial.fmarker;
                btkAppendEvent(btkFile,Trial.Event(i).label,Event,'');
                clear Event;
            end
        end
    end
end

% Append marker trajectories
if marker == 1
    if ~isempty(Trial.Marker)
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.smooth) 
                btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,permute(Trial.Marker(i).Trajectory.smooth,[3,1,2]),zeros(size(permute(Trial.Marker(i).Trajectory.smooth,[3,1,2]),1),1),['Units: ',Trial.Marker(i).Trajectory.units]);
            else
                btkAppendPoint(btkFile,'marker',Trial.Marker(i).label,zeros(Trial.n1,3),zeros(Trial.n1,1),'Units: NA');
            end
        end
    end
end

% Append EMG signals
if emg == 1
    if ~isempty(Trial.EMG)
        for i = 1:size(Trial.EMG,2)
            if ~isempty(Trial.EMG(i).Signal.smooth)
                btkAppendAnalog(btkFile,Trial.EMG(i).label,permute(Trial.EMG(i).Signal.smooth,[3,1,2]),'EMG signal (mV)');
            else
                btkAppendAnalog(btkFile,Trial.EMG(i).label,zeros(ceil(Trial.n1*Trial.fanalog/Trial.fmarker),1),'EMG signal (mV)');
            end
        end
    end
end

% Append Force signals
if force == 1
    if ~isempty(Trial.Force)
        for i = 1:size(Trial.Force,2)
            if ~isempty(Trial.Force(i).Signal.smooth)
                btkAppendAnalog(btkFile,Trial.Force(i).label,permute(Trial.Force(i).Signal.smooth,[3,1,2]),'Force signal (mV)');
            else
                btkAppendAnalog(btkFile,Trial.Force(i).label,zeros(ceil(Trial.n1*Trial.fanalog/Trial.fmarker),1),'Force signal (mV)');
            end
        end
    end
end

% Append GRF signals
if grf == 1
    if ~isempty(Trial.GRF)
        for i = 1:size(Trial.GRF,2)
            if ~isempty(Trial.GRF(i).Signal.F.smooth)
                F      = permute(Trial.GRF(i).Signal.F.smooth,[3,1,2]);
                F(:,1) = -F(:,1);
                F(:,3) = -F(:,3);
                M      = permute(Trial.GRF(i).Signal.M.smooth,[3,1,2]);
                M(:,1) = -M(:,1);
                M(:,3) = -M(:,3);
                btkAppendForcePlatformType2(btkFile,...
                                            F,...
                                            M,...
                                            Trial.GRF(i).corners',[0 0 0],1);
            else
                btkAppendForcePlatformType2(btkFile,...
                                            zeros(size(Trial.GRF(i).Signal.F.raw)),...
                                            zeros(size(Trial.GRF(i).Signal.M.raw)),...
                                            Trial.GRF(i).corners',[0 0 0],1);
            end
        end
    end
end

% Export C3D file
temp = regexprep(Trial.file,'.c3d','');
if contains(Trial.file,'Calibration_force')
    task = 'CALIB1';
    num = str2num(regexprep(temp,'Calibration_force ',''));
elseif contains(Trial.file,'Elevation_coronal')
    task = 'TASK1';
    num = str2num(regexprep(temp,'Elevation_coronal ',''));
elseif contains(Trial.file,'Elevation_sagittal')
    task = 'TASK2';
    num = str2num(regexprep(temp,'Elevation_sagittal ',''));
elseif contains(Trial.file,'Isometric_left')
    task = 'TASK3';
    num = str2num(regexprep(temp,'Isometric_left ',''));
elseif contains(Trial.file,'Isometric_right')
    task = 'TASK4';
    num = str2num(regexprep(temp,'Isometric_right ',''));
elseif contains(Trial.file,'Rotation_external')
    task = 'TASK5';
    num = str2num(regexprep(temp,'Rotation_external ',''));
elseif contains(Trial.file,'Rotation_internal')
    task = 'TASK6';
    num = str2num(regexprep(temp,'Rotation_internal ',''));
elseif contains(Trial.file,'Static_reference1')
    task = 'STATIC1';
    num = str2num(regexprep(temp,'Static_reference1 ',''));
elseif contains(Trial.file,'Static_reference2')
    task = 'STATIC2';
    num = str2num(regexprep(temp,'Static_reference2 ',''));
elseif contains(Trial.file,'SBNNN')
    task = 'SBNNN';
    num = str2num(regexprep(temp,'SBNNN ',''));
elseif contains(Trial.file,'GBNNN')
    task = 'GBNNN';
    num = str2num(regexprep(temp,'GBNNN ',''));
elseif contains(Trial.file,'LBNNN')
    task = 'LBNNN';
    num = str2num(regexprep(temp,'LBNNN ',''));
elseif contains(Trial.file,'ABNNN')
    task = 'ABNNN';
    num = str2num(regexprep(temp,'ABNNN ',''));
end
if num < 10
    num = ['0',num2str(num)];
else
    num = num2str(num);
end

if rename_files
    newFile = [num2str(Patient_ID),'-',...
               Session_ID,'-',...
               Session_date,'-',...
               regexprep(Session_protocol,'KLAB-UPPERLIMB-',''),'-',...
               task,'-',...
               num,...
               '.c3d'];
else
    newFile = [temp,...
               '.c3d'];
end
cd(Folder.data);  
cd ..;
if ~isfolder('Processed')
    mkdir('Processed');
end
cd('Processed');
btkWriteAcquisition(btkFile,newFile);