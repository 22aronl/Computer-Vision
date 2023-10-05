function [centers] = detectCirclesRANSAC(im, radius)
    %hyperparameters
    ransac_threshold = 1;

    grey = rgb2gray(im);
    edges = edge(grey, "Canny", [0.045, 0.22]);

    [y, x] = find(edges);

    center = detectOneCircleRANSAC(y, x, radius, ransac_threshold);
    disp(center)
        disp(size(im))
    circle_center = center;
    distances = sqrt((x - circle_center(1)).^2 + (y - circle_center(2).^2));
    [index]  = find(abs(distances - radius) <= ransac_threshold);
    disp(index)
    %centers = [x, y];
    centers = [x(index), y(index)];
end

function [center] = detectOneCircleRANSAC(y, x, radius, ransac_threshold)
    current_center = [];
    number_inliers = 0;

    for iteration = 1:2000
        sample_points = randperm(length(x), 3);
        x_coords = x(sample_points);
        y_coords = y(sample_points);

        circle_center = fit_circle(x_coords, y_coords);
        distances = sqrt((x - circle_center(1)).^2 + (y - circle_center(2)).^2);
        inliers = find((abs(distances - radius) <= ransac_threshold));

        if(size(inliers, 1) > number_inliers)
            current_center = circle_center;
            number_inliers = size(inliers, 1);
        end
    end
    disp(number_inliers)
    center = current_center;
end

%outputs x, y coords, respectively
function [circle_center] = fit_circle(x_coords, y_coords)
    %least squares fit circle
    A = [x_coords, y_coords];
    b = x_coords.^2 + y_coords.^2;
    sol = lsqr(A, b);
    
    circle_center = [sol(1)/2, sol(2)/2];
end