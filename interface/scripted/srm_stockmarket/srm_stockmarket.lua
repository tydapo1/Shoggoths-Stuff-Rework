function init()
	stockConfig = root.assetJson("/config/srm_stocks.config")
	patternIndices = { default = 0, safe = 1, deadweight = 2 }
	patternNames = { [0] = "default", [1] = "safe", [2] = "deadweight" }
	categoryList = "scrollAreaCategory.itemList"
	stockList = "scrollAreaStocks.itemList"
	searchList = {}
	defaultItem = {name="",parameters={},count=1}
	
	playerData = player.getProperty("stocksMarketData", {noonecares="puregarbage"})
  
	graphCanvas = widget.bindCanvas("chartCanvas")
	graphDimensions = {120,64}
	graphHistoryMax = 30
	graphUpdateRate = 2 --once every 120 ticks, aka every 2 second.
	graphUpdateTimer = graphUpdateRate
	
	categoriesLoaded = false
	stocksLoaded = false
	
	--This tidbit here generates the stock categories inside the config file.
	for k,v in pairs(stockConfig) do
		local newItem = widget.addListItem(categoryList)
		if (stockConfig[k].name == "Company") then 
			widget.setListSelected(categoryList, newItem) 
		end
		widget.setData(string.format("%s.%s",categoryList,newItem), k)
		widget.setImage(string.format("%s.%s.categoryIcon",categoryList,newItem),v.icon)
	end
	categoriesLoaded = true
	updateCategories()
	
	--this is just to test the drawGraph function, it should get overwritten by graph updates anyways so dont worry about it.
	--defaultGraph = {93,21,76,43,124}
	--drawGraph(defaultGraph)
    world.sendEntityMessage(player.id(), "playAltMusic", {"/music/crueltysquad-depressionnap.ogg"}, 0.3)
end

function update(dt)
	playerData = player.getProperty("stocksMarketData", {noonecares="puregarbage"})
	if (graphUpdateTimer >= graphUpdateRate) then
		graphUpdateTimer = 0
		updateData()
	end
	graphUpdateTimer = graphUpdateTimer + dt
end

function uninit()
	world.sendEntityMessage(player.id(), "playAltMusic", jarray(), 0.3)
end





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BUTTON CALLS----------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function searchBar()
	searchResults()
end

function btnBuy()
	buyStock()
end

function btnSell()
	sellStock()
end

function amountFieldBuy()
	verifyBuyable()
end

function amountFieldSell()
	verifySellable()
end

function scrollAreaCategory()
	-- It isn't necessary to play a funny noise here due to the fact updateCategories automatically calls updateStocks.
	updateCategories()
end

function scrollAreaStocks()
	updateStocks()
end





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--INTERFACE FUNCTIONS---------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Once a category is selected, displays the selectable stocks in the middle part of the interface.
function updateCategories()
	if categoriesLoaded then
		stocksLoaded = false
		if selectedCategory() then
			widget.setText("lblCurrentCategory", "^shadow;Current Category : " .. stockConfig[selectedCategory()].name .. " Stocks^reset;")
			widget.clearListItems(stockList)
			searchList = {}
			local firstItem = true
			local offersArray = stockConfig[selectedCategory()].offers
			for k,v in pairs(offersArray) do
				local newItem = widget.addListItem(stockList)
				searchList[k] = newItem
				if firstItem then widget.setListSelected(stockList, newItem) firstItem = false end
				widget.setData(string.format("%s.%s",stockList,newItem), k)
				widget.setText(string.format("%s.%s.stockAcronym",stockList,newItem),"^shadow;" .. v.acronym .. "^reset;")
				if (stockConfig[selectedCategory()].type == "speculative") then
					widget.setText(string.format("%s.%s.stockOwned",stockList,newItem),"^shadow;(" .. player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. widget.getData(string.format("%s.%s",stockList,newItem)), 0) .. ")^reset;")
				else
					widget.setText(string.format("%s.%s.stockOwned",stockList,newItem),"^shadow;(" .. player.hasCountOfItem(offersArray[widget.getData(string.format("%s.%s",stockList,newItem))].sourceItem) .. ")^reset;")
				end		
			end
		end
		stocksLoaded = true
		updateStocks()
	end
