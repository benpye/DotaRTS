require( "abilities.base_build_ability" )
require( "abilities.base_spawn_ability" )
require( "buildings.rts_building_base" )
require( "buildings.rts_building_hq" )
require( "buildings.rts_building_barracks" )
require( "units.rts_unit_base" )
require( "units.rts_unit_worker" )
require( "units.rts_unit_gatherer" )
require( "units.rts_unit_soldier" )
require( "rts_resource_manager" )

RTS.Abilities.Base.RegisterSpawn( "rts_spawn_worker", RTS.Units.Worker )
RTS.Abilities.Base.RegisterSpawn( "rts_spawn_lumberjack", RTS.Units.Gatherer )
RTS.Abilities.Base.RegisterSpawn( "rts_spawn_soldier", RTS.Units.Soldier )

RTS.Abilities.Base.RegisterBuild( "rts_build_hq", RTS.Buildings.HQ )
RTS.Abilities.Base.RegisterBuild( "rts_build_barracks", RTS.Buildings.Barracks )

RTS.Abilities.RegisterAbility( "rts_get_wood", "OnSpellStart", function ( keys )
	local caster = keys.caster
	local gatherer = RTS.Units.GetByEntity( caster )
	local player = caster:GetOwner()
	local team = caster:GetTeamNumber()

	local tree = keys.target
	if tree == nil then
		local treeorigin = keys.target_points[ 1 ] 
		local ents = Entities:FindAllByClassnameWithin( "ent_dota_tree", treeorigin, 1 )

		if #ents == 0 then
			if gatherer.CurrentResource ~= nil then
				gatherer:GoAndGather( gatherer.CurrentResource )
			else
				GameRules:SendCustomMessage( "Not a valid target!", team, player:GetPlayerID() )
			end
			return
		end

		tree = ents[ 1 ]
	end

	local unit = RTS.Units.GetByEntity( caster )
	local resource = RTS.Resources.GetByEntity( tree )

	if unit.TYPE ~= resource.Type then
		GameRules:SendCustomMessage( "Wrong resource!", team, player:GetPlayerID() )
		RTS.Utils.Timer.Register( function() caster:InterruptChannel() end, 0.1 )
	else
		unit:GatherResource( resource )
	end
	end )

RTS.Abilities.RegisterAbility( "rts_get_wood", "OnChannelInterrupted", function ( keys )
	local caster = keys.caster
	local tree = keys.target
	local player = caster:GetOwner()
	local team = caster:GetTeamNumber()
	local unit = RTS.Units.GetByEntity( caster )
	local resource = RTS.Resources.GetByEntity( tree )

	unit:StopGathering()
	end )

RTS.Abilities.RegisterAbility( "rts_deposit_resource", "OnSpellStart", function ( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetOwner()
	local team = caster:GetTeamNumber()
	local unit = RTS.Units.GetByEntity( caster )
	local hq = RTS.Buildings.GetByEntity( target )
	if hq.UNIT ~= "npc_rts_building_hq" then
		GameRules:SendCustomMessage( "Wrong building!", team, player:GetPlayerID() )
		return
	end

	local gatherer = RTS.Units.GetByEntity( caster )
	gatherer:DepositResource()

	if gatherer.CurrentResource ~= nil then
		gatherer:GoAndGather( gatherer.CurrentResource )
	end
	end )