close all; clear all; clc;

addpath('../tools');

% Boolean Definitions
TRUE = 1;
FALSE = 0;

% Load Images
% images = {
%     struct('image', imresize(double(imread('../data_eski/Lena512.tif')), [256, 256]), 'name', 'Lena')
%     };
images = LoadImages('../data');
images_count = length(images);

% Hyper parameters for the algorithm
p_n = 8;
n = p_n * p_n;
k = 256;
sparsity = 0.25;
L = round(k * sparsity);
%L = k;
max_iter = 200;
C = 1.15;

%stdev_list = [2, 5, 10, 15, 20, 25, 50, 75, 100];
stdev_list = [100, 75, 50, 25, 20, 15, 10, 5, 2];
%stdev_list = [100, 75, 50, 25, 20, 15, 10];
%stdev_list = [100, 75, 50, 25];
%stdev_list = [2];
stdev_count = length(stdev_list);

%results = zeros(stdev_count, images_count, 2);
results = [struct('img_index', 0, 's', 0, 'noisy_psnr', 0, 'denoised_psnr', 0, 'rmse', [], 'sparsity', [], 'D', [], 'A', [])];
results_index = 0;

table = zeros(stdev_count, images_count, 2);

noisy_imgs = cell(images_count, stdev_count);
denoised_imgs = cell(images_count, stdev_count);
for img_index = 1:images_count
    img = images{img_index}.image;
    img_name = images{img_index}.name;
    [M, N] = size(img);
    
    h = figure;
    imshow(uint8(img));
    title('Original');
    saveas(h, ['../figures/', img_name, '_org.png'], 'png');
    close(h);
    
    for s = 1:stdev_count
        stdev = stdev_list(s);
        
        log_path = ['../log/', img_name, '_', num2str(stdev, '%d'), '.log'];
        diary(log_path);
        
        noise = stdev * randn(M, N);
        noisy_img = img + noise;
        noisy_imgs{img_index, s} = noisy_img;
        
        results_index = results_index + 1;
        results(results_index) = struct('img_index', img_index, 's', stdev, 'noisy_psnr', 0, 'denoised_psnr', 0, 'rmse', [], 'sparsity', [], 'D', [], 'A', []);
        
        fprintf('Image: %s, s = %3.2f, PSNR = %3.2f, SNR = %3.2f\n', img_name, stdev, PSNR(noisy_img, img), snr(img, noise));
        
        patches_count = (M - p_n + 1) * (N - p_n + 1);
        patches = zeros(n, patches_count);
        window_indeces = zeros(2, patches_count);
        
        patch_index = 1;
        for i = 1:M - p_n + 1
            for j = 1:N - p_n + 1
                patch = noisy_img(i : i + p_n - 1, j : j + p_n - 1);
                patches(:, patch_index) = patch(:);
                window_indeces(:, patch_index) = [i; j];
                patch_index = patch_index + 1;
            end
        end
        fprintf('\tFinished creating the patches.\n');
        
        epsilon = (C*stdev)^2;
        
        [D, A, results(results_index).rmse, results(results_index).sparsity] = KSVD(patches, k, L, epsilon, max_iter, TRUE);
        results(results_index).D = D;
        results(results_index).A = A;
        
        vis_dic = VisualizeDictionary(D);
        imwrite(vis_dic, ['../figures/dictionary/', img_name, '_', num2str(stdev, '%d'), '.png'], 'PNG');
        
        lambda = 30/stdev;
        D_A = D * A;
        
        denoised_img_total = zeros(M, N);
        denoised_img_counter = denoised_img_total;
        patch_shape = [p_n, p_n];
        ones_patch = ones(p_n, p_n);
        for patch_index=1:patches_count
            patch = reshape(D_A(:, patch_index), patch_shape);
            denoised_img_total(window_indeces(1, patch_index):window_indeces(1, patch_index) + p_n - 1, window_indeces(2, patch_index):window_indeces(2, patch_index) + p_n - 1) = denoised_img_total(window_indeces(1, patch_index):window_indeces(1, patch_index) + p_n - 1, window_indeces(2, patch_index):window_indeces(2, patch_index) + p_n - 1) + patch;
            denoised_img_counter(window_indeces(1, patch_index):window_indeces(1, patch_index) + p_n - 1, window_indeces(2, patch_index):window_indeces(2, patch_index) + p_n - 1) = denoised_img_counter(window_indeces(1, patch_index):window_indeces(1, patch_index) + p_n - 1, window_indeces(2, patch_index):window_indeces(2, patch_index) + p_n - 1) + ones_patch;
        end
        denoised_img_total = denoised_img_total + lambda * noisy_img;
        denoised_img_counter = denoised_img_counter + lambda;
        denoised_img = denoised_img_total./denoised_img_counter;
        denoised_imgs{img_index, s} = denoised_img;

        noisy_psnr = PSNR(noisy_img, img);
        denoised_psnr = PSNR(denoised_img, img);
        
        h = figure;
        imshow(uint8(noisy_img));
        title(['Noisy Image, s = ', num2str(stdev, '%d') ,', PSNR = ', num2str(noisy_psnr, '%.2f')]);
        saveas(h, ['../figures/', img_name, '_noisy_', num2str(stdev, '%d'), '.png'], 'png');
        close(h);
        
        h = figure;
        imshow(uint8(denoised_img));
        title(['Denoised Image, s = ', num2str(stdev, '%d') ,', PSNR = ', num2str(denoised_psnr, '%.2f')]);
        saveas(h, ['../figures/', img_name, '_denoised_', num2str(stdev, '%d'), '.png'], 'png');
        close(h);
        
%         h = figure;
%         subplot(1, 3, 1);
%         imshow(uint8(img));
%         title('Original');
%         subplot(1, 3, 2);
%         imshow(uint8(noisy_img));
%         
%         title(['Noisy, PSNR = ', num2str(noisy_psnr, '%.2f')]);
%         subplot(1, 3, 3);
%         imshow(uint8(denoised_img));
%         title(['Denoised, PSNR = ', num2str(denoised_psnr, '%.2f')]);
%         saveas(h, ['../figures/', img_name, '_', num2str(stdev), '.png'], 'png');
        
        results(results_index).noisy_psnr = noisy_psnr; 
        results(results_index).denoised_psnr = denoised_psnr;
        
        table(s, img_index, 1) = noisy_psnr;
        table(s, img_index, 2) = denoised_psnr;
        
        fprintf('Noisy %s, PSNR = %.4f, SNR = %.4f\n', img_name, noisy_psnr, SNR(noisy_img, img));
        fprintf('Denoised %s, PSNR = %.4f, SNR = %.4f\n\n', img_name, denoised_psnr, SNR(denoised_img, img));
        
        diary off;
    end
    save('results.mat', 'results');
    save('table.mat', 'table');
    save res.mat
end
