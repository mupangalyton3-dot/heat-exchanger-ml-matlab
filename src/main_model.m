function heat_exchanger_FINAL()

clc; clear; close all;

%% === GUI WINDOW ===
fig = uifigure('Name','AI + PID Heat Exchanger','Position',[100 100 700 500]);

% Inputs
uilabel(fig,'Position',[50 420 150 22],'Text','Temperature (°C)');
tempInput = uieditfield(fig,'numeric','Position',[200 420 100 22],'Value',350);

uilabel(fig,'Position',[50 380 150 22],'Text','Flow Rate (kg/s)');
flowInput = uieditfield(fig,'numeric','Position',[200 380 100 22],'Value',2);

% Buttons
uibutton(fig,'push','Text','Run Simulation',...
    'Position',[50 320 150 30],...
    'ButtonPushedFcn',@(btn,event) runSim());

uibutton(fig,'push','Text','Auto Optimize',...
    'Position',[220 320 150 30],...
    'ButtonPushedFcn',@(btn,event) autoOptimize());

% Axes
ax = uiaxes(fig,'Position',[350 100 300 300]);
title(ax,'Efficiency vs Time')
xlabel(ax,'Time')
ylabel(ax,'Efficiency')

resultLabel = uilabel(fig,'Position',[50 250 400 22],'Text','Efficiency: ---');

%% === SIMULATION FUNCTION ===
function runSim()

    T = tempInput.Value;
    F = flowInput.Value;

    time = 1:100;
    efficiency = zeros(size(time));

    % PID parameters
    Kp = 0.5; Ki = 0.1; Kd = 0.05;
    target = 0.85;

    error_prev = 0;
    integral = 0;

    for i = 1:length(time)

        % Simple AI model (no toolbox)
        eff = 0.6 + 0.002*T - 0.000002*T^2 + 0.05*F - 0.01*F^2;

        % PID correction
        error = target - eff;
        integral = integral + error;
        derivative = error - error_prev;

        control = Kp*error + Ki*integral + Kd*derivative;

        % Adjust variables
        T = T + control*10;
        F = F + control*2;

        efficiency(i) = eff;
        error_prev = error;

        % Live plot
        plot(ax,time(1:i),efficiency(1:i),'b','LineWidth',2);
        drawnow;
    end

    resultLabel.Text = sprintf('Final Efficiency: %.3f',efficiency(end));

end

%% === OPTIMIZATION FUNCTION ===
function autoOptimize()

    bestEff = 0;

    for T = 300:10:500
        for F = 1:0.5:5

            eff = 0.6 + 0.002*T - 0.000002*T^2 + 0.05*F - 0.01*F^2;

            if eff > bestEff
                bestEff = eff;
                bestT = T;
                bestF = F;
            end
        end
    end

    tempInput.Value = bestT;
    flowInput.Value = bestF;

    resultLabel.Text = sprintf('Optimal → Temp: %.1f °C | Flow: %.1f | Eff: %.3f',bestT,bestF,bestEff);

end

end