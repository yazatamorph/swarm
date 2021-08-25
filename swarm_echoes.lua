local swarm_echoes = {
  echo = function (str, pre, post) --! pre: new line before, post: new line after
    if pre then echo("\n") end
    cecho(string.format("%s", "<medium_sea_green>(<aquamarine>Swarm<medium_sea_green>): <slate_blue>Update: <grey>") .. str:title())
    if post then echo("\n") end
  end,

  error = function (str, pre, post)
		if pre then echo("\n") end
		cecho(string.format("%s", "<medium_sea_green>(<aquamarine>Swarm<medium_sea_green>): <white:red>Error:<red:black> ") .. str:title())
		if post then echo("\n") end
  end,

  info = function (str, pre, post)
		if pre then echo("\n") end
		cecho(string.format("%s", "<medium_sea_green>(<aquamarine>Swarm<medium_sea_green>): <goldenrod>Info: <grey>") .. str:title())
		if post then echo("\n") end
  end,

  warn = function (str, pre, post)
		if pre then echo("\n") end
		cecho(string.format("%s", "<medium_sea_green>(<aquamarine>Swarm<medium_sea_green>): <orange_red>Warning:<navajo_white> ") .. str:title())
		if post then echo("\n") end
  end,
}

return swarm_echoes
