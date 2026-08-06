%%Azione scelta dall'agente



function [index, isExploration] = scegliAzioneEpsGreedy(z, epsilon)

    if rand < epsilon
        index = randi(length(z)); % exploration
        isExploration = 1;
    else
        maxZ = max(z);
        candidati = find(z == maxZ);
        index = candidati(randi(length(candidati))); % exploitation
        isExploration = 0;
    end

end


