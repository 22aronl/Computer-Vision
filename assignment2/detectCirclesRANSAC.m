function [centers] = detectCirclesRANSAC(im, radius)
    %hyperparameters
    ransac_threshold = 1;

    grey = rgb2gray(im);
    edges = edge(grey, "Canny", [0.045, 0.22]);

    [y, x] = find(edges);
    
    center = detectOneCircleRANSAC(y, x, radius, ransac_threshold);
    circle_center = center;
    disp(center)
    distances = sqrt((x - circle_center(1)).^2 + (y - circle_center(2)).^2);
    index = find(abs(distances - radius) <= ransac_threshold);
    %centers = [x, y];
    disp(size(index))
    disp(size(im))
    centers = [x(index), y(index)];
end

function [center] = detectOneCircleRANSAC(y, x, radius, ransac_threshold)
    current_center = [];
    number_inliers = 0;
    p = 0.99;
    max_iteration = Inf;
    number_points = size(x,1);
    iteration = 0;
    while iteration < max_iteration
        sample_points = randperm(length(x), 3);
        x_coords = x(sample_points);
        y_coords = y(sample_points);

        circle_center = fit_circle(x_coords, y_coords, radius);
        distances = sqrt((x - circle_center(1)).^2 + (y - circle_center(2)).^2);
        inliers = find((abs(distances - radius) <= ransac_threshold));

        if(size(inliers, 1) > number_inliers)
            current_center = circle_center;
            number_inliers = size(inliers, 1);

            w = number_inliers / number_points;
            max_iteration = log(1-p)/log(1-w^3);
            disp(max_iteration);
        end
        iteration = iteration + 1;
    end
    center = current_center;
end

%outputs x, y coords, respectively
function [circle_center] = fit_circle(x_coords, y_coords, radius)
    %least squares fit circle
    line_ones = ones(size(x_coords));
    A = [x_coords, y_coords, line_ones];
    b = x_coords.^2 + y_coords.^2;
    sol = lsqr(A, b);
    
    circle_center = [sol(1)/2, sol(2)/2];
end