function [labelIm] = clusterPixels(Im, k)
    %hyperparameters
    max_iterations = 10000;

    feature_space = rgb2hsv(Im);

    initial_indices = randperm(size(feature_space, 1),k);
    centers = feature_space(initial_indices, :);

    for iteration = 1:max_iterations
        distances = pdist2(feature_space, centers);
        [~, clusters] = min(distances, [], 2);
        
        new_centers = zeros(k, size(feature_space, 2));
        for i = 1:k
            cluster_groupi = feature_space(clusters == i, :);
            if ~(isempty(cluster_groupi))

            e
          
        end
    end

end