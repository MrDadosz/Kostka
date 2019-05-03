-- dice:isInvited - timer, który wygasa
-- dice:playerThatInvited -- gracz, który zapraszał jako element
-- dice:amount -- kwota, o którą grają obaj gracze
local minimalAmount = 1000 -- minimalna kwota na wyzwanie
local timerTime = 15 -- ile sekund na przyjęcie
local colshape = createColSphere(2497.00830, -1671.84155, 13.33595, 10)
setElementInterior(colshape, 0)
setElementDimension(colshape, 0)

local function findPlayer(plr,cel)
	local target=nil
	if (tonumber(cel) ~= nil) then
		target=getElementByID("p"..cel)
	else -- podano fragment nicku
		for _,thePlayer in ipairs(getElementsByType("player")) do
			if string.find(string.gsub(getPlayerName(thePlayer):lower(),"#%x%x%x%x%x%x", ""), cel:lower(), 1, true) then
				if (target) then
					outputChatBox("Znaleziono więcej niz jednego gracza o pasującym nicku, podaj więcej liter.", plr, 255,0,0)
					return nil
				end
				target=thePlayer
			end
		end
	end
	return target
end

local function clearData(plr)
	if not isElement(plr) then
		return false
	end
	local plrTimer = getElementData(plr, "dice:isInvited")
	local plrPlayer = getElementData(plr, "dice:playerThatInvited")
	local plrAmount = getElementData(plr, "dice:amount")
	if isTimer(plrTimer) then
		killTimer(plrTimer)
	end
	setElementData(plr, "dice:isInvited", nil, false)
	setElementData(plr, "dice:playerThatInvited", nil, false)
	setElementData(plr, "dice:amount", nil, false)
end

local function cancelDiceByTimer(plr)
	local targetPlayer = getElementData(plr, "dice:playerThatInvited")
	outputChatBox("Zaproszenie do zakładu wygasło.", plr, 255,0,0)
	if isElement(targetPlayer) then
		outputChatBox("Zaproszenie do zakładu wygasło.", targetPlayer, 255,0,0)
	end
	clearData(plr)
end

local function generateDiceWinner(plr1, plr2, amount)
	clearData(plr2)
	--clearData(plr2) -- wyczyszczenie tylko zaproszenia obecnego
	if getPlayerMoney(plr1) < amount then
		outputChatBox("Nie masz już $"..amount.." wymaganego do zakładu.", plr1, 255,0,0)
		outputChatBox("Gracz "..getPlayerName(plr1).." nie ma już $"..amount.." wymaganego do zakładu.", plr2, 255,0,0)
		return
	elseif getPlayerMoney(plr2) < amount then
		outputChatBox("Nie masz już $"..amount.." wymaganego do zakładu.", plr2, 255,0,0)
		outputChatBox("Gracz "..getPlayerName(plr2).." nie ma już $"..amount.." wymaganego do zakładu.", plr1, 255,0,0)
		return
	end
	local plr1dice1 = math.random(1,6)
	local plr1dice2 = math.random(1,6)
	local plr2dice1 = math.random(1,6)
	local plr2dice2 = math.random(1,6)
	local plr1sum = plr1dice1 + plr1dice2
	local plr2sum = plr2dice1 + plr2dice2
	outputChatBox("Gracz "..getPlayerName(plr1).." wylosował "..plr1dice1.." i "..plr1dice2.." - łącznie "..plr1sum..".", plr1, 200,200,200)
	outputChatBox("Gracz "..getPlayerName(plr1).." wylosował "..plr1dice1.." i "..plr1dice2.." - łącznie "..plr1sum..".", plr2, 200,200,200)
	outputChatBox("Gracz "..getPlayerName(plr2).." wylosował "..plr2dice1.." i "..plr2dice2.." - łącznie "..plr2sum..".", plr1, 200,200,200)
	outputChatBox("Gracz "..getPlayerName(plr2).." wylosował "..plr2dice1.." i "..plr2dice2.." - łącznie "..plr2sum..".", plr2, 200,200,200)
	if plr1sum == plr2sum then
		outputChatBox("Remis! Żadna ze stron nie wygrała "..amount.."$.", plr1, 200,200,200)
		outputChatBox("Remis! Żadna ze stron nie wygrała "..amount.."$.", plr2, 200,200,200)
	elseif plr1sum > plr2sum then
		outputChatBox("Wygrałeś "..amount.."$!", plr1, 0,255,0)
		outputChatBox("Przegrałeś "..amount.."$!", plr2, 255,0,0)
		takePlayerMoney(plr2, amount)
		givePlayerMoney(plr1, amount)
	elseif plr2sum > plr1sum then
		outputChatBox("Wygrałeś "..amount.."$!", plr2, 0,255,0)
		outputChatBox("Przegrałeś "..amount.."$!", plr1, 255,0,0)
		givePlayerMoney(plr2, amount)	
		takePlayerMoney(plr1, amount)
	end
end

