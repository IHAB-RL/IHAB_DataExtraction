classdef BlindProgressCommandLine < handle
    
    properties
        sItems = '|/-\';
        targetObj;
        sLast = '-';
        t;
    end
    
    methods
        
        function [obj] = BlindProgressCommandLine()
           
            obj.t = timer();
            obj.t.StartDelay = 0;
            obj.t.ExecutionMode = 'fixedRate';
            obj.t.Period = 0.2;
            obj.t.TimerFcn = @obj.startCallback;
            obj.t.StopFcn = @obj.stopCallback;
            
        end
        
        function [] = stopTimer(obj, ~, ~)
            
            if strcmp(obj.t.Running, 'on')
                stop(obj.t);
            end
            
        end
        
        function [] = startTimer(obj, ~, ~)
            
            if strcmp(obj.t.Running, 'off')
                start(obj.t);
            end
            
        end
        
        function [] = killTimer(obj, ~, ~)
            
            obj.stopTimer();
            delete(obj.t);
         
        end
        
        function [] = stopCallback(obj, ~, ~)
            
            fprintf('\b\n');
            
        end
        
        function [] = startCallback(obj, ~, ~)
            
            switch obj.sLast
                
                case obj.sItems(1)
                    obj.sLast = obj.sItems(2);
                case obj.sItems(2)
                    obj.sLast = obj.sItems(3);
                case obj.sItems(3)
                    obj.sLast = ['\', obj.sItems(4)];
                case ['\', obj.sItems(4)]
                    obj.sLast = obj.sItems(1);
                    
            end
            
            fprintf(['\b', obj.sLast]);
            
        end
        
    end
    
end