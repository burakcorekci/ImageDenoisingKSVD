function [ img ] = VisualizeDictionary( D )
%VISUALIZEDICTIONARY Summary of this function goes here
%   Detailed explanation goes here
    [n, k] = size(D);
    p_n = round(sqrt(n));
    sqrt_k = round(sqrt(k));
    M = 1 + sqrt_k * (p_n + 1);
    N = M;
    img = zeros(M, N);
    
    for i = 1:sqrt_k
        for j = 1:sqrt_k
            k_index = (i - 1) * sqrt_k + j;
            atom = reshape(D(:, k_index), [p_n, p_n]);
            atom_min = min(min(atom));
            atom_max = max(max(atom));
            %atom = round(255 * (atom - atom_min)/(atom_max - atom_min));
            atom = (atom - atom_min)/(atom_max - atom_min);
            
            img((i - 1)*(p_n + 1) + 2:i*(p_n + 1), (j - 1)*(p_n + 1) + 2:j*(p_n + 1)) = atom;
        end
    end

end

