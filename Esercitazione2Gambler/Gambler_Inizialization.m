clear all
close all
clc

gamma = 0.9;
goal = 100;
p_head = 0.5;

P = zeros(goal+1, goal+1, goal);
R = zeros(goal+1, goal);
validA = false(goal+1, goal);

for s = 0:goal
    idx = s + 1;

    if s == 0 || s == goal
        P(idx, idx, :) = 1;
        continue;
    end

    maxBet = min(s, goal - s);

    for a = 1:maxBet
        validA(idx, a) = true; %maschera delle azioni valide

        winState = s + a;
        loseState = s - a;

        winIdx = winState + 1;
        loseIdx = loseState + 1;

        P(idx, winIdx, a) = p_head;
        P(idx, loseIdx, a) = 1 - p_head;

        rewardWin = 0;
        rewardLose = 0;

        if winState == goal
            rewardWin = 1;
        end

        if loseState == 0
            rewardLose = -1;
        end

        R(idx, a) = p_head * rewardWin + (1 - p_head) * rewardLose;
    end
end

save('Gambler_Initialization.mat', 'P', 'R', 'validA', 'gamma')