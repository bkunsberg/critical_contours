function [ V, E, DT, img, full_size_img, mask, full_mask, boundy] = create_tri_from_image(filename, resolution, mask)
%Create a 2D triangulation (masked) of an object (assuming the background
%has scalar value 0)
%%
%sample file: filename = 'blob_texture.png'
%res = 300;
%close all;
tmp_img = imread(filename);
if length(size(tmp_img)) == 3
    img = rgb2gray(tmp_img);
else
    img = tmp_img;
end

full_size_img = double(img)/256;
full_mask = bwmorph(full_size_img ~= 0, 'majority', 5);
img = double(imresize(img, [resolution, resolution]))/256;
%figure; imshow(img);

if ~exist('mask', 'var')
    mask = bwmorph(img > .01, 'majority', 5);
    %figure; imshow(mask);
end

[X, Y] = meshgrid(1:1:resolution, 1:1:resolution);
V = [X(mask), Y(mask)];
%calculate boundary nodes (as rows of DT.Points) for later
[tmp, L] = bwboundaries(mask);
boundy = tmp{1};
DT = delaunayTriangulation(V(:, 1), V(:, 2)); %row (Y), column(X)
E = edges(DT); %based on row numbers of V

%check mask
if 0
    s = zeros(size(img));
    s(sub2ind(size(img), b(:, 1), b(:, 2))) = 1;
    figure; imshow(s);
end
%%


%% Need to clean the DT triangles
if 1
    %find the area of the triangles
    %if the area is significantly over the mean, remove that triangle
    dt_tris = DT.ConnectivityList;
    dt_locs = DT.Points;
    tri_max_lengths = zeros(length(DT.ConnectivityList), 1);
    for i = 1:length(DT.ConnectivityList)
        a = dt_locs(dt_tris(i, 1), :);
        b = dt_locs(dt_tris(i, 2), :);
        c = dt_locs(dt_tris(i, 3), :);
        tri_max_lengths(i) =  max([abs(a - b), abs(b - c), abs(c - a)]);
        %abs(0.5*det([a(1), a(2), 1; b(1), b(2), 1; c(1), c(2), 1]));
    end
    
    thresh_area = 3*mean(tri_max_lengths);
    DT = triangulation(dt_tris(tri_max_lengths < thresh_area, :), dt_locs(:, 1), dt_locs(:, 2));
    E = edges(DT);
end
%%

boundary_nodes = ismember(DT.Points, boundy, 'rows'); %logical vector indexing into rows of DT.Points
%check
if 0
    figure; triplot(DT)
    hold on; scatter(boundy(:, 2), boundy(:, 1), 'r');
    %H = plot(G, 'XData',xdata, 'YData', ydata, 'EdgeColor', 'none', 'MarkerSize', 0.5);
end
%figure; imshow(img, []); truesize([resolution*10 resolution*10]);
end

