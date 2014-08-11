require( "abilities.base_build_ability" )
require( "abilities.base_spawn_ability" )
require( "buildings.rts_building_hq" )
require( "units.rts_unit_worker" )

RTS.Abilities.Base.RegisterSpawn( "rts_spawn_worker", RTS.Units.Worker )
RTS.Abilities.Base.RegisterBuild( "rts_build_hq", RTS.Buildings.HQ )