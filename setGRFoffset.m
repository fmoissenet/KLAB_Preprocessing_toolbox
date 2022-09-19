% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : September 2022
% -------------------------------------------------------------------------
% Description  : To be defined
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : None
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function GRFoffset = setGRFoffset(Folder,Processing,Units)

% Load btk file
btk         = btkReadAcquisition([Folder.data, '\', Processing.GRF.zmethod.parameter]);
% Get GRF records
GRF   = btkGetForcePlatformWrenches(btk);
% Organise arrays
P           = GRF.P;
GRFoffset.P = permute(P,[2,3,1]);
F           = GRF.F;
GRFoffset.F = permute(F,[2,3,1]);
M           = GRF.M;
GRFoffset.M = permute(M,[2,3,1])*Units.ratio;