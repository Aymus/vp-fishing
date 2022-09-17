
local QBCore = exports['qb-core']:GetCoreObject()


--------Satis------------

RegisterNetEvent('doj:client:SellLegalFish')
AddEventHandler('doj:client:SellLegalFish', function()
    exports['qb-menu']:openMenu({
		{
            header = "Balık Restaurant",
            isMenuHeader = true
        },
        {
            header = "Uskumru",
            txt = "Fiyat: $"..Config.uskumruprice.."",
            params = {
				isServer = true,
                event = "fishing:server:SellLegalFish",
				args = 1
            }
        },
	
        
    })
end)