end

-- Once a stock is selected, displays the data of the stock inside the right part of the interface.
function updateStocks()
	if stocksLoaded then
		widget.playSound("/sfx/interface/clickon_success.ogg", 0, 1.0)
		widget.setText("lblPixelsOwned","^shadow;" .. player.currency("money") .. "^reset;")
		if selectedStock() then
			if (stockConfig[selectedCategory()].type == "speculative") then
				local offersArray = stockConfig[selectedCategory()].offers
				local newName = offersArray[selectedStock()].name
				local newDescription = offersArray[selectedStock()].description
				local newIcon = offersArray[selectedStock()].icon
				widget.setText("lblStockName","^shadow;" .. newName .. "^reset;")
				widget.setText("lblStockDescription","^shadow;" .. newDescription .. "^reset;")
				widget.setText("lblStockOwned","^shadow;Owned : " .. player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0) .. "^reset;")
				widget.setText(string.format("%s.%s.stockOwned",stockList,widget.getListSelected(stockList)),"^shadow;(" .. player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0) .. ")^reset;")
				widget.setImage("stockIcon",iconifyImage(newIcon))
				widget.setImage("stockGraphBG",iconifyImage(newIcon) .. "?scalenearest=4.0?multiply=FFFFFF40")
			else
				local offersArray = stockConfig[selectedCategory()].offers
				local currentItem = defaultItem
				currentItem.name = offersArray[selectedStock()].sourceItem
				local itemParameters = root.itemConfig(currentItem).config
				local newName = itemParameters.shortdescription
				local newDescription = itemParameters.description
				local newIcon = offersArray[selectedStock()].icon
				widget.setText("lblStockName","^shadow;" .. newName .. "^reset;")
				widget.setText("lblStockDescription","^shadow;" .. newDescription .. "^reset;")
				widget.setText("lblStockOwned","^shadow;Owned : " .. player.hasCountOfItem(offersArray[selectedStock()].sourceItem) .. "^reset;")
				widget.setText(string.format("%s.%s.stockOwned",stockList,widget.getListSelected(stockList)),"^shadow;(" .. player.hasCountOfItem(offersArray[selectedStock()].sourceItem) .. ")^reset;")
				widget.setImage("stockIcon",iconifyImage(newIcon))
				widget.setImage("stockGraphBG",iconifyImage(newIcon) .. "?scalenearest=4.0?multiply=FFFFFF40")
			end
		end
		searchResults()
		updateData()
	end
end

-- This is a lazy implementation of the search bar, but it basically just hides any results that aren't relevant to the tags.
function searchResults()
  for k,v in pairs(searchList) do
    if (
	  string.find(string.upper(stockConfig[selectedCategory()].offers[widget.getData(string.format("%s.%s",stockList,v))].name), string.upper(widget.getText("searchBar"))) or
	  string.find(string.upper(stockConfig[selectedCategory()].offers[widget.getData(string.format("%s.%s",stockList,v))].acronym), string.upper(widget.getText("searchBar")))
	) then
	  widget.setVisible(string.format("%s.%s",stockList,v), true)
	else
	  widget.setVisible(string.format("%s.%s",stockList,v), false)
	end
  end
end

