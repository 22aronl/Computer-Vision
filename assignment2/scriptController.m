function [] = scriptController
    detectRANSAC();
end

function [] = kMeansBoundry()
    image = imread("eagle.png");
    lableIm = clusterPixels(image, 3);
    imshow(boundaryPixels(lableIm));
end

function [] = kMeansCluster()
    image = imread("eagle.png");
    imshow(label2rgb(clusterPixels(image, 3)));
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