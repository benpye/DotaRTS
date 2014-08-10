require( "abilities.ability_handler" )

if RTS.Abilities._castersToInterrupt == nil then
	RTS.Abilities._castersToInterrupt = {}
end

function RTS.Abilities.InterruptChannelInit()
	GameRules:GetGameModeEntity():SetContextThink( "RTS.Abilities._interruptThink",
		RTS.Abilities._interruptThink, 0.1 )
end

function RTS.Abilities.InterruptChannel( caster )
	table.insert( RTS.Abilities._castersToInterrupt, caster )
end

function RTS.Abilities._interruptThink()
	for _, caster in pairs(RTS.Abilities._castersToInterrupt) do
		caster:InterruptChannel()
	end

	RTS.Abilities._castersToInterrupt = {}

	return 0.1
end