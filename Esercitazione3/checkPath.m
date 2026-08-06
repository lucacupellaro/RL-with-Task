function [crossed_finish, hit_wall] = checkPath(track, r0, c0, r1, c1, H, W)
    % Controlla TUTTE le celle attraversate dal segmento (r0,c0)->(r1,c1).
    % crossed_finish = true se attraversa l'uscita destra restando in pista
    % hit_wall       = true se tocca un muro, esce dalla griglia,
    %                  oppure "taglia" lo spigolo tra due muri (corner cutting)
    crossed_finish = false;
    hit_wall       = false;

    % numero di passi di interpolazione = max distanza in celle
    nsteps = max(abs(r1 - r0), abs(c1 - c0));
    if nsteps == 0
        nsteps = 1;
    end

    % cella di partenza, per il controllo anti corner-cutting
    rr_prev = r0;
    cc_prev = c0;

    for s = 1:nsteps
        % interpola e arrotonda alla cella
        rr = round(r0 + (r1 - r0) * s / nsteps);
        cc = round(c0 + (c1 - c0) * s / nsteps);

        % --- TRAGUARDO: raggiunge/supera l'ultima colonna ---
        if cc >= W
            rr_clamped = max(1, min(H, rr));
            if track(rr_clamped, W) == 1
                crossed_finish = true;
                return;
            end
        end

        % --- FUORI GRIGLIA ---
        if rr < 1 || rr > H || cc < 1 || cc > W
            hit_wall = true;
            return;
        end

        % --- MURO sulla cella corrente ---
        if track(rr, cc) == 0
            hit_wall = true;
            return;
        end

        % --- ANTI CORNER-CUTTING ---
        % Se il passo e' DIAGONALE (cambiano sia riga che colonna),
        % il segmento passa sullo spigolo condiviso tra (rr_prev,cc) e (rr,cc_prev).
        % Se UNA delle due celle ortogonali e' muro (o fuori griglia),
        % la macchina starebbe attraversando un angolo chiuso -> collisione.
        if (rr ~= rr_prev) && (cc ~= cc_prev)
            % cella orizzontale adiacente (stessa riga di prima, nuova colonna)
            ok_a = (cc_prev >= 1 && cc_prev <= W && rr >= 1 && rr <= H) ...
                   && track(rr, cc_prev) == 1;
            % cella verticale adiacente (nuova riga, stessa colonna di prima)
            ok_b = (cc >= 1 && cc <= W && rr_prev >= 1 && rr_prev <= H) ...
                   && track(rr_prev, cc) == 1;
            if ~ok_a || ~ok_b
                hit_wall = true;
                return;
            end
        end

        rr_prev = rr;
        cc_prev = cc;
    end
end