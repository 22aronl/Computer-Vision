%findst he reslative poses given the input coords
function [R, T] = relativepose(sCoord2D, tCoord2D, K)
    %translation to 3d
    sCoord3D = translate_to_3D(sCoord2D, K);
    tCoord3D = translate_to_3D(tCoord2D, K);
    
    %calcualtes the essential matrix
    [E1, E2] = calculate_essential_matrix(sCoord3D, tCoord3D);
    [U, S, V] = svd(E1);

    T = S(1, 1) * U(:,3);
    R = [-U(:,2), U(:,1), U(:,3)] * transpose(V); %calcualtes the R & T

    [U1, S1, V1] = svd(E2);
    T1 = S1(1, 1) * U1(:,3);
    R1 = [-U1(:,2), U1(:,1), U1(:,3)] * transpose(V1); %calcualtes the R & T

    if(det(R) == -1)
        R = R1;
        T = T1;
    end
    %disp(R);
    %disp(T);
    %disp(K);
end

%translates our 2d coordinates into the 3d space with our calibrated K
function coord3D = translate_to_3D(coord2D, K)
    coord2D_homo = [coord2D; ones(1,size(coord2D, 2))];
    %coord3D = coord2D_homo;
    coord3D_homo = K \ coord2D_homo;
    coord3D = coord3D_homo;
end

function [E1, E2] = calculate_essential_matrix(sCoord3D, tCoord3D)
    N = size(sCoord3D, 2);
    A = zeros(N, 9);
    for i = 1:N
        s_coord = sCoord3D(:, i);
        t_coord = tCoord3D(:, i)';
        A(i,:) = reshape(s_coord * t_coord, 1, []);
    end %sets up the matrix for SVD

    [~, ~, V] = svd(A);
    v = V(:,end);
    E1 = reshape(v, [], 3);
    E2 = -E1;

    [Ue, ~, Ve] = svd(E1);
    Se = zeros(3, 3);
    Se(1, 1) = 1;
    Se(2, 2) = 1;
    E1 = Ue * Se * Ve'; %get the two essetial matrixces

    [Ue2, ~, Ve2] = svd(E2);
    E2 = Ue2 * Se * Ve2';

end