function [labelIm] = clusterPixels(Im, k)
    data = reshape(rgb2hsv(Im), size(Im, 1)*size(Im,2), 3);
    centroids = data(randperm(size(data, 1), k), :);
    new_centroids = zeros(size(centroids));
    maxIterations = 10000;
    counter = 0;
    for iter = 1:maxIterations
        distances = zeros(size(data, 1), k);
        for i = 1:k
            centroid = centroids(i, :);
            d = sum((data - centroid).^2, 2);
            distances(:, i) = d;
        end
        [~, clusterAssignments] = min(distances, [], 2);
        
        
        for i = 1:k
            clusterPoints = data(clusterAssignments == i, :);
            if ~isempty(clusterPoints)
                new_centroids(i, :) = mean(clusterPoints);
            end
        end
        if(new_centroids == centroids)
            break;
        end
        centroids = new_centroids;
        counter = counter + 1;
    end
    
    % Display the final cluster centers
    disp('Cluster Centers:');
    disp(centroids);
    disp(counter);
    labelIm = reshape(clusterAssignments, size(Im, 1), size(Im, 2));
end

function [labelIm] = clusterPixels2(Im, k)
    %hyperparameters
    max_iterations = 1000;

    feature_space = rgb2hsv(Im);
    row_perm = randperm(size(feature_space, 1), k);
    col_perm = randperm(size(feature_space, 2), k);
    disp(size(feature_space, 2))
    centers = zeros(k, size(feature_space, 3));
    for i = 1:k
        centers(i,:) = feature_space(row_perm(i), col_perm(i), :);
    end

    features1 = feature_space(:,:,1);
    features2 = feature_space(:,:,2);
    features3 = feature_space(:,:,3);
    for iteration = 1:max_iterations
        distances = zeros(size(feature_space, 1), size(feature_space, 2), k);
        for i = 1:k
            center_point = centers(i, :);
            for xId = 1:size(feature_space, 1)
                for yId = 1:size(feature_space, 2)
                    points = squeeze(feature_space(xId, yId, :));
                    distances(xId, yId, i) = norm(center_point - points);
                end
            end
        end

        [~, clusters] = min(distances, [], 3);
        disp(size(clusters));
        disp(size(feature_space));
        new_centers = zeros(k, size(feature_space, 3));
        for i = 1:k
            [rows, cols] = find(clusters==i);
            linear_indices = sub2ind(size(feature_space), rows, cols);
            
            cluster_groupi = zeros(3);
            disp(size(mean(features1(linear_indices))));
            cluster_groupi(1) = mean(features1(linear_indices));
            cluster_groupi(2) = mean(features2(linear_indices));
            cluster_groupi(3) = mean(features3(linear_indices));
            disp(size(cluster_groupi(1)));
            disp((cluster_groupi))
            if ~(isempty(cluster_groupi))
                new_centers(i, :) = cluster_groupi(:, 1);
            else
                new_centers(i, :) = centers(i, :);
            end

            if(isequal(centers, new_centers))
                break;
            end
            centers = new_centers;
           
         end
         centers
    end

end