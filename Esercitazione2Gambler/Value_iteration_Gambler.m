clear all
close all
clc

rng(2)

% load model
load Gambler_Initialization.mat   % carica P, R, validA, gamma

theta = 1e-6;

% dimensions
S = size(P, 1);   % numero stati = 101
A = size(P, 3);   % numero azioni massime = 100

goal = S - 1;     % stato reale finale = 100

% initialize value function
V = zeros(S,1);

count = 0;
delta_hist = [];

while true
    count = count + 1;
    Delta = 0;

    % aggiorno solo gli stati non terminali: 1..99
    for s = 2:S-1
        s_real = s - 1;
        maxBet = min(s_real, goal - s_real);

        q = -inf(A,1);   % azioni non valide escluse automaticamente

        for a = 1:maxBet
            % ora R è una matrice R(s,a)
            q(a) = R(s,a) + gamma * squeeze(P(s,:,a)) * V;
        end

        Vp = max(q);
        Delta = max(Delta, abs(Vp - V(s)));
        V(s) = Vp;
    end

    delta_hist(end+1) = Delta;

    if Delta < theta
        break;
    end

    disp([count, Delta])
end

% policy greedy rispetto a V
pi = zeros(S,1);

for s = 2:S-1
    s_real = s - 1;
    maxBet = min(s_real, goal - s_real);

    q = -inf(A,1);

    for a = 1:maxBet
        q(a) = R(s,a) + gamma * squeeze(P(s,:,a)) * V;
    end

    [~, pi(s)] = max(q);
end

save vstarVI.mat V pi

%% plot value function
capital = 0:goal;

figure()
plot(capital, V, 'LineWidth', 2)
xlabel('Capital')
ylabel('V(s)')
title('Optimal Value Function - Gambler''s Problem')
grid on

%% plot optimal policy
figure()
stem(capital, pi, 'filled')
xlabel('Capital')
ylabel('\pi(s)')
title('Optimal Policy - Gambler''s Problem')
grid on

%% heatmap di Q(s,a)
Q = NaN(S, A);

for s = 2:S-1
    s_real = s - 1;
    maxBet = min(s_real, goal - s_real);

    for a = 1:maxBet
        Q(s,a) = R(s,a) + gamma * squeeze(P(s,:,a)) * V;
    end
end

figure()
imagesc(1:A, 0:goal, Q)
set(gca, 'YDir', 'normal')
colorbar
xlabel('Puntata a')
ylabel('Capitale s')
title('Heatmap di Q(s,a)')

%% gap tra migliore e seconda migliore azione
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

%% convergenza del value iteration
figure()
semilogy(delta_hist, 'LineWidth', 2)
xlabel('Iterazione')
ylabel('\Delta_k (scala log)')
title('Convergenza del Value Iteration')
grid on

%% relazione tra value function e policy
figure()
scatter(V, pi, 40, 'filled')
xlabel('V(s)')
ylabel('\pi(s)')
title('Relazione tra Value Function e Policy')
grid on