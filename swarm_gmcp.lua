local swarm_gmcp = {
  start = function () --! prepares module to run on system startup
    S.g.check()
    S.g.events()
  end,

  events = function () --! registers event handlers on system startup
    if S.g.registered then return end --! prevents duplicate event handlers on soft reload
    --! room item gmcp events
    registerAnonymousEventHandler("gmcp.Room.Items.Add", "S.g.itemsAdd")
    registerAnonymousEventHandler("gmcp.Room.Items.Remove", "S.g.itemsRemove")
    registerAnonymousEventHandler("gmcp.Room.Items.List", "S.g.itemsList")
    registerAnonymousEventHandler("gmcp.Room.Items.Update", "S.g.itemsUpdate")
    registerAnonymousEventHandler("gmcp.Room.Items.StatusVars", "S.g.itemsStatusVars")
    --! room player gmcp events
    registerAnonymousEventHandler("gmcp.Room.Players", "S.g.playersParse")
    registerAnonymousEventHandler("gmcp.Room.AddPlayer", "S.g.playersAdd")
    registerAnonymousEventHandler("gmcp.Room.removePlayer", "S.g.playersRemove")
    --! character gmcp events
    registerAnonymousEventHandler("gmcp.Char.Status", "S.g.charStatus")
    registerAnonymousEventHandler("gmcp.Char.Vitals", "S.g.charVitals")
    registerAnonymousEventHandler("gmcp.Char.Skills.Groups", "S.g.charSkillsGet")
    registerAnonymousEventHandler("gmcp.Char.Skills.List", "S.g.charSkillsPop")
    --! denotes all gmcp event handlers are registered
    S.g.registered = true
  end,

  check = function ()
    if not gmcp then
      return S.e.error("Swarm needs GMCP to function. Please enable it and restart your profile.")
    end
    if not S.gmcp then
      sendGMCP('Core.Supports.Add ["Comm.Channel 1"]')
      sendGMCP("IRE.Rift.Request")
      S.gmcp = true
    end
  end,

  charStatus = function ()
    if not gmcp.Char or not gmcp.Char.Status then
      return S.e.echo("Swarm is waiting for a GMCP status packet.")
    end
  
    local stats = {
      "bank",
      "city",
      "class",
      "explorer",
      "fullname",
      "gold",
      "guild",
      "level",
      "name",
      "order",
      "race",
      "spec",
      "status",
      "unread_msgs",
      "unread_news",
    }
  
    for _, key in ipairs(stats) do
      S.stats.last[key] = S.stats[key]
      S.stats[key] = gmcp.Char.Status[key]
    end

    S.stats.class = S.stats.class:lower():gsub("(", ""):gsub(")", "")
    --! TODO: emit event for gmcp stats received/updated
  end,

  charVitals = function ()
    if not gmcp.Char or not gmcp.Char.Vitals then
      return S.e.echo("Swarm is waiting for a GMCP vitals packet.")
    end
  
    local bals = {
      "ability_bal",
      "balance",
      "elixir",
      "equilibrium",
      "focus",
      "herb",
      "left_arm",
      "moss",
      "pipe",
      "renew",
      "right_arm",
      "salve",
      "tree",
    }
  
    for _, bal in ipairs(bals) do
      -- if not S.bals[bal] and gmcp.Char.Vitals[bal] == "1" then
      --   if stopwatch[bal] then --! TODO: stopwatches and timers module
      --     stopwatch[bal] = nil
      --   end
      --   tmp.bals[bal] = true --! TODO: what's the purpose of also having this in tmp?
      --   fs.release() --! TODO: fs module?
      -- end

      S.bals[bal] = gmcp.Char.Vitals[bal] == "1" and true or false
      
    --   if S.bals[bal] then
    --     local used = bal .. "_used"
    --     local tobal = "to_" .. bal
    --     timers[tobal] = 0
    --     timers[used] = 0
    --     stopwatch[bal] = nil
    --   end
  end
  
    S.bals.sync = (S.bals.balance and S.bals.equilibrium) and true or false
  
    local vitals = {
      "bio",
      "class",
      "essence",
      "kai",
      "madness",
      "psi",
      "residual",
      "sandstorm",
      "shadowprice",
      "status",
      "wield_left",
      "wield_right",
    }
  
    for _, vital in ipairs(vitals) do
      S.vitals[vital] = gmcp.Char.Vitals[vital]
    end
  
    local states = {
      "blind",
      "burrowed",
      "cloak",
      "deaf",
      "fangbarrier",
      "flying",
      "mounted",
      "prone",
    }
  
    for _, state in ipairs(states) do
      S.vitals[state] = gmcp.Char.Vitals[state] == "1" and true or false
    end
  
    local numbered = {
      "bleeding",
      "blood",
      "devotion",
      "energy",
      "ep",
      "hp",
      "maxep",
      "maxhp",
      "maxmp",
      "maxwp",
      "maxxp",
      "mp",
      "nl",
      "residual",
      "soul",
      "spark",
      "wp",
      "xp",
    }
  
    for _,key in ipairs(numbered) do
      S.vitals[key] = tonumber(gmcp.Char.Vitals[key])
    end
  
    S.vitals.mutated = gmcp.Char.Vitals.mutated == "no" and false or true
    if S.vitals.mutated then
      S.stats.class = "shapeshifter"
    end
  end,

  charSkillsGet = function ()
    if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end
  
    S.skills = {}
  
    for _, set in ipairs(gmcp.Char.Skills.Groups) do
      local skills = string.format("Char.Skills.Get %s", yajl.to_string({ group = set.name }))
      sendGMCP(skills)
    end
    send("\n")
  end,

  charSkillsPop = function ()
    if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end
  
    local group = gmcp.Char.Skills.List.group
    local list = gmcp.Char.Skills.List.list
    local newList = {}
    for i, val in ipairs(list) do
      newList[i] = val:gsub("* ", ""):lower()
    end

    if group then
      S.skills[group] = newList
    end

    raiseEvent("swarm@gmcp skills pop") --! TODO: defs module needs handler for this
  end,

  hasSkill = function (skill, ability)
    if not gmcp or not gmcp.Char or not gmcp.Char.Skills then return end
    if not S.skills then return end
  
    if ability and S.skills[ability] then
      return table.contains(S.skills[ability], skill)
    else
      return false
    end
  end,

  hasAbility = function (ability)
    if not gmcp or not gmcp.Char or not gmcp.Char.Skills or not gmcp.Char.Skills.Groups then return end
  
    for _, v in pairs(gmcp.Char.Skills.Groups) do
      if v.name:lower() == ability then
        return true
      end
    end
  
    return false
  end,

  itemsAdd = function ()
    raiseEvent("swarm@gmcp items add")
  end,

  itemsRemove = function ()
    raiseEvent("swarm@gmcp items remove")
  end,

  itemsList = function ()
    raiseEvent("swarm@gmcp items list")
  end,

  itemsUpdate = function ()
    raiseEvent("swarm@gmcp items update")
  end,

  itemsStatusVars = function ()
    raiseEvent("swarm@gmcp items statusvars")
  end,

  playersParse = function ()
    raiseEvent("swarm@gmcp players parse")
  end,

  playersAdd = function ()
    raiseEvent("swarm@gmcp players add")
  end,

  playersRemove = function ()
    raiseEvent("swarm@gmcp players remove")
  end,
}

return swarm_gmcp
