if RTS.Buildings == nil then
	RTS.Buildings = {}
	RTS.Buildings.List = {}
	RTS.Buildings.Base = class({})
end

-- Base building class, provides simple building mechanic

RTS.Buildings.Base.BUILDTIME = 1.0
RTS.Buildings.Base.TICKSIZE = 0.1
RTS.Buildings.Base.UNIT = "npc_rts_building_hq"
RTS.Buildings.Base.MAXCOUNT = -1
RTS.Buildings.Base.Valid = false
RTS.Buildings.Base.Complete = false
RTS.Buildings.Base._inProgress = false

function RTS.Buildings.Base:constructor( position, player, team )
	if self.MAXCOUNT ~= -1 then
		local existingCount = 0
		for _, building in pairs(RTS.Buildings.List) do
			if building.Player == player and building.Team == team and building.UNIT == self.UNIT then
				existingCount = existingCount + 1
			end
		end

		-- TODO: Better UI for too many of a unit
		if existingCount >= self.MAXCOUNT then
			GameRules:SendCustomMessage( "Unit cap reached", team, player:GetPlayerID() )
			return
		end
	end

	self.Player = player
	self.Team = team
	self.Entity = CreateUnitByName( self.UNIT, position, false,
					self.Player, self.Player, self.Team )

	self.Entity:SetInvulnCount( 0 )
	self.Entity:SetHealth( 1 )

	self.Entity:AddAbility( "rts_building_incomplete" )

	-- Add self to list of buildings
	table.insert( RTS.Buildings.List, self )

	-- If we get this far, we're probably valid
	self.Valid = true
end

function RTS.Buildings.Base:Building()
	-- If we stop building stop building
	if self._inProgress == false then
		return nil
	end

	local maxHealth = self.Entity:GetMaxHealth()
	local healthTick = maxHealth / ( self.BUILDTIME / self.TICKSIZE )
	local curHealth = self.Entity:GetHealth()
	local newHealth = curHealth + healthTick
	if newHealth > maxHealth then
		self.Complete = true
		newHealth = maxHealth
	end
	self.Entity:SetHealth( newHealth )

	if self.Complete == true then
		-- Building is being built, not repaired
		if self.Entity:HasAbility( "rts_building_incomplete" ) then
			self.Entity:RemoveAbility( "rts_building_incomplete" )
		end

		self.Caster:InterruptChannel()
		self._inProgress = false
		-- add correct "abilities" here
		return nil
	end

	return self.TICKSIZE
end

function RTS.Buildings.Base:StopBuilding()
	self._inProgress = false
end

function RTS.Buildings.Base:ResumeBuilding( caster )
	self._inProgress = true
	self.Caster = caster
	self.Entity:SetThink( "Building", self, "building", self.TICKSIZE )
end

function RTS.Buildings.Base:IsBuilding()
	return self._inProgress
end