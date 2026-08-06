
function a = sceltaAzioneGreedy(epsilon, Q, r, c, vr_i, vc_i, numA)
    if rand() < epsilon
       
        a = randi(numA);
    else
       
        q_values = squeeze(Q(r, c, vr_i, vc_i, :));
        
   
        [~, a] = max(q_values); 
    end
end
                


