[fileName, filePath] = uigetfile({'*.jpg;*.png;*.bmp'}, 'Select Noisy Image File');
noisyImage = imread(fullfile(filePath, fileName));
noisyImage = rgb2gray(noisyImage);

%filtering
filteredImage_median = medfilt2(noisyImage);
filteredImage_gaussian = imgaussfilt(filteredImage_median);
filteredImage_wiener = wiener2(filteredImage_gaussian);

imshow(filteredImage_wiener);
title('Select a strip for intensity profile');

% Let the user draw a line strip on the image using improfile
h = imline;
position = wait(h);
delete(h);

% Extract the coordinates of the line strip
x1 = round(position(1, 1));
y1 = round(position(1, 2));
x2 = round(position(2, 1));
y2 = round(position(2, 2));

% Get the intensity values along the chosen strip using improfile
profile_data = improfile(filteredImage_wiener, [x1, x2], [y1, y2]);

% Apply Smoothing Filters
smoothedIntensity = medfilt1(profile_data, 5); % Apply median filtering
smoothedIntensity = imgaussfilt(smoothedIntensity, 1); % Apply Gaussian smoothing
denoisedIntensity = wdenoise(smoothedIntensity);

% Apply Averaging or Binning
segmentSize = 10; % Set the segment size
numSegments = floor(numel(denoisedIntensity) / segmentSize);
segmentedIntensity = reshape(denoisedIntensity(1:numSegments*segmentSize), segmentSize, numSegments);
averagedIntensity = mean(segmentedIntensity, 1);

% Extend the averaged intensity to match the original length
averagedIntensity = repelem(averagedIntensity, segmentSize);
k=numel(averagedIntensity);
averagedIntensity = averagedIntensity(1:k);
averagedIntensity = [averagedIntensity, repmat(averagedIntensity(end), 1, numel(denoisedIntensity) - numel(averagedIntensity))];


% Apply Thresholding
threshold = 50; % Set the threshold value
thresholdedIntensity = averagedIntensity;
thresholdedIntensity(thresholdedIntensity < threshold) = threshold; % Replace values below the threshold

% Apply Fourier Transform
fftIntensity = fft(thresholdedIntensity);
fftIntensity(abs(fftIntensity) < 100) = 0; % Apply a frequency domain threshold
filteredIntensity = ifft(fftIntensity);

figure(2)
plot(real(filteredIntensity)/max(real(filteredIntensity)), 'b', 'LineWidth', 1.5);
ylabel({'Intensity'},'FontSize',18);

% Create xlabel
xlabel({'Pixel length'},'FontSize',18);

% Create title
title({'Intensity profile of Fresnel diffraction by Circular Aperture d = 3 mm'},'FontSize',18);