function [] = script_controller
    [train_data, train_labels] = load_data();
    [test_data, test_labels] = load_test_data();

    %run_knn_classifier(train_data, train_labels, test_data, test_labels);
    %disp(hi);
    run_adaboost_classifier(train_data, train_labels, test_data, test_labels);
    
end

function [] = run_five_folds_knn(train_data, train_labels, test_data, test_labels)
    coeff = pca(double(train_data));
    size_projection = 100;
    projection_matrix = coeff(:,1:size_projection);

    train_data = double(train_data) * projection_matrix;
    test_data = double(test_data) * projection_matrix;

    num_folds = 5;
    cv = cvpartition(size(train_data, 1), 'KFold', num_folds);

    k_values = 1:2:20;
    best_k = 1;
    best_sum = 0;
    for i = 1:length(k_values)
        current_k = k_values(i);
        cur_sum = 0;
        for fold = 1:num_folds
            
            train_indices = training(cv, fold);
            test_indices = test(cv, fold);
            
            data = train_data(train_indices);
            data_index = train_labels(train_indices);
            test = train_data(test_indices);
            test_index = train_labels(test_indices);
          
            predict = knn_classifier(data, data_index, test, current_k);
            total_success = 0;
            for j = 1:size(predict, 1)
                if(predict(j) == test_index(j))
                    total_success = total_success + 1;
                end
            end

            cur_sum = cur_sum + total_success;
        end

        if(cur_sum > best_sum)
            best_sum = cur_sum;
            best_k = current_k;
        end
        
    end

    
    predict = knn_classifier(train_data, train_labels, test_data, best_k);
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

function [] = run_adaboost_classifier(train_data, train_labels, test_data, test_labels)
    [classifiers, alpha_lists, alpha_thresholds] = adaboost_classifier_multi(train_data, train_labels);
    save("classifiers_values", "classifiers", "alpha_lists", "alpha_thresholds");
    predict = run_adaboost_multi(classifiers, alpha_lists, alpha_thresholds, test_data);
    cm = confusionchart(test_labels, uint8(predict));
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

function [] = run_knn_classifier(train_data, train_labels, test_data, test_labels)
    coeff = pca(double(train_data));
    size_projection = 100;
    projection_matrix = coeff(:,1:size_projection);

    train_data_pca = double(train_data) * projection_matrix;
    test_data_pca = double(test_data) * projection_matrix;

    disp(class(test_labels));
    predict = knn_classifier(train_data_pca, train_labels, test_data_pca, 10);
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
end

function [train_data, train_labels] = load_data()
    file_paths = {
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_1";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_2";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_3";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_4";
        "B:\CS376_Images\assignment4\cifar-10-batches-mat\data_batch_5"
        };
    file_paths = {
        "/Users/aaronlo/Downloads/cifar-10-batches-mat/data_batch_1";
        "/Users/aaronlo/Downloads/cifar-10-batches-mat/data_batch_2";
        };
    train_data = [];
    train_labels = [];
    for i = 1:numel(file_paths)
        loaded_data = load(file_paths{i});
        train_data = [train_data; loaded_data.data];
        train_labels = [train_labels; loaded_data.labels];
    end
    
    disp(size(train_data));
    disp(size(train_labels));

end

function [test_data, test_labels] = load_test_data()
    %test_set_name = "B:\CS376_Images\assignment4\cifar-10-batches-mat\test_batch";
    test_set_name = "/Users/aaronlo/Downloads/cifar-10-batches-mat/test_batch";
    S = load(test_set_name);
    test_data = S.data;
    test_labels = S.labels;
end