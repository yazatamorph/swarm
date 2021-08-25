S = S or {
  version = "0.1.0",
  sep = "|",
  on = false,
  paused = false,
  gmcp = false,
  modules = {},
}

function S.start()
  --! Required modules here
  S.u = require "swarm_utils"
  S.e = require "swarm_echoes" --! TODO: restyle with standard colors
  -- S.t = require "swarm_timers" --! TODO: needs to be written
  S.g = require "swarm_gmcp" --! TODO: needs to be completed
  --! Optional modules here
  --! find and load optional modules, e.g.:
  --! if swarm_module.lua exists then S.module = require "swarm_module" end
end

function S.togglePause()
  if S.paused then
    S.paused = false
    return
  end
  S.paused = true
end

function S.setSep(sep)
	S.sep = sep
	S.e.info("Config separator will now be: " .. sep, true, true)
	S.e.info("Attempting to reset command separator...", false, true)
	send("config separator off")
	send("config separator " .. S.sep)
end

function S.setConfigs()
	S.e.info("Attempting to reset command separator...", false, true)
	send("config separator off")
	send("config separator " .. S.sep)

	local configs = {
		"config affliction_view on",
		"config balance_taken on",
		"config combatmessages on",
		"config damage_change on",
		"config grabcorpses on",
		"config pagelength 250",
		"config random_fail off",
		"config simple_diag on",
		"config tellsprefix on",
		"config viewtitles off",
		"config wrapwidth 0",
		"firstaid off", --! TODO: need to check if curing module is included before sending this
	}

	S.e.info("Attempting to configure Aetolia-side settings...", false, true)

	for _, config in ipairs(configs) do
		send(config)
	end
end

function S.qq() --! needs refinement
	S.on = false --! indicates that the system is unloaded
	send("incall")
	S.e.info("Returning to the hive...", true, false)
	raiseEvent("swarm@core qq") --! TODO: modules with cleanup need a qq function, e.g. save cdb
	S.e.info("Character database saved.", true, false)
	S.e.info("Disconnecting. See you next time!", true, true)
	send("quit")
end

function S.onLoad()
	S.on = true --! indicates that the system is fully present and this function has fired on startup
  --! TODO: emit loaded & ready event (triggers, e.g., loading cdb)
end
