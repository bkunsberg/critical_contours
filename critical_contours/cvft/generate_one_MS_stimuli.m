%%
%generates a MS for the last folder.


function generate_one_MS_stimuli(string, resolution)

if ~exist('resolution', 'var')
    resolution = 250;
end
filename = ['data/', string, '/', string, '_slant'];
run_fast_CVFT_deep_generate(filename, resolution, 'slant');


end

%%