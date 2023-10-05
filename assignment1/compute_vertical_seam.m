function ar = compute_vertical_seam(gradient_img)
    img = calculate_min_energy(gradient_img);

    length = size(img, 1);
    width = size(img, 2);
    [~, i] = min(img(end, :));
    ar = zeros(length, 1);
    for row = length:-1:2
        ar(row) = i;
        next = [img(row-1,max(i-1, 1)) img(row-1, i) img(row-1, min(i+1, width))];
        [~, i1] = min(next);
        if (i==1 && i1 == 1) || (i==width&&i1 == 3)
            i1 = 2;
        end
        i = i + i1 - 2;  %dp calcuations!
    end
    ar(1) = i;
end

%calculates the min energy matrix for a vertical seam
function img = calculate_min_energy(gradient_img)
    rows = size(gradient_img, 1);
    cols = size(gradient_img, 2);

    img = zeros(rows, cols);
    for i = 1:rows
        for j = 1:cols
            if i == 1
                img(i, j) = gradient_img(i, j);
            else
                prev = [img(i-1, max(j-1, 1)) img(i-1, j) img(i-1, min(j+1, cols))];
                min_prev = min(prev);
                img(i, j) = gradient_img(i, j)+ min_prev;
            end
        end
    end
end