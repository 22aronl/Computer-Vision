%gets the integral image given an rgb array (1072)
function cum_array = integral_image(array)
    reshape_array = reshape(array, [32, 32, 3]);
    grey_array = rgb2gray(uint32(reshape_array));
    cum_array = cumsum(cumsum(grey_array, 2), 1);
end