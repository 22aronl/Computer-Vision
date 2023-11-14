function [] = script_controller
    [train_data, train_labels] = load_data();
    %disp(size(train_data));
    %disp(size(train_labels));
    [test_data, test_labels] = load_test_data();
    %train_labels = [1 2 3 3];
    %train_data = [[0 0 0]; [1 1 1]; [2 2 2]; [1 2 3]];
    %test_data = [1 2 1];
    cat_to_choose = 1;
    predict = adaboost_classifier(train_data, train_labels, test_data, cat_to_choose);
    %run_knn_classifier(train_data, train_labels, test_data, test_labels);
    %predict = [];
    %disp(hi);
    total_success = 0;
    false_negative = 0;
    false_positive = 0;
    disp(size(predict));
    for i = 1:size(predict, 2)
        if(predict(i) == (test_labels(i) == cat_to_choose))
            total_success = total_success + 1;
        end

        if(predict(i) == 1 && test_labels(i) ~= cat_to_choose)
            false_positive = false_positive + 1;
        end

        if(predict(i) == 0 && test_labels(i) == cat_to_choose)
            false_negative = false_negative + 1;
        end
    end

    disp(total_success)
    disp(false_negative);
    disp(false_positive);
    disp(size(predict, 2));
    disp(total_success / size(predict, 2));
end

function [] = run_knn_classifier(train_data, train_labels, test_data, test_labels)
    coeff = pca(double(train_data));
    size_projection = 100;
    projection_matrix = coeff(:,1:size_projection);
    disp(size(projection_matrix));
    disp(size(train_data));
    train_data_pca = double(train_data) * projection_matrix;
    test_data_pca = double(test_data) * projection_matrix;
    disp(size(projection_matrix));
    predict = knn_classifier(train_data_pca, train_labels, test_data_pca, 10);
        
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