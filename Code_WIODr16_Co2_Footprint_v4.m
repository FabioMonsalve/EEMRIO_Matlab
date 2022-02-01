%% BASIC CODE POR COMPUTING A CO2 EMISSIONS FOOTPRINT 
% This code allows to allocate the total Emissions of CO2 following the
% Producer Based Approach (PBA) and Consumer Based Approach (CBA) Criteria
% as explained in Monsalve, F., Zafrilla, J. E., & Cadarso, M.-Á. (2016).
% "Where have all the funds gone?..."
% https://doi.org/10.1016/j.ecolecon.2016.06.006 

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
WIOTAB=readmatrix('WIOT2014_Nov16_ROW.xlsx','sheet','2014',...
  'range','e7:cyj2478');

Z=WIOTAB(1:s*r,1:s*r);          % Extracting Intermediate Consumption
Y=WIOTAB(1:s*r,2465:2684);      % Extracting Final Demand
Q=WIOTAB(2472,1:s*r)';          % Extracting Output
Q(Q==0)=1;                    % Removing eventual 0 

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
iv=5;                       % Inventories position
Y_reg=zeros(s*r,r);
Yd=zeros(s*r,s*r);  
  for j=1:r
     if (j==1)
          ini=1;
          fin=y;           
      else
          ini=y*(j-1)+1;
          fin=ini+y-1;    
     end
    % Remove negative from Inventories
    temp=Y(:,fin-(y-iv));
    temp(temp<0)=0;
    Y(:,fin-(y-iv))=temp;
    Y_reg(:,j)=sum(Y(:,ini:fin),2);
    % Diagonalization     
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


























