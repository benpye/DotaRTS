if RTS.Abilities == nil then
	RTS.Abilities = {}
end

function RTS.Abilities._onAbility( trigger, keys )
	local abilityName = keys.ability:GetAbilityName()

	if RTS.Abilities[abilityName] ~= nil then
		if RTS.Abilities[abilityName][trigger] ~= nil then
			RTS.Abilities[abilityName][trigger]( keys )
		end
	end
end

function RTS.Abilities.RegisterAbility( name, trigger, func )
	if RTS.Abilities[name] == nil then
		RTS.Abilities[name] = {}
	end

	RTS.Abilities[name][trigger] = func
end

function OnToggleOn( keys )
	RTS.Abilities._onAbility( "OnToggleOn", keys )
end

function OnToggleOff( keys )
	RTS.Abilities._onAbility( "OnToggleOff", keys )
end

function OnSpellStart( keys )
	RTS.Abilities._onAbility( "OnSpellStart", keys )
end

function OnOwnerDied( keys )
	RTS.Abilities._onAbility( "OnOwnerDied", keys )
end

function OnOwnerSpawned( keys )
	RTS.Abilities._onAbility( "OnOwnerSpawned", keys )
end

function OnProjectileHit( keys )
	RTS.Abilities._onAbility( "OnProjectileHit", keys )
end

function OnChannelSucceeded( keys )
	RTS.Abilities._onAbility( "OnChannelSucceeded", keys )
end

function OnChannelFinish( keys )
	RTS.Abilities._onAbility( "OnChannelFinish", keys )
end

function OnChannelInterrupted( keys )
	RTS.Abilities._onAbility( "OnChannelInterrupted", keys )
end