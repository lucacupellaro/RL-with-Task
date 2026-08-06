function r = bandit_tv(a, z)
% retrun with action a
% tv = time varying

switch a
    case 1
        r = randn(1) + 0.1; % Gaussian with mean 0.1 and std 1 
    case 2
        r = rand(1); % Uniform distribution
    case 3
        r = 0.3; % Deterministic
    case 4
        r = randi(5)/5; % Multinomial distribution
    case 5
        r = 10*randn(1); % Gaussian with zero mean and std 10
end

r = r + z(a);

% value of bandit
% q_star = [0.1; 0.5; 0.3; 0.2*sum(1:5)/5 = 0.6; 0]
% optimal_action = 4;