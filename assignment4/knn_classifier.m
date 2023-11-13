function [predictions] = knn_classifier(train_data, train_label, test_imgs, k)
    predictions = zeros(size(test_imgs, 1), 1);

    for i = 1:size(test_imgs, 1)
        %distances = sqrt(sum((train_data - repmat(test_imgs(i,:), size(train_data, 1), 1)).^2));
        distances = sqrt(sum((train_data - repmat(test_imgs(i, :), size(train_data, 1), 1)).^2, 2));
        [~, indicies] = mink(distances, k);
        k_labels = train_label(indicies);
        predictions(i) = mode(k_labels);
    end
end