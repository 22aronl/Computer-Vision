function [] = scriptController
    image = imread("coins.jpg");
    centers = detectCirclesRANSAC(image, 27);

    figure;
    imshow(image);
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