# Airborne Vehicle Detection and Tracking

This MATLAB project focuses on detecting and tracking an airborne vehicle (e.g., an airplane) in a video. The program processes the video frame by frame to detect the vehicle and uses a Kalman filter to maintain accurate tracking throughout the video.

## Features
- **Video Processing:** Processes a video frame by frame to identify the airplane.
- **Grayscale Conversion:** Simplifies object differentiation by reducing color dimensions.
- **Thresholding:** Segments the airplane from the background.
- **Bounding Box:** Marks the detected airplane with a red rectangle in each frame.
- **Kalman Filter Tracking:** Predicts the airplane's position for robust tracking.
- **Output Video:** Saves a new video highlighting the tracked airplane.

## Prerequisites
- MATLAB installed on your system.
- A video file named `resized_video3.mp4` (input video) placed in the working directory.

## Usage
1. **Run the Script:**
   - Execute the MATLAB script to process the video and track the airplane.
2. **Input Video:**
   - The input video should be a resized video (`resized_video3.mp4`) of dimensions 500x500 pixels and length 10 seconds.
3. **Output Video:**
   - The processed video will be saved as `tracked_airplane_son.avi` in the working directory.

## How It Works
### Video Processing
- **Frame-by-Frame Analysis:** The video is processed sequentially to detect the airplane consistently.
- **Grayscale Conversion:** Converts RGB frames to grayscale for easier object detection.
- **Thresholding:** Identifies potential airplane regions by isolating them from the background.
- **Bounding Box:** Surrounds the detected airplane with a rectangle for visual feedback.

### Kalman Filtering
- **Prediction:** Estimates the airplane's future position based on its velocity and previous positions.
- **Initialization:** Configured with the following properties:
  - **Initial State Estimate:** [0, 0] (position)
  - **Process Noise:** [1.1, 1.1]
  - **Measurement Noise:** [1.1, 1.1]
  - **Motion Noise Covariance:** 0.1

### Output Video
- The program creates a new video with the detected airplane marked by a red rectangular box. The airplane's position updates dynamically across frames, ensuring consistent tracking even with distractions such as clouds or static objects.

## Results
The program successfully tracks the airplane throughout the video. It distinguishes the airplane from other objects like clouds and signboards. The tracking is accurate and consistent, even as the airplane moves or changes position in the frame.
