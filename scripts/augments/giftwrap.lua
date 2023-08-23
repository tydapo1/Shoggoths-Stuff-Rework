require "/scripts/util.lua"
require "/scripts/augments/item.lua"

function apply(input)
	if input then
		local output = Item.new({
			name = "srm_packaging",
			count = 1,
			parameters = {}
		})
		output:setInstanceValue("inventoryIcon", config.getParameter("newIcon"))
		output:setInstanceValue("animationCustom", {animatedParts={parts={gun={properties={image=config.getParameter("newIcon")}}}}})
		output:setInstanceValue("shortdescription", "Mystery Present")
		output:setInstanceValue("description", "A present! Open it up to find out what's inside!")
		output:setInstanceValue("content", {
			type = "item",
			item = input
		})
		return output:descriptor(), 1
	else
		return nil
	end
end
