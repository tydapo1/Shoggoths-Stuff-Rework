local oldOnLevelUp = onLevelUp
onLevelUp = function(mag)
	
	-- Required data for evolving mags and the such
	local playerSpecies = raceTables[player.species()].build
	local playerGender = player.gender()
	local playerClass = player.getProperty("magWeaponAffinity", nil)
	local playerSectionId = player.getProperty("magSectionId", nil)
	-- "itemTags" : ["weapon","staff","melee","ranged"]
	-- Class : Hunter, Ranger, Force
	-- Race : Bulky, Swift, Smart
	
	if 		(getLevel(mag) == 10)
		and	(playerClass == "ranger")
	then
		evolve(mag, "kalki")
	end
	
	if oldOnLevelUp then return oldOnLevelUp(mag) end
end