%main script for running all the mtehods of this class
function [] = script_controller()

    %these points correspond with Coord2d
    Coord3d = transpose([ 
        [0 3 1];
        [0 3 6];
        [0 1 6];
        [6 1 0];
        [6 3 0];
        [2 4 2];
     ]);
    
    %Coord2d is stored as Coord2d in the mat file Coord2d
    Coord2d_data = load("Coord2d.mat");
    Coord2d = Coord2d_data.Coord2d;

    K = cameracali(Coord2d, Coord3d);
    relative_pose(K);
    %K = select_10_out_of_20(Coord2d, Coord3d);
    %generate_points();
end

%this runs the set up for selecting the points for the method relativepose
function [R, T] = relative_pose(K)
    image1 = imread("SourceImage.jpg");
    image2 = imread("TargetImage.jpg");

    grayImage1 = rgb2gray(image1);
    grayImage2 = rgb2gray(image2);

    points1 = detectSURFFeatures(grayImage1); %detectcts the important points from the the images
    points2 = detectSURFFeatures(grayImage2);
    
    %extracts the important features with SIFT
    [features1, validPoints1] = extractFeatures(grayImage1, points1, Method="SURF");
    [features2, validPoints2] = extractFeatures(grayImage2, points2, Method="SURF");
    
    %matches the features across each of the images
    [indexPairs] = matchFeatures(features1, features2, MaxRatio=0.25, Unique=true);
    
    %grabbing the matching points
    matchedPoints1 = validPoints1(indexPairs(:, 1), :);
    matchedPoints2 = validPoints2(indexPairs(:, 2), :);
    
    %setting them up
    sCoord2D = transpose(matchedPoints1.Location);
    tCoord2D = transpose(matchedPoints2.Location);
    
    %save motions sCoord2D
    %save motiont tCoord2D

    %display
    %showMatchedFeatures(image1,image2,matchedPoints1,matchedPoints2, "montage");
    [R, T] = relativepose(sCoord2D, tCoord2D, K);
end

%gives 10 points given an inputed 20 points
function [best_points] = select_10_out_of_20(Coord2d, Coord3d)

    numIterations = 10000;
    numPoints = size(Coord2d, 2);
    disp(numPoints)
    best_points = [];
    bestTotalError = inf;
    
    for iter = 1:numIterations
        sampleIndices = randperm(numPoints, 10);
        sampled2DPoints = Coord2d(:, sampleIndices);
        sampled3DPoints = Coord3d(:, sampleIndices);

        K = cameracali(sampled2DPoints, sampled3DPoints);
        projected_2d = K * Coord3d;
        errors = sum((projected_2d - [Coord2d; ones(1, numPoints)]).^2);
        totalError = errors;
    
        if(totalError < bestTotalError)
            best_points = sampleIndices;
            bestTotalError = totalError;
        end
    end
end

%grabs our 2d poitns that we want
function [] = generate_points()
    Coord2d = transpose(select_points("Calibration.jpg", 6));
    save Coord2d Coord2d %saves it to Coord2d.mat
end

%selects the coords with user ginput from the calibration file
function [coords] = select_points(calibration_file, num_points)
    I = imread(calibration_file);

    imshow(I);
    [x, y] = ginput(num_points); %collect user data
    close;
    points = detectSURFFeatures(rgb2gray(I)); %grab the cool features with SURF
    locations = points.Location;
    coords = nearest_neighbor(locations, [x y]); %snaps the fatures to the poitns be selected
end

%calculates the nearest points coords are to a set of locations
function points = nearest_neighbor(locations, coords)
    numCoords = size(coords, 1);
    numLocations = size(locations, 1);

    points = zeros(numCoords, size(locations, 2));

    for i = 1:numCoords
        minDistance = Inf;
        nearestIndex = -1; %finds the closest index coords(i) is to all locations

        for j = 1:numLocations
            distance = sqrt(sum((locations(j, :) - coords(i, :)).^2));

            if distance < minDistance
                minDistance = distance;
                nearestIndex = j;
            end
        end

        points(i, :) = locations(nearestIndex, :); %sets points to be that shortest loc (mean sqr distance)
    end
end
