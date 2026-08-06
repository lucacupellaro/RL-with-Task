clear all; close all; clc;
rng(1);

% Parametri
epsilon     = 0.1;
gamma       = 0.5;
numEpisodes = 10000;
gridSize    = 10;


track=generateTrack(20)


% Dimensioni spazio stati/azioni
H    = size(track, 1);
W    = size(track, 2);
V    = 9;     % velocità -4..4 → indici 1..9 (shift +5)
numA = 9;     % 9 azioni

% azioni: [delta_vr, delta_vc]
actions = [-1 -1; -1  0; -1  1;
            0 -1;  0  0;  0  1;
            1 -1;  1  0;  1  1];

% Inizializzazione Q, Nvisits, pi
Q       = zeros(H, W, V, V, numA);
Nvisits = zeros(H, W, V, V, numA);
pi      = ones(H, W, V, V, numA) / numA;

% Crea figura animazione UNA VOLTA SOLA
figure(2); clf;
imagesc(track);
colormap([1 1 1; 0 0 0]);
axis equal tight; hold on;
h_ball = plot(1, 1, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
h_traj = plot(1, 1, 'b-', 'LineWidth', 1.5);
title('In attesa del primo snapshot...');
drawnow;

% Loop episodi
for ep = 1:numEpisodes

    visualize = mod(ep, 500) == 0; %si mostra solo 1 ogni 500 episodi nell'interfaccia grafica

    % 1) GENERA EPISODIO seguendo pi
    [states, act_idx, rewards] = generateEpisode(track, pi, actions, H, W, visualize, ep, h_ball, h_traj);
    T = length(rewards);

    if T == 0
        continue;
    end

    % 2) BACKWARD PASS - aggiorna Q e pi
    G = 0;
    for t = T:-1:1
        G = gamma * G + rewards(t);

        r    = states(t, 1);
        c    = states(t, 2);
        vr_i = states(t, 3) + 5;
        vc_i = states(t, 4) + 5;
        a    = act_idx(t);

        % controlla che la coppia (stato,azione) era gia comparsa prima
        % nello stesso episodio?
        first_visit = true;
        for k = 1:t-1
            if isequal(states(k,:), states(t,:)) && act_idx(k) == a
                first_visit = false;
                break;
            end
        end

        if first_visit
            Nvisits(r, c, vr_i, vc_i, a) = Nvisits(r, c, vr_i, vc_i, a) + 1;
            n = Nvisits(r, c, vr_i, vc_i, a);

            Q(r, c, vr_i, vc_i, a) = Q(r, c, vr_i, vc_i, a) + ...
                (1/n) * (G - Q(r, c, vr_i, vc_i, a));

            q_vals = squeeze(Q(r, c, vr_i, vc_i, :)); 
            [~, A_star] = max(q_vals);

            pi(r, c, vr_i, vc_i, :)      = epsilon / numA;
            pi(r, c, vr_i, vc_i, A_star) = pi(r, c, vr_i, vc_i, A_star) + (1 - epsilon);
        end
    end

    if mod(ep, 100) == 0
        fprintf('Episodio %d/%d | Steps: %d\n', ep, numEpisodes, T);
    end
end



