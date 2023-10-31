function [] = script_controller()
    coords3d = transpose([
        [0 1 1];
        [0 1 2];
        [1 1 0];
        [2 1 0];
        [1 0 1];
        [0 2 1];
    ]);

    coords2d = transpose(1.0e+03 * [
        [1.7788 2.0354];
        [1.6354 1.9745];
        [2.1475 2.0088];
        [2.2872 1.9556];
        [1.9770 1.7413];
        [1.7811 2.2540];
    ]);

    coords2d = transpose(1.0e+03 * [
        [1.9705    1.8705];
        [2.9465    1.4905];
        [2.9465    1.9785];
        [0.9625    2.0105];
        [0.9585    1.5105];
        [1.9745    1.3785;]
        ]);

    coords3d = transpose([
        [0 0 0];
        [0 0 8];
        [0 3 8];
        [8 3 0];
        [8 0 0];
        [6 0 6];
    ]);

    
    K = cameracali(coords2d, coords3d);
    relative_pose(K);
    %generate_points();
end

function [] = relative_pose(K)
    image1 = imread("SourceImage.jpg");
    image2 = imread("TargetImage.jpg");

    grayImage1 = rgb2gray(image1);
    grayImage2 = rgb2gray(image2);

    points1 = detectSURFFeatures(grayImage1);
    points2 = detectSURFFeatures(grayImage2);

    [features1, validPoints1] = extractFeatures(grayImage1, points1);
    [features2, validPoints2] = extractFeatures(grayImage2, points2);
    
    [indexPairs] = matchFeatures(features1, features2, MaxRatio=0.3);
    
    matchedPoints1 = validPoints1(indexPairs(:, 1), :);
    matchedPoints2 = validPoints2(indexPairs(:, 2), :);
    
    relativepose(transpose(matchedPoints1.Location), transpose(matchedPoints2.Location), K);
    %showMatchedFeatures(image1,image2,matchedPoints1,matchedPoints2);

end

function [] = generate_points()
    coords = select_points("Calibration.jpg", 6);
    disp(coords);
end

function [coords] = select_points(calibration_file, num_points)
    I = imread(calibration_file);

    imshow(I);
    [x, y] = ginput(num_points);
    close;
    points = detectSURFFeatures(rgb2gray(I));
    locations = points.Location;
    points = knnsearch(locations, [x y]);
    coords = locations(points, :);
end