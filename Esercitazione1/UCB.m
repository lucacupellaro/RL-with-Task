%Q(a)=actionValues, N(a)=actionNumbers

%% clean workspace
clear all
close all
clc

% fix random number generation
rng(1)

% define action space
A = 5;

% upper confidence bound
c = 100; % governs how exploratory are chosen

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


%% start algo
% decreasing step size
for t = 2:experiment_length
    
    % extended function q
    q_ext = actionValues(:, t-1) ...
        + c*sqrt(log(t-1)./(actionNumber(:,t-1) + 1));
    % choose greedy actions
    greedy = find(q_ext == max(q_ext)); %trova tutte le azione con valore maasimo
    % take random action among the greedy one
    a = greedy(randi(length(greedy))); %sceglie tra le azioni massime una a caso

    % save action taken
    actions(t) = a;

    % apply action to bandit and measure reward
    r = bandit_ti(a);

    % save reward gained
    rewards(t) = r;

    % update estimate of actions
    actionNumber(:, t) = actionNumber(:, t-1);
    actionValues(:, t) = actionValues(:, t-1);

    actionNumber(a, t) = actionNumber(a, t) + 1;
    % decreasing step size
    step_size = 1/actionNumber(a, t);
    % % constant step size
    % step_size = 0.01;
    error = r - actionValues(a, t);
    actionValues(a, t) = actionValues(a, t) + step_size*error;
end


%% plotting

figure('Name','UCB Results','NumberTitle','off')
tiledlayout(3,1,"TileSpacing","compact","Padding","compact")

% --- Plot 1: number of times each action is selected
ax1 = nexttile();
plot(actionNumber','LineWidth',1.2)
title('Number of Selections per Action')
xlabel('Time step')
ylabel('Selection count')
legend('Action 1','Action 2','Action 3','Action 4','Action 5','Location','best')
grid on

% --- Plot 2: estimated action values
ax2 = nexttile();
plot(actionValues','LineWidth',1.2)
title('Estimated Action Values')
xlabel('Time step')
ylabel('Estimated value Q(a)')
legend('Action 1','Action 2','Action 3','Action 4','Action 5','Location','best')
grid on

% --- Plot 3: cumulative reward
ax3 = nexttile();
plot(cumsum(rewards),'LineWidth',1.4)
title('Cumulative Reward')
xlabel('Time step')
ylabel('Cumulative reward')
grid on