-- This takes care of updating data that changes over time.
function updateData()
	drawGraph(playerData[selectedCategory()][selectedStock()].stockHistory)
	local ogPrice = 0
	if (stockConfig[selectedCategory()].type == "speculative") then
		ogPrice = stockConfig[selectedCategory()].offers[selectedStock()].price
	else
		local currentItem = {name="",parameters={},count=1}
		currentItem.name = stockConfig[selectedCategory()].offers[selectedStock()].sourceItem
		local itemParameters = root.itemConfig(currentItem).config
		ogPrice = itemParameters.price
	end
	widget.setText("lblStockPrice","^shadow;" .. round(playerData[selectedCategory()][selectedStock()].stockValue,0) .. " Pixels " .. getPercentVariation(
		ogPrice,
		playerData[selectedCategory()][selectedStock()].stockHistory["" .. graphHistoryMax .. ""]
	) .. "%^reset;")
	widget.setText("lblStockMarketCap","^shadow;MKC - " .. round(stockConfig[selectedCategory()].offers[selectedStock()].marketCap * playerData[selectedCategory()][selectedStock()].stockValue,0) .. "$^reset;")
	for k,v in pairs(searchList) do
		local currentStockOwned = 0
		if (stockConfig[selectedCategory()].type == "speculative") then
			currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. k, 0))
		else
			currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[k].sourceItem)
		end
		widget.setText(string.format("%s.%s.stockValue",stockList,v),"^shadow;" .. squeezeNumber(playerData[selectedCategory()][k].stockValue*currentStockOwned) .. "^reset;")
		widget.setText(string.format("%s.%s.stockVariation",stockList,v),"^shadow;" .. simplifyNumber(playerData[selectedCategory()][k].stockHistory["30"] - playerData[selectedCategory()][k].stockHistory["29"]) .. "^reset;")
	end
	widget.setText("lblPixelsOwned",player.currency("money"))
end

