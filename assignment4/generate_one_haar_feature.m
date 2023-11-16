%generates one random haar feature 
function haar_feature = generate_one_haar_feature()
    rectangle = [2 3 4];
    haar_feature.rectangle = rectangle(randi(numel(rectangle))); %how mnay rectangesl does it have
    is_horizontal = randi(2); %if it is horizontal
    
    size_max = 32;
    
    %this enourmous switch case, it simple it just selecting the points
    %that the haar feature will use
    switch haar_feature.rectangle
        case 2
            %A-2B+C-D+2E-F
            if is_horizontal == 1
                startX = randi(size_max - 2);
                startY = randi(size_max - 1);
                disturbingX = randi(floor((size_max - startX)/2));
                endX = 2*disturbingX;
                endY = randi(size_max - startY);
                haar_feature.indicies = [[startX + endX, startY + endY]; [startX + disturbingX, startY + endY]; ...
                    [startX, startY + endY]; [startX + endX, startY]; [startX + disturbingX, startY]; [startX, startY]];
            else
                startX = randi(size_max - 1);
                startY = randi(size_max - 2);
                disturbingY = randi(floor((size_max - startY)/2));
                endX = randi(size_max - startX);
                endY = 2*disturbingY;
                haar_feature.indicies = [[startX + endX, startY + endY]; [startX + endX, startY + disturbingY]; ...
                    [startX + endX, startY]; [startX, startY + endY]; [startX, startY + disturbingY]; [startX, startY]];
            end
        case 3
            %A-B-2C+2D+2E-2F-G+H
            if is_horizontal == 1
                startX = randi(size_max - 3);
                startY = randi(size_max - 1);
                disX = randi(floor((size_max - startX)/3));
                endY = randi(size_max - startY);

                haar_feature.indicies = [[startX+3*disX, startY+endY]; [startX+3*disX, startY]; [startX+2*disX, startY+endY]; ...
                    [startX+2*disX, startY]; [startX+disX, startY+endY]; [startX+disX, startY]; [startX, startY+endY]; [startX, startY]];
            else
                startX = randi(size_max - 1);
                startY = randi(size_max - 3);
                disY = randi(floor((size_max - startY)/3));
                endX = randi(size_max - startX);
        
                haar_feature.indicies = [[startX+endX, startY+3*disY]; [startX, startY+3*disY]; [startX+endX, startY+2*disY]; ...
                    [startX, startY+2*disY]; [startX+endX, startY+disY]; [startX, startY+disY]; [startX+endX, startY]; [startX, startY]];
            end
        case 4
            %A-2B+C-2D+4E-2F+G-2H+I
            startX = randi(size_max - 2);
            startY = randi(size_max - 2);
            dis = randi(floor((size_max - max(startY, startX))/2));
            haar_feature.indicies = [[startX+2*dis, startY+2*dis]; [startX+2*dis, startY+dis]; [startX+2*dis, startY]; ...
                [startX+dis, startY+2*dis]; [startX+dis, startY+dis]; [startX+dis, startY]; ...
                [startX, startY+2*dis]; [startX, startY+dis]; [startX, startY]];
    end
end