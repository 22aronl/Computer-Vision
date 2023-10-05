function [img, truth] = removeHorizontal(im, numPixels)
    
    truth = zeros(size(im));
    img = im;
    disp(size(img))
    for i = 1:numPixels
        total_dir = energy_function(img);
        ar = compute_horiz_seam(total_dir);
        length = size(total_dir, 1);
        width = size(total_dir, 2);
        img = removeHorizontalSeam(img, ar, length, width);
        disp(size(img))

        width = size(total_dir, 2);
        for col = 1:width
            counter = 1;
            index = 0;

            while counter < ar(col)
                if truth(counter+index, col) == 0
                    counter = counter + 1;
                else
                    index = index + 1;
                end

            end
            while(truth(index+counter, col) == 1) %a bit of convoluted code to determine
                counter = counter + 1;
            end
            truth(counter+index, col, :) = 1; %where the current removed pixel corresponds to the original image
        end
    end
    img = uint8(img);
end

function img = removeHorizontalSeam(im, ar, length, width)
    img = zeros(length -1, width, 3);
    for col = 1:width
        if(ar(col) == 1)
            img(:,col,:) = [im(ar(col)+1:end, col, :)];
        else
            img(:,col,:) = [im(1:ar(col)-1, col, :); im(ar(col)+1:end, col, :)];
        end
    end
end