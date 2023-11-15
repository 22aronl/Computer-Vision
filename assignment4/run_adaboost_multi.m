function [test_classification] = run_adaboost_multi(classifiers, alpha_lists, alpha_thresholds, test_data)
    
    test_classification = zeros(size(test_data, 3), 1);
    test_img_list = zeros(32, 32, size(test_data, 3));
    for i = 1:size(test_data, 1)
        %disp(10);
        test_img_list(:, :, i) = integral_image(test_data(i,:));
        test_classification(i) = run_multi_classifier(classifiers, alpha_lists, alpha_thresholds, test_img_list(:, :, i));
        %disp(test_classification(i));
    end
end

function val = run_multi_classifier(classifiers, alpha_lists, alpha_thresholds, test_img)
    
    percentages = zeros(10, 1);
    for i = 1:10
        percentages(i) = run_strong_classifier(classifiers{i}, alpha_lists{i}, test_img)/alpha_thresholds{i};
    end
    %disp(percentages);
    [~, val] = max(percentages);
    val = val-1;

end
