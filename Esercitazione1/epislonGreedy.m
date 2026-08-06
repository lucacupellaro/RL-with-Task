% clean workspace
clear all
close all
clc

% fix random number generation
rng(1)

% define action space
A = 5;

% reward with action a
a = 3;
number_rep = 1000;
rewards1 = zeros(number_rep,1);
for i = 1:number_rep
    rewards1(i) = bandit_ti(a);
end
figure()
histogram(rewards1)

%% inizialization
epsilon = 0.1; % probability of taking random action

% length of the experiment
experiment_length = 1e4;

% estimate of action values
% actionValues = zeros(A, experiment_length); % uniform initialization
% optimistic initialization
actionValues = zeros(A, experiment_length); 
actionValues(:,1) = 0*ones(A,1);

% number of times an action has been taken
actionNumber = zeros(A, experiment_length);

% action taken
actions = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

isExploration = zeros(1, experiment_length);

%% epsilon greedy
% decreasing step size
for t = 2:experiment_length
    % choose action
    if rand < epsilon
        % take random action
        a = randi(A);
    else
        % take greedy action
        greedy = find(actionValues(:,t-1) == max(actionValues(:,t-1)));
        % we must break parity

        % % take first action
        a = greedy(1);
        % % take last action
        % a = greedy(end);
        % take random action among the greedy one
        % a = greedy(randi(length(greedy)));
    end

    % save action taken
    actions(t) = a;

    % apply action to bandit and measure reward
    r = bandit_ti(a);

    % save reward gained
    rewards(t) = r;

    % update estimate of actions
    actionNumber(:, t) = actionNumber(:,t-1);
    actionValues(:, t) = actionValues(:, t-1);

    actionNumber(a, t) = actionNumber(a, t) + 1;
    % % decreasing step size
    % step_size = 1/actionNumber(a, t);
    % constant step size
    step_size = 0.01;
    error = r - actionValues(a, t);
    actionValues(a, t) = actionValues(a, t) + step_size*error;
end

%% plotting

true_q = [0.1; 0.5; 0.3; 0.6; 0];

figure()
tiledlayout(3,1,"TileSpacing","compact")

% -------------------------
% Grafico 1: Numero di volte che ogni azione è stata scelta
ax1 = nexttile();
plot(actionNumber')
title('Number of Times Each Action is Selected')
xlabel('Time step t')
ylabel('N(a,t)')
legend('Action 1','Action 2','Action 3','Action 4','Action 5','Location','best')
grid on

% -------------------------
% Grafico 2: Stima dei valori Q(a,t)
ax2 = nexttile();
plot(actionValues')
hold on
yline(true_q(1), '--', 'Action 1 true value = 0.1')
yline(true_q(2), '--', 'Action 2 true value = 0.5')
yline(true_q(3), '--', 'Action 3 true value = 0.3')
yline(true_q(4), '--', 'Action 4 true value = 0.6')
yline(true_q(5), '--', 'Action 5 true value = 0')
hold off
title('Estimated Action Values Q(a,t)')
xlabel('Time step t')
ylabel('Q(a,t)')
legend('Q_1','Q_2','Q_3','Q_4','Q_5','Location','best')
grid on

% -------------------------
% Grafico 3: Reward cumulato
ax3 = nexttile();
plot(cumsum(rewards))
title('Cumulative Reward Over Time')
xlabel('Time step t')
ylabel('Cumulative Reward')
grid on