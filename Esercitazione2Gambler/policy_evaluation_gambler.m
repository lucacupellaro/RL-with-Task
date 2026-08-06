function Vpi = policy_evaluation_gambler(P, R, pi, gamma)
% compute the value function of pi via linear system

S = size(R, 1);

Ppi = zeros(S,S);
Rpi = zeros(S,1);

for s = 1:S
    if pi(s) == 0
        % terminal state
        Ppi(s,s) = 1;
        Rpi(s) = 0;
    else
        Ppi(s,:) = P(s,:,pi(s));
        Rpi(s) = R(s,pi(s));
    end
end

Vpi = (eye(S) - gamma * Ppi) \ Rpi; %Trova il vettore Vpi che soddisfa il sistema lineare, eye(S) e la matrice identita
end