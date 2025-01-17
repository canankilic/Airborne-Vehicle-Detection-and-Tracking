% Airborne Vehicle Tracking Without Frame Loss

% Initialize Video Reader
videoFile = 'resized_video3.mp4';
if ~isfile(videoFile)
    error('Video file not found. Please check the file path.');
end
videoReader = VideoReader(videoFile);

% Initialize Video Writer
outputVideoFile = 'tracked_airborne_vehicle_no_frame_loss.avi';
videoWriter = VideoWriter(outputVideoFile, 'Motion JPEG AVI');
videoWriter.FrameRate = videoReader.FrameRate; % Match the original frame rate
open(videoWriter);

% Kalman Filter for Tracking
kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
    [0, 0], [1, 1], [1, 1], 0.1); % Initial location and noise parameters
isInitialized = false;

% Frame-by-Frame Processing
while hasFrame(videoReader)
    % Read Frame
    frame = readFrame(videoReader);
    
    % Convert to Grayscale
    grayFrame = rgb2gray(frame);
    
    % Dynamic Thresholding
    dynamicThreshold = mean(grayFrame(:)) - 40; % Adjust threshold relative to brightness
    binaryMask = grayFrame < dynamicThreshold;
    
    % Remove Small Noise using Morphological Operations
    cleanedMask = bwareaopen(binaryMask, 30); % Reduced minimum area
    cleanedMask = imclose(cleanedMask, strel('disk', 2)); % Smaller structuring element
    cleanedMask = imfill(cleanedMask, 'holes');
    
    % Identify Regions and Filter by Position
    stats = regionprops(cleanedMask, 'Area', 'BoundingBox', 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    validRegions = [];
    for i = 1:length(stats)
        % Extract properties
        region = stats(i);
        centroid = region.Centroid;
        bbox = region.BoundingBox;
        aspectRatio = region.MajorAxisLength / max(region.MinorAxisLength, 1);
        
        % Dynamic Relaxation for Final Frames
        minAspectRatio = 1.2;
        maxAspectRatio = 6;
        minArea = 20; % Reduced to allow smaller regions
        
        % Check if region is in the upper half and matches airplane shape
        if centroid(2) < videoReader.Height * 0.8 && ... % Allow slightly lower positions
           aspectRatio > minAspectRatio && aspectRatio < maxAspectRatio && ...
           region.Area > minArea
            validRegions = [validRegions, i]; %#ok<AGROW>
        end
    end
    
    if ~isempty(validRegions)
        % Get the largest valid region
        [~, largestIndex] = max([stats(validRegions).Area]);
        largestRegion = stats(validRegions(largestIndex));
        
        % Get Bounding Box and Centroid of the Airplane
        bbox = largestRegion.BoundingBox; % [x, y, width, height]
        centroid = largestRegion.Centroid; % [x, y]
        
        % Use Kalman Filter for Tracking
        if isInitialized
            predict(kalmanFilter);
            trackedLocation = correct(kalmanFilter, centroid);
        else
            trackedLocation = centroid;
            isInitialized = true;
        end
        
        % Annotate the Original Frame
        annotatedFrame = insertShape(frame, 'Rectangle', bbox, ...
            'Color', 'red', 'LineWidth', 2); % Draw bounding box
        annotatedFrame = insertMarker(annotatedFrame, trackedLocation, ...
            'Color', 'red', 'Size', 10); % Mark centroid
    else
        % If no region is detected, predict using Kalman Filter
        if isInitialized
            trackedLocation = predict(kalmanFilter);
            annotatedFrame = insertMarker(frame, trackedLocation, ...
                'Color', 'yellow', 'Size', 10); % Mark predicted position
        else
            % If no initialization, use the original frame
            annotatedFrame = frame;
        end
    end
    
    % Write Annotated Frame to Output Video
    writeVideo(videoWriter, annotatedFrame);
end

% Cleanup
close(videoWriter);

disp('Vehicle tracking completed without frame loss. Output saved as tracked_airborne_vehicle_no_frame_loss.avi');
