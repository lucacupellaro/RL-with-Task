% Q(a)=actionValues, N(a)=actionNumber

%% clean workspace
clear all
close all
clc

% fix random number generation
rng(1)

% define action space
A = 5;

% action labels
actionNames = {'Rock','Paper','Scissors','Lizard','Spock'};

% upper confidence bound
c = 0.1; % governs how exploratory are chosen

% length of the experiment
experiment_length = 1e4;

actionValues = zeros(A, experiment_length); %Q
actionValues(:,1) = zeros(A,1);

actionNumber = zeros(A, experiment_length); %N

actions = zeros(1, experiment_length);
actionsBot = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

%% start algo
for t = 2:experiment_length

    % extended function q
    q_ext = actionValues(:, t-1) + c * sqrt(log(t-1) ./ (actionNumber(:, t-1) + 1));
    
    % choose greedy actions
    greedy = find(q_ext == max(q_ext));
    
    % take random action among the greedy ones
    a = greedy(randi(length(greedy)));

    % bot action
    actionBot = azionebot();
    
    actions(t) = a;
    actionsBot(t) = actionBot;

    % reward
    r = computeReward(a, actionBot);
    rewards(t) = r;

    % update statistics
    actionNumber(:, t) = actionNumber(:, t-1);
    actionValues(:, t) = actionValues(:, t-1);

    actionNumber(a, t) = actionNumber(a, t) + 1;

    % decreasing step size
    step_size = 0.01;

    error = r - actionValues(a, t);
    actionValues(a, t) = actionValues(a, t) + step_size * error;
end

%% conteggio cumulato delle azioni del bot
botActionCount = zeros(A, experiment_length);

for t = 2:experiment_length
    botActionCount(:, t) = botActionCount(:, t-1);
    botActionCount(actionsBot(t), t) = botActionCount(actionsBot(t), t) + 1;
end

%% ===========================
%% PLOTTING RISULTATI
%% ===========================
figure
tiledlayout(2,1,"TileSpacing","compact")

% 1. Reward cumulato
nexttile
plot(cumsum(rewards), 'LineWidth', 1.2)
title('Cumulative Reward')
xlabel('Time step t')
ylabel('Cumulative Reward')
grid on

% 2. Reward medio
nexttile
avgReward = cumsum(rewards) ./ (1:length(rewards));
plot(avgReward, 'LineWidth', 1.2)
title('Average Reward')
xlabel('Time step t')
ylabel('Average Reward')
grid on

figure
tiledlayout(2,1,"TileSpacing","compact")

% 3. Stima dei valori Q(a,t)
nexttile
plot(actionValues', 'LineWidth', 1.1)
title('Estimated Action Values Q(a,t)')
xlabel('Time step t')
ylabel('Q(a,t)')
legend(actionNames, 'Location', 'best')
grid on


% 4. Numero cumulato di selezioni dell'agente
nexttile
plot(actionNumber', 'LineWidth', 1.1)
title('Action Selection Count by Agent N(a,t)')
xlabel('Time step t')
ylabel('N(a,t)')
legend(actionNames, 'Location', 'best')
grid on

