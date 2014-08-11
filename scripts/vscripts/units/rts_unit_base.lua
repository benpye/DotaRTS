if RTS.Units == nil then
	RTS.Units = {}
	RTS.Units.List = {}
	RTS.Units.Base = class({})
end

-- Base unit class, provides simple building mechanic

RTS.Units.Base.BUILDTIME = 10.0
RTS.Units.Base.TICKSIZE = 0.1
RTS.Units.Base.UNIT = "npc_rts_unit_commander"
RTS.Units.Base.MAXCOUNT = -1
RTS.Units.Base.ABILITIES = {}
RTS.Units.Base.Valid = false
RTS.Units.Base.Complete = false
RTS.Units.Base._inProgress = false
RTS.Units.Base._completion = 0.0

function RTS.Units.Base:constructor( position, player, team )
	if self.MAXCOUNT ~= -1 then
		local existingCount = 0
		for _, unit in pairs(RTS.Units.List) do
			if unit.Player == player and unit.Team == team and unit.UNIT == self.UNIT then
				existingCount = existingCount + 1
			end
		end

		-- TODO: Better UI for too many of a unit
		if existingCount >= self.MAXCOUNT then
			GameRules:SendCustomMessage( "Unit cap reached", team, player:GetPlayerID() )
			return
		end
	end
	
	self._initialPosition = position

	self.Player = player
	self.Team = team

	-- Add self to list of units
	table.insert( RTS.Units.List, self )

	-- If we get this far, we're probably valid
	self.Valid = true
end

function RTS.Units.Base:DoComplete()
	self.Complete = true
	self._inProgress = false

	self.Entity = CreateUnitByName( self.UNIT, self._initialPosition, false,
					self.Player, self.Player, self.Team )

	self.Entity:SetControllableByPlayer( self.Player:GetPlayerID(), true )

	local item = CreateItem( "item_quelling_blade", nil, nil )
	self.Entity:AddItem( item )

	-- add correct "abilities" here
	for _,v in pairs( self.ABILITIES ) do
		self.Entity:AddAbility( v )
	end

	for i=0, self.Entity:GetAbilityCount(), 1 do
		local ability = self.Entity:GetAbilityByIndex( i )
		if ability == nil then
			break
		end
		ability:SetLevel( ability:GetMaxLevel() )
	end
end

function RTS.Units.Base:Building()
	-- If we stop building stop building
	if self._inProgress == false then
		return nil
	end

	local completionTick = 100.0 / ( self.BUILDTIME / self.TICKSIZE )
	local newCompletion = self._completion + completionTick
	if newCompletion >= 100.0 then
		self.Complete = true
		newCompletion = 100.0
	end

	self._completion = newCompletion

	if self.Complete == true then
		self:DoComplete()
		self.Caster:InterruptChannel()
		return nil
	end

	return self.TICKSIZE
end

function RTS.Units.Base:StopBuilding()
	self._inProgress = false

	for k,v in pairs( RTS.Units.List ) do
		if v == self then
			table.remove( RTS.Units.List, k )
			return
		end
	end
end

function RTS.Units.Base:StartBuilding( caster )
	self._inProgress = true
	self.Caster = caster
	self.Caster:SetThink( "Building", self, "building", self.TICKSIZE )
end

function RTS.Units.Base:IsBuilding()
	return self._inProgress
end