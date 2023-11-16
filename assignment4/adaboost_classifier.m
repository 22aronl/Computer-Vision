function [classifier, alpha_list, alpha_threshold] = adaboost_classifier(train_data, train_label, current_label, haar_list)
    %num_haar_features = 100;
    num_iterations = 1000;
    %haar_threshold = 200;

    binary_labels = (train_label == current_label);
    correct = find(binary_labels == 1);
    false = find(binary_labels ~= 1);
    false = false(randperm(size(false, 1), size(correct, 1)));
    correct_data = train_data(correct, :, :);
    correct_label = train_label(correct);
    false_data = train_data(false, :, :);
    false_label = train_label(false);
    
    train_data = [correct_data; false_data];
    %disp(size(train_data));
    train_label = [correct_label; false_label];
    

    integral_image_list = zeros(32, 32, size(train_data,1));
    for i = 1:size(train_data,1)
        computed_integral_image = integral_image(train_data(i, :));
        integral_image_list(:, :, i) = computed_integral_image;
    end
    disp(size(integral_image_list));

    haar_matrix = generate_haar_matrix(haar_list, integral_image_list);
    disp(size(haar_matrix));
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
    weights = double(weights);
    for i = 1:num_iterations
        disp(i);
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
        prediction = prediction == binary_labels;

        beta = min_error / (1 - min_error);
        assert(beta > 0, 'min error %i\n', min_error);
        alpha = log(1/beta);
        

        alpha_threshold = alpha_threshold + 0.5 * alpha;
        alpha_list(i) = alpha;
        
        invert_prediction =  ~prediction;
        %weights = weights .* (beta.^(invert_prediction));
        weights = weights .* exp((0.5 * alpha) * invert_prediction);
    end
    
     
    %save("classifiers_for_adaboost", "classifier", "alpha_list")

    %test_classification = zeros(size(test_imgs, 3), 1);
    %test_img_list = zeros(32, 32, size(test_imgs, 3));
    %for i = 1:size(test_imgs, 1)
        %disp(run_strong_classifier(classifier, alpha_list, integral_image(test_imgs(i, :))));
        %disp(run_strong_classifier(classifier, alpha_list, integral_image(test_imgs(i, :)), haar_threshold));
        %test_classification(i) = run_strong_classifier(classifier, alpha_list, integral_image(train_data(i, :)), haar_threshold) >= alpha_threshold;
     %   test_img_list(:, :, i) = integral_image(test_imgs(i,:));
     %   test_classification(i) = run_strong_classifier(classifier, alpha_list, test_img_list(:, :, i)) >= alpha_threshold;
        %test_classification(i) = evaluate_haar_feature_complete(test_img_list(:, :, i), classifier{i}, haar_threshold);

    %end
    
end

function [min_error, error_index, error_haar_threshold, error_parity] = find_optimal_haar(haar_matrix, weights, binary_labels)
    num_haar_features = size(haar_matrix, 2);
    num_thresholds = size(haar_matrix, 1);
    min_error = 1;
    for i = 1:num_haar_features
        %disp(i);
        for j = 1:(num_thresholds-1)
            haar_threshold = haar_matrix(j, i);
            bin_matrix = haar_matrix(:, i) > haar_threshold;
            error = sum(weights .* abs(bin_matrix - binary_labels));
            parity = 1;
            %assert(error <= 1, 'current j: %i i: %i\n', j, i);
            if(error >= 1)
                if(error > 0.5)
                    error = 1 - error;
                    parity = 0;
                end
            end

            if(error < min_error)
                min_error = error;
                error_index = i;
                error_haar_threshold = haar_threshold;
                error_parity = parity;
            end
        end
    end
end

