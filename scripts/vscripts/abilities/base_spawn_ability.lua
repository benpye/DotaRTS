require( "abilities.ability_handler" )
require( "units.rts_unit_base" )
require( "utils.timer" )

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
			RTS.Utils.Timer.Register( function() caster:InterruptChannel() end, 0.25 )
		end
	end )

	RTS.Abilities.RegisterAbility( name, "OnChannelInterrupted", function ( keys )
		for _,unit in pairs( RTS.Units.List ) do
			-- Only one channel so this is our unit
			if unit.Caster == keys.caster and unit:IsBuilding() then
				if unit.Complete == false then
					unit:StopBuilding()
				end
				break
			end
		end
	end )
end