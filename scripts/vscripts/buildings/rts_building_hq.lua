require( "buildings.rts_building_base" )

if RTS.BuildingHQ == nil then
	RTS.BuildingHQ = class({}, {}, RTS.BuildingBase)
end

RTS.BuildingHQ.BUILDTIME = 10.0
RTS.BuildingHQ.TICKSIZE = 0.1
RTS.BuildingHQ.UNIT = "npc_rts_building_hq"