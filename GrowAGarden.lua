-- This script sends a simple test message to a Discord webhook.

local httpService = game:GetService("HttpService")

-- Your webhook URL
local webhookUrl = "https://discord.com/api/webhooks/140196794556691252/Wgt_QIl1e2ksR-7JQimJdQzspRhKGcojgfha_47enequD3zKLEdgYwQhiQ2JPvM9qHVd"

local success, err = pcall(function()
    -- Create the message payload
    local data = {
        content = "Hello, this is a test message from a Roblox script!"
    }
    
    -- Send the message
    httpService:PostAsync(webhookUrl, httpService:JSONEncode(data))
end)

-- Print the result to the executor console
if success then
    print("Webhook message sent successfully!")
else
    warn("Failed to send webhook message: " .. err)
end
