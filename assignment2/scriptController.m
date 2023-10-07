function [] = scriptController
    kMeansBoundry();
end

function [] = kMeansBoundry()
    image = imread("gumballs.jpg");
    lableIm = clusterPixels(image, 5);
    imshow(boundaryPixels(lableIm));
end

function [] = kMeansCluster()
    image = imread("gumballs.jpg");
    imshow(label2rgb(clusterPixels(image, 5)));
end

function [] = detectHT()
    radius_size = 28;
    image = imread("coins.jpg");
    centers = detectCirclesHT(image, radius_size);
    disp(size(centers))
    

    figure;
    imshow(image);
    hold on;
    disp(size(centers))
    viscircles(centers, ones(size(centers, 1), 1)*radius_size);
    hold off;
end

function [] = detectRANSAC()
    radius_size = 58;
    image = imread("marbles.png");

    centers = detectCirclesRANSAC(image, radius_size);
    figure;
    imshow(image);
    hold on;
    disp(size(centers))
    viscircles(centers, ones(size(centers, 1), 1)*radius_size);
    hold off;
end