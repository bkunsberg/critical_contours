%FAST CVFT Version  1/7/17
%Type can be 'shaded' or 'slant'

%Ben Kunsberg

%Example run:
% filename1 = 'horse2';
% filename1 = 'peaks';
% type = 'shaded'; %the type of image
% resolution = 200;

%Parameter 'm' controls the number of separatrices to plot.

function run_fast_CVFT_deep_generate(filename1, resolution, type)
%% 1. Load Image, Define parameters, Compute discrete gradient field
curr_folder = pwd;
filename = [filename1, '.png'];
saved_filename = [filename1, '_ms', '_', num2str(resolution), '_', type];

% 2. Initialize Triangulation
[V, E, DT, img, full_size_img, mask, full_mask, boundary_nodes] = create_tri_from_image(filename, resolution);
orient_field = calc_CVFT_orient_field(full_size_img, resolution, 1);

% 3. Create Simplicial Graph
disp('Generating simplicial graph...');
tic;
[G, lookup] = create_simplicial_graph_from_tri(V, E, DT, orient_field);
toc;

% 4. Predictor/Corrector
nodes_shape = size(G.Nodes);
graph = horzcat(G.Edges.EndNodes, G.Edges.Weight)';
U = find(G.Nodes.U); startU = U(1); endU = U(end); clear U;

%cd /Users/benkunsberg/Dropbox/CVF'T Matlab'/CVFT/;
fid = fopen('matching.txt','wt'); fclose(fid);
fid = fopen('paths.txt','wt'); fclose(fid);

tic; fast_CVFT_mat(graph, nodes_shape(1), startU, endU, floor(size(G.Nodes)/2)); toc;

txt2matching;
P = paths2matlab('paths.txt');
P = P([1, end:-1:1], :);
P(1,:) = [];

Vkn = sortrows(Vkn);
delete 'paths.txt'; delete 'matching.txt'

%% 5. Plot Seperatrices
%Remove some elements from the matching, then trace separatrices
m = 16; Vkn_m = find_lesser_matching(m, Vkn, P);
boundary_seps = 2;
tic; [saddle_pts, seperatrices, salience_mask, ms_full] = calculate_seperatrices_CVFT_deep(DT, G, Vkn_m, G.Nodes.locs, 0, img, boundary_nodes, size(full_size_img), type); toc; %#ok<*ASGLU>

%% 6. Save Image

imwrite(salience_mask, [saved_filename, '.png']);
imwrite(ms_full, [saved_filename, '_full.png']);

close all
end