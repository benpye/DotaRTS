require( "abilities.ability_handler")

if RTS.Abilities.Base == nil then
	RTS.Abilities.Base = {}
end

-- Basic building ability, uses a channel
function RTS.Abilities.Base.RegisterBuild( name, buildingClass )
	RTS.Abilities.RegisterAbility( name, "OnSpellStart", function ( keys )
		local caster = keys.caster
		local position = keys.target_points[1]
		local player = caster:GetOwner()
		local team = caster:GetTeamNumber()

		for _,building in pairs( RTS.Buildings.List ) do
			if building.Team == team
				and building.Complete == false
				and building.Player == player then
				-- There's an existing building, on our team, incomplete, really close, keep building
				if ( building.Entity:GetOrigin() - position ):Length() < 100 then
					building:ResumeBuilding( caster )
					return
				end
			end
		end

		local building = buildingClass( position, player, team )
		if building.Valid == true then
			building:ResumeBuilding( caster )
		else
			caster:InterruptChannel()
		end
	end )

	RTS.Abilities.RegisterAbility( name, "OnChannelInterrupted", function ( keys )
		for _,building in pairs( RTS.Buildings.List ) do
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