%A switcher function that calculates orientation fields for an image with
%several different cases.

%1. Using a standard gradient (only for smooth images)

function orient_field = calc_CVFT_orient_field(full_size_img, resolution, type)




if type == 1
    sigma = round(size(full_size_img, 1)/100);
    blurred_img = filter2(fspecial('gaussian', round(3*sigma), sigma), full_size_img);
    [Ix, Iy] = gradient(blurred_img);
    orient_field = cell(2, 1);
    epsilon = 10^(-10);
    %epsilon = 0;
    orient_field{1} = imresize(Ix, [resolution, resolution]) + rand(resolution, resolution)*epsilon;
    orient_field{2} = imresize(Iy, [resolution, resolution]) + rand(resolution, resolution)*epsilon;
    %figure; imshow(orient_field{1}, []); truesize([resolution*40 resolution*40]); title('Ix');
    %figure; imshow(orient_field{2}, []); truesize([resolution*40 resolution*40]); title('Iy');
    %figure; imshow(orient_field{2}.^2 + orient_field{1}.^2, []); truesize([resolution*40 resolution*40]); title('Norm of gradient');
end


end