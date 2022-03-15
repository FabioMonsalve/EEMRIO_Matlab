%% BASIC CODE POR COMPUTING A CO2 EMISSIONS FOOTPRINT
% ************************************************************************
% ************************************************************************
% This code allows to allocate the total Emissions of CO2 following the
%  Producer Based Approach (PBA) and Consumer Based Approach (CBA) Criteria
%  as explained in Monsalve, F., Zafrilla, J. E., & Cadarso, M.-Á. (2016).
%  "Where have all the funds gone?..."
%  https://doi.org/10.1016/j.ecolecon.2016.06.006 

% It is necessary to download the following files 
% - https://dataverse.nl/api/access/datafile/199104 
%      Note 1. This is a huge zip file including all the years
%      Note 2. Excel format is xlsb; therefore if you are working in a MAC, 
%              you should save as *.xlsx (OSX can't read .xlsb files)
% - https://joint-research-centre.ec.europa.eu/
%           scientific-activities/
%           economic-environmental-and-social-effects-globalisation_en


% The files should be uncompressed and saved in the same folder where 
%  the code is allocated (saving in another folder will require changes
%  in the set path preferences of Matlab).

% The downloaded files cover all the years 2000-2014.
% The Code will only compute 2014, but easily you can change
%  some parameters (as indicated in the code) to compute every other year. 

% I hope you find this code useful in your Multiregional
%  Input-Output analysis.
% ************************************************************************
% ************************************************************************



% SETTING PARAMETERS ***************************************************
tic
clear
s=56;       % Economic sectors
r=44;       % Countries and/or Regions
Countries=['AUS';'AUT';'BEL';'BGR';'BRA';'CAN';'CHE';'CHN';'CYP';'CZE';...
           'DEU';'DNK';'ESP';'EST';'FIN';'FRA';'GBR';'GRC';'HRV';'HUN';...
           'IDN';'IND';'IRL';'ITA';'JPN';'KOR';'LTU';'LUX';'LVA';'MEX';...
           'MLT';'NLD';'NOR';'POL';'PRT';'ROU';'RUS';'SVK';'SVN';'SWE';...
           'TUR';'TWN';'USA';'ROW'];

% DATA PROCESSING *******************************************************
% Loading Input Output Data from Excel
WIOTAB=readmatrix('WIOT2014_Nov16_ROW','sheet','2014',...
  'range','e7:cyj2478');

Z=WIOTAB(1:s*r,1:s*r);          % Extracting Intermediate Consumption
Y=WIOTAB(1:s*r,2465:2684);      % Extracting Final Demand
Q=WIOTAB(2472,1:s*r)';          % Extracting Output
Q(Q==0)=1;                      % Removing eventual 0 

% Loading Co2 Emissions Data for year 2014
EMISS=zeros(s*r,1);
for i=1:r
    ini=s*(i-1)+1;
    fin=ini+s-1;
    sheet=sprintf('%s',Countries(i,:));
    range='P2:P57';   % Year 2014  
    temp=readmatrix('CO2 emissions.xlsx','Sheet',sheet,'Range',range);
    EMISS(ini:fin,1)=temp;        
end

% SOLVING THE MODEL ***************************************************
A=Z/diag(Q);              % Technical Coefficients
I=eye(s*r);               % Identity Matrix
MQ=inv(I-A);              % Leontieff Inverse
e=diag(EMISS)/diag(Q);    % Emissions Coefficients
ME=e*MQ;                  % Emissions Multiplier

% Processing Final Demand
y=5;                        % Final Demand Elements
Y_reg=zeros(s*r,r);
Yd=zeros(s*r,s*r);  
for j=1:r 
    ini=y*(j-1)+1;
    fin=ini+y-1;

    % Activate if you want remove negative elements from Inventories
    %Y_WIOT=max(Y_WIOT,0);     

    Y_reg(:,j)=sum(Y(:,ini:fin),2);
    % - Diagonalizar     
     ini_j=s*(j-1)+1;
     fin_j=ini_j+s-1;
     for i=1:r
         ini_i=s*(i-1)+1;
         fin_i=ini_i+s-1;
         Yd(ini_i:fin_i,ini_j:fin_j)=diag(Y_reg(ini_i:fin_i,j));
     end
end

% COMPUTING EMISSIONS
EMISS_44R=ME*Yd;
PBA=sum(EMISS_44R,2);
CBA=sum(EMISS_44R,1);

toc


























