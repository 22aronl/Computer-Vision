function ar = compute_horiz_seam(gradient_img)
    img = calculate_min_energy(gradient_img);

    length = size(img, 1);
    width = size(img, 2);
    [~, i] = min(img(:,end));
    ar = zeros(width, 1);
    for col = width:-1:2
        ar(col) = i;
        next = [img(max(i-1, 1), col-1) img(i, col-1) img(min(i+1, length), col-1)];
        [~, i1] = min(next);
        if (i==1 && i1 == 1) || (i==length&&i1 == 3)
            i1 = 2;
        end
        i = i + i1 - 2;  %dp calcuations!
    end
    ar(1) = i;  
end

%calculates the min energy matrix for a horizontal seam
function img = calculate_min_energy(gradient_img)
    rows = size(gradient_img, 1);
    cols = size(gradient_img, 2);

    img = zeros(rows, cols);
    for i = 1:cols
        for j = 1:rows
            if i == 1
                img(j, i) = gradient_img(j, i);
            else
                prev = [img(max(j-1, 1), i-1) img(j, i-1) img(min(j+1, rows), i-1)];
                min_prev = min(prev);
                img(j, i) = gradient_img(j, i)+ min_prev;
            end
        end
    end
end