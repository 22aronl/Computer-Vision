%generates the needed number of haar features
function haar_features = generate_haar_features(num_features)
    haar_features = cell(1, num_features);
    for i = 1:num_features
        haar_features{i} = generate_one_haar_feature();
    end
end