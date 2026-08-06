function pip = policy_improvement_gambler(P, R, V, gamma)

S = size(R, 1);
A = size(R, 2);
goal = S - 1;

pip = zeros(S,1);

for s = 2:S-1
    s_real = s - 1;
    maxBet = min(s_real, goal - s_real);

    q = -inf(A,1);

    for a = 1:maxBet
        q(a) = R(s,a) + gamma * P(s,:,a) * V;
    end

    [~, pip(s)] = max(q);
end

end