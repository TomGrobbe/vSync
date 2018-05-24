CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

RegisterNetEvent('vSync:updateWeather')
AddEventHandler('vSync:updateWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

Citizen.CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOverTime(CurrentWeather, 15.0)
            Citizen.Wait(15000)
        end
        Citizen.Wait(100) -- Wait 0 seconds to prevent crashing.
        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

RegisterNetEvent('vSync:updateTime')
AddEventHandler('vSync:updateTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
        Citizen.Wait(0)
        local newBaseTime = baseTime
        if GetGameTimer() - 500  > timer then
            newBaseTime = newBaseTime + 0.25
            timer = GetGameTimer()
        end
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime			
        end
        baseTime = newBaseTime
        hour = math.floor(((baseTime+timeOffset)/60)%24)
        minute = math.floor((baseTime+timeOffset)%60)
        NetworkOverrideClockTime(hour, minute, 0)
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('vSync:requestSync')
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/weather', 'Change the weather.', {{ name="weatherType", help="Available types: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween"}})
    TriggerEvent('chat:addSuggestion', '/time', 'Change the time.', {{ name="hours", help="A number between 0 - 23"}, { name="minutes", help="A number between 0 - 59"}})
    TriggerEvent('chat:addSuggestion', '/freezetime', 'Freeze / unfreeze time.')
    TriggerEvent('chat:addSuggestion', '/freezeweather', 'Enable/disable dynamic weather changes.')
    TriggerEvent('chat:addSuggestion', '/morning', 'Set the time to 09:00')
    TriggerEvent('chat:addSuggestion', '/noon', 'Set the time to 12:00')
    TriggerEvent('chat:addSuggestion', '/evening', 'Set the time to 18:00')
    TriggerEvent('chat:addSuggestion', '/night', 'Set the time to 23:00')
    TriggerEvent('chat:addSuggestion', '/blackout', 'Toggle blackout mode.')
end)

-- Display a notification above the minimap.
function ShowNotification(text, blink)
    if blink == nil then blink = false end
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(blink, false)
end

RegisterNetEvent('vSync:notify')
AddEventHandler('vSync:notify', function(message, blink)
    ShowNotification(message, blink)
end)

--[[ UNIVERSAL MENU HOOKING STUFF ]]--
local weatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}
local itemBlackout, itemFreezeWeather, itemFreezeTime

AddEventHandler('menu:setup', function()
	TriggerServerEvent('vSync:canAddMenuItems')
end)

RegisterNetEvent('vSync:canAddMenuItems')
AddEventHandler('vSync:canAddMenuItems', function()
	TriggerEvent('menu:registerModuleMenu', 'vSync', function(id)
		-- Time
		TriggerEvent('menu:addModuleSubMenu', id, "Time", function(id)
			-- Change Time
			TriggerEvent('menu:addModuleSubMenu', id, "Change Time", function(id)
				TriggerEvent('menu:addModuleItem', id, "Morning", nil, false, function(id) TriggerEvent('vSync:time', {9, 0}) end)
				TriggerEvent('menu:addModuleItem', id, "Noon", nil, false, function(id) TriggerEvent('vSync:time', {12, 0}) end)
				TriggerEvent('menu:addModuleItem', id, "Evening", nil, false, function(id) TriggerEvent('vSync:time', {18, 0}) end)
				TriggerEvent('menu:addModuleItem', id, "Night", nil, false, function(id) TriggerEvent('vSync:time', {23, 0}) end)
			end, false)
		
			-- Freeze Time
			TriggerEvent('menu:addModuleItem', id, "Freeze Time", false, function(id)
				itemFreezeTime = id
			end, function(id)
				TriggerEvent('vSync:freezeTime')
			end)
		end, false)
		
		-- Weather
		TriggerEvent('menu:addModuleSubMenu', id, "Weather", function(id)
			-- Change Weather
			TriggerEvent('menu:addModuleSubMenu', id, "Change Weather", function(id)
				for _, weatherType in ipairs(weatherTypes) do
					TriggerEvent('menu:addModuleItem', id, weatherType, nil, false, function(id)
						TriggerEvent('vSync:weather', {weatherType})
					end)
				end
			end, false)
			
			-- Dynamic Weather
			TriggerEvent('menu:addModuleItem', id, "Dynamic Weather", true, function(id)
				itemFreezeWeather = id
			end, function(id)
				TriggerEvent('vSync:freezeWeather')
			end)
		end, false)
		
		-- Blackout
		TriggerEvent('menu:addModuleItem', id, "Blackout", false, function(id)
			itemBlackout = id
		end, function(id)
			TriggerEvent('vSync:blackout')
		end)
	end, false)
end)

RegisterNetEvent('vSync:time')
AddEventHandler('vSync:time', function(args)
	TriggerServerEvent('vSync:time', args)
end)

RegisterNetEvent('vSync:freezeTime')
AddEventHandler('vSync:freezeTime', function()
	TriggerServerEvent('vSync:freezeTime')
end)

RegisterNetEvent('vSync:itemFreezeTimeSync')
AddEventHandler('vSync:itemFreezeTimeSync', function(state)
	if itemFreezeTime then
		TriggerEvent('menu:setOnOffState', itemFreezeTime, state)
	end
end)

RegisterNetEvent('vSync:weather')
AddEventHandler('vSync:weather', function(args)
	TriggerServerEvent('vSync:weather', args)
end)

RegisterNetEvent('vSync:freezeWeather')
AddEventHandler('vSync:freezeWeather', function()
	TriggerServerEvent('vSync:freezeWeather')
end)

RegisterNetEvent('vSync:itemFreezeWeatherSync')
AddEventHandler('vSync:itemFreezeWeatherSync', function(state)
	if itemFreezeWeather then
		TriggerEvent('menu:setOnOffState', itemFreezeWeather, state)
	end
end)

RegisterNetEvent('vSync:blackout')
AddEventHandler('vSync:blackout', function()
	TriggerServerEvent('vSync:blackout')
end)

RegisterNetEvent('vSync:itemBlackoutSync')
AddEventHandler('vSync:itemBlackoutSync', function(state)
	if itemBlackout then
		TriggerEvent('menu:setOnOffState', itemBlackout, state)
	end
end)