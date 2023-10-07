function [centers] = detectCirclesRANSAC(im, radius)
    %hyperparameters
    ransac_threshold = 0.70;%1.050;
    max_points_in_circle = 3000;
    min_points_needed = 112;
    max_circles = 25;

    grey = rgb2gray(im);
    edges = edge(grey, "Canny", [0.1, 0.25]);

    [y, x] = find(edges);
    centers = [];
    [center, inliers] = detectOneCircleRANSAC(y, x, radius, max_points_in_circle, ransac_threshold);
    counter = 0;
     while(size(inliers, 1) > min_points_needed)
        centers = [centers; center];
        edges(y(inliers),x(inliers)) = 0;
        [y, x] = find(edges);
        [center, inliers] = detectOneCircleRANSAC(y, x, radius, max_points_in_circle, ransac_threshold);
        counter = counter + 1;
        if(counter > max_circles)
            return;
        end
     end
     disp(counter)
end


function [center, current_inliers] = detectOneCircleRANSAC(y, x, radius, max_points_in_circle, ransac_threshold)
    current_center = [];
    current_inliers = [];
    number_inliers = 0;
    p = 0.99;
    max_iteration = 20000;
    number_points = max_points_in_circle;
    iteration = 0;
    while iteration < max_iteration
        sample_points = randperm(length(x), 3);
        x_coords = x(sample_points);
        y_coords = y(sample_points);

        circle_center = fit_circle(x_coords, y_coords);
        distances = sqrt((x - circle_center(1)).^2 + (y - circle_center(2)).^2);
        inliers = find((abs(distances - radius) <= ransac_threshold));
        if(size(inliers, 1) > number_inliers)
            current_center = circle_center;
            number_inliers = size(inliers, 1);
            
            w = number_inliers / number_points;
            max_iteration = log(1-p)/log(1-w^3);
            current_inliers = inliers;
           
        end
        iteration = iteration + 1;
    end
    center = current_center;
end

%outputs x, y coords, respectively
function [circle_center] = fit_circle(x_coords, y_coords)
    line_ones = ones(size(x_coords));
    A = [x_coords, y_coords, line_ones];
    b = x_coords.^2 + y_coords.^2;
    sol = lsqr(A, b);
    
    circle_center = [sol(1)/2, sol(2)/2];
end