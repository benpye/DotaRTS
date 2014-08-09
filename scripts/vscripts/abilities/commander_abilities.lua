require( "abilities.ability_handler")
require( "buildings.rts_building_hq" )

RTS.Abilities.RegisterAbility( "rts_commander_build_hq", "OnSpellStart", function ( keys )
	local caster = keys.caster
	local position = keys.target_points[1]
	local player = caster:GetOwner()
	local team = caster:GetTeamNumber()

	for _,building in pairs( RTS.BuildingList ) do
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

	local hq = RTS.BuildingHQ( position, player, team )
	hq:ResumeBuilding( caster )
end )

RTS.Abilities.RegisterAbility( "rts_commander_build_hq", "OnChannelInterrupted", function ( keys )
	for _,building in pairs( RTS.BuildingList ) do
		-- Only one channel so this is our building
		if building.Caster == keys.caster and building:IsBuilding() then
			if building.Complete == false then
				building:StopBuilding()
			end
			break
		end
	end
end )