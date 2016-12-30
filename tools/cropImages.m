clear all; close all; clc;

cropped_dir_path = '../figures/cropped/';
dir_path = '../figures';

listing = dir(dir_path);
for i = 1:length(listing)
    if listing(i).isdir == 0
        img_split = strsplit(listing(i).name, '.');
        if strcmp(img_split(2), 'png') ~= 1
            continue;
        end
        
        img_path = [dir_path, '/', listing(i).name];
        cropped_img_path = [cropped_dir_path, '/', listing(i).name];
        
        fprintf('%s\n', listing(i).name);
        
        img = imread(img_path);
        img_cropped = img(16:452, 122:545, :);
        imwrite(img_cropped, cropped_img_path, 'PNG');
    end
end

