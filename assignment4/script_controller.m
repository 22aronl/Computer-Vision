%this is the main script controller that allows me to read in the data and
%run the respective methods on them
function [] = script_controller
    [train_data, train_labels] = load_data();
    [test_data, test_labels] = load_test_data();

    %run_knn_classifier(train_data, train_labels, test_data, test_labels);
    %run_ada_classifier(train_data, train_labels, test_data, test_labels);
    run_adaboost_classifier_kfold(train_data, train_labels, test_data, test_labels);
    
end

%this runs adaboost with kfolds to determine the optimal number of weak
%classifiers
function [] = run_adaboost_classifier_kfold(train_data, train_labels, test_data, test_labels)
    num_folds = 5;
    cv = cvpartition(size(train_data, 1), 'KFold', num_folds);
    
    
    current_train = 1;
    k_values = 10:10:1000; %test all the values 
    num_haar_features = 1200;

    train_labels = train_labels == current_train; %we only train for one to save on time
    test_labels = test_labels == current_train;

    total_sum = zeros(length(k_values),1);
    for fold = 1:num_folds
        disp(fold);
        t = training(cv, fold);
        train_indices = find(t == 1);
        test_indices = find(t == 0);
        
        data = train_data(train_indices, :);
        data_index = train_labels(train_indices);
        test = train_data(test_indices, :);
        test_index = train_labels(test_indices);
        haar_list = generate_haar_features(num_haar_features);
        [class, alpha_l, alpha_thresh] = adaboost_classifier(data, data_index, current_train, haar_list);
        %run adaboost training on 4 parts training

        for i = 1:length(k_values)
            current_k = k_values(i);

            predict = run_strong_classifier_limit(class, alpha_l, alpha_thresh, test, current_k);
            %only limi t the strong classifier to run current_k times
            %(number of weak classifiers it uses)
            total_success = 0;
            for j = 1:size(predict, 2)
                if(predict(j) == test_index(j))
                    total_success = total_success + 1;
                end
            end
            total_sum(i) = total_sum(i) + total_success; %store the total result
        end

    end
    disp(0);
    [~, best_k] = max(total_sum); %select the iteration with the most correctness
    current_k = k_values(best_k); %get its corresponding k
    haar_list = generate_haar_features(num_haar_features);
    [class, alpha_l, alpha_thresh] = adaboost_classifier(train_data, train_labels, current_train, haar_list);
    predict = run_strong_classifier_limit(class, alpha_l, alpha_thresh, test_data, current_k);
    %we train and run and predict
    cm = confusionchart(uint8(test_labels), uint8(predict));
    total_success = 0;
    for i = 1:size(predict, 2)
        if(predict(i) == test_labels(i))
            total_success = total_success + 1;
        end
    end %OUTPUT

    disp(total_success)
    disp(size(predict, 2));
    disp(total_success / size(predict, 2));
    disp(current_k);
end

%tests the adaboost prediciton by running it against testimages 
function test_classification = run_ada_classifier(classifier, alpha_list, alpha_threshold, test_imgs)
    test_classification = zeros(size(test_imgs, 3), 1);
    test_img_list = zeros(32, 32, size(test_imgs, 3));
    for i = 1:size(test_imgs, 1)
       
        test_img_list(:, :, i) = integral_image(test_imgs(i,:)); %get hte ingegral image
        test_classification(i) = run_strong_classifier(classifier, alpha_list, test_img_list(:, :, i)) >= alpha_threshold;
        %classifcy 1 or 0 if the classifier outputs above alpha_threshold
    end
end

