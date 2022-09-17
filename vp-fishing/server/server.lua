local QBCore = exports['qb-core']:GetCoreObject()




QBCore.Functions.CreateUseableItem("fishingrod", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
 		TriggerClientEvent('fishing:fishstart', source)
    end
end)

RegisterNetEvent('fishing:server:removeFishingBait', function()
	local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem('fishbait', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['fishbait'], "remove", 1)
end)




RegisterNetEvent('fishing:server:catch', function() 
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local luck = math.random(1, 2)
    local itemFound = true
    local itemCount = 1

	if itemFound then
        for i = 1, itemCount, 1 do
            if luck == 1 then
				local weight = math.random(1,5)
				local info = {species = "USKUMRU", lbs = weight, type = "Normal"}
				-- TriggerClientEvent('fishing:client:spawnFish', src, 1)
				Player.Functions.AddItem('uskumru', 1, nil, info, {["quality"] = 100})
				TriggerClientEvent('fishing:fishstart', source)
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['uskumru'], "add", 1)
				TriggerClientEvent('QBCore:Notify', src, "Vay canına" .. weight .. "Kilo uskumru", "success")
			
            end
            Citizen.Wait(500)
        end
    end
end)


RegisterNetEvent('fishing:server:SellLegalFish', function(args) 
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local args = tonumber(args)
	if args == 1 then 
		local uskumru = Player.Functions.GetItemByName("uskumru").amount
		if uskumru > 0 then
			local payment = Config.uskumruprice	
			Player.Functions.RemoveItem("uskumru", 1, k)
			Player.Functions.AddMoney('bank', payment , "uskumru-sell")
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['uskumru'], "remove", 1)
			TriggerClientEvent("doj:client:SellLegalFish", source)
		else
		    TriggerClientEvent('QBCore:Notify', src, "Dostum Uskumrun Yok", "error")
		end

	end
end)


