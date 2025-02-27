---@diagnostic disable: undefined-global, lowercase-global, undefined-doc-name, undefined-field

-------------------------------------------------- Lua Funcs -----------------------------------------------------------------
lua_Fn = {

  ---Checks whether a string starts with the provided prefix and returns true or false.
  ---@param str string
  ---@param prefix string
  str_startswith = function(str, prefix)
    return str:sub(1, #prefix) == prefix
  end,

  ---Checks whether a string contains the provided substring and returns true or false.
  ---@param str string
  ---@param sub string
  str_contains = function(str, sub)
    return str:find(sub, 1, true) ~= nil
  end,

  ---Checks whether a string ends with the provided suffix and returns true or false.
  ---@param str string
  ---@param suffix string
  str_endswith = function(str, suffix)
    return str:sub(- #suffix) == suffix
  end,

  ---Inserts a string into another string at the given position. (Indexes start from 0).
  ---@param str string
  ---@param pos integer
  ---@param text string
  str_insert = function(str, pos, text)
    return str:sub(1, pos) .. text .. str:sub(pos)
  end,

  ---Replaces a string with a new string.
  ---@param str string
  ---@param old string
  ---@param new string
  str_replace = function(str, old, new)
    local search_index = 1
    while true do
      local start_index, end_index = str:find(old, search_index, true)
      if not start_index then
        break
      end
      local changed = str:sub(end_index + 1)
      result = str:sub(1, (start_index - 1)) .. new .. changed
      search_index = -1 * changed:len()
    end
    return result
  end,

  ---Returns a string containing the input value separated by the thousands and prefixed by a dollar sign.
  ---@param value integer | string
  --[[ -- Example:

      formatMoney(42069)
        -> "$42,069"
  ]]
  formatMoney = function(value)
    return "$" .. tostring(value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
  end,

  ---Must be called from inside a coroutine. Input time is in milliseconds.
  ---@param s integer
  sleep = function(s)
    local ntime = os.clock() + (s / 1000)
    repeat
      coroutine.yield()
    until
      os.clock() > ntime
  end,

  ---Converts HEX strings to RGB integers. Returns 3 separate numbers representing Red, Green and Blue respectively.
  ---@param hex string
  hexToRGB = function(hex)
    local r, g, b
    hex = hex:gsub("#", "")
    if hex:len() == 3 then -- short HEX
      r, g, b = (tonumber("0x" .. hex:sub(1, 1)) * 17) / 255, (tonumber("0x" .. hex:sub(2, 2)) * 17) / 255,
          (tonumber("0x" .. hex:sub(3, 3)) * 17) / 255
    else
      r, g, b = tonumber("0x" .. hex:sub(1, 2)) / 255, tonumber("0x" .. hex:sub(3, 4)) / 255,
          tonumber("0x" .. hex:sub(5, 6)) / 255
    end
    return r, g, b
  end,

  ---Iterates over a table and returns the value from each key.
  ---@param table table
  iter = function(table)
    local i = 0
    local n = #table
    return function()
      i = i + 1
      if i <= n then
        return table[i]
      end
    end
  end,

  ---Returns the number of duplicate values in a table.
  ---@param table table
  ---@param value any
  getTableDupes = function(table, value)
    local count = 0
    for _, v in pairs(table) do
      if value == v then
        count = count + 1
      end
    end
    return count
  end,

  ---Converts 0 and 1 values to bools.
  ---@param value integer
  get_bool = function(value)
    if type(value) == "number" then
      if value == 0 then
        return false
      elseif value == 1 then
        return true
      else
        return error("Incorrect value", 2)
      end
    else
      return error("Incorrect value", 2)
    end
  end,

  ---Lua version of Bob Jenskins' "Jenkins One At A Time" hash function (https://en.wikipedia.org/wiki/Jenkins_hash_function).
  ---@param key string
  ---@return integer
  joaat = function(key)
    local hash = 0
    for i = 1, #key do
      hash = hash + string.byte(key, i)
      hash = hash + (hash << 10)
      hash = hash & 0xffffffff
      hash = hash ~ (hash >> 6)
    end
    hash = hash + (hash << 3)
    hash = hash & 0xffffffff
    hash = hash ~ (hash >> 11)
    hash = hash + (hash << 15)
    hash = hash & 0xffffffff
    return hash
  end
}

-------------------------------------------------- ImGui Stuff ---------------------------------------------------------------
UI = {
  ---@param col string | table
  getColor = function(col)
    local r, g, b
    local errorMsg = ""
    if type(col) == "string" then
      if col:find("^#") then
        r, g, b = lua_Fn.hexToRGB(col)
      elseif col == "black" then
        r, g, b = 0, 0, 0
      elseif col == "white" then
        r, g, b = 1, 1, 1
      elseif col == "red" then
        r, g, b = 1, 0, 0
      elseif col == "green" then
        r, g, b = 0, 1, 0
      elseif col == "blue" then
        r, g, b = 0, 0, 1
      elseif col == "yellow" then
        r, g, b = 1, 1, 0
      elseif col == "orange" then
        r, g, b = 1, 0.5, 0
      elseif col == "pink" then
        r, g, b = 1, 0, 0.5
      elseif col == "purple" then
        r, g, b = 1, 0, 1
      else
        r, g, b = 1, 1, 1
        errorMsg = ("'" .. tostring(col) .. "' is not a valid color for this function.\nOnly these strings can be used as color inputs:\n - 'black'\n - 'white'\n - 'red'\n - 'green'\n - 'blue'\n - 'yellow'\n - 'orange'\n - 'pink'\n - 'purple'")
      end
    elseif type(col) == "table" then
      -- check color input values and convert them to floats between 0 and 1 which is what ImGui accepts for color values.
      if col[1] > 1 then
        col[1] = col[1] / 255
      end
      if col[2] > 1 then
        col[2] = col[2] / 255
      end
      if col[3] > 1 then
        col[3] = col[3] / 255
      end
      r, g, b = col[1], col[2], col[3]
    end
    return r, g, b, errorMsg
  end,

  ---Creates a colored ImGui text.
  ---@param text string
  ---@param color string | table
  ---@param alpha integer
  ---@param wrap_size number
  --[[ -- Usage:
    - text: The text to display.
    - color: Can be either a HEX string (both short and long hex formats are accepted) or a table containing 3 color numbers in RGB format (you can use standard RGB values between 0 and 255 or ImGui values between 0 and 1), or a string literal (ex: "red").
    - alpha: A value between 0 and 1 representing visibility.
    - wrap_size: A number representing the size your text will wrap around.
  ]]
  coloredText = function(text, color, alpha, wrap_size)
    r, g, b, errorMsg = UI.getColor(color)
    if type(alpha) ~= "number" or alpha == nil then
      alpha = 1
    end
    if alpha > 1 then
      alpha = 1
    end
    if alpha < 0.1 then
      alpha = 0.1
    end
    ImGui.PushStyleColor(ImGuiCol.Text, r, g, b, alpha)
    ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
    ImGui.TextWrapped(text)
    ImGui.PopTextWrapPos()
    ImGui.PopStyleColor(1)
    if errorMsg ~= "" then
      if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
        ImGui.SetNextWindowBgAlpha(0.8)
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * wrap_size)
        ImGui.TextWrapped(errorMsg)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
      end
    end
  end,

  ---Creates a colored ImGui button.
  ---@param text string
  ---@param color string | table
  ---@param hovercolor string | table
  ---@param activecolor string | table
  ---@param alpha integer
  ---@return boolean
  --[[ -- Usage:
    - text: The button label.
    - color: The default button color. Can be either a HEX string (both short and long hex formats are accepted), a table containing 3 color numbers in RGB format (you can use standard RGB values between 0 and 255 or ImGui values between 0 and 1), or a string literal (ex: "red").
    - hovercolor: The color the button will change to when it's hovered. Same format as the 'color' parameter.
    - activecolor: The color the button will change to when it's clicked. Same format as the 'color' parameter.
    - alpha: A value between 0 and 1 representing visibility.
  ]]
  coloredButton = function(text, color, hovercolor, activecolor, alpha)
    local r, g, b                   = UI.getColor(color)
    local hoverR, hoverG, hoverB    = UI.getColor(hovercolor)
    local activeR, activeG, activeB = UI.getColor(activecolor)
    if type(alpha) ~= "number" or alpha == nil then
      alpha = 1
    end
    if alpha > 1 then
      alpha = 1
    end
    if alpha < 0.1 then
      alpha = 0.1
    end
    ImGui.PushStyleColor(ImGuiCol.Button, r, g, b, alpha)
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, hoverR, hoverG, hoverB, alpha)
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, activeR, activeG, activeB, alpha)
    local retVal = ImGui.Button(text)
    ImGui.PopStyleColor(3)
    return retVal
  end,

  ---Creates a (?) symbol in front of the widget this function is called after. When the symbol is hovered, it displays a tooltip.
  ---@param colorFlag boolean
  ---@param text string
  ---@param color? string | table | any
  ---@param alpha? integer | any
  --[[ -- Usage:
    - colorFlag: true/false. If set to true, the color parameter will be required and the provided text will be colored, otherwise the color parameter will be ignored and can be left empty.
    - text: The text that will be displayed inside the tooltip.
    - color: Can be either a HEX string (both short and long hex formats are accepted), a table containing 3 color numbers in RGB format (you can use standard RGB values between 0 and 255 or ImGui values between 0 and 1), or a string literal (ex: "red"). If colorFlag is set to true, this parameter will be required.
    - alpha: A value between 0 and 1 representing visibility. If left empty it defaults to 1.
  ]]
  helpMarker = function(colorFlag, text, color, alpha)
    if not disableTooltips then
      ImGui.SameLine()
      ImGui.TextDisabled("(?)")
      if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
        ImGui.SetNextWindowBgAlpha(0.75)
        ImGui.BeginTooltip()
        if colorFlag == true then
          UI.coloredText(text, color, alpha, 20)
        else
          ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
          ImGui.TextWrapped(text)
          ImGui.PopTextWrapPos()
        end
        ImGui.EndTooltip()
      end
    end
  end,

  ---Displays a tooltip whenever the widget this function is called after is hovered.
  ---@param colorFlag boolean
  ---@param text string
  ---@param color? any
  ---@param alpha? any
  --[[ -- Usage:
    - colorFlag: true/false. If set to true, the color parameter will be required and the provided text will be colored otherwise the color parameter will be ignored and can be left empty.
    - text: The text that will be displayed inside the tooltip.
    - color: Can be either a HEX string (both short and long hex formats are accepted), a table containing 3 color numbers in RGB format (you can use standard RGB values between 0 and 255 or ImGui values between 0 and 1), or a string literal (ex: "red"). If colorFlag is set to true, this parameter will be required.
    - alpha: A value between 0 and 1 representing visibility. If left empty it defaults to 1.
  ]]
  toolTip = function(colorFlag, text, color, alpha)
    if not disableTooltips then
      if ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) then
        ImGui.SetNextWindowBgAlpha(0.75)
        ImGui.BeginTooltip()
        if colorFlag == true then
          UI.coloredText(text, color, alpha, 20)
        else
          ImGui.PushTextWrapPos(ImGui.GetFontSize() * 20)
          ImGui.TextWrapped(text)
          ImGui.PopTextWrapPos()
        end
        ImGui.EndTooltip()
      end
    end
  end,

  ---Checks if an ImGui widget was clicked with either the left or the right mouse button.
  ---@param mb string
  ---@return boolean
  --[[

  **Usage:**
  - mb: A string representing a mouse button. Can be either "lmb" for Left Mouse Button or "rmb" for Right Mouse Button.
  ]]
  isItemClicked = function(mb)
    local retBool = false
    if mb == "lmb" then
      retBool = ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(0)
    elseif mb == "rmb" then
      retBool = ImGui.IsItemHovered(ImGuiHoveredFlags.AllowWhenDisabled) and ImGui.IsItemClicked(1)
    else
      error(
        "error in function isItemClicked: Invalid mouse button. Correct inputs: 'lmb' as Left Mouse Button or 'rmb' as Right Mouse Button.",
        2)
    end
    return retBool
  end,

  -- Plays a sound when an ImGui widget is clicked.
  ---@param sound string
  --[[

  **Sound strings:**

  "Select" | "Select2" | "Cancel" | "Error" | "Nav" | "Nav2" | "Pickup" | "Radar" | "Delete" | "W_Pickup" | "Focus_In" | "Focus_Out"
  ]]
  widgetSound = function(sound)
    if not disableUiSounds then
      local sounds_T = {
        { name = "Radar",     sound = "RADAR_ACTIVATE",      soundRef = "DLC_BTL_SECURITY_VANS_RADAR_PING_SOUNDS" },
        { name = "Select",    sound = "SELECT",              soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
        { name = "Pickup",    sound = "PICK_UP",             soundRef = "HUD_FRONTEND_DEFAULT_SOUNDSET" },
        { name = "W_Pickup",  sound = "PICK_UP_WEAPON",      soundRef = "HUD_FRONTEND_CUSTOM_SOUNDSET" },
        { name = "Delete",    sound = "DELETE",              soundRef = "HUD_DEATHMATCH_SOUNDSET" },
        { name = "Cancel",    sound = "CANCEL",              soundRef = "HUD_FREEMODE_SOUNDSET" },
        { name = "Error",     sound = "ERROR",               soundRef = "HUD_FREEMODE_SOUNDSET" },
        { name = "Nav",       sound = "NAV_LEFT_RIGHT",      soundRef = "HUD_FREEMODE_SOUNDSET" },
        { name = "Nav2",      sound = "NAV_UP_DOWN",         soundRef = "HUD_FREEMODE_SOUNDSET" },
        { name = "Select2",   sound = "CHANGE_STATION_LOUD", soundRef = "RADIO_SOUNDSET" },
        { name = "Focus_In",  sound = "FOCUSIN",             soundRef = "HINTCAMSOUNDS" },
        { name = "Focus_Out", sound = "FOCUSOUT",            soundRef = "HINTCAMSOUNDS" },
      }
      script.run_in_fiber(function()
        for _, snd in ipairs(sounds_T) do
          if sound == snd.name then
            AUDIO.PLAY_SOUND_FRONTEND(-1, snd.sound, snd.soundRef, true)
            break
          end
        end
      end)
    end
  end,
}

