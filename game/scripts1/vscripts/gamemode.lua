
if GameMode == nil then
	_G.GameMode = class({})
end

item_drop = {
		{items = {}, chance = 5, duration = 5, count = 3, units = {} },
		{items = {"item_name1"}, units = {"aaa","bbb","ccc"} },--100% drop
		{items = {"item_name2"}, chance = 50, units = {"ddd","eee","fff"} },--100% drop from list
		{items = {"item_name3"}, chance = 5 },
}

function GameMode:InitGameMode()
	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)

end


function GameMode:OnEntityKilled( keys )
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local name = killedUnit:GetUnitName()
	local team = killedUnit:GetTeam()

	if team == DOTA_TEAM_NEUTRALS and name ~= "npc_dota_thinker" then
		RollItemDrop(killedUnit)
	end

end

function RollItemDrop(unit)
	local unit_name = unit:GetUnitName()

	for _,drop in ipairs(item_drop) do
		local items = drop.items or nil
		local items_num = #items
		local units = drop.units or nil -- если юниты не были определены, то срабатывает для любого
		local chance = drop.chance or 100 -- если шанс не был определен, то он равен 100
		local duration = drop.duration or nil -- длительность жизни предмета на земле
		local item_name = items[1]

		if (units and units[unit_name]) or units == nil then
			if items_num > 1 then
				item_name = items[RandomInt(1, #items)]
			end

			local spawnPoint = unit:GetAbsOrigin()	
			local newItem = CreateItem( item_name, nil, nil )
			local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
			local dropRadius = RandomFloat( 50, 100 )

			newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
			if loot_duration then
				newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, loot_duration )
			end
		end
	end	
end

function KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
--	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

GameMode:InitGameMode()