function [obs,nav,doy,Year] = readrinex211(r_o_name,r_n_name,rinex_path)
% Read observation and navigation RINEX file V. 2.11
% Inputs  : 
%          r_o_name - Observation RINEX's name
%          r_n_name - Navigation RINEX's name
% Outputs :
%          ----------- obs - observation ---------------
%          obs.date    - date, month, year
%          obs.epoch   - epoch of day (second of day)
%          obs.type    - type of pseudorange
%          obs.station - station name
%          obs.data    - data (pseudorange, SNR, etc.)
%          obs.index   - number of satellites
%          obs.rcvpos  - receiver position
%          ----------- nav - navigation ----------------
%          nav.eph     - ephemaris data of satellites
%          nav.index   - number of satellites
%          nav.ionprm  - Ionospheric coefficients
% You can change IGS station to download nav file
% Look at : ftp://anonymous:anonymous@cddis.gsfc.nasa.gov/pub/gps/data/daily/'year'/'doy'/'*n'/
n_name = 'cusv'; %amu2, ankr, cnmr, chpi
current_path = [pwd '\'];
cd(rinex_path)
% Read RINEX Observation Files
    [obs.date, obs.epoch, obs.type, ~, ~, obs.station, obs.data, obs.index, obs.rcvpos,...
        ~, ~, ~] = readrinexobs(r_o_name);
    
% Calculate Date Of Year (DOY)
disp('The data date:');
disp(datetime(obs.date(1:3)));
D1  = obs.date(1:3); % obs.date
D2  = D1; D2(:,2:3) = 0;
ydoy = cat(2, D1(:,1), datenum(D1) - datenum(D2));
Year = num2str(ydoy(1,1));
doy  = num2str(ydoy(1,2),'%.3d');
    
% Check NAV file \ Get online ephemeris
if isempty(r_n_name)
    n   = dir([rinex_path '*' doy '0.' Year(3:4) 'n']);
    if isempty(n)  % Download Navigation file
        try
            nav_filename   = ['brdc' doy '0.' Year(3:4) 'n.gz'];
            disp(['Download NAV RINEX file ' nav_filename])
            % download nav file
            source1 = ['ftp://gdc.cddis.eosdis.nasa.gov/pub/gps/data/daily/' Year '/brdc/' nav_filename];
            cd(rinex_path)
            nav_dl_cmd = ['curl -u anonymous:cssrg.telecom@gmail.com -O --ftp-ssl ' source1];

            % nav_dl_cmd = ['curl.exe -s -v -O --retry 50 --retry-max-time 0 ftp://anonymous:anonymous@cddis.gsfc.nasa.gov/pub/gps/data/daily/' Year '/' doy '/' Year(3:4) 'n/' nav_filename];
            system(nav_dl_cmd)
            % unzip nav file
            nav_uz_cmd    = ['gzip.exe -d ' nav_filename];
            system(nav_uz_cmd)
            n = dir([rinex_path nav_filename(1:end-2)]);
            r_n_name = n.name;
            disp(['Nav file: ' r_n_name ' is downloaded'])
        catch
            cd(current_path)
            error(['error to download Nav file: ' nav_filename '. Please edit new Nav name in **readrinex211**'])
        end
    else
        r_n_name = n.name;
    end
end

% Read RINEX Navigation File
    [~, ~, nav.eph, nav.index, nav.ionprm,...
        ~, ~] = readrinexnav(r_n_name);
    
cd(current_path)
end

