if RTS.Utils == nil then
	RTS.Utils = {}
end

if RTS.Utils.Timer == nil then
	RTS.Utils.Timer = {}
end


function RTS.Utils.Timer.Init()
	local GameMode = GameRules:GetGameModeEntity()

	-- Register Think
	GameMode:SetContextThink( "RTS.Utils.Timer.Think", RTS.Utils.Timer.Think, 0.1 )

	RTS.Utils.Timer._counter = 0.0
	RTS.Utils.Timer._functions = {}
end

function RTS.Utils.Timer.Think()
	RTS.Utils.Timer._counter = RTS.Utils.Timer._counter + 0.1

	for i = #RTS.Utils.Timer._functions, 1, -1 do
		local func = RTS.Utils.Timer._functions[ i ]
		if func.timer <= RTS.Utils.Timer._counter then
			local nextTime = func.func()
			if nextTime == nil then
				table.remove( RTS.Utils.Timer._functions, i )
			else
				func.timer = RTS.Utils.Timer._counter + nextTime
			end
		end
	end

	return 0.1
end

function RTS.Utils.Timer.Register( func, delay )
	table.insert( RTS.Utils.Timer._functions, { func = func, timer = RTS.Utils.Timer._counter + delay } )
end