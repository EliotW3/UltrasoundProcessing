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
lv_deviation = 5;
rv_centroid = [438,146];
rv_deviation = 5;
ao_centroid = [522,271];
ao_deviation = 5;
la_centroid = [472,378];
la_deviation = 5;

% predicted feature ellipse parameters (add when required)

% generated feature variables
lv_found = false;
rv_found = false;
ao_found = false;
la_found = false;


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


% Left ventricle
lv_box = [lv_centroid(1) - lv_deviation, lv_centroid(2) - lv_deviation, lv_centroid(1) + lv_deviation, lv_centroid(2) + lv_deviation];
plot_box(lv_box(1),lv_box(2),lv_box(3),lv_box(4),'g','LineWidth',1);
text(lv_box(3),lv_box(4), ...
    "LV", 'Color','y','FontSize',10,'FontWeight','bold');

% Right ventricle
rv_box = [rv_centroid(1) - rv_deviation, rv_centroid(2) - rv_deviation, rv_centroid(1) + rv_deviation, rv_centroid(2) + rv_deviation];
plot_box(rv_box(1),rv_box(2),rv_box(3),rv_box(4),'g','LineWidth',1);
text(rv_box(3),rv_box(4), ...
    "RV", 'Color','y','FontSize',10,'FontWeight','bold');

% Aorta
ao_box = [ao_centroid(1) - ao_deviation, ao_centroid(2) - ao_deviation, ao_centroid(1) + ao_deviation, ao_centroid(2) + ao_deviation];
plot_box(ao_box(1),ao_box(2),ao_box(3),ao_box(4),'g','LineWidth',1);
text(ao_box(3),ao_box(4), ...
    "AO", 'Color','y','FontSize',10,'FontWeight','bold');


%% Select a black pixel from within the centroid boxes to act as the center

% left atrium
first_la_centroid = selectPredictedCentroid(bw, la_centroid, la_deviation);

if first_la_centroid ~= [0,0]
    la_found = true;
end

% left ventricle
first_lv_centroid = selectPredictedCentroid(bw, lv_centroid, lv_deviation);

if first_lv_centroid ~= [0,0]
    lv_found = true;
end

% right ventricle
first_rv_centroid = selectPredictedCentroid(bw, rv_centroid, rv_deviation);

if first_rv_centroid ~= [0,0]
    rv_found = true;
end

% aorta
first_ao_centroid = selectPredictedCentroid(bw, ao_centroid, ao_deviation);

if first_ao_centroid ~= [0,0]
    ao_found = true;
end


% if any of the features cant be found, their weighting will be set to 0
% which will nullify the final result

%% Key feature ellipses
% perform the first pass of drawing key feature ellipses
% for each feature, starting at the centroid, propogate lines out at n
% degree intervals until reaching a white(1) pixel. These lines will
% provide the set of coordinates that we will build a best fit ellipse from

ao_first_edges = buildFirstEllipse(bw, first_ao_centroid);
lv_first_edges = buildFirstEllipse(bw,first_lv_centroid);
rv_first_edges = buildFirstEllipse(bw, first_rv_centroid);
la_first_edges = buildFirstEllipse(bw,first_la_centroid);


% remove outliers from edges outside a set tolerance
ao_first_edges = cleanEdges(ao_first_edges, first_ao_centroid,40);
lv_first_edges = cleanEdges(lv_first_edges, first_lv_centroid,40);
la_first_edges = cleanEdges(la_first_edges, first_la_centroid,40);
rv_first_edges = cleanEdges(rv_first_edges, first_rv_centroid,40);

%% plotting ellipse edge points (debug)