%this tests runs five folds on knn to find the best k to use
function [] = run_five_folds_knn(train_data, train_labels, test_data, test_labels)
    coeff = pca(double(train_data));
    size_projection = 100;
    projection_matrix = coeff(:,1:size_projection);

    train_data = double(train_data) * projection_matrix;
    test_data = double(test_data) * projection_matrix; %pca to reduce the side of the data

    num_folds = 5;
    cv = cvpartition(size(train_data, 1), 'KFold', num_folds);

    k_values = 1:100;
    best_k = 1;
    best_sum = 0;
    for i = 1:length(k_values)
        current_k = k_values(i);
        cur_sum = 0;
        disp(i);
        for fold = 1:num_folds
            t = training(cv, fold);
            train_indices = find(t == 1);
            test_indices = find(t == 0);
            
            data = train_data(train_indices, :);
            data_index = train_labels(train_indices);
            test = train_data(test_indices, :);
            test_index = train_labels(test_indices);
          
            predict = knn_classifier(data, data_index, test, current_k); %we run the classifier on each k and for the folds
            total_success = 0;
            for j = 1:size(predict, 1)
                if(predict(j) == test_index(j))
                    total_success = total_success + 1;
                end
            end

            cur_sum = cur_sum + total_success;
        end

        if(cur_sum > best_sum)
            best_sum = cur_sum; %select the best k to use
            best_k = current_k;
        end
        
    end

    
    predict = knn_classifier(train_data, train_labels, test_data, best_k); %run the output on the test data
    disp(class(predict));
    size(predict);
    cm = confusionchart(test_labels, uint8(predict));
    total_success = 0;
    for i = 1:size(predict, 1)
        if(predict(i) == test_labels(i))
            total_success = total_success + 1;
        end
    end

    disp(total_success)
    disp(size(predict, 1));
    disp(total_success / size(predict, 1));
    disp(best_k);
end

%runs adaboost classifier, multi, on the given dagtaset
function [] = run_adaboost_classifier(train_data, train_labels, test_data, test_labels)
    [classifiers, alpha_lists, alpha_thresholds] = adaboost_classifier_multi(train_data, train_labels);
    save("classifiers_values", "classifiers", "alpha_lists", "alpha_thresholds"); %train and run
    predict = run_adaboost_multi(classifiers, alpha_lists, alpha_thresholds, test_data);
    cm = confusionchart(test_labels, uint8(predict)); %create confusion matrix
    total_success = 0;
    disp(size(predict));
    for i = 1:size(predict, 2)
        if(predict(i) == test_labels(i))
            total_success = total_success + 1;
        end
    end

    disp(total_success);
    disp(size(predict, 2));
    disp(total_success / size(predict, 2));
end

%runs the knn classifier
function [] = run_knn_classifier(train_data, train_labels, test_data, test_labels)
    coeff = pca(double(train_data));
    size_projection = 100;
    projection_matrix = coeff(:,1:size_projection);

    train_data_pca = double(train_data) * projection_matrix;
    test_data_pca = double(test_data) * projection_matrix; %pca reduction to increase speed

    disp(class(test_labels));
    predict = knn_classifier(train_data_pca, train_labels, test_data_pca, 10); %runs the knn classifier
    disp(class(predict));
    size(predict);
    cm = confusionchart(test_labels, uint8(predict)); %confusion matrix
    total_success = 0;
    for i = 1:size(predict, 1)
        if(predict(i) == test_labels(i))
            total_success = total_success + 1;
        end
    end

    disp(total_success)
    disp(size(predict, 1));
    disp(total_success / size(predict, 1));
end

function [train_data, train_labels] = load_data()
    file_paths = {
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_1";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_2";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_3";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_4";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_5"
        };
    %file_paths = {
    %    "/Users/aaronlo/Downloads/cifar-10-batches-mat/data_batch_1";
    %    "/Users/aaronlo/Downloads/cifar-10-batches-mat/data_batch_2";
    %    };
    train_data = [];
    train_labels = [];
    for i = 1:numel(file_paths)
        loaded_data = load(file_paths{i});
        train_data = [train_data; loaded_data.data];
        train_labels = [train_labels; loaded_data.labels]; %loads in the data from the file paths
    end
    
    disp(size(train_data));
    disp(size(train_labels));

end

function [test_data, test_labels] = load_test_data()
    test_set_name = "B:\CS376_Images\assignment4\cifar-10-batches-mat\test_batch";
    %test_set_name = "/Users/aaronlo/Downloads/cifar-10-batches-mat/test_batch";
    S = load(test_set_name);
    test_data = S.data;
    test_labels = S.labels; %loads in the test data!
end