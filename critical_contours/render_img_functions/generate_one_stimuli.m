function string = generate_one_stimuli(save_number)

% Create random meshes and generate image and slant
[newShape, vertex_normals, ~] = generate_shape();
V = [1, 1, 1]; L = -V;

ints = max(vertex_normals(:, 1)*L(1) + vertex_normals(:, 2)*L(2) + vertex_normals(:,3)*L(3), 0);
ints = ints/max(ints);
slants = atan2(1, ints); slants = slants/max(slants);
depths = V(1) * newShape.vertices(:, 1) + V(2) * newShape.vertices(:, 2) + V(3) * newShape.vertices(:, 3);


[img, mask] = render_model_w_scalar_field(newShape, ints, V); tmp = imresize(img, [500 500]); img = (tmp - min(tmp(:)))./(max(tmp(:)) - min(tmp(:)));
slant = render_model_w_scalar_field(newShape, slants, V);  slant = imresize(slant, [500 500]); 
depth = render_model_w_scalar_field(newShape, depths, V);  tmp = imresize(depths, [500 500]); depths = (tmp - min(tmp(:)))./(max(tmp(:)) - min(tmp(:)));


%% Collect several different images, same viewpoint
n = 3;
Ls = cell(n, 1); new_imgs = cell(n, 1);
for j = 1:n
    Ls{j} = -V + rand(1, 3)*1.3;
    ints = max(vertex_normals(:, 1)*Ls{j}(1) + vertex_normals(:, 2)*Ls{j}(2) + vertex_normals(:,3)*Ls{j}(3), 0);
    ints = ints/max(ints);
    new_img = render_model_w_scalar_field(newShape, ints, V); tmp = imresize(new_img, [500 500]);
    new_imgs{j} = (tmp - min(tmp(:)))./(max(tmp(:)) - min(tmp(:)));
end

%% save images, slant, etc to folder
% if there isn't an input number, then choose a new number

if exist('save_number','var')
    string = ['shape_', num2str(save_number)];
else
    cd('data');
    d = dir;
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
    num_shapes = 0;
    for i = 1:length(nameFolds)
        a = double(regexp(nameFolds{i}, 'shape'));
        if ~isempty(a)
            num_shapes = num_shapes + a;
        end
    end
    string = ['shape_', num2str(num_shapes  + 1)];
    cd ..
end


cd('data');
mkdir(string);
cd(string);

imwrite(img, [string, '_img.png'])


for j = 1:n
    imwrite(new_imgs{j}, [string, '_img', num2str(j), '.png'])
end
imwrite(slant, [string, '_slant.png'])
imwrite(depth, [string, '_depths.png'])
imwrite(mask, [string, '_mask.png'])
cd ..
cd ..


end

