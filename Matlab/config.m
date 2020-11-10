% To be run from ...../Matlab

%BASEDIR = '/home/eckhard/Documents/2018 05 05 Chronic stroke refactored/Chronic stroke refactored/';
%BASEDIR='/home/eckhard/Dropbox/2018 05 02 Chronic stroke refactored/Chronic stroke refactored/';
makeconfig

cd ..
BASEDIR = pwd;
cd([BASEDIR filesep 'Matlab'])
OUTPUTDIR = sprintf('%s/.output/%s/%s/%1.2f',BASEDIR,normalisation,thresholding,griddelta);

addpath(genpath('./'))
addpath(genpath('/home/eckhard/Documents/MATLAB/toolboxes'))


pat_ex=[28,30,32,36];

runflag = true; % used for GGP, LGP, MTCP, NBS