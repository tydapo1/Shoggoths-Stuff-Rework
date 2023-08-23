require "/scripts/util.lua"
require "/scripts/augments/item.lua"

function isArmor(item)
	local armors = {
		headarmor = true,
		chestarmor = true,
		legsarmor = true,
		backarmor = true
	}
	return armors[item:type()] == true
end

function apply(input)
	local output = Item.new(input)

	if not isArmor(output) then
		return nil
	end

	local dyeDirectives = config.getParameter("color")

	if dyeDirectives then
		output:setInstanceValue("directives", dyeDirectives)

		return output:descriptor(), 1
	end
end
