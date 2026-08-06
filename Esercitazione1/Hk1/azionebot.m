%% azione scelta dal bot con probailita uniforme


function index = azionebot()
    
   probs = [0.1, 0.2, 0.4, 0.1, 0.2];   % P(rock,paper,scissors,lizard,spock)

    % campiona: primo indice dove il cumulato supera rand
   index = find(rand <= cumsum(probs), 1);

 
end
