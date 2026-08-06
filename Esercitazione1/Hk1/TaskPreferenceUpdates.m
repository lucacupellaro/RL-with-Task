%% clean workspace
clear all
close all
clc

rng(1)

A = 5;
experiment_length = 1e7;

actionNames = {'Rock','Paper','Scissors','Lizard','Spock'};

preferences = ones(A, experiment_length);

actions = zeros(1, experiment_length);
actionsBot = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

alpha = 0.01;
beta = 0.01;

actionNumber = zeros(A, experiment_length);

mean_rew = 0;

%% algoritmo
for t = 2:experiment_length
    
    H = preferences(:, t-1);
    probabilities = exp(H)/sum(exp(H));
    
    cum_prob = cumsum(probabilities);
    a = find(cum_prob >= rand, 1, 'first'); 
    
    actions(t) = a;

    % bot
    actionBot = azionebot();
    actionsBot(t) = actionBot;

    % reward
    r = computeReward(a, actionBot);
    rewards(t) = r;

    % mean reward
    mean_rew = mean_rew + beta*(r - mean_rew);
    
    % update preferences
    for act = 1:A
        if act == a
            preferences(act, t) = preferences(act, t-1) + ...
                alpha*(r - mean_rew)*(1 - probabilities(act));
        else
            preferences(act, t) = preferences(act, t-1) - ...
                alpha*(r - mean_rew)*probabilities(act);
        end
    end

    % action count
    actionNumber(:, t) = actionNumber(:, t-1);
    actionNumber(a, t) = actionNumber(a, t) + 1;
end

%% ===========================
%% FIGURA 1 (3 grafici)
%% ===========================
figure('Name','Preferences Algorithm - Part 1')

tiledlayout(3,1,"TileSpacing","compact")

% 1. Reward cumulato
nexttile
plot(cumsum(rewards),'LineWidth',1.2)
title('Cumulative Reward')
xlabel('t')
ylabel('Reward')
grid on

% 2. Reward medio
nexttile
avgReward = cumsum(rewards)./(1:length(rewards));
plot(avgReward,'LineWidth',1.2)
title('Average Reward')
xlabel('t')
ylabel('Average Reward')
grid on

% 3. Preferences H(a)
nexttile
plot(preferences','LineWidth',1.1)
title('Preferences H(a)')
xlabel('t')
ylabel('H(a)')
legend(actionNames,'Location','best')
grid on

%% ===========================
%% FIGURA 2 (3 grafici)
%% ===========================
figure('Name','Preferences Algorithm - Part 2')

tiledlayout(3,1,"TileSpacing","compact")

% 4. Probabilità delle azioni
probMatrix = exp(preferences) ./ sum(exp(preferences),1);

nexttile
plot(probMatrix','LineWidth',1.1)
title('Action Probabilities')
xlabel('t')
ylabel('π(a)')
legend(actionNames,'Location','best')
grid on

% 5. Conteggio azioni agente
nexttile
plot(actionNumber','LineWidth',1.1)
title('Action Count (Agent)')
xlabel('t')
ylabel('N(a)')
legend(actionNames,'Location','best')
grid on

% 6. Frequenza relativa azioni
nexttile
freq = actionNumber ./ sum(actionNumber,1);
plot(freq','LineWidth',1.1)
title('Relative Frequency Actions')
xlabel('t')
ylabel('Frequency')
legend(actionNames,'Location','best')
grid on