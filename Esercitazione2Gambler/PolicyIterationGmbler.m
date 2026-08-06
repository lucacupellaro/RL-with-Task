clear all
close all
clc

% for reproducibility
rng(2)

% load model
load Gambler_Initialization.mat   % carica P, R, validA, gamma

% dimensions
S = size(P, 1);   % numero stati = 101
A = size(P, 3);   % numero azioni massime = 100
goal = S - 1;     % stato reale finale = 100

% initialize V
V = zeros(S,1);

% initialize a valid random policy
pi = zeros(S,1);
for s = 2:S-1
    s_real = s - 1;
    maxBet = min(s_real, goal - s_real);
    pi(s) = randi(maxBet);
end

% counters and histories
count = 0;
policy_changes_hist = [];
value_change_hist = [];

maxOuterIter = 1000;

% repeat until convergence
while true
    count = count + 1;
    disp(['Policy iteration step: ', num2str(count)])

    Vold = V;
    pi_old = pi;

    % evaluate current policy
    V = policy_evaluation_gambler(P, R, pi, gamma);

    % improve policy
    pip = policy_improvement_gambler(P, R, V, gamma);

    % histories
    policy_changes_hist(end+1) = sum(pip ~= pi_old);
    value_change_hist(end+1) = norm(V - Vold, inf);

    % stop if stable
    if isequal(pip, pi)
        disp('Policy stabile: algoritmo terminato.')
        break
    end

    pi = pip;

    if count >= maxOuterIter
        error('Raggiunto il numero massimo di iterazioni esterne.')
    end
end

save vstarPI.mat V pi policy_changes_hist value_change_hist

%% base vectors
capital = 0:goal;

%% plot 1: optimal value function
figure()
plot(capital, V, 'LineWidth', 2)
xlabel('Capitale s')
ylabel('V(s)')
title('Value Function Ottima - Policy Iteration')
grid on
drawnow

%% plot 2: optimal policy
figure()
stem(capital, pi, 'filled')
xlabel('Capitale s')
ylabel('\pi(s)')
title('Policy Ottima - Gambler''s Problem')
grid on
drawnow

%% construct Q(s,a)
Q = NaN(S, A);

for s = 2:S-1
    s_real = s - 1;
    maxBet = min(s_real, goal - s_real);

    for a = 1:maxBet
        Q(s,a) = R(s,a) + gamma * P(s,:,a) * V;
    end
end

%% plot 3: heatmap of Q(s,a)
figure()
imagesc(1:A, 0:goal, Q)
set(gca,'YDir','normal')
colorbar
xlabel('Puntata a')
ylabel('Capitale s')
title('Heatmap di Q(s,a) - Policy Iteration')
drawnow

%% plot 4: 3D surface of Q(s,a)
[X, Y] = meshgrid(1:A, 0:goal);

figure()
surf(X, Y, Q, 'EdgeColor', 'none')
xlabel('Puntata a')
ylabel('Capitale s')
zlabel('Q(s,a)')
title('Superficie 3D di Q(s,a)')
colorbar
view(135, 30)
grid on
drawnow

%% plot 5: gap between best and second-best action
gap = NaN(S,1);

for s = 2:S-1
    vals = Q(s,:);
    vals = vals(~isnan(vals));
    vals = sort(vals, 'descend');

    if numel(vals) >= 2
        gap(s) = vals(1) - vals(2);
    end
end

figure()
plot(0:goal, gap, 'LineWidth', 2)
xlabel('Capitale s')
ylabel('Gap tra 1^a e 2^a azione')
title('Quanto la policy è "decisa"')
grid on
drawnow

%% plot 6: value vs policy scatter
figure()
scatter(V(2:end-1), pi(2:end-1), 40, 'filled')
xlabel('V(s)')
ylabel('\pi(s)')
title('Relazione tra Value Function e Policy')
grid on
drawnow

%% plot 7: number of policy changes per iteration
figure()
stairs(1:length(policy_changes_hist), policy_changes_hist, 'LineWidth', 2)
xlabel('Iterazione di Policy Iteration')
ylabel('Numero di stati con policy cambiata')
title('Cambiamenti della policy per iterazione')
grid on
drawnow

%% plot 8: change in value function per iteration
figure()
semilogy(1:length(value_change_hist), value_change_hist, 'LineWidth', 2)
xlabel('Iterazione di Policy Iteration')
ylabel('||V_k - V_{k-1}||_\infty')
title('Variazione della Value Function tra iterazioni')
grid on
drawnow

%% plot 9: 3D stem of optimal policy
figure()
stem3(capital, pi', V', 'filled')
xlabel('Capitale s')
ylabel('\pi(s)')
zlabel('V(s)')
title('Rappresentazione 3D di Policy e Value Function')
grid on
drawnow


