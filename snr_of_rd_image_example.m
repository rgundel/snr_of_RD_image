%% Synthetic Range-Doppler Image with 2D Sinc Target and Subfigure Display

% Define image size (e.g., 128 x 128 pixels)
Nrange = 128;
Ndoppler = 128;
imgSize = [Nrange, Ndoppler];

% Create a complex Gaussian noise background
rdImage = (randn(imgSize) + 1i*randn(imgSize)) / sqrt(2);

%% Define a 2D sinc target
% Target parameters
targetAmplitude     = 10;    % Amplitude of the target
targetRangeCenter   = 64;    % Center position in range bins
targetDopplerCenter = 80;    % Center position in Doppler bins
sigma_range         = 5;     % Spread in range bins
sigma_doppler       = 5;     % Spread in Doppler bins

% Create coordinate grids
[rangeGrid, dopplerGrid] = ndgrid(1:Nrange, 1:Ndoppler);

% Compute normalized differences
rangeDiff   = (rangeGrid - targetRangeCenter) / sigma_range;
dopplerDiff = (dopplerGrid - targetDopplerCenter) / sigma_doppler;

% Create the 2D sinc target (using MATLAB's sinc, defined as sin(pi*x)/(pi*x))
targetSinc = targetAmplitude * sinc(rangeDiff) .* sinc(dopplerDiff);

% Inject the target into the noise background
rdImage = rdImage + targetSinc;

%% Define physical axes (example: range in meters, Doppler in m/s)
rangeMax   = 100;         % Maximum range (m)
dopplerMax = 50;          % Maximum Doppler (m/s)
rangeAxis   = linspace(0, rangeMax, Nrange);
dopplerAxis = linspace(-dopplerMax/2, dopplerMax/2, Ndoppler);  % Centered around 0

%% Display the Range-Doppler Image in Linear and dB scales
figure;

% Subplot 1: Linear Scale (Magnitude)
subplot(1,2,1);
imagesc(dopplerAxis, rangeAxis, abs(rdImage));
set(gca, 'YDir', 'normal');   % Ensure range axis increases upward
colormap('jet');
colorbar;
title('Linear Scale (Magnitude)');
xlabel('Doppler (m/s)');
ylabel('Range (m)');

% Subplot 2: dB Scale (20*log10 of magnitude)
subplot(1,2,2);
rdImage_dB = 20 * log10(abs(rdImage));
imagesc(dopplerAxis, rangeAxis, rdImage_dB);
set(gca, 'YDir', 'normal');
colormap('jet');
colorbar;
title('dB Scale (Magnitude)');
xlabel('Doppler (m/s)');
ylabel('Range (m)');

%% SNR Calculation

% Option 1: ROI-based estimation
% Define an ROI for the target (signal) around the target center (±5 bins)
targetROI = (rangeGrid >= targetRangeCenter-5 & rangeGrid <= targetRangeCenter+5) & ...
            (dopplerGrid >= targetDopplerCenter-5 & dopplerGrid <= targetDopplerCenter+5);

% Define an ROI for noise (e.g., top-left corner, away from the target)
noiseROI = (rangeGrid <= 10 & dopplerGrid <= 10);

% Compute the power image (magnitude squared)
powerImage = abs(rdImage).^2;

% Calculate average power in the signal and noise regions
signalPower = mean(powerImage(targetROI));
noisePower  = mean(powerImage(noiseROI));

% Compute SNR in linear scale and convert to dB
SNR_linear = signalPower / noisePower;
SNR_dB     = 10 * log10(SNR_linear);

fprintf('Option 1: ROI-based estimation\nROI-based SNR: %.2f (linear), %.2f dB\n', SNR_linear, SNR_dB);

% Option 2: Global estimation using image statistics
imgMean = mean(rdImage(:));
imgStd  = std(rdImage(:));

% Use absolute mean for complex data
SNR_global = abs(imgMean) / imgStd;
SNR_global_dB = 10 * log10(SNR_global);

fprintf('\nOption 2: Global estimation using image statistics\nGlobal SNR: %.2f (linear), %.2f dB\n', SNR_global, SNR_global_dB);
