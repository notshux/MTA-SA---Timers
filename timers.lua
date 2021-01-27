local LuaTimers = {}

local _setTimer = setTimer
local _killTimer = killTimer 

function setTimer(theFunction, timeInterval, timesToExecute, ...)
    local theTimer = _setTimer(theFunction, timeInterval, timesToExecute, ...)
    if theTimer and isTimer(theTimer) then
        table.insert(LuaTimers,{theTimer=theTimer, theFunction=theFunction, timeInterval=timeInterval, timesToExecute=timesToExecute, arguments={...}})
        return theTimer
    end
    return false
end 

function killTimer(theTimer)
    local timerFound, tableValue, tableIndex = findTimer(theTimer)
    if timerFound then
        _killTimer(theTimer)
        LuaTimers[tableIndex] = nil
        return true
    end
    return false
end

function findTimer(theTimer)
    if theTimer and isTimer(theTimer) then
        for i,v in ipairs(LuaTimers) do 
            if v.theTimer == theTimer then
                return true, v, i
            end
        end
    elseif theTimer and LuaTimers[theTimer] then
        return true, LuaTimers[theTimer], theTimer
    end
    return false
end

function freezeTimer(theTimer)
    if theTimer and isTimer(theTimer) then

        local timerFound, tableValue, tableIndex = findTimer(theTimer)
        if timerFound then
            local remaining, executesRemaining, timeInterval = getTimerDetails(theTimer)
            _killTimer(theTimer)

            LuaTimers[tableIndex].timeInterval = remaining
            LuaTimers[tableIndex].timesToExecute = executesRemaining

            return true
        end
    end
    return false
end

function unfreezeTimers(theFunction)
    local timersUnfrozen = {}
    if theFunction then
        for i,v in ipairs(LuaTimers) do
            if v.theFunction == theFunction then
                if not isTimer(v.theTimer) then
                    local timerPointer = _setTimer(LuaTimers[i].theFunction, LuaTimers[i].timeInterval, LuaTimers[i].timesToExecute, unpack(LuaTimers[i].arguments))
                    if timerPointer then
                        LuaTimers[i].theTimer = timerPointer
                        timersUnfrozen[#timersUnfrozen+1] = #timersUnfrozen + 1
                    end
                end 
            end 
        end 
    end
    if #timersUnfrozen > 0 then
        return true
    else
        return false
    end
end
