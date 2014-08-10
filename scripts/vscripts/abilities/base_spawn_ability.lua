require( "abilities.ability_handler" )
require( "abilities.channel_interrupt" )

if RTS.Abilities.Base == nil then
	RTS.Abilities.Base = {}
end

-- Basic building ability, uses a channel
function RTS.Abilities.Base.RegisterSpawn( name, spawnClass )
	RTS.Abilities.RegisterAbility( name, "OnSpellStart", function ( keys )
		local caster = keys.caster
		local position = keys.target_points[1]
		local player = caster:GetOwner()
		local team = caster:GetTeamNumber()

		local unit = spawnClass( position, player, team )
		if unit.Valid == true then
			unit:StartBuilding( caster )
		else
			RTS.Abilities.InterruptChannel( caster )
		end
	end )

	RTS.Abilities.RegisterAbility( name, "OnChannelInterrupted", function ( keys )
		for _,building in pairs( RTS.Units.List ) do
			-- Only one channel so this is our building
			if building.Caster == keys.caster and building:IsBuilding() then
				if building.Complete == false then
					building:StopBuilding()
				end
				break
			end
		end
	end )
end