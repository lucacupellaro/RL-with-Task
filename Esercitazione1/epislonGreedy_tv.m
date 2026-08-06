%obiettivo: scegliere nel tempo l'azione che massimizza il reward atteso e
%quidni Q(a,t)


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
rewards1 = zeros(number_rep,1); %1 array composta 1000 zeri
for i = 1:number_rep
    rewards1(i) = bandit_ti(a);
end

figure()
histogram(rewards1)

%% epsilon greedy
epsilon = 0.1; % probability of taking random action

% length of the experiment
experiment_length = 1e7;

% estimate of action values
% actionValues = zeros(A, experiment_length); % uniform initialization
% optimistic initialization
actionValues = zeros(A, experiment_length);  %Q(a) righe=azioni, colonne=tempo
actionValues(:,1) = 0*ones(A,1);

% number of times an action has been taken
actionNumber = zeros(A, experiment_length); %N(a) righe = azioni (A = 5), colonne = tempo (t)

% number of times an action has been taken
stateBandit = zeros(A, experiment_length); % righe = azioni (5) colonne = tempo (t)

% action taken
actions = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

%% Egreedy
% decreasing step size
for t = 2:experiment_length
    % update state of the bandit
    stateBandit(:,t) = stateBandit(:,t-1) + rand(A, 1) - 0.5; %sottraggo allo stato t-1 rand(A,1) vettore di 5 righe con numero casuale fino a 1

    % choose action
    if rand < epsilon %rand e un numero compre tra 0 e1 
        % take random action
        a = randi(A); % un'azione casuale tra 1 e 5
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
    r = bandit_tv(a, stateBandit(:, t));

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

figure()
tiledlayout(4,1,"TileSpacing","compact")

% -------------------------
% Grafico 1: Valori reali q*(a,t)
ax1 = nexttile();
plot((stateBandit + [0.1; 0.5; 0.3; 0.6; 0])')
title('True Action Values q*(a,t)')
xlabel('Time step t')
ylabel('q*(a,t)')
legend('Action 1','Action 2','Action 3','Action 4','Action 5')

% -------------------------
% Grafico 2: Numero di volte che ogni azione è stata scelta
ax2 = nexttile();
plot(actionNumber')
title('Number of Times Each Action is Selected')
xlabel('Time step t')
ylabel('N(a,t)')
legend('Action 1','Action 2','Action 3','Action 4','Action 5')

% -------------------------
% Grafico 3: Stima dei valori Q(a,t)
ax3 = nexttile();
plot(actionValues')
title('Estimated Action Values Q(a,t)')
xlabel('Time step t')
ylabel('Q(a,t)')
legend('Action 1','Action 2','Action 3','Action 4','Action 5')

% -------------------------
% Grafico 4: Reward cumulato
ax4 = nexttile();
plot(cumsum(rewards))
title('Cumulative Reward Over Time')
xlabel('Time step t')
ylabel('Cumulative Reward')