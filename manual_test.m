%% manual testing script for PLAX view id

%{

    1. threshold and binarise image to show approximate shapes for key
    features of view

    2. using predicted centroids, build an ellipse of best fit for each
    feature

    3. repeat using the best fit centroid, use both ellipses to create a
    predicted feature ellipse

    4. Compare shape of the PFE to expected shape

    5. Measure image gradient/sharpness

    Results :

        - Compare the position of the PFEs, do they imply that all key
        features are present in the image?
    
        - Compare the size/shape of all PFEs, do they imply that key
        features are correctly represented?

        - Is the image sharpness/gradient distribution appropriate for use?

    For an initial attempt we will identify the Left Ventricle, Right
    Ventricle, Aorta, and Left Atrium

%}

%% temporary master data set (to be replaced with measured data from "good" images

% coordinates for framing the triangle mask
master_frame_l = [53,424];
master_frame_r = [679,424];
master_frame_t = [411,5];

% Predicted feature centroids and deviations
lv_centroid = [357,251];
lv_deviation = 10;
rv_centroid = [438,146];
rv_deviation = 10;
ao_centroid = [522,271];
ao_deviation = 10;
la_centroid = [472,378];
la_deviation = 10;

% predicted feature ellipse parameters (add when required)



%% load image 
img = imread('plax_1.jpg');
figure;
idisp(img);

% convert image to greyscale format
if ndims(img) == 3
    img_grey = rgb2gray(img);
else
    img_grey = img;
end

%% scale intensities
% noise reduction
g = kgauss(5,2);
img_smooth = iconvolve(img_grey,2*g);


% contrast enhancement
h = [0 -1 0; -1 5 -1; 0 -1 0];
img_enhanced = iconvolve(img_smooth, h);

% rescale
img_enhanced = double(img_enhanced);
img_enhanced = img_enhanced - min(img_enhanced(:));
img_enhanced = img_enhanced / max(img_enhanced(:));

figure;
idisp(img_enhanced);

%% Threshold

bw = img_enhanced > 0.14;
bw = double(bw);

figure;
idisp(bw);

%% sort image by adding triangle frame to act as edges
top = master_frame_t;
left = master_frame_l;
right = master_frame_r;

% add lines
bw = insertShape(bw, 'Line', [top(1), top(2), left(1), left(2)], 'Color', 'white', 'Linewidth', 5);
bw = insertShape(bw, 'Line', [top(1), top(2), right(1), right(2)], 'Color', 'white', 'Linewidth', 5);

% Create triangle mask
triangle_mask = poly2mask([top(1),left(1), right(1)], [top(2),left(2),right(2)], size(bw,1), size(bw,2));
bw(~triangle_mask) = 1; 

figure;
idisp(bw);

%% convert to logical b/w
bw = logical(rgb2gray(bw));
figure;
idisp(bw);
hold on;

%% find and choose predicted feature centroids (and plot for debug)

% Left Atrium
la_box = [la_centroid(1) - la_deviation, la_centroid(2) - la_deviation, la_centroid(1) + la_deviation, la_centroid(2) + la_deviation];
plot_box(la_box(1),la_box(2),la_box(3),la_box(4),'g','LineWidth',1);
text(la_box(3),la_box(4), ...
    "LA", 'Color','y','FontSize',10,'FontWeight','bold');




hold off;