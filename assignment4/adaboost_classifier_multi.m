function [classifiers, alpha_lists, alpha_thresholds] = adaboost_classifier_multi(train_data, train_label)
    
    classifiers = cell(10, 1);
    alpha_lists = cell(10, 1);
    alpha_thresholds = cell(10, 1);
    num_haar_features = 1500;
    haar_list = generate_haar_features(num_haar_features);

    for i = 0:9
        disp(i);
        [class, alpha_l, alpha_thresh] = adaboost_classifier(train_data, train_label, i, haar_list);
        classifiers{i + 1} = class;
        alpha_lists{i + 1} = alpha_l;
        alpha_thresholds{i + 1} = alpha_thresh;
    end
end