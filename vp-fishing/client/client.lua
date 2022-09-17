
local QBCore = exports['qb-core']:GetCoreObject()
local fishing = false
local pause = false
local pausetimer = 0
local correct = 0
local genderNum = 0
local peds = {} 



if Config.TestFish then 
	RegisterCommand("startfish", function(source)
		TriggerEvent("fishing:fishstart")
	end)

	RegisterCommand('spawnfish', function()
	 	TriggerServerEvent('fishing:server:catch') 
	end)
end


CreateThread(function()
	while true do
		Wait(1200)
		if pause and fishing then
			pausetimer = pausetimer + 1
		end
	end
end)

CreateThread(function()
	while true do
		Wait(1)
		if fishing then
				if IsControlJustReleased(0, 23) then
					input = 1
			   	end

			if IsControlJustReleased(0, Config.StopFishing) then
				endFishing()
				QBCore.Functions.Notify('Balık tutmayı bıraktın', 'error')
			end

			if fishing then
				playerPed = PlayerPedId()
				local pos = GetEntityCoords(playerPed)
				if IsEntityDead(playerPed) or IsEntityInWater(playerPed) then
					endFishing()
					QBCore.Functions.Notify('Balık tutma durduruldu', 'error')
				end
			end
			
			if pausetimer > 3 then
				input = 99
			end
			
			if pause and input ~= 0 then
				pause = false
				if input == correct then
					TriggerEvent('fishing:SkillBar')
				else
					QBCore.Functions.Notify('Balık kaçtı!', 'error')
					
					loseBait()
				end
			end
		end
	end
end)

CreateThread(function()
	while true do

		local wait = math.random(Config.FishingWaitTime.minTime , Config.FishingWaitTime.maxTime)
		Wait(wait)
		if fishing then
			pause = true
			correct = 1
			TriggerEvent('3dme:triggerDisplay', 'Olta Çekmeye Başladı')
			QBCore.Functions.Notify('Balık Geldi [F]', 'success', time)
			input = 0
			pausetimer = 0
		end
	end
end)

CreateThread(function()
	while true do
		Wait(500)
		for k = 1, #Config.PedList, 1 do
			v = Config.PedList[k]
			local playerCoords = GetEntityCoords(PlayerPedId())
			local dist = #(playerCoords - v.coords)

			if dist < 50.0 and not peds[k] then
				local ped = nearPed(v.model, v.coords, v.heading, v.gender, v.animDict, v.animName, v.scenario)
				peds[k] = {ped = ped}
			end

			if dist >= 50.0 and peds[k] then
				for i = 255, 0, -51 do
					Wait(50)
					SetEntityAlpha(peds[k].ped, i, false)
				end
				DeletePed(peds[k].ped)
				peds[k] = nil
			end
		end
	end
end)


RegisterNetEvent('fishing:client:progressBar', function()
	exports['progressBars']:drawBar(1000, 'Opening Tackel Box')
end)

RegisterNetEvent('fishing:client:attemptTreasureChest', function()
	local ped = PlayerPedId()
	attemptTreasureChest()
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
			QBCore.Functions.Progressbar("accepted_key", "Inserting Key..", (math.random(2000, 5000)), false, true, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {
				animDict = "mini@repair",
				anim = "fixing_a_player",
				flags = 16,
			}, {}, {}, function() -- Done
				ClearPedTasks(ped)
				openedTreasureChest()
			end, function() -- Cancel
				ClearPedTasks(ped)
				QBCore.Functions.Notify("İptal Edildi!", "error")
			end)
		else
		  QBCore.Functions.Notify("Açabilecek bir anahtarın yok!", "error")
		end
	  end, 'fishingkey')
end)


RegisterNetEvent('fishing:SkillBar', function(message)
	if Config.Skillbar == "reload-skillbar" then
		local finished = exports["reload-skillbar"]:taskBar(math.random(5000,7500),math.random(2,4))
		if finished ~= 100 then
			QBCore.Functions.Notify('Balık kaçtı!', 'error')
			loseBait()
		else
			local finished2 = exports["reload-skillbar"]:taskBar(math.random(2500,5000),math.random(3,5))
			if finished2 ~= 100 then
				QBCore.Functions.Notify('Balık kaçtı!', 'error')
				loseBait()
			else
				local finished3 = exports["reload-skillbar"]:taskBar(math.random(900,2000),math.random(5,7))
				if finished3 ~= 100 then
					QBCore.Functions.Notify('Balık kaçtı!', 'error')
					loseBait()
				else
					catchAnimation()
				end
			end
		end
	elseif Config.Skillbar == "np-skillbar" then 
		local finished = exports["np-skillbar"]:taskBar(1000,math.random(3,5))
		if finished ~= 100 then
			QBCore.Functions.Notify('Balık Kaçtı!', 'error')
			loseBait()
		else
			catchAnimation()
		end
	elseif Config.Skillbar == "qb-skillbar" then
		local finished = exports["tgiann-skillbar"]:taskBar(30000)
		if finished then
			catchAnimation()
		else
			QBCore.Functions.Notify('Balık Kaçtı!', 'error')
			loseBait()
		end
	end
end) 

RegisterNetEvent('fishing:client:spawnFish', function(args)
	local time = 10000
	local args = tonumber(args)
	if args == 1 then 
		RequestTheModel("a_c_fish")
		local pos = GetEntityCoords(PlayerPedId())
		local ped = CreatePed(29, `a_c_fish`, pos.x, pos.y, pos.z, 90.0, true, false)
		SetEntityHealth(ped, 0)
		DecorSetInt(ped, "propHack", 74)
		SetModelAsNoLongerNeeded(`a_c_fish`)
		Wait(time)
		DeletePed(ped)
	
	else
	end
end)

