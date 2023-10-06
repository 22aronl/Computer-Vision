function [centers] = detectCirclesHT(im, radius)
    %hyperparameters
    theta_step = 0.005;
    threshold_percent = 0.60; %34

    grey = rgb2gray(im);
    edges = edge(grey, "Canny", [0.045, 0.22]);
    accumulator_matrix = zeros(size(im));

    [y, x] = find(edges);
    
    for index = 1:size(x)
        X = x(index);
        Y = y(index);
        for theta = 0:theta_step:2*pi
            a = round(X + radius * cos(theta));
            b = round(Y - radius * sin(theta));
            if(a > 0 && a <= size(im, 2) && b > 0 && b <= size(im, 1))
                accumulator_matrix(b, a) = accumulator_matrix(b, a) + 1;
            end
        end
    end
    greatest = max(accumulator_matrix, [], "all");
    threshold = greatest * threshold_percent;
    normalized_accumulator_matrix = accumulator_matrix / max(accumulator_matrix(:));
    colormap('hot');
    imshow(normalized_accumulator_matrix, []);
    [rows, cols] = find(accumulator_matrix >= threshold);
    centers = [cols, rows];

end