----------------------------------------------- GTA Funcs -------------------------------------------------------
Game = {

  -- Returns GTA V's latest build number.
  GetBuildNumber = function()
    local game_build = memory.scan_pattern("8B C3 33 D2 C6 44 24 20"):add(0x24):rip()
    return tonumber(game_build:get_string())
  end,

  GetLang = function()
    local language_codes_T = {
        { name = "English",             id = 0,  iso = "en-US" },
        { name = "French",              id = 1,  iso = "fr-FR" },
        { name = "German",              id = 2,  iso = "de-DE" },
        { name = "Italian",             id = 3,  iso = "it-IT" },
        { name = "Spanish, Spain",      id = 4,  iso = "es-ES" },
        { name = "Portugese",           id = 5,  iso = "pt-BR" },
        { name = "Polish",              id = 6,  iso = "pl-PL" },
        { name = "Russian",             id = 7,  iso = "ru-RU" },
        { name = "Korean",              id = 8,  iso = "ko-KR" },
        { name = "Chinese Traditional", id = 9,  iso = "zh-TW" },
        { name = "Japanese",            id = 10, iso = "ja-JP" },
        { name = "Spanish, Mexico",     id = 11, iso = "es-MX" },
        { name = "Chinese Simplified",  id = 12, iso = "zh-CN" },
    }
    local lang_iso, lang_name
    local lang = LOCALIZATION.GET_CURRENT_LANGUAGE()
    for _, l in ipairs(language_codes_T) do
        if lang == l.id then
            lang_iso  = l.iso
            lang_name = l.name
            break
        else
            lang_iso  = "en-US"
            lang_name = "English"
        end
    end
    return lang_iso, lang_name
  end,

  isOnline = function()
    if NETWORK.NETWORK_IS_GAME_IN_PROGRESS() and NETWORK.NETWORK_IS_SESSION_ACTIVE() then
      return true
    else
      return false
    end
  end,

  updatePlayerList = function()
    filteredPlayers = {}
    local players = entities.get_all_peds_as_handles()
    for _, ped in ipairs(players) do
      if PED.IS_PED_A_PLAYER(ped) then
        if NETWORK.NETWORK_IS_PLAYER_ACTIVE(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)) then
          table.insert(filteredPlayers, ped)
        end
      end
    end
  end,

  -- Grabs all players in a session and displays them inside an ImGui combo.
  displayPlayerList = function()
    Game.updatePlayerList()
    local playerNames = {}
    for _, player in ipairs(filteredPlayers) do
      local playerName  = PLAYER.GET_PLAYER_NAME(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(player))
      local playerHost  = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX()
      local friendCount = NETWORK.NETWORK_GET_FRIEND_COUNT()
      if NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(player) == PLAYER.PLAYER_ID() then
        playerName = playerName .. "  [You]"
      end
      if friendCount > 0 then
        for i = 0, friendCount do
          if playerName == NETWORK.NETWORK_GET_FRIEND_NAME(i) then
            playerName = playerName .. "  [Friend]"
          end
        end
      end
      if playerHost == NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(player) then
        playerName = playerName .. "  [Host]"
      end
      table.insert(playerNames, playerName)
    end
    playerIndex, used = ImGui.Combo("##playerList", playerIndex, playerNames, #filteredPlayers)
  end,

  -- Returns the number of players in an online session.
  ---@return number
  getPlayerCount = function()
    local retNum
    if Game.isOnline() then
      retNum = NETWORK.NETWORK_GET_NUM_CONNECTED_PLAYERS()
    else
      retNum = 0
    end
    return retNum
  end,

  -- Returns the player's cash
  ---@param player integer
  getPlayerWallet = function(player)
    local wallet     = (tonumber(lua_Fn.str_replace(MONEY.NETWORK_GET_STRING_WALLET_BALANCE(player), "$", "")))
    local wallet_int = wallet
    local formatted  = lua_Fn.formatMoney(wallet)
    return formatted, wallet_int
  end,

  -- Returns the player's bank balance
  ---@param player integer
  getPlayerBank = function(player)
    local _, wallet = Game.getPlayerWallet(player)
    local bank = (tonumber(lua_Fn.str_replace(MONEY.NETWORK_GET_STRING_BANK_WALLET_BALANCE(player), "$", "")) - wallet)
    return lua_Fn.formatMoney(bank)
  end,

  ---@param text string
  ---@param type integer
  busySpinnerOn = function(text, type)
    HUD.BEGIN_TEXT_COMMAND_BUSYSPINNER_ON("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
    HUD.END_TEXT_COMMAND_BUSYSPINNER_ON(type)
  end,

  busySpinnerOff = function()
    return HUD.BUSYSPINNER_OFF()
  end,

  ---@param entity integer
  createBlip = function(entity)
    return HUD.ADD_BLIP_FOR_ENTITY(entity)
  end,

  ---Full list of blip icon IDs: https://wiki.rage.mp/index.php?title=Blips
  ---@param blip integer
  ---@param icon integer
  blipIcon = function(blip, icon)
    HUD.SET_BLIP_SPRITE(blip, icon)
  end,

  ---Sets a custom name for a blip. Custom names appear on the pause menu and the world map.
  ---@param blip integer
  ---@param name string
  blipName = function(blip, name)
    HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(name)
    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
  end,

  ---@param model integer
  requestModel = function(model)
    local counter = 0
    while not STREAMING.HAS_MODEL_LOADED(model) do
      STREAMING.REQUEST_MODEL(model)
      coroutine.yield()
      if counter > 100 then
        return
      else
        counter = counter + 1
      end
    end
    return STREAMING.HAS_MODEL_LOADED(model)
  end,

  ---@param dict string
  requestNamedPtfxAsset = function(dict)
    local counter = 0
    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(dict) do
      STREAMING.REQUEST_NAMED_PTFX_ASSET(dict)
      coroutine.yield()
      if counter > 100 then
        return
      else
        counter = counter + 1
      end
    end
    return STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(dict)
  end,

  ---@param dict string
  requestAnimDict = function(dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do
      STREAMING.REQUEST_ANIM_DICT(dict)
      coroutine.yield()
    end
    return STREAMING.HAS_ANIM_DICT_LOADED(dict)
  end,

  ---@param entity integer
  ---@param isAlive boolean
  getCoords = function(entity, isAlive)
    return ENTITY.GET_ENTITY_COORDS(entity, isAlive)
  end,

  ---@param entity integer
  getHeading = function(entity)
    return ENTITY.GET_ENTITY_HEADING(entity)
  end,

  ---@param entity integer
  getForwardX = function(entity)
    return ENTITY.GET_ENTITY_FORWARD_X(entity)
  end,

  ---@param entity integer
  getForwardY = function(entity)
    return ENTITY.GET_ENTITY_FORWARD_Y(entity)
  end,

  ---@param entity integer
  getForwardVec = function(entity)
    return ENTITY.GET_ENTITY_FORWARD_VECTOR(entity)
  end,

  ---@param ped integer
  ---@param boneID integer
  getPedBoneIndex = function(ped, boneID)
    return PED.GET_PED_BONE_INDEX(ped, boneID)
  end,

  ---@param ped integer
  ---@param boneID integer
  getPedBoneCoords = function(ped, boneID)
    return PED.GET_PED_BONE_COORDS(ped, boneID)
  end,

  ---@param entity integer
  ---@param boneName string
  getEntityBoneIndexByName = function(entity, boneName)
    return ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(entity, boneName)
  end,

  ---@param entity integer
  ---@param boneName string
  getWorldPosFromEntityBone = function(entity, boneName)
    local boneIndex = Game.getEntityBoneIndexByName(entity, boneName)
    return ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, boneIndex)
  end,

  ---@param entity integer
  ---@param boneName string
  getEntityBonePos = function(entity, boneName)
    local boneIndex = Game.getEntityBoneIndexByName(entity, boneName)
    return ENTITY.GET_ENTITY_BONE_POSTION(entity, boneIndex)
  end,

  ---@param entity integer
  ---@param boneName string
  getEntityBoneRot = function(entity, boneName)
    local boneIndex = Game.getEntityBoneIndexByName(entity, boneName)
    return ENTITY.GET_ENTITY_BONE_ROTATION(entity, boneIndex)
  end,

  ---@param entity integer
  getEntityBoneCount = function(entity)
    return ENTITY.GET_ENTITY_BONE_COUNT(entity)
  end,

  ---Returns the entity localPlayer is aiming at.
  getAimedEntity = function()
    local Entity = 0
    if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) then
      _, Entity = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(PLAYER.PLAYER_ID(), Entity)
    end
    return Entity
  end,

  ---Gets the hash from an entity handle.
  ---@param entity integer
  getEntityModel = function(entity)
    return ENTITY.GET_ENTITY_MODEL(entity)
  end,

  ---Returns a readable entity type (human, animal, vehicle, object).
  ---@param entity integer
  getEntityTypeString = function(entity)
    local type = ENTITY.GET_ENTITY_TYPE(entity)
    local definedType
    if type == 0 then
      definedType = "None"
    elseif type == 1 then
      if PED.IS_PED_HUMAN(entity) then
        definedType = "Human"
      else
        if ENTITY.GET_ENTITY_MODEL(entity) == 351016938 then
          definedType = "Chop <3"
        else
          definedType = "Animal/Non-Human Ped"
        end
      end
    elseif type == 2 then
      definedType = "Vehicle"
    elseif type == 3 then
      definedType = "Object"
    else
      definedType = "Invalid"
    end
    return definedType
  end,

  ---Returns a number for the vehicle seat the provided ped is sitting in (-1 driver, 0 front passenger, etc...).
  ---@param ped integer
  getPedVehicleSeat = function(ped)
    if PED.IS_PED_SITTING_IN_ANY_VEHICLE(ped) then
      local pedSeat
      local vehicle  = PED.GET_VEHICLE_PED_IS_IN(ped, false)
      local maxSeats = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(vehicle))
      for i = -1, maxSeats do
        if not VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, true) then
          local sittingPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i, true)
          if sittingPed == ped then
            pedSeat = i
            break
          end
        end
      end
      return pedSeat
    end
  end,

  ---Returns an entity handle for the closest vehicle to a provided entity.
  ---@param closeTo integer
  ---@param range integer
  getClosestVehicle = function(closeTo, range)
    local vehicleHandles = entities.get_all_vehicles_as_handles()
    local closestVehicle = 0
    for _, veh in ipairs(vehicleHandles) do
      local thisPos = ENTITY.GET_ENTITY_COORDS(closeTo, true)
      local vehPos  = ENTITY.GET_ENTITY_COORDS(veh, true)
      local vDist   = SYSTEM.VDIST2(thisPos.x, thisPos.y, thisPos.z, vehPos.x, vehPos.y, vehPos.z)
      if vDist <= range then
        closestVehicle = veh
      end
    end
    return closestVehicle
  end,

  ---Returns an entity handle for the closest human ped to a provided entity.
  ---@param closeTo integer
  ---@param range integer
  getClosestPed = function(closeTo, range)
    local closestPed = 0
    local gtaPeds = entities.get_all_peds_as_handles()
    for _, ped in ipairs(gtaPeds) do
      if PED.IS_PED_HUMAN(ped) and ped ~= self.get_ped() then
        local thisPos      = ENTITY.GET_ENTITY_COORDS(closeTo, true)
        local randomPedPos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local distCalc     = SYSTEM.VDIST2(thisPos.x, thisPos.y, thisPos.z, randomPedPos.x, randomPedPos.y,
          randomPedPos.z)
        if distCalc <= range then
          if not ENTITY.IS_ENTITY_DEAD(ped) then
            closestPed = ped
          end
        end
      end
    end
    return closestPed
  end,

  ---Returns a sol pointer object from a game entity.
  ---@param gameEntity integer
  getEntPtr = function(gameEntity)
    return memory.handle_to_ptr(gameEntity)
  end,

  Self = {

    -- Returns localPlayer's maximum health.
    maxHealth = function()
      return ENTITY.GET_ENTITY_MAX_HEALTH(self.get_ped())
    end,

    -- Returns localPlayer's current health.
    health = function()
      return ENTITY.GET_ENTITY_HEALTH(self.get_ped())
    end,

    -- Returns localPlayer's current armour
    armour = function()
      return PED.GET_PED_ARMOUR(self.get_ped())
    end,

    -- Checks if localPlayer is alive.
    isAlive = function()
      if ENTITY.IS_ENTITY_DEAD(self.get_ped()) then
        return false
      else
        return true
      end
    end,

    -- Checks if localPlayer is on foot.
    ---@return boolean
    isOnFoot = function()
      return PED.IS_PED_ON_FOOT(self.get_ped())
    end,

    -- Checks if localPlayer is in the water.
    ---@return boolean
    isInWater = function()
      return ENTITY.IS_ENTITY_IN_WATER(self.get_ped())
    end,

    -- Checks if localPlayer is outside.
    isOutside = function()
      if INTERIOR.GET_INTERIOR_FROM_ENTITY(self.get_ped()) == 0 then
        return true
      else
        return false
      end
    end,

    isMoving = function()
      if PED.IS_PED_STOPPED(self.get_ped()) then
        return false
      else
        return true
      end
    end,

    isDriving = function()
      local retBool
      if not Game.Self.isOnFoot() then
        if Game.getPedVehicleSeat(self.get_ped()) == -1 then
          retBool = true
        else
          retBool = false
        end
      else
        retBool = false
      end
      return retBool
    end,

    -- Returns the hash of localPlayer's selected weapon.
    ---@return number
    weapon = function()
      local weaponHash
      check, weapon = WEAPON.GET_CURRENT_PED_WEAPON(self.get_ped(), weapon, 0)
      if check then
        weaponHash = weapon
      end
      return weaponHash
    end,

    -- Teleports localPlayer to the provided coordinates.
    ---@param keepVehicle boolean
    ---@param coords vector3
    teleport = function(keepVehicle, coords)
      script.run_in_fiber(function(selftp)
        STREAMING.REQUEST_COLLISION_AT_COORD(coords.x, coords.y, coords.z)
        selftp:sleep(200)
        if keepVehicle then
          PED.SET_PED_COORDS_KEEP_VEHICLE(self.get_ped(), coords.x, coords.y, coords.z)
        else
          if not Game.Self.isOnFoot() then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(self.get_ped())
          end
          ENTITY.SET_ENTITY_COORDS(self.get_ped(), coords.x, coords.y, coords.z, false, false, true)
        end
      end)
    end,
  },

  Vehicle = {

    -- Returns the name of the vehicle localPlayer is sitting in.
    name = function()
      ---@type string
      local retVal
      if not Game.Self.isOnFoot() then
        retVal = vehicles.get_vehicle_display_name(Game.getEntityModel(self.get_veh()))
      else
        retVal = ""
      end
      return retVal
    end,

    -- Returns the manufacturer name of the vehicle localPlayer is sitting in.
    manufacturer = function()
      ---@type string
      local retVal
      if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
        local mfr = VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(Game.getEntityModel(self.get_veh()))
        retVal = (mfr:lower():gsub("^%l", string.upper))
      else
        retVal = ""
      end
      return retVal
    end,

    -- Returns the class of the vehicle localPlayer is sitting in.
    class = function()
      ---@type string
      local retVal
      local class_T = {
        { class = 0,  name = "Compacts" },
        { class = 1,  name = "Sedans" },
        { class = 2,  name = "SUVs" },
        { class = 3,  name = "Coupes" },
        { class = 4,  name = "Muscle" },
        { class = 5,  name = "Sports Classics" },
        { class = 6,  name = "Sports" },
        { class = 7,  name = "Super" },
        { class = 8,  name = "Motorcycles" },
        { class = 9,  name = "Off-road" },
        { class = 10, name = "Industrial" },
        { class = 11, name = "Utility" },
        { class = 12, name = "Vans" },
        { class = 13, name = "Cycles" },
        { class = 14, name = "Boats" },
        { class = 15, name = "Helicopters" },
        { class = 16, name = "Planes" },
        { class = 17, name = "Service" },
        { class = 18, name = "Emergency" },
        { class = 19, name = "Military" },
        { class = 20, name = "Commercial" },
        { class = 21, name = "Trains" },
      }

      if not Game.Self.isOnFoot() then
        for _, v in ipairs(class_T) do
          if VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) == v.class then
            retVal = v.name
            break
          end
        end
      else
        retVal = ""
      end
      return retVal
    end,

    -- Returns whether a vehicle has weapons or not.
    ---@return boolean
    weaponized = function()
      return VEHICLE.DOES_VEHICLE_HAVE_WEAPONS(self.get_veh())
    end,
  },
}