-- This takes care of drawing the graph, using an array of stock values.
function drawGraph(stockValues)
	coordinateArray = fitCoordinates(stockValues)
	if categoriesLoaded then
		graphCanvas:clear()
		-- First, the lines.
		for i=1,(#coordinateArray+1) do
			if ((not(coordinateArray[i-1] == nil)) and (not(coordinateArray[i] == nil))) then
				if (coordinateArray[i-1][2] <= coordinateArray[i][2]) then
					graphCanvas:drawLine(coordinateArray[i-1], coordinateArray[i], getColorName(getColorIndex("green")), 1)
				else
					graphCanvas:drawLine(coordinateArray[i-1], coordinateArray[i], getColorName(getColorIndex("red")), 1)
				end
			elseif ((coordinateArray[i-1] == nil) and (not(coordinateArray[i] == nil))) then
				graphCanvas:drawLine({coordinateArray[i][1],coordinateArray[i][2]}, coordinateArray[i], getColorName(getColorIndex("green")), 1)
				
			elseif ((not(coordinateArray[i-1] == nil)) and (coordinateArray[i] == nil)) then
				graphCanvas:drawLine(coordinateArray[i-1], {coordinateArray[i-1][1],coordinateArray[i-1][2]}, getColorName(getColorIndex("green")), 1)
			end
		end
		-- This has to be separate in order for the yellow rectangles to overlap the lines.
		for i=1,(#coordinateArray+1) do
			if ((not(coordinateArray[i-1] == nil)) and (not(coordinateArray[i] == nil))) then
				graphCanvas:drawRect({coordinateArray[i][1]-1,coordinateArray[i][2]-1,coordinateArray[i][1]+1,coordinateArray[i][2]+1}, getColorName(getColorIndex("yellow")))
			elseif ((coordinateArray[i-1] == nil) and (not(coordinateArray[i] == nil))) then
				graphCanvas:drawRect({coordinateArray[i][1]-1,coordinateArray[i][2]-1,coordinateArray[i][1]+1,coordinateArray[i][2]+1}, getColorName(getColorIndex("yellow")))
			elseif ((not(coordinateArray[i-1] == nil)) and (coordinateArray[i] == nil)) then
				graphCanvas:drawRect({coordinateArray[i-1][1]-1,coordinateArray[i-1][2]-1,coordinateArray[i-1][1]+1,coordinateArray[i-1][2]+1}, getColorName(getColorIndex("yellow")))
			end
		end
	end
end

-- This makes sure any data put in the graph will fit within it's boundaries.
function fitCoordinates(stockValues)
	sortedArray = {}
	unsortedArray = {}
	for i=0,graphHistoryMax do
		table.insert(sortedArray, stockValues["" .. i .. ""])
		table.insert(unsortedArray, stockValues["" .. i .. ""])
	end
	--93,21,76,43,124
	coordinateArray = {}
	table.sort(sortedArray)
	-- 21, 43, 76, 93, 124
	numberMin = sortedArray[1]
	-- 21
	numberMax = sortedArray[#sortedArray]
	-- 124
	variation = numberMax - numberMin
	-- 124 - 21 = 103
	variation = variation / graphDimensions[2]
	-- 103 / 64 = 1.609375
	for i=1,(#unsortedArray) do
		coordinateArray[i] = {0,0}
		coordinateArray[i][1] = (i-1)*(graphDimensions[1]/graphHistoryMax)
		coordinateArray[i][2] = ((unsortedArray[i] - numberMin) / variation)
	end
	-- (93-21) / 1.609375 = 44.7378641
	-- (21-21) / 1.609375 = 0
	-- (76-21) / 1.609375 = 34.1747573
	-- (43-21) / 1.609375 = 13.5599029
	-- (124-21) / 1.609375 = 64
	-- Within boundaries!
	return coordinateArray
end

function buyStock()
	verifyBuyable()
	if (not ((widget.getText("amountFieldBuy") == "") or (widget.getText("amountFieldBuy") == "0"))) then
		local buyAmount = tonumber(widget.getText("amountFieldBuy")) 
		local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
		local currentStockOwned = 0
		if (stockConfig[selectedCategory()].type == "speculative") then
			currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		else
			currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		end
		if (player.consumeCurrency("money", (buyAmount*currentStockValue))) then
			widget.playSound("/sfx/interface/item_pickup.ogg", 0, 1.0)
			buyTransaction()
		else
			widget.playSound("/sfx/interface/clickon_error.ogg", 0, 1.0)
		end
	end 
end

function buyTransaction()
	local buyAmount = tonumber(widget.getText("amountFieldBuy"))
	local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
	local currentStockOwned = 0
	if (stockConfig[selectedCategory()].type == "speculative") then
		currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		currentStockOwned = currentStockOwned + buyAmount
		player.setProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), currentStockOwned)
	else
		currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		buyLoop = buyAmount
		while (buyLoop>0) do
			loopAmount = 0
			if (math.floor(buyLoop/1000) > 0) then
				loopAmount = 1000
			else
				loopAmount = buyLoop
			end
			player.giveItem({name=stockConfig[selectedCategory()].offers[selectedStock()].sourceItem,count=loopAmount})
			buyLoop = buyLoop - loopAmount
			currentStockOwned = currentStockOwned + loopAmount
		end
	end
	widget.setText(string.format("%s.%s.stockOwned",stockList,widget.getListSelected(stockList)),"^shadow;(" .. currentStockOwned .. ")^reset;")
	widget.setText("lblStockOwned","^shadow;Owned : " .. currentStockOwned .. "^reset;")
	widget.setText(string.format("%s.%s.stockValue",stockList,widget.getListSelected(stockList)),"^shadow;" .. squeezeNumber(playerData[selectedCategory()][selectedStock()].stockValue*currentStockOwned) .. "^reset;")
	widget.setText("lblPixelsOwned",player.currency("money"))
end

function verifyBuyable()
	widget.setText("amountFieldSell", "")
	if (not ((widget.getText("amountFieldBuy") == "") or (widget.getText("amountFieldBuy") == "0"))) then
		local buyAmount = tonumber(widget.getText("amountFieldBuy"))
		local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
		local currentStockOwned = 0
		if (stockConfig[selectedCategory()].type == "speculative") then
			currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		else
			currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		end
		if (player.currency("money") < (buyAmount * currentStockValue)) then
			widget.setText("amountFieldBuy", (math.floor((player.currency("money")*currentStockValue))))
		end
		widget.setText("lblBalanceAmount", "^shadow;" .. round((currentStockValue*tonumber(widget.getText("amountFieldBuy"))),0) .. "^reset;")
	end
end

function sellStock()
	verifySellable()
	if (not ((widget.getText("amountFieldSell") == "") or (widget.getText("amountFieldSell") == "0"))) then
		local sellAmount = tonumber(widget.getText("amountFieldSell"))
		local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
		local currentStockOwned = 0
		if (stockConfig[selectedCategory()].type == "speculative") then
			currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		else
			currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		end
		if (sellTransaction()) then
			widget.playSound("/sfx/interface/item_pickup.ogg", 0, 1.0)
			world.spawnItem("money", world.entityPosition(player.id()), sellAmount*currentStockValue)
		else
			widget.playSound("/sfx/interface/clickon_error.ogg", 0, 1.0)
		end
	end
end

function sellTransaction()
	local didGoThrough = false
	local sellAmount = tonumber(widget.getText("amountFieldSell"))
	local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
	local currentStockOwned = 0
	if (stockConfig[selectedCategory()].type == "speculative") then
		currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		if (currentStockOwned >= sellAmount) then
			currentStockOwned = currentStockOwned - sellAmount
			player.setProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), (currentStockOwned))
			didGoThrough = true
		end
	else
		currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		if (currentStockOwned >= sellAmount) then
			buyLoop = sellAmount
			while (buyLoop>0) do
				loopAmount = 0
				if (math.floor(buyLoop/1000) > 0) then
					loopAmount = 1000
				else
					loopAmount = buyLoop
				end
				player.consumeItem({name=stockConfig[selectedCategory()].offers[selectedStock()].sourceItem,count=loopAmount})
				buyLoop = buyLoop - loopAmount
				currentStockOwned = currentStockOwned - loopAmount
			end
			didGoThrough = true
		end
	end
	widget.setText(string.format("%s.%s.stockOwned",stockList,widget.getListSelected(stockList)),"^shadow;(" .. currentStockOwned .. ")^reset;")
	widget.setText("lblStockOwned","^shadow;Owned : " .. currentStockOwned .. "^reset;")
	widget.setText(string.format("%s.%s.stockValue",stockList,widget.getListSelected(stockList)),"^shadow;" .. squeezeNumber(playerData[selectedCategory()][selectedStock()].stockValue*currentStockOwned) .. "^reset;")
	widget.setText("lblPixelsOwned",player.currency("money"))
	return didGoThrough
