if RTS.Utils == nil then
	RTS.Utils = {}
end

if RTS.Utils.Abilities == nil then
	RTS.Utils.Abilities = {}
end

function RTS.Utils.Abilities.Init()
	RTS.Utils.Abilities._internalUnit = CreateUnitByName( "npc_rts_internal_ability_unit", Vector( 10000, 0, 10000 ), false, nil, nil, DOTA_TEAM_NOTEAM )
	RTS.Utils.Abilities._internalUnit:AddNewModifier( npc, nil, "modifier_invulnerable", {} )
	RTS.Utils.Abilities._internalUnit:AddNoDraw()
	RTS.Utils.Abilities._internalUnit:AddAbility( "rts_internal_destroy_tree" )
	RTS.Utils.Abilities._abilities = {}

	for i=0, RTS.Utils.Abilities._internalUnit:GetAbilityCount(), 1 do
		local ability = RTS.Utils.Abilities._internalUnit:GetAbilityByIndex( i )
		if ability == nil then
			break
		end
		ability:SetLevel( ability:GetMaxLevel() )
		RTS.Utils.Abilities._abilities[ ability:GetAbilityName() ] = ability
	end
end

function RTS.Utils.KillTree( tree )
	local ability = RTS.Utils.Abilities._abilities[ "rts_internal_destroy_tree" ]
	RTS.Utils.Abilities._internalUnit:CastAbilityOnPosition( tree:GetOrigin(), ability, 0 )
end

function RTS.Utils.GetAbilityByName( entity, str )
	for i=0, entity:GetAbilityCount(), 1 do
		local ability = entity:GetAbilityByIndex( i )
		if ability ~= nil then
			if ability:GetAbilityName() == str then
				return ability
			end
		end
	end

	return nil
end