local function acceptDice(plr, cmd, accept)
	if accept ~= "akceptuj" then
		return
	end
	local playerThatInvited = getElementData(plr, "dice:playerThatInvited")
	local plrTimer = getElementData(plr, "dice:isInvited")
	local amount = getElementData(plr, "dice:amount")
	if not isTimer(plrTimer) then
		outputChatBox("Nie masz żadnego zaproszenia.", plr, 255,0,0)
		clearData(plr)
		return
	end
	if not isElement(playerThatInvited) then
		outputChatBox("Gracz, który Cię zaprosił wyszedł z gry.", plr, 255,0,0)
		clearData(plr)
		return
	end
	if getElementInterior(plr) ~= getElementInterior(colshape) or getElementDimension(plr) ~= getElementDimension(colshape) then
		outputChatBox("Wyszedłeś z kasyna, zakład zostaje przerwany!", plr, 255,0,0)
		outputChatBox("Gracz "..plr.." wyszedł z kasyna, zakład zostaje przerwany!", playerThatInvited, 255,0,0)
		clearData(plr)
		return
	elseif getElementInterior(playerThatInvited) ~= getElementInterior(colshape) or getElementDimension(playerThatInvited) ~= getElementDimension(colshape) then
		outputChatBox("Wyszedłeś z kasyna, zakład zostaje przerwany!", playerThatInvited, 255,0,0)
		outputChatBox("Gracz "..playerThatInvited.." wyszedł z kasyna, zakład zostaje przerwany!", plr, 255,0,0)
		clearData(plr)
	end
	generateDiceWinner(playerThatInvited, plr, amount)
end
addCommandHandler("kostka", acceptDice)

local function invitePlayer(plr, cmd, targetName, amount)
	if targetName == "akceptuj" then
		return
	end
	if not isElementWithinColShape(plr, colshape) or getElementInterior(plr) ~= getElementInterior(colshape) or getElementDimension(plr) ~= getElementDimension(colshape) then
		outputChatBox("W tym miejscu nie można użyć kostki. Udaj się do kasyna.", plr, 255,0,0)
		return
	end
	if not targetName or not amount or (amount and not tonumber(amount)) then
		outputChatBox("Użyj: /"..cmd.." <nick> <kwota> lub /"..cmd.." akceptuj.", plr, 255,0,0)
		return
	end
	amount = tonumber(amount)
	if amount <= 0 or amount % 1 ~= 0 then
		outputChatBox("Kwota jest niepoprawna.", plr, 255,0,0)
		return
	end
	if amount < minimalAmount then
		outputChatBox("Minimalna kwota zakładu to "..minimalAmount..".", plr, 255,0,0)
		return
	end
	if getPlayerMoney(plr) < amount then
		outputChatBox("Nie masz tylu pieniędzy.", plr, 255,0,0)
		return
	end
	local target = findPlayer(targetName, targetName)
	if not target then
		outputChatBox("Nie odnaleziono gracza o podanym nicku.", plr, 255,0,0)
		return
	end
	if plr == target then
		outputChatBox("Nie możesz sam siebie wyzwać.", plr, 255,0,0)
		return
	end
	if not isElementWithinColShape(target, colshape) or getElementInterior(target) ~= getElementInterior(colshape) or getElementDimension(target) ~= getElementDimension(colshape) then
		outputChatBox("Ten gracz nie jest w kasynie.", plr, 255,0,0)
		return
	end
	if getPlayerMoney(target) < amount then
		outputChatBox("Gracz nie ma tylu pieniędzy.", plr, 255,0,0)
		outputChatBox("Gracz "..getPlayerName(plr).." próbował wyzwać Cię na kwotę $"..amount..", jednak nie masz takiej kwoty.", target, 255,0,0)
		return
	end
	local targetTimer = getElementData(target, "dice:isInvited")
	local targetPlayer = getElementData(target, "dice:playerThatInvited")
	if isTimer(targetTimer) and isElement(targetPlayer) then
		outputChatBox("Gracz został zaproszony już przez inną osobę. Poczekaj chwilę.", plr, 255,0,0)
		return
	else
		if not isElement(targetPlayer) then
			clearData(target)
			outputChatBox("Zaproszenie wygasło, ze względu na wyjście gracza z gry.", target, 255,0,0)
		end
	end	
	setElementData(target, "dice:isInvited", setTimer(cancelDiceByTimer, timerTime*1000, 1, plr), false)
	setElementData(target, "dice:playerThatInvited", plr, false)
	setElementData(target, "dice:amount", amount, false)
	outputChatBox("Wyzywasz "..getPlayerName(target).." na $"..amount..". Gracz ma "..timerTime.." sekund na odpowiedź.", plr, 0,255,0)
	outputChatBox("Gracz "..getPlayerName(plr).." wyzywa Cię na $"..amount..". Użyj w ciągu "..timerTime.." sekund /"..cmd.." akceptuj, by przyjąć zaproszenie.", target, 0,255,0)
end
addCommandHandler("kostka", invitePlayer)

local function onPlayerGameQuit(plr)
	for _, target in pairs(getElementsByType("player")) do
		local playerThatInvited = getElementData(target, "dice:playerThatInvited")
		if playerThatInvited and playerThatInvited == plr then
			outputChatBox("Zaproszenie wygasło, ze względu na wyjście gracza z gry.", target, 255,0,0)
			clearData(target)
		end
	end
end
addEventHandler("onPlayerQuit", root, onPlayerGameQuit)