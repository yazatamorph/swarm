local swarm_utils = {
  copyTable = function (source)
    local copy
    if type(source) == "table" then
      copy = {}
      for k, v in pairs(source) do
        copy[k] = v
      end
    else --! number, string, boolean, etc
      copy = source
    end
    return copy
  end,
}

return swarm_utils
