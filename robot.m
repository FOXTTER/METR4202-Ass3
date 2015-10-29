clc
% Task number
task = 4;
%%%%%%%%%%%%%%%%%%%%%%%%
clear M
[h] = setupNXT();
mA = NXTMotor('A', 'Power', -10);
mB = NXTMotor('B', 'Power', -10);
mC = NXTMotor('C', 'Power', -10);
mA.SpeedRegulation = true;
mB.SpeedRegulation = true;
mC.SpeedRegulation = true;
disp('Put robot arm in desired position and press enter')
mA.Stop('Brake');
mB.Stop('Brake');
mC.Stop('Brake');
disp('Press enter to start')
% Initial point
current = [0.06 0.13 0.01]; % Initial point of tip
alpha_error = 0;
beta_error = 0;
gamma_error = 0;
enginePowerA = 15;
enginePowerB = -15;
enginePowerC = 30;
i = 1;
mB.ResetPosition();
if (task == 1)
    M = realPath; 
    safeAngle = 0;
elseif (task == 2)
    M = importdata('coords.txt'); 
    %M = expandPath(M);
    safeAngle = 200;
    M(:,3) = M(:,3)+0.03;
elseif (task == 3)
    M(1,:) = current + [0.05 0.05 0.12];
    M(2,:) = realPos/1000 + [0 0 0.12]';
    M(3,:) = realPos/1000 + [0 0 -0.02]';
    M(4,:) = M(2,:);
    safeAngle = 0;
elseif (task == 4) %% And task 5
    %M = [(current + [0.05 0.05 0.1]); realPath]; % Task 4
    M = path4; % Task 5
    M(:,2) = M(:,2) - 0.02;
    M = [M(1,:) + [0 0 0.07]; M];
    M = [M; [0.06 0.13 0]];
    safeAngle = 200;
else
end
while(i <= size(M,1))
    fprintf('Point: %d\n',i);
    disp(M(i,:))
    desired = M(i,:);
    %Convert the point to angles for the motors
    [alpha, beta, gamma] = calcAngles_LAB3(current, desired);
    fprintf('Angles (a,b,g) = (%d, %d, %d)\n',alpha,beta,gamma);
    
    % First move engine C up then do the rest of the moves
    moveEngine(mC,enginePowerC,safeAngle);
    mC.WaitFor();
    moveEngine(mA,enginePowerA,alpha);
    moveEngine(mB,enginePowerB, beta);
    moveEngine(mC,enginePowerC,gamma-safeAngle);
    mA.WaitFor();
    mB.WaitFor();
    mC.WaitFor();
    %Update current position
    current = desired;
    %Wrap around the points
    if (task == 1)
        i = i + 1;
    elseif (task ==2)
        i = i + 1;
    elseif(task == 3) 
        i = i +1;
    elseif(task == 4)
        i = i + 1;
        safeAngle = 0;
        if(i == size(M,1))
            safeAngle = 200;
        end
    else
        i = mod(i,length(M(:,1)))+1;
    end
end
setupNXT();
