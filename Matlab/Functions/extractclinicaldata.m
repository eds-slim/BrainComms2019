
%preprocess

%% extract lesion volumes
formatstr = '%s%f%f';
fid = fopen([BASEDIR '/Input/stroke_volume.txt']);
data_vol = textscan(fid, formatstr, 'HeaderLines', 1, 'Delimiter', ';');
fclose(fid);
clear formatstr fid

volumes = [zeros(n_con,1); data_vol{3}];
clear data_vol


%% extract age and sex as covariates -- patients and controls
formatstr = '%s%q%s%s%f%s%f%*[^\n]';
fid = fopen([BASEDIR '/Input/clinical_data_patients_and_controls.csv']); 
data_clin = textscan(fid, formatstr, n, 'HeaderLines', 1, 'Delimiter', ',');
fclose(fid);
clear formatstr fid


age = data_clin{5};
age = [age(n_pat+1:end); age(1:n_pat)];

sex = data_clin{7};
sex = [sex(n_pat+1:end); sex(1:n_pat)];

%% load and export clinical data
formatstr = '%s%q%s%s%f%s%f%s%s%f%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
fid = fopen([BASEDIR '/Input/clinical_data_patients_and_controls.csv']);
data_clin = textscan(fid, formatstr, n_pat, 'HeaderLines', 1, 'Delimiter', ',');
fclose(fid);
clear formatstr fid

side = [zeros(n_con,1); strcmp(data_clin{2},'l')]; % lesion left coded as 1

GripU =  [zeros(n_con,1); data_clin{13}];
GripA =  [zeros(n_con,1); data_clin{14}];
PinchU =  [zeros(n_con,1); data_clin{15}];
PinchA =  [zeros(n_con,1); data_clin{16}];

ratioGrip =  [zeros(n_con,1); data_clin{13} ./ data_clin{14}];
ratioPinch =  [zeros(n_con,1); data_clin{15} ./ data_clin{16}];

ARAT = [zeros(n_con,1); data_clin{21}];

UEFM = [zeros(n_con,1); data_clin{31}]; 

strokedate = cellfun(@(s)(datenum(s,'dd/mm/yyyy HH:MM')),data_clin{8});
mridate = cellfun(@(s)(datenum(s,'dd/mm/yyyy HH:MM')),data_clin{9});
fuperiod = [zeros(n_con,1); daysact(strokedate,mridate)];

ARAT = [zeros(n_con,1); data_clin{21}];

UEFM = [zeros(n_con,1); data_clin{31}];


%% all subjects
filename=[OUTPUTDIR '/intermediate/subjectdata.csv'];
if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID,group,age,sex\n');
fclose(fid);
M=[ID,group,age,sex];
dlmwrite(filename,M,'-append')

%% patients
filename=[OUTPUTDIR '/intermediate/patientdata.csv'];
if exist(filename,'file'); delete(filename); end
fid=fopen(filename,'w');
fprintf(fid,'ID,fuperiod,volume,gripU, gripA, pinchU, pinchA,ARAT,UEFM\n');
fclose(fid);
M=[ID,fuperiod,volumes,GripU, GripA, PinchU,PinchA,ARAT,UEFM];
dlmwrite(filename,M(n_con+1:end,:),'-append')

save([OUTPUTDIR '/intermediate/clinicaldata.mat'],'volumes','age','sex','fuperiod','deltaGrip', 'deltaPinch','ratioGrip','ratioPinch','ARAT', 'UEFM','-mat')


%% load and export hemisphere specific data
filename=[OUTPUTDIR '/intermediate/hemispheredata.csv'];
if exist(filename,'file'); delete(filename); end

fid=fopen(filename,'w');
fprintf(fid,'ID,region, group\n');
fclose(fid);
M=[repmat(ID,[2,1]), kron([0;1],ones(n,1)), repmat(group,[2,1])];
dlmwrite(filename,M,'-append')
