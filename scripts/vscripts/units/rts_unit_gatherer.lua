require( "units.rts_unit_base" )
require( "buildings.rts_building_hq" )
require( "utils.abilities" )

if RTS.Units.Gatherer == nil then
	RTS.Units.Gatherer = class({}, {}, RTS.Units.Base)
end

RTS.Units.Gatherer.BUILDTIME = 1.0
RTS.Units.Gatherer.TICKSIZE = 0.1
RTS.Units.Gatherer.UNIT = "npc_rts_unit_lumberjack"
RTS.Units.Gatherer.MAXCOUNT = -1
RTS.Units.Gatherer.TYPE = "RESOURCE_WOOD"
RTS.Units.Gatherer.INVENTORY = 100
RTS.Units.Gatherer.RATE = 50
RTS.Units.Gatherer.ABILITIES = {
	"rts_get_wood",
	"rts_deposit_resource"
}

RTS.Units.Gatherer.Resources = 0
RTS.Units.Gatherer.IsGathering = false

function RTS.Units.Gatherer:GatherResource( resource )
	self.CurrentResource = resource
	self.Resources = 0
	self.IsGathering = true
	self.Entity:SetThink( "Gathering", self, "gathering", self.TICKSIZE )
end

function RTS.Units.Gatherer:Gathering()
	if self.IsGathering == false then
		return nil
	end

	local newResources = self.Resources + self.RATE * self.TICKSIZE
	if newResources >= self.INVENTORY then
		newResources = self.INVENTORY
		self.IsGathering = false
	end

	local take = self.Resources - newResources
	-- CHeck if resource has the resources we are going to take
	self.Resources = newResources

	if self.IsGathering == false then
		local buildings = RTS.Buildings.GetByPlayer( self.Player, RTS.Buildings.HQ )
		local hq = buildings[ 1 ]

		local ability = RTS.Utils.GetAbilityByName( self.Entity, "rts_deposit_resource" )
		self.Entity:CastAbilityOnTarget( hq.Entity, ability, 0 )

		return nil
	else
		return self.TICKSIZE
	end
end

function RTS.Units.Gatherer:StopGathering()
	if self.IsGathering == true then
		self.IsGathering = false
	end
end