function [R, T] = relativepose(sCoord2D, tCoord2D, K)
    sCoord3D = translate_to_3D(sCoord2D, K);
    tCoord3D = translate_to_3D(tCoord2D, K);
    E = calculate_essential_matrix(sCoord3D, tCoord3D);
    disp(E)
    [U, S, V] = svd(E);
    disp(S);
end

function [R, t] = extractRelativePoseFromEssential(E)
    % Perform SVD on the essential matrix
    [U, ~, V] = svd(E);
    
    % Ensure proper rotation matrix by correcting determinant if necessary
    if det(U) < 0
        U = -U;
    end
    if det(V) < 0
        V = -V;
    end
    
    % Calculate the possible rotation and translation matrices
    W = [0, -1, 0; 1, 0, 0; 0, 0, 1];
    
    R1 = U * W * V';
    R2 = U * W' * V';
    
    t1 = U(:, 3);
    t2 = -U(:, 3);
    
    % Ensure the translation vectors are in the right direction (towards the camera)
    if t1(3) < 0
        t1 = -t1;
    end
    if t2(3) < 0
        t2 = -t2;
    end
    
    % Return both possible rotation and translation pairs
    R = {R1, R2};
    t = {t1, t2};
end

function coord3D = translate_to_3D(coord2D, K)
    coord2D_homo = [coord2D; ones(1,size(coord2D, 2))];
    %coord3D = coord2D_homo;
    coord3D_homo = K \ coord2D_homo;
    coord3D = coord3D_homo;
end

function E = calculate_essential_matrix(sCoord3D, tCoord3D)
    N = size(sCoord3D, 2);
    A = zeros(N, 9);
    for i = 1:N
        s_coord = sCoord3D(:, i);
        t_coord = tCoord3D(:, i)';
        A(i,:) = reshape(s_coord * t_coord, 1, []);
        %A(i, :) = [x2 * x1, x2 * y1, x2, y2 * x1, y2 * y1, y2, x1, y1, 1];
    end
    


    [U, S, V] = svd(A);
    v = V(:,end);
    E = reshape(v, [], 3)';

    [Ue, Se, Ve] = svd(E);
    Se(1, 1) = 1;
    Se(2, 2) = 1;
    Se(3, 3) = 0;
    E = Ue * Se * Ve';
end