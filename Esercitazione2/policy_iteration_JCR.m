clear all
close all
clc

% for reproducibility fix random seed
rng(2)

% load model
load modelJCR.mat

% gather dimensions
S = size(R, 1);
A = size(R, 2);

% initialize V and pi
V = randn(S,1);
pi = randi(A, [S, 1]);

% count iterations
count = 0;

% repeat until convergence
while true
    % increment the counter
    count = count + 1;
    disp(count)

    % evaluate the current policy
    V = policy_evaluation(P, R, pi, gamma);
    % V = iterative_policy_evaluation(P, R, pi, V, gamma);

    % update the policy
    pip = policy_improvement(P, R, V, gamma);

    % interrupt if the policy is stable
    if norm(pip - pi) == 0
        break
    else
        pi = pip; % update the policy
    end
end

save vstarPI.mat V

%% plot the optimal policy
N1 = 30;
N2 = 30;
cars_moved = 7;

% optimal policy and value function
ncars1 = zeros(N1+1,N2+1);
ncars2 = zeros(N1+1,N2+1);
pistar = zeros(N1+1,N2+1);
vstar = zeros(N1+1,N2+1);

for c1 = 0:N1
    for c2 = 0:N2
        ncars1(c1+1,c2+1) = c1;
        ncars2(c1+1,c2+1) = c2;
        % map number of cars in states
        state = sub2ind([N1+1, N2+1], c1+1, c2+1);
        pistar(c1+1,c2+1) = pi(state) - cars_moved - 1;
        vstar(c1+1,c2+1) = V(state);
    end
end

figure()
contourf(ncars1,ncars2,pistar,-cars_moved:cars_moved)

figure()
surf(ncars1,ncars2,vstar)
