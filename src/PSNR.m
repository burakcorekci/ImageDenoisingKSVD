function [ psnr ] = PSNR( noisy_img, img )
%PSNR Summary of this function goes here
%   Detailed explanation goes here
    noise = noisy_img - img;
    [M, N] = size(noise);
    
    %psnr = 20 * log10( max(max(img)) / sqrt(sum(sum(noise.^2)) / (M * N)) );
    psnr = 20 * log10(( 255 ) / sqrt(sum(sum(noise.^2)) / (M * N)) );

end

