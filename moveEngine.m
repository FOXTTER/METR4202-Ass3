function [ error ] = moveEngine( engine, power, angle, alpha_old )
%Function moves the specified engine
error = 0;
if (abs(angle) <= 1)
    disp('Angle is 0');
    return
end
port = engine.Port;
if (port ==0)
    % play compensation of motor A - Start has to be with positiv alpha
    % No play at first motion
    if (sign(angle) == sign(alpha_old)) && (alpha_old~=0)
        angle = angle + 0;
    elseif (sign(angle) ~= sign(alpha_old)) && (alpha_old~=0)
        angle = angle + 4 * sign(angle);
    end
elseif (port == 1) % Error compensation for the other engines
    % No compensation for B
    if(angle > 2)
        angle = angle + (0);
    elseif (angle < -2)
        angle = angle + (0);
    end
elseif (port == 2)
    % Little compensation for C
    if(angle > 1)
        angle = angle + (0);
    elseif (angle < 0)
        angle = angle + (1);
    end
end
engine.TachoLimit = abs(angle); % Angle for motor A
engine.Power = power * sign(angle);
engine.ActionAtTachoLimit = 'Holdbrake';
engine.SendToNXT();
end

