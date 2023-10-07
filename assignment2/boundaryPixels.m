function [boundaryIm] = boundaryPixels(labelIm)
    
    boundaryIm = edge(labelIm, "Canny");

end