function points = buildFirstEllipse(image, centroid, precision)

    arguments
        image (:,:) logical
        centroid (1,2) double
        precision {mustBeNonempty} = 16
    end
    
    % starting at centroid, propogate n = precision lines at equal
    % intervals around the centroid, and record where they hit a white
    % pixel

    edges = zeros(precision,2);
    true_x = 0.0;
    true_y = 0.0;
    edgeFound = false;

    for n = 1:precision

        theta = 2 * pi / precision * n;
        % get a normalized value for x and y changes 
        norm_x = 1 * cos(theta);
        norm_y = 1 * sin(theta);

        true_x = centroid(1);
        true_y = centroid(2);

        while ~edgeFound

            true_x = true_x + norm_x;
            true_y = true_y + norm_y;

            round_x = round(true_x,0);
            round_y = round(true_y,0);

            if image(round_y,round_x)
                edgeFound = true;
                edges(n,1) = round_x;
                edges(n,2) = round_y;
            end
        end
        edgeFound = false;
    end

    points = edges;
end