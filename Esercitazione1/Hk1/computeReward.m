% ===========================
% CALCOLO DELLA REWARD
% ===========================
% Azioni:
% 1 = Rock
% 2 = Paper
% 3 = Scissors
% 4 = Lizard
% 5 = Spock

function r = computeReward(a, opp)

    % inizializza reward
    r = 0;

    % pareggio
    if a == opp
        r = 0;
        return;
    end

    % casi di vittoria
    if (a == 1 && (opp == 3 || opp == 4)) || ... % Rock batte Scissors, Lizard
       (a == 2 && (opp == 1 || opp == 5)) || ... % Paper batte Rock, Spock
       (a == 3 && (opp == 2 || opp == 4)) || ... % Scissors batte Paper, Lizard
       (a == 4 && (opp == 2 || opp == 5)) || ... % Lizard batte Paper, Spock
       (a == 5 && (opp == 1 || opp == 3))        % Spock batte Rock, Scissors

        r = 1; % vittoria
    else
        r = -1; % sconfitta
    end

end