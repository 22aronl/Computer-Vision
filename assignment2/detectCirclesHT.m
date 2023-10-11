function [centers] = detectCirclesHT(im, radius)
    %hyperparameters
    theta_step = 0.0075;
    threshold_percent = 0.70; %34
    bin_size = 1;

    grey = rgb2gray(im);
    edges = edge(grey, "Canny", [0.045, 0.22]); %find sthe edges of the graph
    
    %sets up the accumulator matrix according to the binsize
    accumulator_matrix = zeros(int64(size(im,1)/bin_size), int64(size(im, 2)/bin_size));
    [y, x] = find(edges);
    for index = 1:size(x) %for all edge points
        X = x(index);
        Y = y(index);
        for theta = 0:theta_step:2*pi %loop around in a circle and increment their accumulator matrix
            a = round(X + radius * cos(theta));
            b = round(Y - radius * sin(theta));
            b1 = int64(b/bin_size);
            a1 = int64(a/bin_size);
            if(a1 > 0 && a1 <= int64(size(im, 2)/bin_size) && b1 > 0 && b1 <= int64(size(im,1)/bin_size))
                accumulator_matrix(b1, a1) = accumulator_matrix(b1, a1) + 1;
            end
        end
    end
    greatest = max(accumulator_matrix, [], "all");
    threshold = greatest * threshold_percent;
    %normalized_accumulator_matrix = accumulator_matrix / max(accumulator_matrix(:));
    %colormap('hot');
    %imshow(normalized_accumulator_matrix, []);
    [rows, cols] = find(accumulator_matrix >= threshold); %find all center points
    centers = [cols, rows]*bin_size;

end