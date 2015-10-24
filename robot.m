clc
%clear

[h] = setupNXT();
mA = NXTMotor('A', 'Power', -10);
mB = NXTMotor('B', 'Power', -10);
mC = NXTMotor('C', 'Power', -10);
mA.SpeedRegulation = true;
mB.SpeedRegulation = true;
mC.SpeedRegulation = true;
M = importdata('coords.txt');
disp('Put robot arm in desired position and press enter')
pause
mA.Stop('Brake');
mB.Stop('Brake');
mC.Stop('Brake');
disp('Press enter to start')
pause
% Initial point

current = [0.06 0.13 0];
alpha_error = 0;
beta_error = 0;
gamma_error = 0;
enginePowerA = 15;
enginePowerB = -15;
enginePowerC = 30;
i = 1;
mB.ResetPosition();
M = realPath;
while(i < size(M,1))
    fprintf('Point: %d\n',i);
    disp(M(i,:,:))
    desired = M(i,:,:);
    %Convert the point to angles for the motors
    [alpha, beta, gamma] = calcAngles_LAB3(current, desired);
    fprintf('Angles (a,b,g) = (%d, %d, %d)\n',alpha,beta,gamma);
    
    % First move engine B up then do the rest of the moves
    moveEngine(mA,enginePowerA,alpha);
    moveEngine(mC,enginePowerC,gamma);
    moveEngine(mB,enginePowerB, beta);
    mA.WaitFor();
    mC.WaitFor();
    mB.WaitFor();
    %Update current position
    current = desired;
    %Wrap around the points
    pause(1);
    i = mod(i,length(M(:,1)))+1;
end
