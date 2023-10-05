function [img, truth] = removeVertical(im, numPixels)
    
    truth = zeros(size(im));
    img = im;
    disp(size(img))
    for i = 1:numPixels
        total_dir = energy_function(img);
        ar = compute_vertical_seam(total_dir);
        length = size(total_dir, 1);
        width = size(total_dir, 2);
        img = removeVerticalSeam(img, ar, length, width);
        disp(size(img))

        length = size(total_dir, 1);
        for row = 1:length
            counter = 1;
            index = 0;
            while counter < ar(row)
                if truth(row, counter+index) == 0
                    counter = counter + 1;
                else
                    index = index + 1;
                end

            end
            while(truth(row, index+counter) == 1) %a bit of convoluted code to determine
                counter = counter + 1;
            end
            truth(row, counter+index, :) = 1; %where the current removed pixel corresponds to the original image
        end
    end
    img = uint8(img);
end

function img = removeVerticalSeam(im, ar, length, width)
    img = zeros(length, width-1, 3);
    for row = 1:length
        if(ar(row) == 1)
            img(row,:,:) = [im(row, ar(row)+1:end, :)];
        else
            img(row,:,:) = [im(row, 1:ar(row)-1, :) im(row, ar(row)+1:end, :)];
        end
    end
end