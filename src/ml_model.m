clc;
clear;
close all;

% ================================
% HEAT EXCHANGER + MACHINE LEARNING
% ================================

Cp = 4.18;
Tc_in = 30;

Th_in_range = 100:5:150;
m_range = 0.5:0.5:3;

X = []; % Inputs
Y = []; % Outputs

% ================================
% GENERATE DATA (SIMULATION)
% ================================

for i = 1:length(Th_in_range)
    for j = 1:length(m_range)

        Th_in = Th_in_range(i);
        m = m_range(j);

        Th_out = Th_in - (40 / m);
        Tc_out = Tc_in + (30 / m);

        Q_actual = m * Cp * (Th_in - Th_out);
        Q_max = m * Cp * (Th_in - Tc_in);

        eta = Q_actual / Q_max;

        % Store data
        X = [X; Th_in m];
        Y = [Y; eta];

    end
end

% ================================
% TRAIN MACHINE LEARNING MODEL
% ================================

model = fitlm(X, Y); % Linear Regression Model

disp(' ');
disp('=== MACHINE LEARNING MODEL CREATED ===');
disp(model);

% ================================
% PREDICTION (AI PART)
% ================================

% New unseen conditions
new_input = [130 2.2]; % [Temperature, Flow rate]

predicted_eff = predict(model, new_input);

fprintf('\n=== AI PREDICTION ===\n');
fprintf('For Temp = %.2f °C and Flow = %.2f kg/s:\n', new_input(1), new_input(2));
fprintf('Predicted Efficiency = %.3f\n', predicted_eff);

% ================================
% VISUALIZATION (REAL vs PREDICTED)
% ================================

Y_pred = predict(model, X);

figure;
scatter(Y, Y_pred, 'filled')
xlabel('Actual Efficiency')
ylabel('Predicted Efficiency')
title('Machine Learning Model Accuracy')
grid on

% ================================
% 3D SURFACE (AI VERSION)
% ================================

[Th_grid, m_grid] = meshgrid(Th_in_range, m_range);

Z_pred = zeros(size(Th_grid));

for i = 1:size(Th_grid,1)
    for j = 1:size(Th_grid,2)
        Z_pred(i,j) = predict(model, [Th_grid(i,j), m_grid(i,j)]);
    end
end

figure;
surf(Th_grid, m_grid, Z_pred)
xlabel('Temperature (°C)')
ylabel('Flow Rate (kg/s)')
zlabel('Predicted Efficiency')
title('AI-Based Efficiency Prediction Surface')
colorbar
grid on

disp(' ');
disp('AI Simulation Complete.');