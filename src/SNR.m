function [ snr ] = SNR( noisy_img, img )
%PSNR Summary of this function goes here
%   Detailed explanation goes here
    noise = noisy_img - img;
    
    snr = 20 * log10( sqrt(sum(sum(img.^2))) / sqrt(sum(sum(noise.^2))) );
end

