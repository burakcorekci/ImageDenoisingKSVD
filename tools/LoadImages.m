function [ images ] = LoadImages( directory_path )
%LOADIMAGES Summary of this function goes here
%   Detailed explanation goes here
    images = cell(1, 1);
    img_index = 1;
    listing = dir(directory_path);
    for i = 1:length(listing)
        if listing(i).isdir == 0
            img_split = strsplit(listing(i).name, '.');
            if strcmp(img_split(2), 'png') ~= 1
                continue;
            end
            
            img_path = [directory_path, '/', listing(i).name];
            img = imread(img_path);
            if size(img, 3) == 3
                img = rgb2gray(img);
            end
            
            images{img_index} = struct('image', double(imresize(img, [256, 256])), 'name', img_split{1});
            img_index = img_index + 1;
        end
    end

end