end

function verifySellable()
	widget.setText("amountFieldBuy", "")
	if (not ((widget.getText("amountFieldSell") == "") or (widget.getText("amountFieldSell") == "0"))) then
		local sellAmount = tonumber(widget.getText("amountFieldSell"))
		local currentStockValue = tonumber(playerData[selectedCategory()][selectedStock()].stockValue)
		local currentStockOwned = 0
		if (stockConfig[selectedCategory()].type == "speculative") then
			currentStockOwned = tonumber(player.getProperty("ownedStocks_" .. selectedCategory() .. "_" .. selectedStock(), 0))
		else
			currentStockOwned = player.hasCountOfItem(stockConfig[selectedCategory()].offers[selectedStock()].sourceItem)
		end
		if (currentStockOwned < sellAmount) then
			widget.setText("amountFieldSell", currentStockOwned)
		end
		widget.setText("lblBalanceAmount", "^shadow;" .. round((currentStockValue*tonumber(widget.getText("amountFieldSell")))*-1,0) .. "^reset;")
	end
end

function selectedCategory()
	return widget.getData(string.format("%s.%s",categoryList,widget.getListSelected(categoryList)))
end

function selectedStock()
	return widget.getData(string.format("%s.%s",stockList,widget.getListSelected(stockList)))
