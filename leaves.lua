local channel = "crafter"
local crafter_dir = "white"
local other_dir = "blue"
local filter_dir = "green"

if event.type=="program" then
  mem.leaves = {}
  mem.status = ""
  interrupt(1)
end

local function is_leaves(s)
  return string.sub(s,-6) == "leaves" or string.sub(s,-4) == "twig" or string.sub(s,-7,-2) == "leaves" or string.sub(s,-7) == "needles"
end

local function add_leaves(n, c)
  if mem.leaves[n] then
    mem.leaves[n] = mem.leaves[n] + c
  else
    mem.leaves[n] = c
  end
  if mem.leaves[n]<1 then
    mem.leaves[n] = nil
  end
end

local function count_leaves()
  local c = 0
  for _,i in pairs(mem.leaves) do
    c = c + i
  end
  digiline_send("lcd", c.." leaves")
  return c
end

local function is_full(n, c)
  if mem.leaves[n] and mem.leaves[n]%99 + c < 100 then
    return false
  else
    local stacks = 0
    for _,i in pairs(mem.leaves) do
      stacks = stacks + math.ceil(i/99)
    end
    return stacks > 23
  end
end

local function remove_leaves()
  local L = {}
  for l,_ in pairs(mem.leaves) do
    L[#L+1] = l
  end
  local r = L[1]
  add_leaves(r, -1)
  return r
end

local function set_recipe(channel)
  local M = {} 
  for i=1, 6 do
    M[#M+1] = remove_leaves()
  end
  local recipe = {
    {M[1], M[2], M[3]},
    {M[4], M[5], M[6]},
    { "" ,  "" ,  "" }
  }
  digiline_send(channel, recipe)
end

if event.type =="item" then
  local n = event.item.name
  local c = event.item.count
  if is_leaves(n) and not is_full(n,c) then
    add_leaves(n, c)
    return crafter_dir
  else
    return other_dir
  end
end

if event.type == "interrupt" then
  if mem.status == "set" then
    digiline_send(channel, "single")
    mem.status = ""
  elseif count_leaves() > 5 then
    set_recipe(channel)
    mem.status = "set"
  end
  port[filter_dir] = not port[filter_dir]
  interrupt(.5)
end
