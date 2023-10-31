function [K] = cameracali(Coord2d, Coord3d)
    p = estimate_projection_matrix(Coord2d, Coord3d);
    if(det(p(:, 1:3)) < 0)
       p = -p;
    
    end

    [K, R, t] = convert_projection(p);
    disp(K);
    disp(R);
    disp(det(R));
    disp(t);
end

function [K, R, t] = convert_projection(p)
    %[K, R] = qr((p(:,1:3)));
    %t = K\p(:,4:4);
    u1 = p(:,1);
    u2 = p(:,2);
    u3 = p(:,3);

    k = zeros(3, 3);
    r = zeros(3, 3);
    k(3, 3) = norm(u3);
    r(:,3) = u3/k(3, 3);
    k(2, 3) = u2'*r(:,3);
    k(2, 2) = norm(u2 - k(2, 3)*r(:,3));
    r(:,2) = (u2 - k(2,3)*r(:,3))/k(2, 2);
    k(1,3) = u1'*r(:,3);
    k(1,2)=u1'*r(:,2);
    k(1,1)=norm(u1-k(1,2)*r(:,2)-k(1,3)*r(:,3));
    r(:,1) = (u1 - k(1,2)*r(:,2) - k(1,3)*r(:,3))/k(1,1);

    K = k;
    R = r;
    t = k\p(:,4);
end

function [M] = test(Points_2D, Points_3D)
    n = size(Points_2D,1);
	u = Points_2D(:,1);
	v = Points_2D(:,2);
	X = Points_3D(:,1);
	Y = Points_3D(:,2);
	Z = Points_3D(:,3);
	A=[];

	for i = 1:n
	    r1=[X(i) Y(i) Z(i) 1 0 0 0 0 -u(i)*X(i) -u(i)*Y(i) -u(i)*Z(i) -u(i)];
	    r2=[0 0 0 0 X(i) Y(i) Z(i) 1 -v(i)*X(i) -v(i)*Y(i) -v(i)*Z(i) -v(i)];
	    A = [A; r1; r2];
	end

	[U,S,V] = svd(A);
	M = V(:,end);
	M = reshape(M,[],3)';
end

function [p] = estimate_projection_matrix(Coord2d, Coord3d)
    
    N = size(Coord2d, 2);
    M = zeros(2 * N, 12);
    
    for i = 1:N
        lowerx_i = Coord2d(:, i);
        upperx_i = Coord3d(:, i);
        M(2 * i, :) = [upperx_i', 1, 0, 0, 0, 0, -lowerx_i(1) * [upperx_i' 1]];
        M(2 * i - 1, :) = [0, 0, 0, 0, upperx_i', 1, -lowerx_i(2) * [upperx_i' 1]];
    end
    [~, ~, V] = svd(M);
    v = V(:,end);
    p = reshape(v, [], 3)';
end

function P = get_camera_matrix(x, X)
    A = getA(x, X);
   [U,S, V] = svd(A);
    P = V(:, size(V,2));
    P = reshape(P, 4, 3)';
end

function A = getA(x, X)

    n = size(x, 2);
    h = 1;
    for k =1:n
        A(h, :) = [X(1, k) X(2, k) X(3, k) 1 ...
            0 0 0 0 ...
            -x(1, k)*X(1, k) -x(1, k)*X(2, k) ...
            -x(1, k)*X(3, k) -x(1, k)];
            A(h + 1, :) = [0 0 0 0 ...
            X(1, k) X(2, k) X(3, k) 1 ...
            -x(2, k)*X(1, k) -x(2, k)*X(2, k) ...
            -x(2, k)*X(3, k) -x(2, k)];
        h = h + 2;
    end
end

function M = calculate_projection_matrix( Points_2D, Points_3D )
    % create the A matrix for SVD
    A = zeros(size(Points_2D, 1) * 2, 12);
    for i = 1:size(A, 1)
        if (mod(i, 2) == 0)
            A(i, :) = [Points_3D(round(i/2), 1) Points_3D(round(i/2), 2) Points_3D(round(i/2), 3)...
            1 0 0 0 0 Points_3D(round(i/2), 1)*-1*Points_2D(round(i/2), 1)...
            Points_3D(round(i/2), 2)*-1*Points_2D(round(i/2), 1)...
            Points_3D(round(i/2), 3)*-1*Points_2D(round(i/2), 1) -1*Points_2D(round(i/2), 1)];
        else
            A(i, :) = [0 0 0 0 Points_3D(round(i/2), 1) Points_3D(round(i/2), 2) Points_3D(round(i/2), 3)...
            1 Points_3D(round(i/2), 1)*-1*Points_2D(round(i/2), 2)...
            Points_3D(round(i/2), 2)*-1*Points_2D(round(i/2), 2)...
            Points_3D(round(i/2), 3)*-1*Points_2D(round(i/2), 2) -1*Points_2D(round(i/2), 2)];
        end
    end
    [U, S, V] = svd(A);
    M = V(:,end);
    M = reshape(M, [], 3)';
end