RegisterNetEvent('fishing:client:useFishingBox', function(BoxId)
	TriggerServerEvent("inventory:server:OpenInventory", "stash", 'FishingBox_'..BoxId, {maxweight = 18000000, slots = 250})
	TriggerEvent("inventory:client:SetCurrentStash", 'FishingBox_'..BoxId) 
end) 

loseBait = function()
	local chance = math.random(1, 15)
	if chance <= 5 then
		TriggerServerEvent("fishing:server:removeFishingBait")
		loseBaitAnimation()
	end
end

loseBaitAnimation = function()
	local ped = PlayerPedId()
	local animDict = "gestures@f@standing@casual"
	local animName = "gesture_damn"
	DeleteEntity(rodHandle)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end
	TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, 1.0, 0, 0, 0, 48, 0)
	RemoveAnimDict(animDict)
	QBCore.Functions.Notify('succes', "Balık yemi yedi")
	Wait(2000)
	fishAnimation()
end

RequestTheModel = function(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

catchAnimation = function()
	local ped = PlayerPedId()
	local animDict = "mini@tennis"
	local animName = "forehand_ts_md_far"
	DeleteEntity(rodHandle)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end
	TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, 1.0, 0, 0, 0, 48, 0)
	local time = 1750
	QBCore.Functions.Notify('Balık yakalandı!', 'success', time)
	Wait(time)
	TriggerServerEvent('fishing:server:catch') 
	loseBait()
	if math.random(1, 100) < 50 then
		TriggerServerEvent('hud:server:RelieveStress', 50)
	end
	PlaySoundFrontend(-1, "OK", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
	RemoveAnimDict(animDict)
	--endFishing()
end

fishAnimation = function()
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
		if HasItem then
			local ped = PlayerPedId()
			local animDict = "amb@world_human_stand_fishing@idle_a"
			local animName = "idle_c"
			RequestAnimDict(animDict)
			while not HasAnimDictLoaded(animDict) do
				Wait(100)
			end
			TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, 1.0, 11, 0, 0, 0, 0)
			fishingRodEntity()
			fishing = true
			Wait(3700)
			
		else
		  endFishing()
		  QBCore.Functions.Notify("Yemin Yok", "error", 1000)
		end
	end, 'fishbait')
end

fishingRodEntity = function()
	local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)
	local fishingRodHash = `prop_fishing_rod_01`
	local bone = GetPedBoneIndex(ped, 18905)
    rodHandle = CreateObject(fishingRodHash, pedPos, true)
    AttachEntityToEntity(rodHandle, ped, bone, 0.1, 0.05, 0, 80.0, 120.0, 160.0, true, true, false, true, 1, true)
end

endFishing = function() 
	local ped = PlayerPedId()
    if rodHandle ~= 0 then
		DeleteObject(rodHandle)
		ClearPedTasks(ped)
		fishing = false
		rodHandle = 0
	
    end
end

RegisterNetEvent('fishing:fishstart', function()
	local playerPed = PlayerPedId()
	local pos = GetEntityCoords(playerPed) 
	if IsPedSwimming(playerPed) then return QBCore.Functions.Notify("Yüzerken balık tutamazsın", "error") end 
	if IsPedInAnyVehicle(playerPed) then return QBCore.Functions.Notify("Araçtan balık tutamazsın.", "error") end 
	if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, -1844.72, -1227.81, 13.02, false) < 50 then
		if GetWaterHeight(pos.x, pos.y, pos.z-2, pos.z - 3.0)  then
			
			QBCore.Functions.Notify('Balık tutuyorsun', 'primary', 2000)
			Wait(3000)
			
			fishAnimation()
		else
			QBCore.Functions.Notify('Suya yakın biryerde tutmalısın.', 'error')
		end
	else
		QBCore.Functions.Notify('Burada balık tutamazsın. Tutabileceğin yerin konumu girildi.', 'primary', 5000)
		SetNewWaypoint(-1844.72, -1227.81)
	end
end, false)

attemptTreasureChest = function()
	local ped = PlayerPedId()
	local animDict = "veh@break_in@0h@p_m_one@"
	local animName = "low_force_entry_ds"
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end
	TaskPlayAnim(ped, animDict, animName, 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)
	RemoveAnimDict(animDict)
	QBCore.Functions.Notify('Attempting to open Treasure Chest', 'primary', 1500)
	Wait(1500)
	ClearPedTasks(PlayerPedId())
end

openedTreasureChest = function()
	if math.random(1,15) == 10 then
		TriggerServerEvent("QBCore:Server:RemoveItem", "fishingkey", 1)
		TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["fishingkey"], "remove", 1)
		QBCore.Functions.Notify("The corroded key has snapped", "error", 7500)
	end
	TriggerServerEvent("QBCore:Server:RemoveItem", "fishinglootbig", 1)
	TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["fishinglootbig"], "remove", 1)
	QBCore.Functions.Notify("Sandık açıldı", "success", 7500)
	local ShopItems = {} 
	ShopItems.label = "Treasure Chest"
	ShopItems.items = Config.largeLootboxRewards
	ShopItems.slots = #Config.largeLootboxRewards
	TriggerServerEvent("inventory:server:OpenInventory", "shop", "Vendingshop_", ShopItems)
end

nearPed = function(model, coords, heading, gender, animDict, animName, scenario)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Wait(1)
	end

	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
		print("No gender provided! Check your configuration!")
	end	

	ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
	SetEntityAlpha(ped, 0, false)

	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	if scenario then
		TaskStartScenarioInPlace(ped, scenario, 0, true) 
	end
	for i = 0, 255, 51 do
		Wait(50)
		SetEntityAlpha(ped, i, false)
	end

	return ped
end
