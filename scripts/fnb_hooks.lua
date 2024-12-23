if not game:IsLoaded() then game.Loaded:Wait() end

local getnamecallmethod= getnamecallmethod;
local getcallingscript = getcallingscript;
local hookmetamethod   = hookmetamethod;
local checkcaller      = checkcaller;
local hookfunction     = hookfunction;
local coroutine        = coroutine;
local genv             = getgenv();
local type             = type;
local game             = game;
local task             = task;

-- Create console if it doesn't exist
if not rconsolecreate then
    rconsolecreate = function() end
    rconsoleprint = function() end
end

-- Initialize console
rconsolecreate()
rconsoleprint("@@LIGHT_CYAN@@")
rconsoleprint("Note Logger Initialized\n")

if not getgenv().IsAnimeFan then
    local creating_methods = { ["getService"] = true, ["GetService"] = true };
    local indexing_methods = {
        ["FindService"] = true,
        ["findService"] = true,
        
        ["FindService"] = true,
        ["findService"] = true,
        
        ["FindFirstChild"] = true,
        ["findFirstChild"] = true,
        
        ["FindFirstChildOfClass"] = true,
        ["findFirstChildOfClass"] = true,
        
        ["FindFirstChildWhichIsA"] = true,
        ["findFirstChildWhichIsA"] = true
    };
    
    local service = "VirtualInputManager";
    local created = false;
    
    local __namecall, __index, __newindex;
    
    -- Track last note time to prevent duplicate logs
    local lastNoteTime = 0
    local function logNote(judgment)
        local currentTime = tick()
        if currentTime - lastNoteTime > 0.05 then  -- 50ms debounce
            rconsoleprint("@@" .. (judgment == "Marvelous" and "LIGHT_GREEN@@" or 
                         judgment == "Sick" and "GREEN@@" or 
                         judgment == "Good" and "YELLOW@@" or 
                         judgment == "Ok" and "LIGHT_RED@@" or 
                         judgment == "Bad" and "RED@@" or 
                         "DARK_RED@@"))
            rconsoleprint(string.format("[%s] Hit registered\n", judgment))
            lastNoteTime = currentTime
        end
    end
    
    if not getvirtualinputmanager then
        __namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...};

            if (self == game) and (args[1] == service) and not checkcaller() then
                local method = getnamecallmethod();

                if indexing_methods[ method ] and not created then
                    return nil;
                end;

                if creating_methods[ method ] then
                    created = true;
                end;
            end;

            return __namecall(self, ...)
        end );

        __index = hookmetamethod(game, "__index", function(table, index)
            if (not checkcaller()) and (table == game) and (index == service) then
                created = true;
            end

            return __index(table, index);
        end );
    end
    
    __newindex = hookmetamethod(game, "__newindex", function(...)
        local args = {...}
        local index = args[2]
        
        -- Log note judgments
        if typeof(args[1]) == "Instance" and args[1]:IsA("StringValue") and 
           args[1].Name == "Judgment" and not checkcaller() then
            local judgment = args[3]
            if judgment then
                logNote(judgment)
            end
        end
        
        if (index == "Health") and (not checkcaller()) and (getcallingscript().Name == "Client") then
            return;
        end;
        
        return __newindex(...);
    end );
    
    --
    -- hooking functions
    --
    
    if not getvirtualinputmanager then
        for method, v in pairs(indexing_methods) do
            indexing_methods[method] = hookfunction(game[method], function(self, ...)
                local args = {...};

                if self == game and (args[1] == service) and not checkcaller() and not created then
                    return;
                end

                return indexing_methods[method](self, ...);
            end );
        end;

        for method, v in pairs(creating_methods) do
            creating_methods[method] = hookfunction(game[method], function(self, ...)
                if self == game and (... == service) and not checkcaller() then
                    created = true;
                end;

                return creating_methods[method](self, ...);
            end );
        end;
    end
    
    --
    
    genv.IsAnimeFan = true;
end
