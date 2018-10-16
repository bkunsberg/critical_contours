%%
clc
addpath('/Users/benkunsberg/Documents/Deep_Learning_Invariant/stimuli/')
cd '/Users/benkunsberg/Documents/Deep_Learning_Invariant/stimuli/data';
files = dir('/Users/benkunsberg/Documents/Deep_Learning_Invariant/stimuli/data');
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
subFolders = subFolders(3:end);
disp(['Number of different surfaces: ', num2str(length(subFolders))]);
resolution = 300;
type = 1;
%%
for i = 1:1%length(subFolders)
    cd '/Users/benkunsberg/Documents/Deep Learning Invariant Features/stimuli/data';
    cd(subFolders(i).name)
    filename = [subFolders(i).name, '_slant'];
    run_fast_CVFT_deep_generate(filename, resolution, type);
end




%%
