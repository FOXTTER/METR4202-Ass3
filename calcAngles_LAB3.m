function [ alpha, beta, gamma ] = calcAngles_LAB3(start, desired)
%calcAngles Summary of this function goes here
% Lego unit conversion 4 dots = one big square
%Motor gearing
mA_gear = 36/12;
mB_gear = 36/12;
mC_gear = 36/12;
%Lengths of robot
a2b = 0.170; %length first joint A to second joint B
b2c = 0.116; %length second joint B to third joint C
c2d = 0.21; %length third joint C to tip (called D)
c2ground = 0.156; %height third joint C to surface

% T length
a2d_new = norm([desired(1),desired(2)]);
a2d_old = norm([start(1),start(2)]);
% Calculations
% Gamma = third joint
gamma = int32(rad2deg(acos((c2ground-desired(3))/c2d)-acos((c2ground-start(3))/c2d))*mC_gear);
% Beta = second joint
phi_d = @(T, offZ) acos(((b2c+sqrt(c2d^2-(c2ground - offZ)^2))^2 + a2b^2 - T^2)/(2*(b2c+sqrt(c2d^2-(c2ground - offZ)^2))*a2b));
beta = int32(rad2deg(phi_d(a2d_new,desired(3))-phi_d(a2d_old,start(3)))*mB_gear);
% Alpha = first joint
phi_e = @(T, offZ) acos((a2b^2+T^2-(b2c+sqrt(c2d^2-(c2ground - offZ)^2))^2)/(2*a2b*T));
phi_f = @(x,y) atan2(y,x);
alpha  = int32(rad2deg((-phi_e(a2d_new,desired(3)) + phi_f(desired(1),desired(2))) - (-phi_e(a2d_old, start(3)) + phi_f(start(1),start(2))))*mA_gear);
end