plot(ao_first_edges(:,1), ao_first_edges(:,2), 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(lv_first_edges(:,1), lv_first_edges(:,2), 'go', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(rv_first_edges(:,1), rv_first_edges(:,2), 'bo', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(la_first_edges(:,1), la_first_edges(:,2), 'yo', 'MarkerSize', 6, 'LineWidth', 1.5);



%% create and plot the best fit ellipse to these points
% aorta
ao_ellipse = bestFitEllipse(ao_first_edges);

% plot ellipse
t = linspace(0,2*pi,100);
x_ellipse = ao_ellipse.x0 + ao_ellipse.a * cos(t) * cos(ao_ellipse.theta) - ao_ellipse.b*sin(t)*sin(ao_ellipse.theta);
y_ellipse = ao_ellipse.y0 + ao_ellipse.a * cos(t) * sin(ao_ellipse.theta) - ao_ellipse.b*sin(t)*cos(ao_ellipse.theta);
plot(x_ellipse,y_ellipse, 'r--', 'LineWidth', 2);

% left ventricle
lv_ellipse = bestFitEllipse(lv_first_edges);
t = linspace(0,2*pi,100);
x_ellipse = lv_ellipse.x0 + lv_ellipse.a * cos(t) * cos(lv_ellipse.theta) - lv_ellipse.b*sin(t)*sin(lv_ellipse.theta);
y_ellipse = lv_ellipse.y0 + lv_ellipse.a * cos(t) * sin(lv_ellipse.theta) - lv_ellipse.b*sin(t)*cos(lv_ellipse.theta);
plot(x_ellipse,y_ellipse, 'g--', 'LineWidth', 2);

% right ventricle
rv_ellipse = bestFitEllipse(rv_first_edges);
t = linspace(0,2*pi,100);
x_ellipse = rv_ellipse.x0 + rv_ellipse.a * cos(t) * cos(rv_ellipse.theta) - rv_ellipse.b*sin(t)*sin(rv_ellipse.theta);
y_ellipse = rv_ellipse.y0 + rv_ellipse.a * cos(t) * sin(rv_ellipse.theta) - rv_ellipse.b*sin(t)*cos(rv_ellipse.theta);
plot(x_ellipse,y_ellipse, 'b--', 'LineWidth', 2);

% left atrium
la_ellipse = bestFitEllipse(la_first_edges);
t = linspace(0,2*pi,100);
x_ellipse = la_ellipse.x0 + la_ellipse.a * cos(t) * cos(la_ellipse.theta) - la_ellipse.b*sin(t)*sin(la_ellipse.theta);
y_ellipse = la_ellipse.y0 + la_ellipse.a * cos(t) * sin(la_ellipse.theta) - la_ellipse.b*sin(t)*cos(la_ellipse.theta);
plot(x_ellipse,y_ellipse, 'y--', 'LineWidth', 2);

%% ellipse clean up
% take the new centroid of the best fit ellipse and perform the same steps

second_ao_centroid = [round(ao_ellipse.x0),round(ao_ellipse.y0)];
second_lv_centroid = [round(lv_ellipse.x0),round(lv_ellipse.y0)];
second_la_centroid = [round(la_ellipse.x0),round(la_ellipse.y0)];
second_rv_centroid = [round(rv_ellipse.x0),round(rv_ellipse.y0)];

ao_second_edges = buildFirstEllipse(bw,second_ao_centroid);
lv_second_edges = buildFirstEllipse(bw,second_lv_centroid);
la_second_edges = buildFirstEllipse(bw,second_la_centroid);
rv_second_edges = buildFirstEllipse(bw,second_rv_centroid);


% clean second edges

ao_second_edges = cleanEdges(ao_second_edges, second_ao_centroid,40);
lv_second_edges = cleanEdges(lv_second_edges, second_lv_centroid,40);
la_second_edges = cleanEdges(la_second_edges, second_la_centroid,40);
rv_second_edges = cleanEdges(rv_second_edges, second_rv_centroid,40);

%% plotting ellipse edge points (debug)

plot(ao_second_edges(:,1), ao_second_edges(:,2), 'cx', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(lv_second_edges(:,1), lv_second_edges(:,2), 'mx', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(rv_second_edges(:,1), rv_second_edges(:,2), 'yx', 'MarkerSize', 6, 'LineWidth', 1.5);
plot(la_second_edges(:,1), la_second_edges(:,2), 'gx', 'MarkerSize', 6, 'LineWidth', 1.5);

%% create and plot second pass ellipse of best fit
ao_ellipse2 = bestFitEllipse(ao_second_edges);
x_ellipse = ao_ellipse2.x0 + ao_ellipse2.a * cos(t) * cos(ao_ellipse2.theta) - ao_ellipse2.b*sin(t)*sin(ao_ellipse2.theta);
y_ellipse = ao_ellipse2.y0 + ao_ellipse2.a * cos(t) * sin(ao_ellipse2.theta) - ao_ellipse2.b*sin(t)*cos(ao_ellipse2.theta);
plot(x_ellipse,y_ellipse, 'c-', 'LineWidth', 2);

lv_ellipse2 = bestFitEllipse(lv_second_edges);
x_ellipse = lv_ellipse2.x0 + lv_ellipse2.a * cos(t) * cos(lv_ellipse2.theta) - lv_ellipse2.b*sin(t)*sin(lv_ellipse2.theta);
y_ellipse = lv_ellipse2.y0 + lv_ellipse2.a * cos(t) * sin(lv_ellipse2.theta) - lv_ellipse2.b*sin(t)*cos(lv_ellipse2.theta);
plot(x_ellipse,y_ellipse, 'm-', 'LineWidth', 2);

rv_ellipse2 = bestFitEllipse(rv_second_edges);
x_ellipse = rv_ellipse2.x0 + rv_ellipse2.a * cos(t) * cos(rv_ellipse2.theta) - rv_ellipse2.b*sin(t)*sin(rv_ellipse2.theta);
y_ellipse = rv_ellipse2.y0 + rv_ellipse2.a * cos(t) * sin(rv_ellipse2.theta) - rv_ellipse2.b*sin(t)*cos(rv_ellipse2.theta);
plot(x_ellipse,y_ellipse, 'y-', 'LineWidth', 2);

la_ellipse2 = bestFitEllipse(la_second_edges);
x_ellipse = la_ellipse2.x0 + la_ellipse2.a * cos(t) * cos(la_ellipse2.theta) - la_ellipse2.b*sin(t)*sin(la_ellipse2.theta);
y_ellipse = la_ellipse2.y0 + la_ellipse2.a * cos(t) * sin(la_ellipse2.theta) - la_ellipse2.b*sin(t)*cos(la_ellipse2.theta);
plot(x_ellipse,y_ellipse, 'g-', 'LineWidth', 2);


