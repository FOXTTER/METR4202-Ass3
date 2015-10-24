function [ error ] = moveEngine( engine, power, angle)
%Function moves the specified engine
error = 0;
if (abs(angle) <= 1)
    disp('Angle is 0');
    return
end
engine.TachoLimit = abs(angle); % Angle for motor A
engine.Power = power * sign(angle);
engine.ActionAtTachoLimit = 'Holdbrake';
engine.SendToNXT();
end

