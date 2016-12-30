function [ D, A, rmses, sparsity ] = KSVD( X, k, L, epsilon, max_iter, print )
%KSVD Summary of this function goes here
%   Detailed explanation goes here
    [n, ~] = size(X);
    
    % Generate column normalized positive D
    D = randn(n, k);
    D = D - min(min(D));
    D = bsxfun(@rdivide, D, sqrt(sum(D.^2)));
    
    rmses = zeros(1, max_iter);
    sparsity = zeros(1, max_iter);
    
    last_rmse = 0;
    A = OMP(D, k, X, L, epsilon);
    [M_A, N_A] = size(A);
    size_A = M_A * N_A;
    Il_empty = 1:N_A;
    for iter = 1:max_iter
        tic;
        R = X - D * A;
        for k_index = 1:k
            Il = find(A(k_index, :) ~= 0);
            %fprintf('\t%d\n', length(Il));
            if isempty(Il)
                Il = Il_empty;
            end
            Ri = R(:, Il) + D(:, k_index) * A(k_index, Il);
            [U, S, V] = svds(Ri, 1);

            D(:, k_index) = U;
            A(k_index, Il) = S*V';
            R(:, Il) = Ri - D(:, k_index) * A(k_index, Il);
        end
        A = OMP(D, k, X, L, epsilon);
        
        sparsity(iter) = 100*(1 - double(sum(sum(A ~= 0)))/size_A);
        rmse = RMSE(X, D * A);
        rmses(iter) = rmse;
        
        t = toc;
        if print
            fprintf('\tIteration %d: %.4fs, RMSE = %.4f, Sparsity = %.4f\n', iter, t, rmses(iter), sparsity(iter));
        end
        if abs(rmse - last_rmse) < 1e-4
            break;
        end
        last_rmse = rmse;
    end
    rmses = rmses(1:iter);
    sparsity = sparsity(1:iter);
end

