% Specify the folder where the images are stored
folderPath = 'D:\20240515\cali1\data\temp\undistortedImages\102\';
filePattern = fullfile(folderPath, '*.jpg'); % or '*.png' etc.
imageFiles = dir(filePattern);

% Process each file in the directory
for k = 1:length(imageFiles)
    baseFileName = imageFiles(k).name;
    fullFileName = fullfile(folderPath, baseFileName);
    
    % Load the image
    img = imread(fullFileName);
    
    % Rotate the image by 180 degrees
    rotatedImg = imrotate(img, 180);
    
    % Display the image (optional)
    figure;
    imshow(rotatedImg);
    title(['Rotated Image - ', baseFileName]);
    
    % Save the rotated image
    savePath = fullfile(folderPath, baseFileName);  % Example new name
    imwrite(rotatedImg, savePath);
end
