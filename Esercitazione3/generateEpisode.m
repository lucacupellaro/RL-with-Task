
function [states, act_idx, rewards] = generateEpisode(track, pi, actions, H, W, visualize, ep, h_ball, h_traj)

    states  = [];
    act_idx = [];
    rewards = [];

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

    for step = 1:maxSteps
        vr_i = vr + 5;
        vc_i = vc + 5;

        probs = squeeze(pi(r, c, vr_i, vc_i, :));
        probs = probs / sum(probs);
      

        %scegliamo l'azione dando più peso alla azioni con probabilità piu
        %alta
        rnd_val = rand()
        
        somma = 0;
        
        for i = 1:length(probs)
            
            somma = somma + probs(i);
           
            if rnd_val <= somma
                a = i;  
                break;  
            end
            
        end

        %salvo lo stato e l'azione 
        states(end+1, :) = [r, c, vr, vc];
        act_idx(end+1)   = a;



        %Limitiamo le velocita nel range -4,4
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


        %calcoliamo le nuove posizioni
        r_new  = r + vr_new;
        c_new  = c + vc_new;

        % controlla TUTTE le celle attraversate 
        [crossed_finish, hit_wall] = checkPath(track, r, c, r_new, c_new, H, W);

        % fuori pista (muro lungo il percorso o fuori griglia)
        if hit_wall
            rewards(end+1) = -100;
            r  = generateStartCoordinates(track);
            c  = 1; vr = 0; vc = 0;
            trajectory = [r, c];

            if visualize
                set(h_ball, 'XData', c, 'YData', r);
                set(h_traj, 'XData', trajectory(:,2), 'YData', trajectory(:,1));
                title(sprintf('Episodio %d | Step %d | RESET!', ep, step));
                drawnow;
                pause(0.05);
            end

        % traguardo: ha attraversato l'uscita destra restando in pista
        elseif crossed_finish
            rewards(end+1) = 100;

            if visualize
                trajectory(end+1,:) = [r_new, c_new];
                set(h_ball, 'XData', c_new, 'YData', r_new);
                set(h_traj, 'XData', trajectory(:,2), 'YData', trajectory(:,1));
                title(sprintf('Episodio %d | TRAGUARDO in %d steps!', ep, step));
                drawnow;
                pause(1);
            end
            return;

        % step normale
        else
            rewards(end+1) = -1;
            r = r_new; c = c_new;
            vr = vr_new; vc = vc_new;

            if visualize
                trajectory(end+1,:) = [r, c];
                set(h_ball, 'XData', c,  'YData', r);
                set(h_traj, 'XData', trajectory(:,2), 'YData', trajectory(:,1));
                title(sprintf('Episodio %d | Step %d | vel=(%d,%d)', ep, step, vr, vc));
                drawnow;
                pause(0.05);
            end
        end
    end
end

