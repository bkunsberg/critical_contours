 function [matrix_img, mask] = render_model_w_scalar_field(model, field, view_vector, blurring)

if ~exist('blurring', 'var')
   blurring = 0; 
end

lims = 3;

close all
%image mesh
figure('numbertitle','on','color','w', 'units','normalized','outerposition',[0 0 1 1]);
caxis([min(field(:))-0.2 max(field(:))]); % color overlay the slant
mesh_h=patch(model,'FaceVertexCdata',field,'CDataMapping', 'scaled','facecolor','interp', ...
    'edgecolor','interp','EdgeAlpha',0); %#ok<NASGU>
%set(gcf, 'XLim', [-2 2], 'YLim', [-2, 2], 'ZLim', [-2, 2]);
% xlim([-lims lims]);
% ylim([0.3 2.5]);
% zlim([-lims lims]);
axis equal;
camproj('orthographic')
view(view_vector)
axis off;
camlight();
zoom(1);
lighting none
shading interp;
map = linspace(0, 1, 10000)';
map = [map, map, map];
colormap(map);
%%

%capture image
tmp = getframe(1);
frame_img = tmp;
img = rgb2gray(im2double(tmp.cdata));
%pause(1);
close(1);
mask = ~(img == 1);

%fix mask for oscar
fixed_mask = ones(size(img)); %so biggest ~mask component is the true mask
CC = bwconncomp(~mask);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
fixed_mask(CC.PixelIdxList{idx}) = 0;
mask = fixed_mask;

%%
[I, J] = find(mask);
boundsI = [min(I)-100, max(I) + 100];
boundsJ = [min(J)-100, max(J) + 100];
% Blur, save the images
sigma = 2;
H = fspecial('gaussian', sigma, 3*sigma);
if blurring
    matrix_img = filter2(H, img) .* erodeMask(mask, 5);
else
    matrix_img = img .* erodeMask(mask, 5);
end
matrix_img = matrix_img(boundsI(1):boundsI(2), boundsJ(1):boundsJ(2));
mask = mask(boundsI(1):boundsI(2), boundsJ(1):boundsJ(2));
if 0
    matrix_img(~logical(mask)) = 0;
end
%matrix_img(1, 1) = 1; %for oscar

matrix_img = (matrix_img - min(matrix_img(:)))./(max(matrix_img(:)) - min(matrix_img(:)));


%matrix_img = img; %testing for oscar; remove after

end