%This function takes in a shaded image (.png) and outputs the critical (min-saddle) contours.
%Leave off the extension '.png'
%The results will output in this folder.


%Ex: find_critical_contours_from_image('shape_slant')


% By Ben Kunsberg
% C++ Speedup by Shivam Nadimpalli

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function find_critical_contours_from_image(filename)

addpath(genpath(pwd))
cd(fileparts(mfilename('fullpath')));
cd data
resolution = 100;
run_fast_CVFT_deep_generate(filename, resolution, 'shaded')

end