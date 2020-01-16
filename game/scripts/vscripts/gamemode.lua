
if GameMode == nil then
	_G.GameMode = class({})
end

item_drop = {
--		{items = {"item_branches"}, chance = 5, duration = 5, limit = 3, units = {} },
		{items = {"item_branches"}, limit = 10, duration = 10, units = {"npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner"} },--100% drop from list with limit and timer
		{items = {"item_belt_of_strength","item_boots_of_elves","item_robe"}, chance = 10, limit = 5, units = {"npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner"}},--50% drop from list with limit
		{items = {"item_ogre_axe","item_blade_of_alacrity","item_staff_of_wizardry"}, chance = 75, units = {"npc_dota_neutral_black_dragon","npc_dota_neutral_centaur_khan"}},--75% drop from list
		{items = {"item_clarity","item_flask"}, chance = 25, duration = 10},-- global drop 25%
		{items = {"item_rapier"}, chance = 10, limit = 1},-- global drop 10% with limit 1
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
		local loot_duration = drop.duration or nil -- длительность жизни предмета на земле
		local limit = drop.limit or nil -- лимит предметов
		local item_name = items[1] -- название предмета
		local roll_chance = RandomFloat(0, 100)
			
		if units then 
			for _,current_name in pairs(units) do
				if current_name == unit_name then
					units = nil
					break
				end
			end
		end

		if units == nil and (limit == nil or limit > 0) and roll_chance < chance then
			if limit then
				drop.limit = drop.limit - 1
			end

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