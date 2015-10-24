function [h] = setupNXT()
% Resets NXT and opens connection
COM_CloseNXT('all');
close all
clear
h = COM_OpenNXT();
COM_SetDefaultNXT(h)
%NXT_PlayTone(450, 500);
end

