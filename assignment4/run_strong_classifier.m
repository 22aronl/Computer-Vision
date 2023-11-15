function val = run_strong_classifier(classifiers, alpha_list, image)
    val = 0;
    for i = 1:size(classifiers, 2)
        val = val + alpha_list(i) * evaluate_haar_feature_complete(image, classifiers{i});
    end
end