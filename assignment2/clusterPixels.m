function [labelIm] = clusterPixels(Im, k)
    data = reshape(rgb2hsv(Im), size(Im, 1)*size(Im,2), 3);
    centroids = data(randperm(size(data, 1), k), :); %find k poitns for begining guess
    new_centroids = zeros(size(centroids));
    maxIterations = 10000;
    counter = 0;
    for iter = 1:maxIterations
        distances = zeros(size(data, 1), k);
        for i = 1:k
            centroid = centroids(i, :);
            d = sum((data - centroid).^2, 2);
            distances(:, i) = d; %finds the distances to all points relative to our centers
        end
        [~, clusterAssignments] = min(distances, [], 2); %gets the center that is closest to that edge
        
        
        for i = 1:k
            clusterPoints = data(clusterAssignments == i, :);
            if ~isempty(clusterPoints)
                new_centroids(i, :) = mean(clusterPoints); %update our centers with the new mean
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