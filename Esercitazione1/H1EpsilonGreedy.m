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


%Inizio gioco 

action=scegliAzioneEpsGreedy(actionValues,epsilon);
actionaBoT=azionebot();

for t=2:experiment_length

    %l'agente scegli l'azione
    action=scegliAzioneEpsGreedy(actionValues(:,t-1),epsilon);
    %il bot scegli l'azione
    actionaBoT=azionebot();

    % save action dell'agente
    actions(t) = action;

    
    % apply action to bandit and measure reward
    r=computeReward(action,actionaBoT)


    % save reward gained
    rewards(t) = r;


     % update estimate of actions
    actionNumber(:, t) = actionNumber(:,t-1);
    actionValues(:, t) = actionValues(:, t-1);

    actionNumber(action, t) = actionNumber(a, t) + 1;
    % % decreasing step size
    % step_size = 1/actionNumber(a, t);
    % constant step size
    step_size = 0.01;
    error = r - actionValues(a, t);
    actionValues(a, t) = actionValues(a, t) + step_size*error;

end      
