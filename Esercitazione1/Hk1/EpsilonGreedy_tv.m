% ===========================
% MULTI-ARMED BANDIT TASK
% ===========================
%
% OBIETTIVO:
% Implementare un agente che seleziona ripetutamente un'azione
% (Rock, Paper, Scissors, Lizard, Spock) per massimizzare
% la reward totale attesa nel tempo.
%
% Il problema è modellato come Multi-Armed Bandit:
% - ogni azione = un "braccio"
% - ogni azione ha una reward media da stimare
%
% ===========================
% COSA SVILUPPARE
% ===========================
%
% 1) MODELLO DEL GIOCO
% - Azioni:
%   Rock, Paper, Scissors, Lizard, Spock
%
% - Avversario:
%   gioca random
%
% - Reward:
%   +1 -> vittoria
%   -1 -> sconfitta
%   (0 -> pareggio opzionale)
%
% ===========================
% 2) MODELLO BANDIT
% ===========================
% - Ogni azione = un braccio
% - Stimare la reward media nel tempo
%
% ===========================
% 3) POLICY DA IMPLEMENTARE
% ===========================
%
% a) Epsilon-Greedy (sample-average)
%    - Exploitation: azione migliore
%    - Exploration: random con probabilità epsilon
%
% b) Upper Confidence Bound (UCB)
%    - Usa media + incertezza
%
% c) Preference Updates (Gradient Bandit)
%    - Aggiorna preferenze
%
% ===========================
% 4) SIMULAZIONE
% ===========================
%
% - Loop su molti step:
%   1. scegliere azione
%   2. generare mossa avversario
%   3. calcolare reward
%   4. aggiornare stime
%
% ===========================
% 5) ANALISI
% ===========================
%
% - Reward media nel tempo
% - Confronto tra policy
% - Valutare quale algoritmo performa meglio
%

%% Clear workspace
clear all
close all
clc

% fix random number generation
rng(1)

% define action space
A = 5;


%% Pre stup iniziale
epsilon = 0.1; % probability of taking random action

% length of the experiment
experiment_length = 1e4;

% estimate of action values
% actionValues = zeros(A, experiment_length); % uniform initialization
% optimistic initialization
actionValues = zeros(A, experiment_length);  %Q(a,t) righe=azioni, colonne=tempo
actionValues(:,1) = 0*ones(A,1);

% number of times an action has been taken
actionNumber = zeros(A, experiment_length); %N(a) righe = azioni (A = 5), colonne = tempo (t)


% action taken
actions = zeros(1, experiment_length);
rewards = zeros(1, experiment_length);

%azioni bot
actionsBot = zeros(1, experiment_length);




%% ESecuzione

for t=2:experiment_length

   

    %l'agente scegli l'azione
    action=scegliAzioneEpsGreedy(actionValues(:,t-1),epsilon);
    %il bot scegli l'azione
    %actionBoT=azionebotNonStazionary(t);
    actionBoT=azionebot();

    % save action dell'agente
    actions(t) = action;

    % save action del bot
    actionsBot(t) = actionBoT;

    
    % apply action to bandit and measure reward
    r=computeReward(action,actionBoT);


    % save reward gained
    rewards(t) = r;


     % update estimate of actions
    actionNumber(:, t) = actionNumber(:,t-1);
    actionValues(:, t) = actionValues(:, t-1);

    actionNumber(action, t) = actionNumber(action, t) + 1;
  
    step_size = 0.01;
    error = r - actionValues(action, t);
    actionValues(action, t) = actionValues(action, t) + step_size*error;

end      




%% ===========================
%% PLOTTING RISULTATI BANDIT
% ===========================

figure
tiledlayout(2,1,"TileSpacing","compact")

% -------------------------
% Grafico 1: Reward cumulato
nexttile
plot(cumsum(rewards))
title('Cumulative Reward')
xlabel('Time step t')
ylabel('Cumulative Reward')

% -------------------------
% Grafico 2: Reward medio
nexttile
avgReward = cumsum(rewards) ./ (1:length(rewards));
plot(avgReward)
title('Average Reward')
xlabel('Time step t')
ylabel('Average Reward')

figure
tiledlayout(2,1,"TileSpacing","compact")

% -------------------------
% Grafico 3: Stima valori Q(a,t)
nexttile
plot(actionValues')
title('Estimated Action Values Q(a,t)')
xlabel('Time step t')
ylabel('Q(a,t)')
legend('Rock','Paper','Scissors','Lizard','Spock')

% -------------------------
% Grafico 4: Numero volte azioni scelte
nexttile
plot(actionNumber')
title('Action Selection Count N(a,t)')
xlabel('Time step t')
ylabel('N(a,t)')
legend('Rock','Paper','Scissors','Lizard','Spock')