--[[
  #### RXI JSON Library

  <u>Credits:</u> [rxi's json.lua](https://github.com/rxi/json.lua).

  *Permission is hereby granted, free of charge, to any person obtaining a copy of
  this software and associated documentation files (the "Software"), to deal in
  the Software without restriction, including without limitation the rights to
  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
  of the Software, and to permit persons to whom the Software is furnished to do
  so, subject to the following conditions:*

  *- The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.*

  *THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.*

  Copyright (c) 2020 rxi
]]
function json()
  local json = { _version = "0.1.2" }
  --encode
  local encode

  local escape_char_map = {
    ["\\"] = "\\",
    ["\""] = "\"",
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
  }

  local escape_char_map_inv = { ["/"] = "/" }
  for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
  end

  local function escape_char(c)
    return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
  end

  local function encode_nil(val)
    return "null"
  end

  local function encode_table(val, stack)
    local res = {}
    stack = stack or {}
    if stack[val] then error("circular reference") end

    stack[val] = true

    if rawget(val, 1) ~= nil or next(val) == nil then
      local n = 0
      for k in pairs(val) do
        if type(k) ~= "number" then
          error("invalid table: mixed or invalid key types")
        end
        n = n + 1
      end
      if n ~= #val then
        error("invalid table: sparse array")
      end
      for i, v in ipairs(val) do
        table.insert(res, encode(v, stack))
      end
      stack[val] = nil
      return "[" .. table.concat(res, ",") .. "]"
    else
      for k, v in pairs(val) do
        if type(k) ~= "string" then
          error("invalid table: mixed or invalid key types")
        end
        table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
      end
      stack[val] = nil
      return "{" .. table.concat(res, ",") .. "}"
    end
  end

  local function encode_string(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
  end

  local function encode_number(val)
    if val ~= val or val <= -math.huge or val >= math.huge then
      error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
  end

  local type_func_map = {
    ["nil"] = encode_nil,
    ["table"] = encode_table,
    ["string"] = encode_string,
    ["number"] = encode_number,
    ["boolean"] = tostring,
  }

  encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
      return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
  end

  function json.encode(val)
    return (encode(val))
  end

  --decode
  local parse

  local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
      res[select(i, ...)] = true
    end
    return res
  end

  local space_chars  = create_set(" ", "\t", "\r", "\n")
  local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
  local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
  local literals     = create_set("true", "false", "null")

  local literal_map  = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
  }

  local function next_char(str, idx, set, negate)
    for i = idx, #str do
      if set[str:sub(i, i)] ~= negate then
        return i
      end
    end
    return #str + 1
  end

  local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
      col_count = col_count + 1
      if str:sub(i, i) == "\n" then
        line_count = line_count + 1
        col_count = 1
      end
    end
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
  end

  local function codepoint_to_utf8(n)
    local f = math.floor
    if n <= 0x7f then
      return string.char(n)
    elseif n <= 0x7ff then
      return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
      return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
      return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
        f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string.format("invalid unicode codepoint '%x'", n))
  end

  local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(1, 4), 16)
    local n2 = tonumber(s:sub(7, 10), 16)
    if n2 then
      return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
      return codepoint_to_utf8(n1)
    end
  end

  local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
      local x = str:byte(j)
      if x < 32 then
        decode_error(str, j, "control character in string")
      elseif x == 92 then -- `\`: Escape
        res = res .. str:sub(k, j - 1)
        j = j + 1
        local c = str:sub(j, j)
        if c == "u" then
          local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
              or str:match("^%x%x%x%x", j + 1)
              or decode_error(str, j - 1, "invalid unicode escape in string")
          res = res .. parse_unicode_escape(hex)
          j = j + #hex
        else
          if not escape_chars[c] then
            decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
          end
          res = res .. escape_char_map_inv[c]
        end
        k = j + 1
      elseif x == 34 then -- `"`: End of string
        res = res .. str:sub(k, j - 1)
        return res, j + 1
      end
      j = j + 1
    end
    decode_error(str, i, "expected closing quote for string")
  end

  local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
      decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
  end

  local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
      decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
  end

  local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
      local x
      i = next_char(str, i, space_chars, true)
      -- Empty / end of array?
      if str:sub(i, i) == "]" then
        i = i + 1
        break
      end
      -- Read token
      x, i = parse(str, i)
      res[n] = x
      n = n + 1
      -- Next token
      i = next_char(str, i, space_chars, true)
      local chr = str:sub(i, i)
      i = i + 1
      if chr == "]" then break end
      if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
    end
    return res, i
  end

  local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
      local key, val
      i = next_char(str, i, space_chars, true)
      -- Empty / end of object?
      if str:sub(i, i) == "}" then
        i = i + 1
        break
      end
      -- Read key
      if str:sub(i, i) ~= '"' then
        decode_error(str, i, "expected string for key")
      end
      key, i = parse(str, i)
      -- Read ':' delimiter
      i = next_char(str, i, space_chars, true)
      if str:sub(i, i) ~= ":" then
        decode_error(str, i, "expected ':' after key")
      end
      i = next_char(str, i + 1, space_chars, true)
      -- Read value
      val, i = parse(str, i)
      -- Set
      res[key] = val
      -- Next token
      i = next_char(str, i, space_chars, true)
      local chr = str:sub(i, i)
      i = i + 1
      if chr == "}" then break end
      if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
    end
    return res, i
  end

  local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object,
  }

  parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
      return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
  end

  function json.decode(str)
    if type(str) ~= "string" then
      error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
      decode_error(str, idx, "trailing garbage")
    end
    return res
  end

  return json
