if RTS.Utils == nil then
	RTS.Utils = {}
end

if RTS.Utils.Timer == nil then
	RTS.Utils.Timer = {}
end


function RTS.Utils.Timer.Init()
	local GameMode = GameRules:GetGameModeEntity()

	RTS.Utils.Timer._functions = {}

	RTS.Utils.Timer._counter = GameRules:GetGameTime()
end

function RTS.Utils.Timer.Think( time )
	RTS.Utils.Timer._counter = time

	for i = #RTS.Utils.Timer._functions, 1, -1 do
		local func = RTS.Utils.Timer._functions[ i ]
		if func.timer <= time then
			local nextTime = func.func()
			if nextTime == nil then
				table.remove( RTS.Utils.Timer._functions, i )
			else
				func.timer = RTS.Utils.Timer._counter + nextTime
			end
		end
	end
end

function RTS.Utils.Timer.Register( func, delay )
	table.insert( RTS.Utils.Timer._functions, { func = func, timer = RTS.Utils.Timer._counter + delay } )
end