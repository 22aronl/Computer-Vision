function [R, T, E] = relativepose(sCoord2D, tCoord2D, K)
    sCoord3D = translate_to_3D(sCoord2D, K);
    tCoord3D = translate_to_3D(tCoord2D, K);
    E = calculate_essential_matrix(sCoord3D, tCoord3D);
    camIntrinsic = cameraIntrinsics([K(1, 1) K(2, 2)], [K(1, 3) K(2, 3)], [3024 4032]);
    E2 = estimateEssentialMatrix(transpose(sCoord2D), tCoord2D', camIntrinsic);

    disp(E2);
    disp(E)
    [U, S, V] = svd(E);
    disp(S);

    [U2, S2, V2] = svd(E2);
    disp(S2);

    disp(U);
    disp(U2);

    T = S(1, 1) * U(:,3);
    R = [-U(:,2), U(:,1), U(:,3)] * transpose(V);
    disp(R);
    disp(det(R))
    disp(T);
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
        A(i,:) = reshape((s_coord * t_coord), 1, []);
        %A(i, :) = [x2 * x1, x2 * y1, x2, y2 * x1, y2 * y1, y2, x1, y1, 1];
    end

    [~, ~, V] = svd(A);
    v = V(:,end);
    E = reshape(v, [], 3);
end