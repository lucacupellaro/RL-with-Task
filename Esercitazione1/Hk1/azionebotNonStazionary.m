 function actionBot = azionebotNonStazionary(t)

    if t < 3000
        % fase 1: uniforme
        probs = [0.2 0.2 0.2 0.2 0.2];

    elseif t < 6000
        % fase 2: preferisce Rock
        probs = [0.5 0.125 0.125 0.125 0.125];

    else
        % fase 3: preferisce Spock
        probs = [0.1 0.1 0.1 0.1 0.6];
    end

    u = rand;
    c = cumsum(probs);

    if u <= c(1)
        actionBot = 1;
    elseif u <= c(2)
        actionBot = 2;
    elseif u <= c(3)
        actionBot = 3;
    elseif u <= c(4)
        actionBot = 4;
    else
        actionBot = 5;
    end
end