end

jsonConf = json()
--[[¤ Config System For Lua ¤

  - Written by [Harmless](https://github.com/harmless05).

  - Modified by [SAMURAI](https://github.com/xesdoog).

  *Uses [RXI JSON Library](https://github.com/rxi/json.lua)*.
]]
lua_cfg = {

  writeToFile = function(data)
    local file, _ = io.open("samurais_scripts.json", "w")
    if file == nil then
      log.warning("Failed to write to " .. "samurais_scripts.json")
      gui.show_error("Lua Config", "Failed to write to " .. "samurais_scripts.json")
      return false
    end
    file:write(jsonConf.encode(data))
    file:close()
    return true
  end,

  readFromFile = function()
    local file, _ = io.open("samurais_scripts.json", "r")
    if file == nil then
      return nil
    end
    local content = file:read("*all")
    file:close()
    return jsonConf.decode(content)
  end,

  checkAndCreateConfig = function(default_config)
    local config = lua_cfg.readFromFile()
    if config == nil then
      log.warning("Config file not found! Creating a default config profile...")
      if not lua_cfg.writeToFile(default_config) then
        return false
      end
      config = default_config
    end

    for key, defaultValue in pairs(default_config) do
      if config[key] == nil then
        config[key] = defaultValue
      end
    end

    if not lua_cfg.writeToFile(config) then
      return false
    end
    return true
  end,

  readAndDecodeConfig = function()
    while not lua_cfg.checkAndCreateConfig(default_config) do
      os.execute("sleep " .. tonumber(1))
      log.info("Waiting for " .. "samurais_scripts.json" .. " to be created")
    end
    return lua_cfg.readFromFile()
  end,

  save = function(item_tag, value)
    local t = lua_cfg.readAndDecodeConfig()
    if t then
      t[item_tag] = value
      if not lua_cfg.writeToFile(t) then
        log.error("Failed to save config to " .. "samurais_scripts.json")
      end
    end
  end,

  read = function(item_tag)
    local t = lua_cfg.readAndDecodeConfig()
    if t then
      return t[item_tag]
    else
      log.error("Failed to read config from " .. "samurais_scripts.json")
    end
  end,

  reset = function(default_config)
    lua_cfg.writeToFile(default_config)
  end,
}

--[[
 ### LuaXml

 <u>Credits:</u> http://lua-users.org/wiki/LuaXml
]]
XmlParser = {}

function XmlParser:ToXmlString(value)
  value = string.gsub(value, "&", "&amp;");   -- '&' -> "&amp;"
  value = string.gsub(value, "<", "&lt;");    -- '<' -> "&lt;"
  value = string.gsub(value, ">", "&gt;");    -- '>' -> "&gt;"
  --value = string.gsub (value, "'", "&apos;");	-- '\'' -> "&apos;"
  value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
  -- replace non printable char -> "&#xD;"
  value = string.gsub(value, "([^%w%&%;%p%\t% ])",
    function(c)
      return string.format("&#x%X;", string.byte(c))
      --return string.format("&#x%02X;", string.byte(c))
      --return string.format("&#%02d;", string.byte(c))
    end);
  return value;
end

function XmlParser:FromXmlString(value)
  value = string.gsub(value, "&#x([%x]+)%;",
    function(h)
      return string.char(tonumber(h, 16))
    end);
  value = string.gsub(value, "&#([0-9]+)%;",
    function(h)
      return string.char(tonumber(h, 10))
    end);
  value = string.gsub(value, "&quot;", "\"");
  value = string.gsub(value, "&apos;", "'");
  value = string.gsub(value, "&gt;", ">");
  value = string.gsub(value, "&lt;", "<");
  value = string.gsub(value, "&amp;", "&");
  return value;
end

function XmlParser:ParseArgs(s)
  local arg = {}
  s:gsub("(%w+)=([\"'])(.-)%2", function(w, _, a)
    arg[w] = self:FromXmlString(a);
  end)
  return arg
end

function XmlParser:ParseXmlText(xmlText)
  local stack = {}
  local top = {
    Name       = nil,
    Value      = nil,
    Attributes = {},
    ChildNodes = {}
  }
  table.insert(stack, top)
  local ni, c, label, xarg, empty
  local i, j = 1, 1
  while true do
    ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then
      break
    end
    local text = string.sub(xmlText, i, ni - 1)
    if not string.find(text, "^%s*$") then
      top.Value = (top.Value or "") .. self:FromXmlString(text)
    end
    if empty == "/" then -- empty element tag
      table.insert(top.ChildNodes, { Name = label, Value = nil, Attributes = self:ParseArgs(xarg), ChildNodes = {} })
    elseif c == "" then  -- start tag
      top = {
        Name       = label,
        Value      = nil,
        Attributes = self:ParseArgs(xarg),
        ChildNodes = {}
      }
      table.insert(stack, top)            -- new level
    else                                  -- end tag
      local toclose = table.remove(stack) -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("XmlParser: nothing to close with " .. label)
      end
      if toclose.Name ~= label then
        error("XmlParser: trying to close " .. toclose.Name .. " with " .. label)
      end
      table.insert(top.ChildNodes, toclose)
    end
    i = j + 1
  end
  local text = string.sub(xmlText, i)
  if not string.find(text, "^%s*$") then
    stack[#stack].Value = (stack[#stack].Value or "") .. self:FromXmlString(text)
  end
  if #stack > 1 then
    error("XmlParser: unclosed " .. stack[stack.n].Name)
  end
  return stack[1].ChildNodes[1]
end

function XmlParser:ParseXmlFile(xmlFileName)
  local file, err = io.open(xmlFileName, "r")
  if not err and file ~= nil then
    local xmlText = file:read("*a")
    io.close(file)
    return self:ParseXmlText(xmlText), nil
  else
    error(tostring(err), 2)
    return nil, err
  end
end
