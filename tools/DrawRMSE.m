close all;
h = figure;
plot(results(8).rmse, 'LineWidth', 4);
xlabel('Iterations', 'FontSize', 12);
ylabel('RMSE', 'FontSize', 12);
title('Barbara, s = 5', 'FontSize', 12);
xlim([1, length(results(8).rmse)]);

saveas(h, '../figures/curves/barbara_5_rmse.png', 'png');