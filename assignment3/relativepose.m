%findst he reslative poses given the input coords
function [R, T] = relativepose(sCoord2D, tCoord2D, K)

    %translation to 3d
    sCoord3D = translate_to_3D(sCoord2D, K);
    tCoord3D = translate_to_3D(tCoord2D, K);
    
    %calcualtes the essential matrix
    E1 = calculate_essential_matrix(sCoord3D, tCoord3D);
    
    [R1, T1, T2, R2, T3, T4] = calculateRT(E1);

    R_total = {R1, R1, R2, R2};
    T_total = {T1, T2, T3, T4};
    
    R = R1;
    T = T1;

    for i = 1:4
        is_neg = structure_recovery(R_total{i}, T_total{i}, sCoord3D, tCoord3D);
        if ~is_neg
            R = R_total{i};
            T = T_total{i};
        end
    end
    %R
    %T
    %disp(det(R));
end

%checks if this is a vlaidcomivnation of R and T
function is_neg = structure_recovery(R, T, x1, x2)
    num_points = size(x1, 2);
    is_neg = false;
    for i = 1:num_points
        x1_1 = x1(:,i);
        x2_1 = x2(:,i);
        A = [(R * x1_1)'; x2_1'] * [(R * x1_1)'; x2_1']';
        b = [(R * x1_1)'; x2_1'] * T;
        out = A \ b;
        if(out(1, 1) <= 0 || out(2, 1) <= 0)
            is_neg = true;
            return;
        end
    end
    
    
end

%gest the 4 combinations of R and T
function [R1, T1, T2, R2, T3, T4] = calculateRT(E1)
    [U, ~, V] = svd(E1);

    T = U(:,3) / norm(U(:,3));
    R = [-U(:,2), U(:,1), U(:,3)] * transpose(V); %calcualtes the R & T
    if(det(R) < 0)
        R = -R;
    end

    R2 = [U(:,2), -U(:,1), U(:,3)] * transpose(V);
    if(det(R2) < 0)
        R2 = -R2;
    end
    R1 = R;

    T1 = T;
    T2 = -T;
    T3 = T;
    T4 = -T;
end

%translates our 2d coordinates into the 3d space with our calibrated K
function coord3D = translate_to_3D(coord2D, K)
    coord2D_homo = [coord2D; ones(1,size(coord2D, 2))];
    %coord3D = coord2D_homo;
    coord3D_homo = K \ coord2D_homo;
    coord3D = coord3D_homo;
end

function E1 = calculate_essential_matrix(sCoord3D, tCoord3D)
    N = size(sCoord3D, 2);
    A = zeros(N, 9);
    for i = 1:N
        s_coord = sCoord3D(:, i);
        t_coord = tCoord3D(:, i)';
        A(i,:) = reshape(s_coord * t_coord, 1, []);
    end %sets up the matrix for SVD

    [~, ~, V] = svd(A);
    v = V(:,end);
    E1 = reshape(v, [], 3)';
    E1 = E1 / norm(E1(3));

    %v = V(:,1);
    %E2 = -E1;

    [Ue, ~, Ve] = svd(E1);
    Se = zeros(3, 3);
    Se(1, 1) = 1;
    Se(2, 2) = 1;
    E1 = Ue * Se * Ve'; %get the two essetial matrixces

end