function test_classification = run_strong_classifier_limit(classifiers, alpha_list, alpha_thres, test_data, limit)
    test_classification = zeros(size(test_data, 3), 1);
    test_img_list = zeros(32, 32, size(test_data, 3));
    for i = 1:size(test_data, 1)
        %disp(10);
        test_img_list(:, :, i) = integral_image(test_data(i,:));
        test_classification(i) = run_strong_classifier_limit_one(classifiers, alpha_list, alpha_thres, test_img_list(:, :, i), limit);
        %disp(test_classification(i));
    end
end

function val = run_strong_classifier_limit_one(classifiers, alpha_list, alpha_thres, image, limit)
    val = 0;
    for i = 1:limit
        val = val + alpha_list(i) * evaluate_haar_feature_complete(image, classifiers{i});
    end

    val = val >= alpha_thres;
end