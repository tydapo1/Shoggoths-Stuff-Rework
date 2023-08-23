function uninit()
	if (not player.getProperty("magWeaponAffinity", nil)) then
		local classes = {}
		classes[1] = "hunter"
		classes[2] = "ranger"
		classes[3] = "force"
		local class = classes[math.random(1,3)]
		player.setProperty("magWeaponAffinity", class)
	end
end

function meleeAffinity()
	player.setProperty("magWeaponAffinity", "hunter")
	pane.dismiss()
end

function rangedAffinity()
	player.setProperty("magWeaponAffinity", "ranger")
	pane.dismiss()
end

function staffAffinity()
	player.setProperty("magWeaponAffinity", "force")
	pane.dismiss()
end