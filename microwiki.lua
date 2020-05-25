VERSION = "1.0.0"

local micro = import("micro")
local config = import("micro/config")
local filepath = import("path/filepath")
local os = import("os")
local ioutil = import("io/ioutil")
local utf8 = import("utf8")
-- local shell = import("micro/shell")
-- local buffer = import("micro/buffer")
-- local action = import("micro/action")

local function fileName(absolutePath)
  local dir, file = filepath.Split(absolutePath)
  return file
end

local function getWikiLink(bufPane)
  local lineNo = bufPane.Cursor.Y
  local colNo = bufPane.Cursor.X
  local line = bufPane.Buf:Line(lineNo)

  local startCol = nil
  for i = colNo, 1, -1 do
    local chunk = line:sub(i-1, i)
    if chunk == "[[" then
      startCol = i+1
      break
    end
  end
  if startCol == nil then
    return nil
  end
  
  local endCol = nil
  for i = colNo, line:len(), 1 do
    local chunk = line:sub(i+1, i+2)
    if chunk == "]]" then
      endCol = i
      break
    end
  end
  if endCol == nil then
    return nil
  end
  
  return line:sub(startCol, endCol)
end

local function getWikiFile(bufPane)
  local link = getWikiLink(bufPane)
  -- do not go to dir/
  if link == nil or link:sub(-1) == "/" then
    return nil
  end
  return link .. ".md"
end

local function getLocalDir(absolutePath)
  local dir, file = filepath.Split(absolutePath)
  local cwd, err = os.Getwd()
  if err ~= nil then
    micro.InfoBar():Error(err)
    return nil
  end
  return dir:sub(cwd:len() + 2);
end

function go(bufPane)
  local file = getWikiFile(bufPane)
  local dir = getLocalDir(bufPane.Buf.AbsPath)
  if file == nil or dir == nil then
    return true
  end
  
  bufPane:Save()
  local filePath = filepath.Join(dir, file)
  bufPane:HandleCommand("tab \"" .. filePath .. "\"")  
  micro.InfoBar():Message("Wiki: Open \"" .. filePath .. "\"")

  return false
end

function back(bufPane)
  local dir = getLocalDir(bufPane.Buf.AbsPath)
  if dir == nil then
    return true
  end

  bufPane:Save()
  bufPane:Quit()
  local path = filepath.Join(dir, fileName(bufPane.Buf.AbsPath))
  micro.InfoBar():Message("Wiki: Saved \"" .. path .. "\"")
  return false
end

function autocomplete(bufPane)
  local link = getWikiLink(bufPane)
  if link == nil then
    return false
  end
  
  -- move cursor to end of link
  local colNo = bufPane.Cursor.X
  local line = bufPane.Buf:Line(bufPane.Cursor.Y)
  local start = line:find("]]", colNo, true)
  bufPane.Cursor.X = start - 1

  local base = filepath.Split(bufPane.Buf.AbsPath)
  local dir
  if link == "" then
    dir = base
  else
    dir = filepath.Join(base, link)
  end

  local localDir = getLocalDir(bufPane.Buf.AbsPath)
  if localDir == nil then
    localDir = dir
  end
  micro.InfoBar():Message("Wiki: List \"" .. localDir .. "\"")

  local files, err = ioutil.ReadDir(dir)
  if err ~= nil then
    micro.InfoBar():Error("Wiki: \"" .. link .. "\" is not a directory")
    return true
  end

  -- if last char is not "/", insert it
  if link ~= "" and link:sub(-1) ~= "/" then
    local rune, runeSize = utf8.DecodeRuneInString("/")
    bufPane:DoRuneInsert(rune)
  end

  local names = {}
  for i = 1, #files do
    local file = files[i]
    local name = file:Name()
    if file:IsDir() then
      names[i] = name .. "/"
    else
      names[i] = name:sub(1, -4)
    end
  end

  bufPane.Buf:Autocomplete(function(buf)
    return names, names
  end)

  return true
end

local function copyLoc(loc)
  local table = {}
  table["X"] = loc.X
  table["Y"] = loc.Y
  return table
end

local function gotoNextLink(bufPane, down)
  local match, found, err = bufPane.Buf:FindNext(
    "\\[\\[(.*?)\\]\\]", 
    bufPane.Buf:Start(), 
    bufPane.Buf:End(),
    -- needs copyLoc or throws
    -- bad argument #5 to FindNext (cannot use &{16 3} (type *buffer.Loc) as type buffer.Loc)
    copyLoc(bufPane.Cursor.Loc),
    down,
    true
  )
  if err ~= nil then
    micro.InfoBar():Error(err)
    return false
  end
  if found == false then
    return false
  end

  local loc = copyLoc(match[2])
  -- move cursor to the end of link accounting for "]]"
  loc["X"] = loc.X - 2
  bufPane.Cursor:GotoLoc(loc)
  return true
end

-- go to next wiki link
function preInsertTab(bufPane)
  local link = getWikiLink(bufPane)
  if link == nil then
    return true
  end
  
  if gotoNextLink(bufPane, true) then
    micro.InfoBar():Message("Wiki: Go to next link")
  end

  return false
end

-- go to previous wiki link
function preOutdentLine(bufPane)
  local link = getWikiLink(bufPane)
  if link == nil then
    return true
  end
  
  if gotoNextLink(bufPane, false) then
    micro.InfoBar():Message("Wiki: Go to previus link")
  end

  return false
end

function onBufPaneOpen(bufPane)
  -- necessary for micro to apply wiki link syntax
  bufPane.Buf:UpdateRules()
end

function init()
  -- used when creating newdir/newfile
  config.SetGlobalOption("mkparents", "true")
  -- remember cursor position, useful when navigating between files
  config.SetGlobalOption("savecursor", "true")

  -- extend markdown to include [[wikilink]] syntax
  config.AddRuntimeFile("microwiki", config.RTSyntax, "microwiki.yaml")
  config.AddRuntimeFile("microwiki", config.RTHelp, "help/microwiki.md")
  
  -- necessary for micro to load syntax file
  config.Reload()
  
  -- open [[link]].md in new tab
  config.TryBindKey("Alt-Enter", "lua:microwiki.go", false)
  
  -- save and close tab
  config.TryBindKey("Alt-Backspace", "lua:microwiki.back", false)
  
  -- activate autocomplete
  config.TryBindKey("Ctrl-Space", "lua:microwiki.autocomplete", false)
end
