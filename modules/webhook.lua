local webhook = {}

webhook._contentType = { ["Content-Type"] = "application/json" }

local function send(url, data)
    local request, message = http.post(url, textutils.serializeJSON(data), webhook._contentType)

    if not request then
        return false, message
    end

    return true
end

function webhook:createWebhook(url, username, avatar_url)
    local hook = {}

    hook.url = url
    hook.username = username
    hook.avatar = avatar_url

    hook.sent = 0
    hook.createdEmbeds = {}

    function hook:sendMessage(message)
        return send(hook.url, {
            content = message,
            username = hook.username,
            avatar_url = hook.avatar
        })
    end

    function hook:sendEmbed(embed)
        if embed then
            return send(hook.url, { embeds = { embed.data }, content = "" })
        end
    end

    function hook:createEmbed(title, description)
        local embed = {}

        embed.data = {
            title = title,
            description = description,
            color = 0xFFFFFF,
            fields = {}
        }

        function embed:setAuthor(author)
            embed.data.author = { name = author }
        end

        function embed:setFooter(text)
            embed.data.footer = { text = text }
        end

        function embed:addField(name, value, inline)
            local field = { name = name, value = value, inline = inline ~= nil and inline or true }

            table.insert(embed.data.fields, field)
        end

        function embed:removeField(index)
            if embed.data.fields[index] then
                table.remove(embed.data.fields, index)
            end
        end

        function embed:addImage(url)
            embed.data.image = { url = url }
        end

        table.insert(hook.createdEmbeds, embed)

        return embed
    end

    return hook
end

function webhook:getUrlFromFile(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local url = file.readAll()
        file.close()

        if url and http.checkURL(url) then
            return url
        end
    end

    return false
end

function webhook:saveUrlToFile(url, path)
    if url and path then
        if fs.exists(path) then
            fs.delete(path)
        end

        local file = fs.open(path, "w")
        file.write(url)
        file.close()

        return true
    end

    return false
end

function webhook:update()
    if fs.exists("webhook") then
        fs.delete("webhook")
    end

    shell.run("pastebin get ybU4xHv6 webhook")
end

return webhook
