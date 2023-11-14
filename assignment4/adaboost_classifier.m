function [test_classification] = adaboost_classifier(train_data, train_label, test_imgs, current_label)
    num_haar_features = 1000;
    num_iterations = 5;
    %haar_threshold = 200;
    
    integral_image_list = zeros(32, 32, size(train_data,1));
    for i = 1:size(train_data,1)
        computed_integral_image = integral_image(train_data(i, :));
        integral_image_list(:, :, i) = computed_integral_image;
    end

    disp(size(integral_image_list));

    haar_list = generate_haar_features(num_haar_features);
    haar_matrix = generate_haar_matrix(haar_list, integral_image_list);
    disp(size(haar_matrix))
    binary_labels = (train_label == current_label);
    alpha_threshold = 0;
    alpha_list = zeros(1, num_iterations);
    classifier = {};
    weights = zeros(size(train_data, 1), 1);

    %set up weights
    valid_label = find(binary_labels == 1);
    invalid_label = find(binary_labels ~= 1);
    weights(valid_label) = 1/size(valid_label, 1);
    weights(invalid_label) = 1/size(invalid_label, 1);
   
    for i = 1:num_iterations
        disp(i)
        weights = weights / sum(weights);
        
        [min_error, error_index, error_haar_threshold, error_parity] = find_optimal_haar(haar_matrix, weights, binary_labels);
        %errors = sum(weights .* abs(haar_matrix - mult_binary_labels));
        %[min_error, error_index] = min(errors);
        classifier{i} = haar_list{error_index};
        classifier{i}.haar_threshold = error_haar_threshold;
        classifier{i}.parity = error_parity;

        if(error_parity == 0)
            prediction = haar_matrix(:, error_index) <= error_haar_threshold;
        else
            prediction = haar_matrix(:, error_index) > error_haar_threshold;
        end

        beta = min_error / (1 - min_error);
        alpha = log(1/beta);
        

        alpha_threshold = alpha_threshold + 0.5 * alpha;
        alpha_list(i) = alpha;
        
        invert_prediction =  ~prediction;
        weights = weights .* (beta .^(invert_prediction));
    end
    
     
    %save("classifiers_for_adaboost", "classifier", "alpha_list")

    test_classification = zeros(size(test_imgs, 3), 1);
    test_img_list = zeros(32, 32, size(test_imgs, 3));
    for i = 1:size(test_imgs, 1)
        %disp(run_strong_classifier(classifier, alpha_list, integral_image(test_imgs(i, :))));
        %disp(run_strong_classifier(classifier, alpha_list, integral_image(test_imgs(i, :)), haar_threshold));
        %test_classification(i) = run_strong_classifier(classifier, alpha_list, integral_image(train_data(i, :)), haar_threshold) >= alpha_threshold;
        test_img_list(:, :, i) = integral_image(test_imgs(i,:));
        test_classification(i) = run_strong_classifier(classifier, alpha_list, test_img_list(:, :, i)) >= alpha_threshold;
        %test_classification(i) = evaluate_haar_feature_complete(test_img_list(:, :, i), classifier{i}, haar_threshold);

    end
    
end

function [min_error, error_index, error_haar_threshold, error_parity] = find_optimal_haar(haar_matrix, weights, binary_labels)
    num_haar_features = size(haar_matrix, 2);
    num_thresholds = size(haar_matrix, 1);
    min_error = 1;
    for i = 1:num_haar_features
        for j = 1:(num_thresholds-1)
            haar_threshold = haar_matrix(j, i) + 1;
            bin_matrix = haar_matrix(:, i) > haar_threshold;
            error = sum(weights .* abs(bin_matrix - binary_labels));
            parity = 1;
            if(error > 0.5)
                error = 1 - error;
                parity = 0;
            end

            if(error < min_error)
                min_error = error;
                error_index = i;
                error_haar_threshold = haar_threshold;
                error_parity = parity;
            end
        end
    end
    disp(min_error);
end

function val = run_strong_classifier(classifiers, alpha_list, image)
    val = 0;
    for i = 1:size(classifiers, 1)
        val = val + alpha_list(i) * evaluate_haar_feature_complete(image, classifiers{i});
    end
end

function haar_matrix = generate_haar_matrix(haar_list, img_list)
    haar_matrix = zeros(size(img_list, 3), size(haar_list, 2));
    for i = 1:size(img_list, 3)
        for j = 1:size(haar_list, 2)
            haar_matrix(i, j) = evaluate_haar_feature_incomplete(img_list(:, :, i), haar_list{j});
        end
    end
end

function val = evaluate_haar_feature_complete(ar, haar_feature)
    if(haar_feature.parity == 0)
        val = evaluate_haar_feature_incomplete(ar, haar_feature) <= haar_feature.haar_threshold;
    else
        val = evaluate_haar_feature_incomplete(ar, haar_feature) > haar_feature.haar_threshold;
    end
end

function val = evaluate_haar_feature_incomplete(ar, haar_feature)
    ind = haar_feature.indicies;
    switch haar_feature.rectangle
        case 2
            val = ar(ind(1, 1), ind(1, 2)) - 2 * ar(ind(2, 1), ind(2, 2)) + ar(ind(3, 1), ind(3, 2)) ...
                - ar(ind(4, 1), ind(4, 2)) + 2 * ar(ind(5, 1), ind(5, 2)) - ar(ind(6, 1), ind(6, 2));
        case 3
            val = ar(ind(1, 1), ind(1, 2)) - ar(ind(2, 1), ind(2, 2)) - 2 * ar(ind(3, 1), ind(3, 2)) + 2 * ar(ind(4, 1), ind(4, 2)) ...
                + 2 * ar(ind(5, 1), ind(5, 2)) - 2 * ar(ind(6, 1), ind(6, 2)) - ar(ind(7, 1), ind(7, 2)) + ar(ind(8, 1), ind(8, 2));
        case 4
            val = ar(ind(1, 1), ind(1, 2)) - 2 * ar(ind(2, 1), ind(2, 2)) + ar(ind(3, 1), ind(3, 2)) - 2 * ar(ind(4, 1), ind(4, 2)) ...
                + 4 * ar(ind(5, 1), ind(5, 2)) - 2 * ar(ind(6, 1), ind(6, 2)) + ar(ind(7, 1), ind(7, 2)) - 2 * ar(ind(8, 1), ind(8, 2)) ...
                + ar(ind(9, 1), ind(9, 2));
    end

    %if(val < 0)
    %    haar_threshold = -haar_threshold;
    %end
    %val = val < haar_threshold;
    %if(haar_feature.neg == -1)
    %    val = ~val;
    %end
    %val = val * haar_feature.neg;
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
    %haar_feature.neg = 1;
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
    grey_array = rgb2gray(uint32(reshape_array));
    cum_array = cumsum(cumsum(grey_array, 2), 1);
end