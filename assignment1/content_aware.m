function img = content_aware()
    orig_img = imread("ut.jpg");
    figure
    tiledlayout(3,1,'TileSpacing','none');
    nexttile
    imshow(orig_img)

    [img, truth] = removeHorizontal(orig_img, 50);
    %[img, truth] = removeVertical(orig_img, 50);
    
    nexttile
    imshow(img);

    %displays the red lines (of removed seams) over the original image
    for i = 1:size(orig_img, 1)
        for j = 1:size(orig_img, 2)
            if truth(i, j) == 1
                orig_img(i, j, :) = [255 0 0];
            end
        end
    end

    nexttile
    imshow(orig_img)
end