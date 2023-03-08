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