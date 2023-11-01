function [K] = cameracali(Coord2d, Coord3d)
    p = estimate_projection_matrix(Coord2d, Coord3d);
    if(det(p(:, 1:3)) < 0)
       p = -p;
    
    end
   
    [K, R, t] = convert_projection(p);
    K = K / K(3, 3);
end

function [K, R, t] = convert_projection(p)
    %[K, R] = qr((p(:,1:3)));
    %t = K\p(:,4:4);
    u1 = p(1,1:3);
    u2 = p(2,1:3);
    u3 = p(3,1:3);

    k = zeros(3, 3);
    r = zeros(3, 3);
    k(3, 3) = norm(u3);
    r(3,:) = u3/k(3, 3);
    k(2, 3) = u2 * r(3,:)';
    k(2, 2) = norm(u2 - k(2, 3)*r(3,:));
    r(2,:) = (u2 - k(2,3)*r(3,:))/k(2, 2);
    k(1,3) = u1*r(3,:)';
    k(1,2)= u1*r(2,:)';
    k(1,1)= norm(u1-k(1,2)*r(2,:)-k(1,3)*r(3,:));
    r(1,:) = (u1 - k(1,2)*r(2,:) - k(1,3)*r(3,:))/k(1,1);

    K = k;
    R = r;
    t = k\p(:,4);
end

function [p] = estimate_projection_matrix(Coord2d, Coord3d)
    
    N = size(Coord2d, 2);
    M = zeros(2 * N, 12);
    
    for i = 1:N
        lowerx_i = Coord2d(:, i);
        upperx_i = Coord3d(:, i);
        M(2 * i -1, :) = [upperx_i', 1, 0, 0, 0, 0, -lowerx_i(1) * [upperx_i' 1]];
        M(2 * i, :) = [0, 0, 0, 0, upperx_i', 1, -lowerx_i(2) * [upperx_i' 1]];
    end
    
    [V, D] = eig(M' * M);
    v = V(:,1);

    %[~, ~, V] = svd(M);
    %v = V(:,end);
    p = reshape(v, [], 3)';
end