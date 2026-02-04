
function ellipse = directEllipse(points)

    directCoef = EllipseDirectFit(points);

    A = directCoef(1);
    B = directCoef(2);
    C = directCoef(3);
    D = directCoef(4);
    E = directCoef(5);
    F = directCoef(6);


    % as a matrix
    M = [A B/2 D/2
        B/2 C E/2
        D/2 E/2 F];

    % Eigen decomposition
    [V, L] = eig(M(1:2,1:2));
    lambda = diag(L);

    % center of ellipse
    center = M(1:2,1:2) \ (-M(1:2,3));

    x0 = center(1);
    y0 = center(2);

    % Semi-axis lengths
    detM = det(M);
    a = sqrt(-detM / (lambda(1)*lambda(2)*lambda(1)));
    b = sqrt(-detM / (lambda(1)*lambda(2)*lambda(2)));

    % Rotation angle
    theta = atan2(V(2,1), V(1,1));

    data.x0 = x0;
    data.y0 = y0;
    data.a = a;
    data.b = b;
    data.theta = theta;

    ellipse = data;

end