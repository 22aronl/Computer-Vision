%this evaluates the haar featre on the integral array
%the haar feature indicies have been placed so the orientation of the haar
%feature does not matter
function val = evaluate_haar_feature_incomplete(ar, haar_feature)
    ind = haar_feature.indicies;
    switch haar_feature.rectangle
        case 2
            val = ar(ind(1, 1), ind(1, 2)) - 2 * ar(ind(2, 1), ind(2, 2)) + ar(ind(3, 1), ind(3, 2)) ...
                - ar(ind(4, 1), ind(4, 2)) + 2 * ar(ind(5, 1), ind(5, 2)) - ar(ind(6, 1), ind(6, 2));
        case 3
            val = ar(ind(1, 1), ind(1, 2)) - ar(ind(2, 1), ind(2, 2)) - 2 * ar(ind(3, 1), ind(3, 2)) + 2 * ar(ind(4, 1), ind(4, 2)) ...
                + 2 * ar(ind(5, 1), ind(5, 2)) - 2 * ar(ind(6, 1), ind(6, 2)) - ar(ind(7, 1), ind(7, 2)) + ar(ind(8, 1), ind(8, 2));
        case 4
            val = ar(ind(1, 1), ind(1, 2)) - 2 * ar(ind(2, 1), ind(2, 2)) + ar(ind(3, 1), ind(3, 2)) - 2 * ar(ind(4, 1), ind(4, 2)) ...
                + 4 * ar(ind(5, 1), ind(5, 2)) - 2 * ar(ind(6, 1), ind(6, 2)) + ar(ind(7, 1), ind(7, 2)) - 2 * ar(ind(8, 1), ind(8, 2)) ...
                + ar(ind(9, 1), ind(9, 2));
    end
end