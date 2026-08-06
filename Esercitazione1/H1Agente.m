%%Azione scelta dall'agente



function index = scegliAzioneEpsGreedy(Q, epsilon)


    if rand<epsilon
         index = randi(length(Q)); % exploration

    else

        maxQ = max(Q);
        candidati = find(Q == maxQ);
        a = candidati(randi(length(candidati))); % exploitation

       
    end



end

    



