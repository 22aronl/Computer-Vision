%grey scales inputed image and then calcualtes the energy function
function total_grad  = energy_function(input_img)
    [x_grad, y_grad] = imgradientxy(rgb2gray(uint8(input_img)));
    total_grad = abs(y_grad) + abs(x_grad);
end