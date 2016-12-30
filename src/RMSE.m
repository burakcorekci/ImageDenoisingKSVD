function [ rmse ] = RMSE( X, Y )
%RMSE Summary of this function goes here
%   Detailed explanation goes here
    [M, N] = size(X);
    
    rmse = sqrt( sum(sum((X - Y).^2)) / (M * N) );

end

