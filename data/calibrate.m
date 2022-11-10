
% img = "./Calibration_Camera2/Camera No.2_C002H001S0001000004.tif";
img = "./data_Camera1/Camera No.1_C001H001S0001000150.tif";

imshow(img);
[xs, ys] = ginput(1); %where n is th number of calibration points you want to measure
% xs and ys are then vectors of these pixel locations