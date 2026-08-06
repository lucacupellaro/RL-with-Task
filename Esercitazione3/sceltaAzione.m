
function a=sceltaAzioneGreedy(eps,Q,r,c,vr_i,vc_i)
         probs = squeeze(Q(r, c, vr_i, vc_i, :));
         probs = probs / sum(probs);
        
         rnd_val = rand();
            
         if(rnd_val<eps)
             a = randi(length(probs)); % Select a random action
             

         end

            max=probs(1)

            for i=1:length(probs)-1
                 if max<probs(i+1)
                    max=probs(i+1)
                 end
            end
                


