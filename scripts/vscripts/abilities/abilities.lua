require( "abilities.base_build_ability" )
require( "abilities.base_spawn_ability" )
require( "buildings.rts_building_hq" )
require( "units.rts_unit_worker" )
require( "utils.abilities" )

RTS.Abilities.Base.RegisterSpawn( "rts_spawn_worker", RTS.Units.Worker )
RTS.Abilities.Base.RegisterBuild( "rts_build_hq", RTS.Buildings.HQ )

RTS.Abilities.RegisterAbility( "rts_destroy_tree", "OnSpellStart", function ( keys )
	Msg( "Killing tree\n" )
	RTS.Utils.KillTree( keys.target )
end )