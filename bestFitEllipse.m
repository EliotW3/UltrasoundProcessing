function ellipse = bestFitEllipse(points, method)
    arguments
        points (:,2) double
        method string {mustBeNonempty} = "least"
    end

    if method == "least"
        ellipse = leastSquareEllipse(points);
    elseif method == "direct"
        ellipse = directEllipse(points);
    end
end

% https://ieeexplore.ieee.org/document/765658/authors#authors - direct
% least square fitting of ellipse

%https://uk.mathworks.com/matlabcentral/fileexchange/22684-ellipse-fit-direct-method
%code for direct method

% https://mathworld.wolfram.com/Ellipse.html equations for direct method
