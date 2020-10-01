function [x] = mel2hz(Mel)
% function to get Mel in Hz
% Usage [x] = mel2hz(Mel)
%
% Parameters
% ----------
% Mel - frequency in Mel (vectors possible)
%
% Returns
% -------
% x - frequency in Hz 
%
% Author: Jule Pohlhausen 
% 28-05-2020 

x = (10.^(Mel./2595) - 1) * 700;