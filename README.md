# Ultrasound Processing Module

Matlab module to handle the image recognition portion of an automated cardiac ultrasound acquisition robot.
This is a rudimentary approach using basic computer vision techniques to compare ultrasound scans of a PLAX view to a data set of what we would expect to see in a PLAX view.

Human determination of whether an ultrasound is appropriate follows a set of criteria:
- Does the image contain all the key features of the view?
- Are the key features the correct shape?
- Is there occlusion / a shadow cast by the ribs?
- Is the image centered/framed correctly?
- Is the image sharp enough? (not too blurry)

This module aims to perform a number of steps to cover all of these criteria:
- Identify where we expect the centroid of key features to be
- Build an ellipse of best fit for each of these key features and compare it to the expected values
- Determine image suitability: (criteria)
    - Are all key feature ellipses present in the image? (1,3,4)
    - Are the key feature shapes appropriate? (2,3,4)
    - Is the overall sharpness of the image within acceptable thresholds? (5)


#### Requirements: (as of last update, intended to be reduced as the project progresses)
    - Computer Vision Toolbox
    - Peter Corke's Machine Vision Toolbox
    - Image Processing Toolbox