end





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--UTILITY FUNCTIONS-----------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Converts the right string to a number, concatenates them, and converts the whole thing back to a number.
function superConcat(newDateSeed, currentTextSeed)
	local textAmnt = 0
	for i=1,string.len(currentTextSeed) do
    textAmnt = textAmnt + string.byte(currentTextSeed, i)
	end
	textAmnt = tonumber(textAmnt)
	local concatenatedNumber = newDateSeed .. textAmnt
	return tonumber(concatenatedNumber)
end

-- Returns the total owned of a specific selectedStock.
function getAmntItem(itemToLookFor)
	return player.hasCountOfItem(itemToLookFor)
end

-- Fits a number into a smaller box.
function squeezeNumber(n)
	local n2 = round(n,0)
	if (n2 >= 10000000) or (n2 <= -10000000) then
		return notationNumber(n2)
	else 
		return n2
	end
end

-- Transforms a number from regular presentation to scientific notation. Useful when you make too much money.
function notationNumber(n)
	if not (n == 0) then
		local times10 = 0
		local currentNumber = n
		local s = ""
		while currentNumber >= 10 do
			currentNumber = currentNumber / 10
			times10 = times10 + 1
		end
		while currentNumber < 1 do
			currentNumber = currentNumber * 10
			times10 = times10 - 1
		end
		s = round(currentNumber, 5) .. " x 10^" .. times10
		return s
	else
		return n
	end
end

-- Simplifies a number. This is useful for the mini variation display, where numbers with more than two digits won't fit.
function simplifyNumber(n)
	local nm = round(n,1)
	local s = ""
	if nm > 9.9 then nm = 9.9 elseif nm < -9.9 then nm = -9.9 end
	if nm > 0 then s = "+" .. nm else s = "" .. nm end
	return s
end

--- Rounds a number.
function round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

-- Returns the variation from num1 to num2.
function getPercentVariation(num1, num2)
	-- 20 and 25
	-- 25 and 20
	local var = num2-num1
	-- 5
	-- -5
	var = (var / num1) * 100
	-- 25 = (5/20)*100
	-- -20 = (-5/25)*100
	var = round(var,5)
	-- Cuts off unnecessary follow ups.
	return var
end

-- Lookup tables
local colorIndices = { none = 0, red = 1, blue = 2, green = 3, yellow = 4, orange = 5, pink = 6, black = 7, white = 8 }
local colorNames = { [0] = "none", [1] = "red", [2] = "blue", [3] = "green", [4] = "yellow", [5] = "orange", [6] = "pink", [7] = "black", [8] = "white" }

--- Retrieves the color index of a color.
-- This color index can be used by functions such as world.setMaterialColor.
-- The index 0 represents no selected color or an invalid selection.
-- @param color Case insensitive name of the color.
-- @return Color index number.
function getColorIndex(color)
	if type(color) ~= "string" then return 0 end
	return colorIndices[color:lower()] or 0
end

--- Retrieves the color name of a color index.
-- The name "none" represents no color selection.
-- @param index Index of the color.
-- @return Lowercase color name.
function getColorName(index)
	if type(index) ~= "number" then return "none" end
	return colorNames[index] or "none"
end

-- Transforms any icon into an icon of a 16x16 format.
function iconifyImage(path)
	local dimensions = root.imageSize(path)
	local ratio = 1.0
	local ratio1 = 1.0
	local ratio2 = 1.0
	ratio1 = ((dimensions[1] / 16) ^ -1)
	ratio2 = ((dimensions[2] / 16) ^ -1)
	if ratio1<=ratio2 then ratio=ratio1 else ratio=ratio2 end
	local newPath = path .. "?scalenearest=" .. ratio
	return newPath
end