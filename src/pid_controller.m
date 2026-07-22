clc;
clear;
close all;

% ============================================
% HEAT EXCHANGER + NN + PID HYBRID CONTROL
% ============================================

Cp = 4.18;
Tc_in = 30;

Th_in_range = 100:5:150;
m_range = 0.5:0.5:3;

X = [];
Y = [];

% ============================================
% DATA GENERATION
% ============================================

for i = 1:length(Th_in_range)
    for j = 1:length(m_range)

        Th_in = Th_in_range(i);
        m = m_range(j);

        Th_out = Th_in - (40 / m);
        Tc_out = Tc_in + (30 / m);

        Q_actual = m * Cp * (Th_in - Th_out);
        Q_max = m * Cp * (Th_in - Tc_in);

        eta = Q_actual / Q_max;

        X = [X; Th_in m];
        Y = [Y; eta];

    end
end

% NORMALIZATION
X_max = max(X);
X_norm = X ./ X_max;

% ============================================
% TRAIN NN
% ============================================

input_size = 2;
hidden_size = 6;

W1 = rand(hidden_size, input_size);
b1 = rand(hidden_size, 1);

W2 = rand(1, hidden_size);
b2 = rand(1,1);

lr = 0.01;
epochs = 400;

for epoch = 1:epochs
    for i = 1:size(X_norm,1)

        x = X_norm(i,:)';
        y = Y(i);

        % Forward
        z1 = W1*x + b1;
        a1 = tanh(z1);
        y_pred = W2*a1 + b2;

        % Backprop
        dW2 = 2*(y_pred - y)*a1';
        db2 = 2*(y_pred - y);

        da1 = W2'*2*(y_pred - y);
        dz1 = da1 .* (1 - tanh(z1).^2);

        dW1 = dz1 * x';
        db1 = dz1;

        % Update
        W2 = W2 - lr*dW2;
        b2 = b2 - lr*db2;
        W1 = W1 - lr*dW1;
        b1 = b1 - lr*db1;

    end
end

disp('NN TRAINED');

% ============================================
% PID CONTROL SETUP
% ============================================

target_eff = 0.85;

Kp = 2.5;
Ki = 0.8;
Kd = 0.2;

error_prev = 0;
integral = 0;

% Initial conditions
Th_in = 130;
m = 1.0;

time_steps = 50;

eff_history = [];
flow_history = [];

% ============================================
% SIMULATION LOOP (CONTROL SYSTEM)
% ============================================

for t = 1:time_steps

    % Normalize input
    x = [Th_in m] ./ X_max;
    x = x';

    % NN Prediction
    z1 = W1*x + b1;
    a1 = tanh(z1);
    eff = W2*a1 + b2;

    % Error
    error = target_eff - eff;

    % PID
    integral = integral + error;
    derivative = error - error_prev;

    adjustment = Kp*error + Ki*integral + Kd*derivative;

    % Update flow rate
    m = m + adjustment;

    % Constraints (real system limits)
    if m < 0.5
        m = 0.5;
    elseif m > 3
        m = 3;
    end

    error_prev = error;

    % Store
    eff_history = [eff_history; eff];
    flow_history = [flow_history; m];

end

% ============================================
% RESULTS
% ============================================

figure;
plot(eff_history, 'LineWidth', 2)
hold on
yline(target_eff, '--r', 'Target')
xlabel('Time Step')
ylabel('Efficiency')
title('PID + AI Control Performance')
grid on

figure;
plot(flow_history, 'LineWidth', 2)
xlabel('Time Step')
ylabel('Flow Rate (kg/s)')
title('Flow Rate Adjustment by PID')
grid on

disp(' ');
disp('HYBRID AI + PID CONTROL COMPLETE');