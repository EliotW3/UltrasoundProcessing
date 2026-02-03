% Takes the black and white logical image, the predicted centroid
% coordiantes and the deviation value as inputs and attempts to find a
% valid pixel (black/0) inside that range

% Returns the first instance of a valid coordinate, or [0,0] if failed

function centroid = selectPredictedCentroid(image, predicted_centroid, deviation)
    
    found_centroid = false;
    found_u = 0;
    found_v = 0;

    for u = predicted_centroid(1)-deviation:1:predicted_centroid(1)+deviation

        for v = predicted_centroid(2)-deviation:1:predicted_centroid(2) + deviation
       
            if ~image(v,u) && ~found_centroid
                % black pixel therefore valid center
                found_centroid = true;
                found_u = u;
                found_v = v;
                
            end

        end
    end
    
    centroid = [found_u,found_v];

end