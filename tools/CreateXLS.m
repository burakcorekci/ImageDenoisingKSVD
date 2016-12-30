clear all; close all; clc;

load('../src/table.mat');
table_psnr = table;
clear table;

[s_count, img_count, ~] = size(table_psnr);
stdev_list = [100, 75, 50, 25, 20, 15, 10, 5];
img_names = {'Barbara', 'Brick-House', 'Cameraman', 'Lena', 'Mandrill', 'Peppers'};

xls = cell(s_count + 2, 1 + 2 * img_count);
for i = 1:img_count
    xls{1, 2*i} = img_names{i};
end

xls{2, 1} = 's';
for i = 1:img_count
    xls{2, 2*i} = 'Noisy PSNR';
    xls{2, 2*i + 1} = 'Denoised PSNR';
end

for s = 1:s_count
    xls{s + 2, 1} = stdev_list(s);
    for i = 1:img_count
        xls{s + 2, 2*i} = table_psnr(s, i, 1);
        xls{s + 2, 2*i + 1} = table_psnr(s, i, 2);
    end
end

csv_file = fopen('table.csv', 'w+');
[M, N] = size(xls);
for i = 1:M
    for j = 1:N
        if isempty(xls{i, j})
            ;
        elseif ischar(xls{i, j})
            fprintf(csv_file, '%s', xls{i, j});
        else
            fprintf(csv_file, '%.2f', xls{i, j});
        end
        if j ~= N
            fprintf(csv_file, ',');
        end
    end
    fprintf(csv_file, '\n');
end
fclose(csv_file);
