function [] = scriptController
    detectHT();
end

function [] = kMeansCluster()
    image = imread("gumballs.jpg");
    clusterPixels(image, 7);
end

function [] = detectHT()
    
    image = imread("coins.jpg");
    centers = detectCirclesHT(image, 28);

    figure;
    grey = rgb2gray(image);
    imshow(edge(grey, "Canny", [0.045, 0.22]));
    hold on;
    disp(size(centers))
    % Plot the detected circles
    for i = 1:size(centers,1)
        point = centers(i,:);
        x = point(1);
        y = point(2);
        plot(x, y, 'r*'); % You can change the marker style and color
    end
    hold off;
end

function [] = detectRANSAC()
    
    image = imread("coins.jpg");
    centers = detectCirclesRANSAC(image, 28);

    figure;
    grey = rgb2gray(image);
    imshow(edge(grey, "Canny", [0.045, 0.22]));
    hold on;
    disp(size(centers))
    % Plot the detected circles
    for i = 1:size(centers,1)
        point = centers(i,:);
        x = point(1);
        y = point(2);
        plot(x, y, 'r*'); % You can change the marker style and color
    end
    hold off;
end