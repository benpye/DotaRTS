if RTS.Resources == nil then
	RTS.Resources = {}
	RTS.Resources.Regions = {}
	RTS.Resources.List = {}
	RTS.Resources.Resource = class({})
end

function RTS.Resources._KVStringToVector( str )
	local split = vlua.split( str, " " )
	return { tonumber( split[ 1 ] ), tonumber( split[ 2 ] ) }
end

function RTS.Resources._VectorInRegion( vec, region )
	if vec.x >= region.Min[ 1 ] and vec.y >= region.Min[ 2 ] then
		if vec.x <= region.Max[ 1 ] and vec.y <= region.Max[ 2 ] then
			return true
		end
	end
	return false
end

function RTS.Resources.GetByEntity( ent )
	for _, resource in pairs( RTS.Resources.List ) do
		if resource.Entity == ent then
			return resource
		end
	end

	return nil
end

function RTS.Resources.Init()
	local resourceEntities = Entities:FindAllByClassname( "ent_dota_tree" )

	local kv = LoadKeyValues( "scripts/resources/" .. GetMapName() .. ".txt" )

	if kv == nil then
		Warning( "[RESOURCES] No resources defined for map " .. GetMapName() .. "\n" )
		return
	end


	for _, region in pairs( kv.ResourceRegions ) do
		local minVec = RTS.Resources._KVStringToVector( region.Min )
		local maxVec = RTS.Resources._KVStringToVector( region.Max )
		local res = region.Type

		table.insert( RTS.Resources.Regions, {
			Min = minVec,
			Max = maxVec,
			Resource = res
			})
	end

	for _, ent in pairs( resourceEntities ) do
		table.insert( RTS.Resources.List, RTS.Resources.Resource( ent ) )
	end
end

function RTS.Resources.Resource:constructor( ent )
	self.Origin = ent:GetOrigin()

	for k, region in pairs( RTS.Resources.Regions ) do
		if RTS.Resources._VectorInRegion( self.Origin, region ) then
			self.RegionID = k
			self.Type = region.Resource
			Msg( "Resource " .. self.Type .. " at " .. tostring( self.Origin ) .. "\n" )
		end
	end

	self.Entity = ent
	self.Units = 1000
end