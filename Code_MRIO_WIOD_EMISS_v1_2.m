%% BASIC MODEL FOR ESTIMATING GLOBAL GREEN HOUSE GASES (GHG) EMISSIONS
% USING WIOD Database, release 2013.
tic
clear
% setting parameters
s=35;       % Number of sectors of WIOD Database
r=41;       % Number of regions of WIOD Data
df=5;       % Categories of final demanda
paises_wiod=['AUS';'AUT';'BEL';'BGR';'BRA';'CAN';'CHN';'CYP';'CZE';'DEU';...
    'DNK';'ESP';'EST';'FIN';'FRA';'GBR';'GRC';'HUN';'IDN';'IND';'IRL';'ITA'...
    ;'JPN';'KOR';'LTU';'LUX';'LVA';'MEX';'MLT';'NLD';'POL';'PRT';'ROU';'RUS'...
    ;'SVK';'SVN';'SWE';'TUR';'TWN';'USA';'ROW'];

% LOADING DATA -----------------------------------------------------------
% First retrived the required files from http://www.wiod.org, release 2013
% File the downloaded dataset in the same directory than this code (or,
% alternatively, change the set Path preferences in matlab)
% Loading Input-Output Table of last available year (2009)
[num,txt]=xlsread('wiot09_row_apr12.xlsx','WIOT_2009','e4:bkf1449');
WIOT_09=num;

% Loading Emissions of last available year (2009)
EM_GHG=zeros(s*r,1);
% Loading emissions vectors for all wiod countries and convert to CO2eq
for k=1:r
    ini_k=(k-1)*s+1;
    fin_k=k*s; 
    nombre_fichero=sprintf('%s_AIR_May12.xls',paises_wiod(k,:));
    EMI_TEMP1=(xlsread(nombre_fichero,'2009','c2:j42'));
      % Removing NaN from emissions matrix
        ind=find(isnan(EMI_TEMP1)); 
        EMI_TEMP1(ind)=0;
    EMI_TEMP2(:,:)=EMI_TEMP1(1:35,:);
    EM_GHG(ini_k:fin_k)=EMI_TEMP2(:,1)+EMI_TEMP2(:,2)*(28/1000)+EMI_TEMP2(:,3)*(265/1000);
end

% SOLVING DE MODEL -------------------------------------------------------
% Extracting Intermediate Consumption Matrix for year 2009
Z_09=WIOT_09(1:s*r,1:s*r);
% Extracting Output row vector
Q_09=WIOT_09(1443,1:s*r);
% Removing zeros
    for i=1:s*r
        if (Q_09(i)==0) 
            Q_09(i)=1;
        end
    end

% Computing matrix of technical coefficientes
A_09=Z_09/diag(Q_09); % Alternatively A_09=Z_09*inv(diag(Q_09));

% Computing Leontieff inverse
I=eye(s*r); 
MQ_09=inv(I-A_09);

% Computing Emissions coefficientes
e_09=diag(EM_GHG)/diag(Q_09);

% Processing The bill of Final Demand
DF_WIOT_09=WIOT_09(1:s*r,1436:1640);    % Isolation of Final Demand
DF_Country=zeros(s*r,r);
DF_09=zeros(s*r,s*r);  
    for j=1:r
       if (j==1)
            ini_country=1;
            fin_country=df;
       else
            ini_country=df*(j-1)+1;
            fin_country=ini_country+(df-1);
       end
        DF_Country(:,j)=sum(DF_WIOT_09(:,ini_country:fin_country),2);
        % - Diagonalization    
         ini_j=s*(j-1)+1;
         fin_j=ini_j+s-1;
         for i=1:r
             ini_i=s*(i-1)+1;
             fin_i=ini_i+s-1;
             DF_09(ini_i:fin_i,ini_j:fin_j)=diag(DF_Country(ini_i:fin_i,j));
         end
    end
    
% Computing GHG Emissions for 41 countries/resgions and 35 sectors
EM_GHG_41R35s_09=(e_09*MQ_09)*DF_09;

% EXPORTING RESULTS ------------------------------------------------------
% Writing row headings (region/country and sector)
xlswrite('Results_WIOD_Basic_Model_EMISS.xlsx',txt,'EMISS41R','e4');    
% Writing column headings (region/country and sector)
xlswrite('Results_WIOD_Basic_Model_EMISS.xlsx',txt','EMISS41R','b7');
% Writing final results
xlswrite('Results_WIOD_Basic_Model_EMISS.xlsx',EM_GHG_41R35s_09,'EMISS41R','e7');

toc




