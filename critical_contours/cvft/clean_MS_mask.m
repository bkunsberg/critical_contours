%try score based on True slant!!!!, not on Lap

%assuming image is slant
function clean_mask = clean_MS_mask(des_seperatrices, img)

%get a per pixel cost of the laplacian and then sum over all members of
%sigma = 0.5;
%lap = filter2(fspecial('log', round([10*sigma, 10*sigma]), sigma), img);

num_seps = length(des_seperatrices);
sep_score = zeros(num_seps, 2);
single_seps = cell(num_seps, 2);

for i = 1:num_seps
    single_sep = zeros(size(img));
    for j = 1:length(des_seperatrices{i}) %always 2
        for k = 1:length(des_seperatrices{i}{j})
            single_sep(round(des_seperatrices{i}{j}(k, 2)), round(des_seperatrices{i}{j}(k, 1))) = 1;
        end
       single_seps{i, j} = single_sep;
       tmp = img .* single_sep;
       nonzeros = tmp(tmp ~= 0);
       sep_score(i, j) = mean(nonzeros); 
    end
    %figure; imshow(single_sep);

end


% mu = mean(sep_score(:));
% sig = std(sep_score(:));
bad_seps = sep_score < 0.2;


%rebuild salience_mask
salience_mask_small = zeros(size(img));
for i = 1:size(bad_seps, 1)
    for j = 1:size(bad_seps, 2)
        if bad_seps(i, j) ~= 1
            salience_mask_small(logical(single_seps{i, j})) = 1;
        end
    end
end

%figure; imshow(salience_mask_small);
%figure; imshow(salience_mask);
clean_mask = salience_mask_small;



end