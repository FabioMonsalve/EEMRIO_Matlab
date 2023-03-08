%% BASIC CODE POR COMPUTING A CO2 EMISSIONS FOOTPRINT
% ************************************************************************
% ************************************************************************
% This code allows allocating the total Emissions of CO2 with the ICIO dataset
% from OCDE for the year 2018 following the 
%  Producer Based Approach (PBA) and Consumer Based Approach (CBA) Criteria
%  as explained in Monsalve, F., Zafrilla, J. E., & Cadarso, M.-Á. (2016).
%  "Where have all the funds gone?..."
%  https://doi.org/10.1016/j.ecolecon.2016.06.006 

% It is necessary to download the following files 
% Multi-Regional Input-Output Dataset
% - https://www.oecd.org/sti/ind/inter-country-input-output-tables.htm
%      Note 1. Download the 2015-2018 series.
%      Note 2. Unzip the file to give access to the 2018 year.
% 
% Data for Carbon dioxide emissions embodied in international trade
% - https://stats.oecd.org/Index.aspx?DataSetCode=IO_GHG_2019#
%      Note 1. You need to download the 2021 edition, formatted...
%      Note 2. ... accordingly with the ICIO structure, i.e., a  column
%               vector with all the countries and sectors ordered. It is
%               relatively easy to do that with the customize option in
%               in the website.
%      Note 3. I provided an "*.xlsx" file as an example
%  The files should be uncompressed and saved in the same folder where 
%  the code is allocated (saving in another folder will require changes
%  in the set path preferences of Matlab).

% The Code will only compute 2018, but you can easily change
% some parameters to compute every other year. 

% ¡¡¡ IMPORTANT!!! ICIO Dataset is provided with four "virtual" regions 
% corresponding to the processing exports of Mexico and China as the final 
% blocks; therefore some additional arrangements should be made with
% respect to other MRIO datasets, in order to rearrange the processing
% exports to the positions of the corresponding countries. Those lines are
% specified in the code.

% I hope you find this code useful in your Multi-regional Input-Output analysis.

% Please report to fabio.monsalve@uclm.es any issue related to this code
% ************************************************************************
% ************************************************************************

%% SETTING PARAMETERS ***************************************************
tic
clear

% LOADING INITIAL DATA
T = readtable ('ICIO2021_2018.csv');

% Isolating list of countries and sectors
labels = cell2table(split(T.Var1(1:3262,1),'_'));
[list_region,~,~] = unique(labels(:,1),'stable');
[list_sector,~,~] = unique(labels(:,2),'stable');

r = height (list_region);
s = height (list_sector)-1;  % Not counting TAXSUB row

%% DATA PROCESSING *******************************************************
Data = table2array(T(:,2:3599));
    Z = Data (1:s*r,1:s*r);          % Extracting Intermediate Consumption
    Y = Data (1:s*r,3196:3597);      % Extracting Final Demand
    Q = Data (3264,1:s*r)';          % Extracting Output
        Q(Q==0)=1;                      % Removing eventual 0 

Co2_read = readmatrix ('ICIO_Co2_2018.xlsx');
Co2 = Co2_read(:,3);

% REORDERING PROCESSING EXPORTS ******************************************
% ************************************************************************
% ************************  WARNING **************************************
% *********************** ONLY FOR ICIO DATASETS *************************
% ************************************************************************
% The following lines are of use only for ICIO Dataset considering that
% Intermediate and final data consumption for Mexico and China are in 
% different blocks, specifically, in the last "four" blocks (regions 68:71).

% Reorder data for Mexico
Z (1081:1125,:) = Z(3016:3060,:) + Z(3061:3105,:);
Y (1081:1125,:) = Y(3016:3060,:) + Y(3061:3105,:);
Q (1081:1125,:) = Q(3016:3060,:) + Q(3061:3105,:);

% Redorder data for China
Z (1936:1980,:) = Z(3106:3150,:) + Z(3151:3195,:);
Y (1936:1980,:) = Y(3106:3150,:) + Y(3151:3195,:);
Q (1936:1980,:) = Q(3106:3150,:) + Q(3151:3195,:);

% Removing the last four blocks
Z (3016:3195,:) = [];
Z (:,3016:3195) = [];
Y (3016:3195,:) = [];
Q (3016:3195,:) = [];

r2 = height(Z)/s;            % New number of regions after removing


%% SOLVING THE MODEL ***************************************************
A = Z / diag(Q);              % Technical Coefficients
I = eye(s*r2);               % Identity Matrix
MQ = inv(I-A);              % Leontieff Inverse
e = diag(Co2) / diag(Q);    % Emissions Coefficients
ME = e * MQ;                  % Emissions Multiplier

% Processing Final Demand block diagonalization
y = 6;                        % Final Demand Elements
Y_reg = zeros(s*r2,r2);
Yd = zeros(s*r2,s*r2);  
for j = 1:r2 
    ini = y*(j-1)+1;
    fin = ini+y-1;

    Y_reg(:,j) = sum(Y(:,ini:fin),2);
    % - Diagonalizar     
     ini_j = s*(j-1)+1;
     fin_j = ini_j+s-1;
     for i = 1:r2
         ini_i = s*(i-1)+1;
         fin_i = ini_i+s-1;
         Yd(ini_i:fin_i,ini_j:fin_j) = diag(Y_reg(ini_i:fin_i,j));
     end
end

% COMPUTING EMISSIONS
Emissions_Co2 = ME * Yd;
PBA = sum (Emissions_Co2,2);
CBA = sum (Emissions_Co2,1);

toc


























