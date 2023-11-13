function [] = adaboost_classifier(train_data, train_label, test_imgs)
    num_haar_features = 10;
    integral_image(train_data(1,:))
    haar_list = generate_haar_features(num_haar_features);
    disp(haar_list{1}.indicies);

end

function val = evaluate_haar_feature(ar, haar_feature)
    ind = haar_feature.indicies;
    switch haar_feature.rectangle
        case 2
            val = ar(ind(1)) - 2*ar(ind(2)) + ar(ind(3)) - ar(ind(4)) + 2*ar(ind(5))-ar(ind(6));
        case 3
            val = ar(ind(1))-ar(ind(2))-2*ar(ind(3))+2*ar(ind(4))+2*ar(ind(5))-2*ar(ind(6))-ar(ind(7))+ar(ind(8));
        case 4
            val = ar(ind(1))-2*ar(ind(2))+ar(ind(3))-2*ar(ind(4))+4*ar(ind(5))-2*ar(ind(6))+ar(ind(7))-2*ar(ind(8))+ar(ind(9));
    end
end

function haar_features = generate_haar_features(num_features)
    haar_features = cell(1, num_features);
    for i = 1:num_features
        haar_features{i} = generate_one_haar_feature();
    end
end

function haar_feature = generate_one_haar_feature()
    rectangle = [2 3 4];
    haar_feature.rectangle = rectangle(randi(numel(rectangle)));
    is_horizontal = randi(2);
    
    size_max = 32;

    switch haar_feature.rectangle
        case 2
            %A-2B+C-D+2E-F
            if is_horizontal == 1
                startX = randi(size_max - 2);
                startY = randi(size_max - 1);
                disturbingX = randi(floor((size_max - startX)/2));
                endX = 2*disturbingX;
                endY = randi(size_max - startY);
                haar_feature.indicies = [[startX + endX, startY + endY]; [startX + disturbingX, startY + endY]; ...
                    [startX, startY + endY]; [startX + endX, startY]; [startX + disturbingX, startY]; [startX, startY]];
            else
                startX = randi(size_max - 1);
                startY = randi(size_max - 2);
                disturbingY = randi(floor((size_max - startY)/2));
                endX = randi(size_max - startX);
                endY = 2*disturbingY;
                haar_feature.indicies = [[startX + endX, startY + endY]; [startX + endX, startY + disturbingY]; ...
                    [startX + endX, startY]; [startX, startY + endY]; [startX, startY + disturbingY]; [startX, startY]];
            end
        case 3
            %A-B-2C+2D+2E-2F-G+H
            if is_horizontal == 1
                startX = randi(size_max - 3);
                startY = randi(size_max - 1);
                disX = randi(floor((size_max - startX)/3));
                endY = randi(size_max - startY);

                haar_feature.indicies = [[startX+3*disX, startY+endY]; [startX+3*disX, startY]; [startX+2*disX, startY+endY]; ...
                    [startX+2*disX, startY]; [startX+disX, startY+endY]; [startX+disX, startY]; [startX, startY+endY]; [startX, startY]];
            else
                startX = randi(size_max - 1);
                startY = randi(size_max - 3);
                disY = randi(floor((size_max - startY)/3));
                endX = randi(size_max - startX);
        
                haar_feature.indicies = [[startX+endX, startY+3*disY]; [startX, startY+3*disY]; [startX+endX, startY+2*disY]; ...
                    [startX, startY+2*disY]; [startX+endX, startY+disY]; [startX, startY+disY]; [startX+endX, startY]; [startX, startY]];
            end
        case 4
            %A-2B+C-2D+4E-2F+G-2H+I
            startX = randi(size_max - 2);
            startY = randi(size_max - 2);
            dis = randi(floor((size_max - max(startY, startX))/2));
            haar_feature.indicies = [[startX+2*dis, startY+2*dis]; [startX+2*dis, startY+dis]; [startX+2*dis, startY]; ...
                [startX+dis, startY+2*dis]; [startX+dis, startY+dis]; [startX+dis, startY]; ...
                [startX, startY+2*dis]; [startX, startY+dis]; [startX, startY]];
    end
end

function cum_array = integral_image(array)
    reshape_array = reshape(array, [32, 32, 3]);
    grey_array = rgb2gray(uint8(reshape_array));
    cum_array = cumsum(cumsum(grey_array, 1), 2);
end