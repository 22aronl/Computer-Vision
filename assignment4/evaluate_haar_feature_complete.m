%evalutes the haar feature with the threshold and parity
function val = evaluate_haar_feature_complete(ar, haar_feature)
    if(haar_feature.parity == 0)
        val = evaluate_haar_feature_incomplete(ar, haar_feature) <= haar_feature.haar_threshold;
    else
        val = evaluate_haar_feature_incomplete(ar, haar_feature) > haar_feature.haar_threshold;
    end
end