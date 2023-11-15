function [test_classification] = run_adaboost_multi2(classifiers, alpha_lists, alpha_thresholds, test_data, classifiers_to_run)
    
    test_classification = zeros(size(test_data, 3), 1);
    test_img_list = zeros(32, 32, size(test_data, 3));
    for i = 1:size(test_data, 1)
        %disp(10);
        test_img_list(:, :, i) = integral_image(test_data(i,:));
        test_classification(i) = run_multi_classifier2(classifiers, alpha_lists, alpha_thresholds, test_img_list(:, :, i), classifiers_to_run);
        %disp(test_classification(i));
    end
end

function val = run_multi_classifier2(classifiers, alpha_lists, alpha_thresholds, test_img, classifiers_to_run)
    
    percentages = zeros(10, 1);
    for i = 1:10
        percentages(i) = run_strong_classifier2(classifiers{i}, alpha_lists{i}, test_img, classifiers_to_run)/alpha_thresholds{i};
    end
    %disp(percentages);
    [~, val] = max(percentages);
    val = val-1;

end

function val = run_strong_classifier2(classifiers, alpha_list, image, classifiers_to_run)
    val = 0;
    for i = 1:classifiers_to_run
        val = val + alpha_list(i) * evaluate_haar_feature_complete(image, classifiers{i});
    end
end
