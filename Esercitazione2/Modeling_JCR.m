clear all
close all
clc

% number of cars at each location
N1 = 30;
N2 = 30;

% parameters
gain = 10;
cost = 2;

% discount parameter
gamma = 0.9;

% max moved cars
cars_moved = 7;

% number of actions available
A = 2*cars_moved + 1;

% dimension of state space
S = (N1+1)*(N2+1);

% Poisson distribution
cars1 = 0:N1;
cars2 = 0:N2;
% Generate Poisson distribution for arrivals and rentals
lambda1R = 3;
dist1R = lambda1R.^cars1./factorial(cars1)*exp(-lambda1R);
% Ensure that the probability sum to 1
dist1R(end) = 1 - sum(dist1R(1:end-1)); 
lambda2R = 4;
dist2R = lambda2R.^cars2./factorial(cars2)*exp(-lambda2R);
dist2R(end) = 1 - sum(dist2R(1:end-1)); 
lambda1A = 3;
dist1A = lambda1A.^cars1./factorial(cars1)*exp(-lambda1A);
% Ensure that the probability sum to 1
dist1A(end) = 1 - sum(dist1A(1:end-1)); 
lambda2A = 2;
dist2A = lambda2A.^cars2./factorial(cars2)*exp(-lambda2A);
dist2A(end) = 1 - sum(dist2A(1:end-1)); 

figure()
tiledlayout(2,1)

ax1 = nexttile();
hold on
stairs(cars1,dist1R,'LineWidth',2)
stairs(cars2,dist2R,'LineWidth',2)
title('Rental requests probability')
xlabel('Cars')

ax2 = nexttile();
hold on
stairs(cars1,dist1A,'LineWidth',2)
stairs(cars2,dist2A,'LineWidth',2)
title('Rental requests')
title('Returns probability')
xlabel('Cars')

%%
% construct the transition matrix from number of cars to number of cars
% after adding the cars returned at the previous day

% we consider the two locations disjointly

% location 1
PA1 = zeros(S,S);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars at each location after return
    nc1 = min([c1 + cars1; N1*ones(1,N1+1)], [], 1);
    nc2 = c2;
    for j = 1:length(nc1)
        % map number of cars in states
        sp = sub2ind([N1+1, N2+1], nc1(j)+1, nc2+1);
        PA1(s,sp) = PA1(s,sp) + dist1A(j);
    end
end

% location 2
PA2 = zeros(S,S);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars at each location after return
    nc1 = c1;
    nc2 = min([c2 + cars2; N2*ones(1, N2+1)], [], 1);
    for j = 1:length(nc2)
        % map number of cars in states
        sp = sub2ind([N1+1, N2+1], nc1+1, nc2(j)+1);
        PA2(s,sp) = PA2(s,sp) + dist2A(j);
    end
end

% sanity check
max(abs(sum(PA1, 2) - 1))
max(abs(sum(PA2, 2) - 1))
norm(PA1*PA2 - PA2*PA1)

% transition matrix from end-day to after return
PA = PA1*PA2;

%%

% construct the transition matrix from number of cars to number of cars
% at the beginning of the day to the cars available after rental

% we can consider the locations disjointly

% location 1
PR1 = zeros(S,S);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars after rental
    nc1 = max([c1 - cars1; zeros(1, N1+1)], [], 1);
    nc2 = c2;
    for j = 1:length(nc1)
        % map number of cars in states
        sp = sub2ind([N1+1, N2+1], nc1(j)+1, nc2+1);
        PR1(s,sp) = PR1(s,sp) + dist1R(j);
    end
end

% location 2
PR2 = zeros(S,S);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars after rental
    nc1 = c1;
    nc2 = max([c2 - cars2; zeros(1,N2+1)], [], 1);
    for j = 1:length(nc2)
        % map number of cars in states
        sp = sub2ind([N1+1, N2+1], nc1+1, nc2(j)+1);
        PR2(s,sp) = PR2(s,sp) + dist2R(j);
    end
end

% sanity check
max(abs(sum(PR1, 2) - 1))
max(abs(sum(PR2, 2) - 1))
norm(PR1*PR2 - PR2*PR1)

% transition matrix from after return to after rental
PR = PR1*PR2;

% note that the two events are not interchangable
norm(PR*PA - PA*PR) % not zero
max(abs(sum(PR*PA, 2)-1))
max(abs(sum(PA*PR, 2)-1))

%%

% construct transition matrix for the Jack's action

PJ = zeros(S,S,A);
for s = 1:S % sweep over states
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    for a = 1:A % sweep over actions
        % map action in number of cars moved from 1 to 2
        c_mov = max(min(a - cars_moved - 1,c1),-c2);
        % actually move cars
        nc1 = min(max(c1 + c_mov, 0), N1);
        nc2 = min(max(c2 - c_mov, 0), N2);
        % map number of cars in states
        sp = sub2ind([N1+1, N2+1], nc1+1, nc2+1);
        % next state is deterministic
        PJ(s,sp,a) = 1;
    end
end

%%
% compute overall transition matrix
P = zeros(S,S,A);
for a = 1:A
    P(:,:,a) = PJ(:,:,a)*PA*PR;
    % sanity check
    disp([a, max(abs(sum(P(:,:,a),2)-1))]);
end

% construct reward matrix
R = zeros(S,A);

% inspect what happens if the state was the number of cars after return

% location 1
Ec1 = zeros(S,1);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars after rental
    nc1 = max([c1 - cars1; zeros(1, N1+1)], [], 1);
    nc2 = c2;
    % rented cars
    rc1 = c1 - nc1;
    % expected cars
    Ec1(s) = rc1*dist1R';
end

% location 2
Ec2 = zeros(S,1);
for s = 1:S
    % map state in number of cars at the two locations
    [c1, c2] = ind2sub([N1+1, N2+1],s);
    c1 = c1 - 1;
    c2 = c2 - 1;
    % new number of cars after rental
    nc1 = c1;
    nc2 = max([c2 - cars2; zeros(1, N2+1)], [], 1);
    % rented cars
    rc2 = c2 - nc2;
    % expected cars
    Ec2(s) = rc2*dist2R';
end

% total expected value of number of cars if the state was 
% the number of cars after return
EC = Ec1 + Ec2;

% parity check
disp(max(EC))

% compute the expected number of cars after movement
% return cars of the previous day -> rent new cars
EC2 = PA*EC;

% compute the expected number of cars before movement (that is our state)
% using again the same logic
R = zeros(S,A);
for s = 1:S
    for a = 1:A
        % map action in number of cars moved from 1 to 2
        c_mov = a - cars_moved - 1;
        expected_rented_cars = PJ(s,:,a)*EC2;
        R(s,a) = gain*expected_rented_cars - cost*abs(c_mov);
    end
end

% save model
save modelJCR.mat P R gamma