function cleaned_edges = cleanEdges(points, centroid,threshold)

arguments
    points (:,2) double
    centroid (1,2) double
    threshold {mustBeNonempty} = 40
end

    % find distance to centroid
    % trimmean for middle 80%
    % remove any values outside trimmean + threshold%

    distances = [sqrt((points(:,1) - centroid(1,1)).^2 + (points(:,2) - centroid(1,2)).^2)];
    % average for middle 80%
    trim_d_mean = trimmean(distances,20);

    % remove any value greater than threshold % of the trimmed mean
    cleaned_edges = points(distances <= trim_d_mean * (1 + threshold / 100), :);
    % also remove any value less than threshold % of the trimmed mean
    cleaned_edges = cleaned_edges(distances(distances <= trim_d_mean * (1 + threshold / 100)) >= trim_d_mean * (1 - threshold / 100), :);


end