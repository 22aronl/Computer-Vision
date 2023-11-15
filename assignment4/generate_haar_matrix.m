function haar_matrix = generate_haar_matrix(haar_list, img_list)
    haar_matrix = zeros(size(img_list, 3), size(haar_list, 2));
    for i = 1:size(img_list, 3)
        for j = 1:size(haar_list, 2)
            haar_matrix(i, j) = evaluate_haar_feature_incomplete(img_list(:, :, i), haar_list{j});
        end
    end
end