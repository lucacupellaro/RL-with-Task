clear all; close all; clc;

rng(1);

% Parametri
epsilon     = 0.1;
gamma       = 0.9;
numEpisodes = 10000;
gridSize    = 10;
alpha       = 0.2; % 0.2 è un valore stabile per il SARSA

track = generateTrack(20);

% Dimensioni spazio stati/azioni
H    = size(track, 1);
W    = size(track, 2);
V    = 9;     % velocità -4..4 → indici 1..9 (shift +5)
numA = 9;     % 9 azioni

% azioni: [delta_vr, delta_vc]
actions = [-1 -1; -1  0; -1  1;
            0 -1;  0  0;  0  1;
            1 -1;  1  0;  1  1];

% Inizializzazione Q
Q = zeros(H, W, V, V, numA);

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
    
 
    visualize = (mod(ep, 500) == 0); 
    
    r  = generateStartCoordinates(track);
    c  = 1;
    vr = 0;
    vc = 0;
    maxSteps  = 500;
    trajectory = [r, c];
    
    if visualize
        set(h_ball, 'XData', c, 'YData', r);
        set(h_traj, 'XData', c, 'YData', r);
        title(sprintf('Episodio %d | Start', ep));
        drawnow;
    end
    
    % SARSA: Scegliamo la PRIMA azione (A) prima di iniziare a muoverci
    vr_i = vr + 5;
    vc_i = vc + 5;
    a = sceltaAzioneGreedy(epsilon, Q, r, c, vr_i, vc_i, numA);
    
    for step = 1:maxSteps
        vr_i = vr + 5;
        vc_i = vc + 5;
       
        % Limitiamo le velocita nel range -4,4 calcolando le nuove teoriche
        vr_new = vr + actions(a,1);
        if vr_new > 4
            vr_new = 4;   
        elseif vr_new < -4
            vr_new = -4;  
        end
        
        vc_new = vc + actions(a,2); 
        if vc_new > 4
            vc_new = 4;   
        elseif vc_new < -4
            vc_new = -4;  
        end
        
        % calcoliamo le nuove posizioni perciò s'
        r_new  = r + vr_new;
        c_new  = c + vc_new;
       
        % controlla TUTTE le celle attraversate 
        [crossed_finish, hit_wall] = checkPath(track, r, c, r_new, c_new, H, W);
        
        % Determiniamo Reward (R) e Stato Successivo Reale (S')
        if hit_wall
            R = -100;
            r_next = generateStartCoordinates(track);
            c_next = 1; vr_next = 0; vc_next = 0;
            is_terminal = false; % Sbatte e riparte, l'episodio non finisce
        elseif crossed_finish
            R = 100;
            r_next = r_new; c_next = c_new; 
            vr_next = vr_new; vc_next = vc_new;
            is_terminal = true;  % Traguardo! Fine episodio
        else
            R = -1;
            r_next = r_new; c_next = c_new;
            vr_next = vr_new; vc_next = vc_new;
            is_terminal = false;
        end
        
        % Indici shiftati per lo stato successivo S'
        vr_next_i = vr_next + 5;
        vc_next_i = vc_next + 5;
        
        % SARSA: Scegliamo la mossa successiva A' nello stato S'
        if is_terminal
            a_next = 1; % Fittizio, se è terminale Q vale 0
            target = R; 
        else
            a_next = sceltaAzioneGreedy(epsilon, Q, r_next, c_next, vr_next_i, vc_next_i, numA);
            target = R + gamma * Q(r_next, c_next, vr_next_i, vc_next_i, a_next);
        end
        
        % AGGIORNAMENTO MATRICE Q
        Q(r, c, vr_i, vc_i, a) = Q(r, c, vr_i, vc_i, a) + alpha * (target - Q(r, c, vr_i, vc_i, a));
        
        % Aggiornamento Grafico
        if visualize
            if hit_wall
                trajectory = [r_next, c_next];
            else
                trajectory(end+1,:) = [r_next, c_next];
            end
            set(h_ball, 'XData', c_next, 'YData', r_next);
            set(h_traj, 'XData', trajectory(:,2), 'YData', trajectory(:,1));
            title(sprintf('Episodio %d | Step %d', ep, step));
            drawnow;
        end
        
        % Passaggio di consegne (S <- S', A <- A')
        if is_terminal
            break; % Esce dal ciclo dei passi
        end
        
        r = r_next; 
        c = c_next;
        vr = vr_next; 
        vc = vc_next;
        a = a_next; 
        
    end
end

