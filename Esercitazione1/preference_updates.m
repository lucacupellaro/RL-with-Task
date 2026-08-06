% clean workspace
clear all
close all
clc

% fix random number generation
rng(1)

% define action space
A = 5;

% length of the experiment
experiment_length = 1e4;

% initialize preferences
preferences = ones(A, experiment_length);

% action taken
actions = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

% algorithms parameters
alpha = 0.01;
beta = 0.01;

% number of times an action has been taken
actionNumber = zeros(A, experiment_length);

% mean reward
mean_rew = 0;

% decreasing step size
for t = 2:experiment_length
    
    % compute probabilities of taking actions
    H = preferences(:, t-1);
    probabilities = exp(H)/sum(exp(H));
    % cumulative sum of probabilities
    cum_prob = cumsum(probabilities);
    % take random action according to probabilities
    a = find(cum_prob >= rand, 1, 'first'); 
    
    % save action taken
    actions(t) = a;

    % apply action to bandit and measure reward
    r = bandit_ti(a);

    % save reward gained
    rewards(t) = r;

    % update mean reward
    % % decreasing step size
    % mean_rew = mean_rew  + 1/t*(r - mean_rew);
    % constant step size
    mean_rew = mean_rew  + beta*(r - mean_rew);
    
    % update preferences
    for act = 1:A
        % taken actions
        if act == a
            preferences(act, t) = preferences(act, t-1)  ...
                + alpha*(r - mean_rew)*(1 - probabilities(act));
        else
            preferences(act, t) = preferences(act, t-1) + ...
                - alpha*(r - mean_rew)*probabilities(act);
        end
    end

     % update number of actions
    actionNumber(:, t) = actionNumber(:, t-1);
    actionNumber(a, t) = actionNumber(a, t) + 1;
end

figure()
tiledlayout(3,1,"TileSpacing","compact")

ax1 = nexttile();
plot(preferences')
legend('1','2','3','4','5')

ax2 = nexttile();
plot(actionNumber')
legend('1','2','3','4','5')

ax3 = nexttile();
plot(cumsum(rewards))