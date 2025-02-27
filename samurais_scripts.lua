---@diagnostic disable: undefined-global, lowercase-global

require('lib/samurais_utils')
require('lib/Translations')
Samurais_scripts = gui.get_tab("Samurai's Scripts")

default_config = {
  Regen             = false,
  objectiveTP       = false,
  disableTooltips   = false,
  phoneAnim         = false,
  sprintInside      = false,
  lockpick          = false,
  replaceSneakAnim  = false,
  disableSound      = false,
  disableActionMode = false,
  Triggerbot        = false,
  aimEnemy          = false,
  autoKill          = false,
  disableUiSounds   = false,
  driftMode         = false,
  DriftTires        = false,
  speedBoost        = false,
  nosvfx            = false,
  hornLight         = false,
  nosPurge          = false,
  rgbLights         = false,
  loud_radio        = false,
  launchCtrl        = false,
  popsNbangs        = false,
  limitVehOptions   = false,
  louderPops        = false,
  autobrklight      = false,
  holdF             = false,
  noJacking         = false,
  useGameLang       = false,
  lang_idx          = 0,
  DriftIntensity    = 0,
  lightSpeed        = 1,
  LANG              = 'en-US',
  current_lang      = 'English',
}

LANG = lua_cfg.read("LANG")
current_lang = lua_cfg.read("current_lang")

--[[
    *self*
]]
local self_tab          = Samurais_scripts:add_tab(translateLabel("Self"))
local Regen             = lua_cfg.read("Regen")
local objectiveTP       = lua_cfg.read("objectiveTP")
local phoneAnim         = lua_cfg.read("phoneAnim")
local sprintInside      = lua_cfg.read("sprintInside")
local lockPick          = lua_cfg.read("lockPick")
local replaceSneakAnim  = lua_cfg.read("replaceSneakAnim")
local disableActionMode = lua_cfg.read("disableActionMode")
local isCrouched        = false
local objectives_T      = { 0, 1, 2, 143, 144, 145, 146, 280, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 535, 536, 537, 538, 539, 540, 541, 542 }
self_tab:add_imgui(function()
  Regen, RegenUsed = ImGui.Checkbox(translateLabel("Auto-Heal"), Regen, true)
  UI.helpMarker(false, translateLabel("autoheal_tooltip"))
  if RegenUsed then
    lua_cfg.save("Regen", Regen)
    UI.widgetSound("Nav2")
  end

  objectiveTP, objectiveTPUsed = ImGui.Checkbox(translateLabel("objectiveTP"), objectiveTP, true)
  UI.helpMarker(false, translateLabel("objectiveTP_tooltip"))
  if objectiveTPUsed then
    lua_cfg.save("objectiveTP", objectiveTP)
    UI.widgetSound("Nav2")
  end

  replaceSneakAnim, rsanimUsed = ImGui.Checkbox(translateLabel("CrouchCB"), replaceSneakAnim, true)
  UI.helpMarker(false, translateLabel("Crouch_tooltip"))
  if rsanimUsed then
    lua_cfg.save("replaceSneakAnim", replaceSneakAnim)
    UI.widgetSound("Nav2")
  end

  phoneAnim, phoneAnimUsed = ImGui.Checkbox(translateLabel("PhoneAnimCB"), phoneAnim, true)
  UI.helpMarker(false, translateLabel("PhoneAnim_tooltip"))
  if phoneAnimUsed then
    lua_cfg.save("phoneAnim", phoneAnim)
    UI.widgetSound("Nav2")
  end

  sprintInside, sprintInsideUsed = ImGui.Checkbox(translateLabel("SprintInsideCB"), sprintInside, true)
  UI.helpMarker(false,
    translateLabel("SprintInside_tooltip"))
  if sprintInsideUsed then
    lua_cfg.save("sprintInside", sprintInside)
    UI.widgetSound("Nav2")
  end

  lockPick, lockPickUsed = ImGui.Checkbox(translateLabel("LockpickCB"), lockPick, true)
  UI.helpMarker(false,
    translateLabel("Lockpick_tooltip"))
  if lockPickUsed then
    lua_cfg.save("lockPick", lockPick)
    UI.widgetSound("Nav2")
  end

  disableActionMode, actionModeUsed = ImGui.Checkbox(translateLabel("ActionModeCB"), disableActionMode, true)
  UI.helpMarker(false, translateLabel("ActionMode_tooltip"))
  if actionModeUsed then
    lua_cfg.save("disableActionMode", disableActionMode)
    UI.widgetSound("Nav2")
  end
end)

sound_player = self_tab:add_tab(translateLabel"soundplayer")
local sound_index1    = 0
local sound_index2    = 0
local switch          = 0
local male_sounds_T   = {
  { name = "Charge",            soundName = "GENERIC_WAR_CRY",          soundRef = "S_M_Y_BLACKOPS_01_BLACK_MINI_01" },
  { name = "Creep",             soundName = "SHOUT_PERV_AT_WOMAN_PERV", soundRef = "A_M_Y_MEXTHUG_01_LATINO_FULL_01" },
  { name = "Franklin Laughing", soundName = "LAUGH",                    soundRef = "WAVELOAD_PAIN_FRANKLIN" },
  { name = "How are you?",      soundName = "GENERIC_HOWS_IT_GOING",    soundRef = "S_M_M_PILOT_01_WHITE_FULL_01" },
  { name = "Insult",            soundName = "GENERIC_INSULT_HIGH",      soundRef = "S_M_Y_SHERIFF_01_WHITE_FULL_01" },
  { name = "Insult 02",         soundName = "GENERIC_FUCK_YOU",         soundRef = "FRANKLIN_DRUNK" },
  { name = "Threaten",          soundName = "CHALLENGE_THREATEN",       soundRef = "S_M_Y_BLACKOPS_01_BLACK_MINI_01" },
  { name = "You Look Stupid!",  soundName = "FRIEND_LOOKS_STUPID",      soundRef = "FRANKLIN_DRUNK" },
}
local female_sounds_T = {
  { name = "Blowjob",      soundName = "SEX_ORAL",              soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
  { name = "Hooker Offer", soundName = "HOOKER_OFFER_SERVICE",  soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
  { name = "How are you?", soundName = "GENERIC_HOWS_IT_GOING", soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
  { name = "Insult",       soundName = "GENERIC_INSULT_HIGH",   soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
  { name = "Moan",         soundName = "SEX_GENERIC_FEM",       soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
  { name = "Threaten",     soundName = "CHALLENGE_THREATEN",    soundRef = "S_F_Y_HOOKER_03_BLACK_FULL_01" },
}

local selected_sound
local function displayMaleSounds()
  filteredMaleSounds = {}
  for _, v in ipairs(male_sounds_T) do
    table.insert(filteredMaleSounds, v.name)
  end
  sound_index1, used = ImGui.Combo("##maleSounds", sound_index1, filteredMaleSounds, #male_sounds_T)
end

local function displayFemaleSounds()
  filteredFemaleSounds = {}
  for _, v in ipairs(female_sounds_T) do
    table.insert(filteredFemaleSounds, v.name)
  end
  sound_index2, used = ImGui.Combo("##femaleSounds", sound_index2, filteredFemaleSounds, #female_sounds_T)
end

sound_player:add_imgui(function()
  switch, isChanged = ImGui.RadioButton(translateLabel("malesounds"), switch, 0); ImGui.SameLine()
  if isChanged then
    UI.widgetSound("Nav")
  end
  switch, isChanged = ImGui.RadioButton(translateLabel("femalesounds"), switch, 1)
  if isChanged then
    UI.widgetSound("Nav")
  end
  if switch == 0 then
    displayMaleSounds()
    selected_sound = male_sounds_T[sound_index1 + 1]
  else
    displayFemaleSounds()
    selected_sound = female_sounds_T[sound_index2 + 1]
  end
  if ImGui.Button(translateLabel("playButton") .. "##sound") then
    script.run_in_fiber(function()
      local myCoords = Game.getCoords(self.get_ped(), true)
      AUDIO.PLAY_AMBIENT_SPEECH_FROM_POSITION_NATIVE(selected_sound.soundName, selected_sound.soundRef, myCoords.x,
        myCoords.y, myCoords.z, "SPEECH_PARAMS_FORCE", 0)
    end)
  end
end)

--[[
    *weapon*
]]
local weapon_tab  = Samurais_scripts:add_tab(translateLabel("weaponTab"))
local Triggerbot  = lua_cfg.read("Triggerbot")
local aimEnemy    = lua_cfg.read("aimEnemy")
local autoKill    = lua_cfg.read("autoKill")
local aimBool     = false
local HashGrabber = false
local Entity      = 0

weapon_tab:add_imgui(function()
  HashGrabber, HgUsed = ImGui.Checkbox(translateLabel("hashgrabberCB"), HashGrabber, true)
  UI.helpMarker(false,
    translateLabel("hashgrabber_tt"))
  if HgUsed then
    UI.widgetSound("Nav2")
  end

  Triggerbot, TbUsed = ImGui.Checkbox(translateLabel("triggerbotCB"), Triggerbot, true)
  UI.helpMarker(false,
    translateLabel("triggerbot_tt"))
  if Triggerbot then
    ImGui.SameLine(); aimEnemy, aimEnemyUsed = ImGui.Checkbox(translateLabel("enemyonlyCB"), aimEnemy, true)
    if aimEnemyUsed then
      lua_cfg.save("aimEnemy", aimEnemy)
      UI.widgetSound("Nav2")
    end
  end
  if TbUsed then
    lua_cfg.save("Triggerbot", Triggerbot)
    UI.widgetSound("Nav2")
  end

  autoKill, autoKillUsed = ImGui.Checkbox(translateLabel("autokillCB"), autoKill, true)
  UI.helpMarker(false, translateLabel("autokill_tt"))
  if autoKillUsed then
    lua_cfg.save("autoKill", autoKill)
    UI.widgetSound("Nav2")
  end
end)

--[[
    *vehicle*
]]
local vehicle_tab = Samurais_scripts:add_tab(translateLabel("vehicleTab"))
local popsnd, sndRef
local flame_size
local driftMode          = lua_cfg.read("driftMode")
local DriftIntensity     = lua_cfg.read("DriftIntensity")
local DriftTires         = lua_cfg.read("DriftTires")
local speedBoost         = lua_cfg.read("speedBoost")
local nosvfx             = lua_cfg.read("nosvfx")
local hornLight          = lua_cfg.read("hornLight")
local nosPurge           = lua_cfg.read("nosPurge")
local lightSpeed         = lua_cfg.read("lightSpeed")
local loud_radio         = lua_cfg.read("loud_radio")
local launchCtrl         = lua_cfg.read("launchCtrl")
local popsNbangs         = lua_cfg.read("popsNbangs")
local louderPops         = lua_cfg.read("louderPops")
local limitVehOptions    = lua_cfg.read("limitVehOptions")
local autobrklight       = lua_cfg.read("autobrklight")
local rgbLights          = lua_cfg.read("rgbLights")
local holdF              = lua_cfg.read("holdF")
local noJacking          = lua_cfg.read("noJacking")
local is_car             = false
local is_quad            = false
local is_boat            = false
local is_bike            = false
local validModel         = false
local has_xenon          = false
local purge_started      = false
local nos_started        = false
local twostep_started    = false
local is_typing          = false
local open_sounds_window = false
local started_lct        = false
local launch_active      = false
local started_popSound   = false
local started_popSound2  = false
local timerA             = 0
local timerB             = 0
local lastVeh            = 0
local defaultXenon       = 0
local vehSound_index     = 0
local tdBtn              = 21
local search_term        = ""
local nosptfx_t          = {}
local purgePtfx_t        = {}
local lctPtfx_t          = {}
local popSounds_t        = {}
local popsPtfx_t         = {}
local gta_vehicles       = { "Airbus", "Airtug", "akula", "akuma", "aleutian", "alkonost", "alpha", "alphaz1",
  "AMBULANCE", "annihilator", "annihilator2", "apc", "ardent", "armytanker", "armytrailer", "armytrailer2", "asbo",
  "asea", "asea2", "asterope", "asterope2", "astron", "autarch", "avarus", "avenger", "avenger2", "avenger3", "avenger4",
  "avisa", "bagger", "baletrailer", "Baller", "baller2", "baller3", "baller4", "baller5", "baller6", "baller7", "baller8",
  "banshee", "banshee2", "BARRACKS", "BARRACKS2", "BARRACKS3", "barrage", "bati", "bati2", "Benson", "benson2", "besra",
  "bestiagts", "bf400", "BfInjection", "Biff", "bifta", "bison", "Bison2", "Bison3", "BjXL", "blade", "blazer", "blazer2",
  "blazer3", "blazer4", "blazer5", "BLIMP", "BLIMP2", "blimp3", "blista", "blista2", "blista3", "BMX", "boattrailer",
  "boattrailer2", "boattrailer3", "bobcatXL", "Bodhi2", "bombushka", "boor", "boxville", "boxville2", "boxville3",
  "boxville4", "boxville5", "boxville6", "brawler", "brickade", "brickade2", "brigham", "brioso", "brioso2", "brioso3",
  "broadway", "bruiser", "bruiser2", "bruiser3", "brutus", "brutus2", "brutus3", "btype", "btype2", "btype3", "buccaneer",
  "buccaneer2", "buffalo", "buffalo2", "buffalo3", "buffalo4", "buffalo5", "bulldozer", "bullet", "Burrito", "burrito2",
  "burrito3", "Burrito4", "burrito5", "BUS", "buzzard", "Buzzard2", "cablecar", "caddy", "Caddy2", "caddy3", "calico",
  "CAMPER", "caracara", "caracara2", "carbonizzare", "carbonrs", "Cargobob", "cargobob2", "Cargobob3", "Cargobob4",
  "cargoplane", "cargoplane2", "casco", "cavalcade", "cavalcade2", "cavalcade3", "cerberus", "cerberus2", "cerberus3",
  "champion", "cheburek", "cheetah", "cheetah2", "chernobog", "chimera", "chino", "chino2", "cinquemila", "cliffhanger",
  "clique", "clique2", "club", "coach", "cog55", "cog552", "cogcabrio", "cognoscenti", "cognoscenti2", "comet2", "comet3",
  "comet4", "comet5", "comet6", "comet7", "conada", "conada2", "contender", "coquette", "coquette2", "coquette3",
  "coquette4", "corsita", "coureur", "cruiser", "CRUSADER", "cuban800", "cutter", "cyclone", "cypher", "daemon",
  "daemon2", "deathbike", "deathbike2", "deathbike3", "defiler", "deity", "deluxo", "deveste", "deviant", "diablous",
  "diablous2", "dilettante", "dilettante2", "Dinghy", "dinghy2", "dinghy3", "dinghy4", "dinghy5", "dloader",
  "docktrailer", "docktug", "dodo", "Dominator", "dominator2", "dominator3", "dominator4", "dominator5", "dominator6",
  "dominator7", "dominator8", "dominator9", "dorado", "double", "drafter", "draugur", "drifteuros", "driftfr36",
  "driftfuto", "driftjester", "driftremus", "drifttampa", "driftyosemite", "driftzr350", "dubsta", "dubsta2", "dubsta3",
  "dukes", "dukes2", "dukes3", "dump", "dune", "dune2", "dune3", "dune4", "dune5", "duster", "Dynasty", "elegy", "elegy2",
  "ellie", "emerus", "emperor", "Emperor2", "emperor3", "enduro", "entity2", "entity3", "entityxf", "esskey", "eudora",
  "Euros", "everon", "everon2", "exemplar", "f620", "faction", "faction2", "faction3", "fagaloa", "faggio", "faggio2",
  "faggio3", "FBI", "FBI2", "fcr", "fcr2", "felon", "felon2", "feltzer2", "feltzer3", "firetruk", "fixter", "flashgt",
  "FLATBED", "fmj", "FORKLIFT", "formula", "formula2", "fq2", "fr36", "freecrawler", "freight", "freight2", "freightcar",
  "freightcar2", "freightcont1", "freightcont2", "freightgrain", "Frogger", "frogger2", "fugitive", "furia", "furoregt",
  "fusilade", "futo", "futo2", "gargoyle", "Gauntlet", "gauntlet2", "gauntlet3", "gauntlet4", "gauntlet5", "gauntlet6",
  "gb200", "gburrito", "gburrito2", "glendale", "glendale2", "gp1", "graintrailer", "GRANGER", "granger2", "greenwood",
  "gresley", "growler", "gt500", "guardian", "habanero", "hakuchou", "hakuchou2", "halftrack", "handler", "Hauler",
  "Hauler2", "havok", "hellion", "hermes", "hexer", "hotknife", "hotring", "howard", "hunter", "huntley", "hustler",
  "hydra", "imorgon", "impaler", "impaler2", "impaler3", "impaler4", "impaler5", "impaler6", "imperator", "imperator2",
  "imperator3", "inductor", "inductor2", "infernus", "infernus2", "ingot", "innovation", "insurgent", "insurgent2",
  "insurgent3", "intruder", "issi2", "issi3", "issi4", "issi5", "issi6", "issi7", "issi8", "italigtb", "italigtb2",
  "italigto", "italirsx", "iwagen", "jackal", "jb700", "jb7002", "jester", "jester2", "jester3", "jester4", "jet",
  "jetmax", "journey", "journey2", "jubilee", "jugular", "kalahari", "kamacho", "kanjo", "kanjosj", "khamelion",
  "khanjali", "komoda", "kosatka", "krieger", "kuruma", "kuruma2", "l35", "landstalker", "landstalker2", "Lazer", "le7b",
  "lectro", "lguard", "limo2", "lm87", "locust", "longfin", "lurcher", "luxor", "luxor2", "lynx", "mamba", "mammatus",
  "manana", "manana2", "manchez", "manchez2", "manchez3", "marquis", "marshall", "massacro", "massacro2", "maverick",
  "menacer", "MESA", "mesa2", "MESA3", "metrotrain", "michelli", "microlight", "Miljet", "minitank", "minivan",
  "minivan2", "Mixer", "Mixer2", "mogul", "molotok", "monroe", "monster", "monster3", "monster4", "monster5",
  "monstrociti", "moonbeam", "moonbeam2", "Mower", "Mule", "Mule2", "Mule3", "mule4", "mule5", "nebula", "nemesis", "neo",
  "neon", "nero", "nero2", "nightblade", "nightshade", "nightshark", "nimbus", "ninef", "ninef2", "nokota", "Novak",
  "omnis", "omnisegt", "openwheel1", "openwheel2", "oppressor", "oppressor2", "oracle", "oracle2", "osiris", "outlaw",
  "Packer", "panthere", "panto", "paradise", "paragon", "paragon2", "pariah", "patriot", "patriot2", "patriot3",
  "patrolboat", "pbus", "pbus2", "pcj", "penetrator", "penumbra", "penumbra2", "peyote", "peyote2", "peyote3",
  "pfister811", "Phantom", "phantom2", "phantom3", "Phantom4", "Phoenix", "picador", "pigalle", "polgauntlet", "police",
  "police2", "police3", "police4", "police5", "policeb", "policeold1", "policeold2", "policet", "polmav", "pony", "pony2",
  "postlude", "Pounder", "pounder2", "powersurge", "prairie", "pRanger", "Predator", "premier", "previon", "primo",
  "primo2", "proptrailer", "prototipo", "pyro", "r300", "radi", "raiden", "raiju", "raketrailer", "rallytruck",
  "RancherXL", "rancherxl2", "RapidGT", "RapidGT2", "rapidgt3", "raptor", "ratbike", "ratel", "ratloader", "ratloader2",
  "rcbandito", "reaper", "Rebel", "rebel2", "rebla", "reever", "regina", "remus", "Rentalbus", "retinue", "retinue2",
  "revolter", "rhapsody", "rhinehart", "RHINO", "riata", "RIOT", "riot2", "Ripley", "rocoto", "rogue", "romero",
  "rrocket", "rt3000", "Rubble", "ruffian", "ruiner", "ruiner2", "ruiner3", "ruiner4", "rumpo", "rumpo2", "rumpo3",
  "ruston", "s80", "sabregt", "sabregt2", "Sadler", "sadler2", "Sanchez", "sanchez2", "sanctus", "sandking", "sandking2",
  "savage", "savestra", "sc1", "scarab", "scarab2", "scarab3", "schafter2", "schafter3", "schafter4", "schafter5",
  "schafter6", "schlagen", "schwarzer", "scorcher", "scramjet", "scrap", "seabreeze", "seashark", "seashark2",
  "seashark3", "seasparrow", "seasparrow2", "seasparrow3", "Seminole", "seminole2", "sentinel", "sentinel2", "sentinel3",
  "sentinel4", "serrano", "SEVEN70", "Shamal", "sheava", "SHERIFF", "sheriff2", "shinobi", "shotaro", "skylift",
  "slamtruck", "slamvan", "slamvan2", "slamvan3", "slamvan4", "slamvan5", "slamvan6", "sm722", "sovereign", "SPECTER",
  "SPECTER2", "speeder", "speeder2", "speedo", "speedo2", "speedo4", "speedo5", "squaddie", "squalo", "stafford",
  "stalion", "stalion2", "stanier", "starling", "stinger", "stingergt", "stingertt", "stockade", "stockade3", "stratum",
  "streamer216", "streiter", "stretch", "strikeforce", "stromberg", "Stryder", "Stunt", "submersible", "submersible2",
  "Sugoi", "sultan", "sultan2", "sultan3", "sultanrs", "Suntrap", "superd", "supervolito", "supervolito2", "Surano",
  "SURFER", "Surfer2", "surfer3", "surge", "swift", "swift2", "swinger", "t20", "Taco", "tahoma", "tailgater",
  "tailgater2", "taipan", "tampa", "tampa2", "tampa3", "tanker", "tanker2", "tankercar", "taxi", "technical",
  "technical2", "technical3", "tempesta", "tenf", "tenf2", "terbyte", "terminus", "tezeract", "thrax", "thrust",
  "thruster", "tigon", "TipTruck", "TipTruck2", "titan", "toreador", "torero", "torero2", "tornado", "tornado2",
  "tornado3", "tornado4", "tornado5", "tornado6", "toro", "toro2", "toros", "TOURBUS", "TOWTRUCK", "Towtruck2",
  "towtruck3", "towtruck4", "tr2", "tr3", "tr4", "TRACTOR", "tractor2", "tractor3", "trailerlarge", "trailerlogs",
  "trailers", "trailers2", "trailers3", "trailers4", "trailers5", "trailersmall", "trailersmall2", "Trash", "trash2",
  "trflat", "tribike", "tribike2", "tribike3", "trophytruck", "trophytruck2", "tropic", "tropic2", "tropos", "tug",
  "tula", "tulip", "tulip2", "turismo2", "turismo3", "turismor", "tvtrailer", "tvtrailer2", "tyrant", "tyrus",
  "utillitruck", "utillitruck2", "Utillitruck3", "vacca", "Vader", "vagner", "vagrant", "valkyrie", "valkyrie2", "vamos",
  "vectre", "velum", "velum2", "verlierer2", "verus", "vestra", "vetir", "veto", "veto2", "vigero", "vigero2", "vigero3",
  "vigilante", "vindicator", "virgo", "virgo2", "virgo3", "virtue", "viseris", "visione", "vivanite", "volatol",
  "volatus", "voltic", "voltic2", "voodoo", "voodoo2", "vortex", "vstr", "warrener", "warrener2", "washington",
  "wastelander", "weevil", "weevil2", "windsor", "windsor2", "winky", "wolfsbane", "xa21", "xls", "xls2", "yosemite",
  "yosemite2", "yosemite3", "youga", "youga2", "youga3", "youga4", "z190", "zeno", "zentorno", "zhaba", "zion", "zion2",
  "zion3", "zombiea", "zombieb", "zorrusso", "zr350", "zr380", "zr3802", "zr3803", "Ztype", }

local vehOffsets = {
  fc   = 0x001C,
  ft   = 0x0014,
  rc   = 0x0020,
  rt   = 0x0018,
  cg   = 0x0882,
  ng   = 0x0880,
  tg   = 0x0886,
  vm   = 0x000C,
  dfm  = 0x0014,
  accm = 0x004C,
  cofm = 0x0020,
  bf   = 0x006C,
}

local function filterVehNames()
  filteredNames = {}
  for _, veh in ipairs(gta_vehicles) do
    if VEHICLE.IS_THIS_MODEL_A_CAR(joaat(veh)) or VEHICLE.IS_THIS_MODEL_A_BIKE(joaat(veh)) or VEHICLE.IS_THIS_MODEL_A_QUADBIKE(joaat(veh)) then
      valid_veh = veh
      if string.find(string.lower(valid_veh), string.lower(search_term)) then
        table.insert(filteredNames, valid_veh)
      end
    end
  end
end

local function displayVehNames()
  filterVehNames()
  local vehNames = {}
  for _, veh in ipairs(filteredNames) do
    local vehName = vehicles.get_vehicle_display_name(joaat(veh))
    table.insert(vehNames, vehName)
  end
  vehSound_index, used = ImGui.ListBox("##Vehicle Names", vehSound_index, vehNames, #filteredNames)
end

local function resetLastVehState()
  -- placeholder func
end

local function onVehEnter()
  lastVeh         = PLAYER.GET_PLAYERS_LAST_VEHICLE()
  current_vehicle = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
  lastVehPtr      = Game.getEntPtr(lastVeh)
  currentVehPtr   = Game.getEntPtr(current_vehicle)
  if current_vehicle ~= lastVeh then
    resetLastVehState()
  end
  return lastVeh, lastVehPtr, current_vehicle, currentVehPtr
end

vehicle_tab:add_imgui(function()
  local manufacturer  = Game.Vehicle.manufacturer()
  local vehicle_name  = Game.Vehicle.name()
  local full_veh_name = manufacturer .. " " .. vehicle_name
  local vehicle_class = Game.Vehicle.class()
  if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) then
    if validModel then
      ImGui.Text(full_veh_name .. "   (" .. vehicle_class .. ")")
      ImGui.Spacing()
      driftMode, driftModeUsed = ImGui.Checkbox(translateLabel("driftModeCB"), driftMode, true)
      UI.helpMarker(false, translateLabel("driftMode_tt"))
      if driftModeUsed then
        UI.widgetSound("Nav2")
        lua_cfg.save("driftMode", driftMode)
        lua_cfg.save("DriftTires", false)
      end
      if driftMode then
        DriftTires = false
        ImGui.Spacing()
        ImGui.Text(translateLabel("driftSlider"))
        ImGui.PushItemWidth(250)
        DriftIntensity, DriftIntensityUsed = ImGui.SliderInt("##Intensity", DriftIntensity, 0, 3)
        UI.toolTip(false, translateLabel("driftSlider_tt"))
        ImGui.PopItemWidth()
        if DriftIntensityUsed then
          UI.widgetSound("Nav")
          lua_cfg.save("DriftIntensity", DriftIntensity)
        end
      end
      DriftTires, DriftTiresUsed = ImGui.Checkbox(translateLabel("driftTiresCB"), DriftTires, true)
      UI.helpMarker(false, translateLabel("driftTires_tt"))
      if DriftTires then
        driftMode = false
      end
      if DriftTiresUsed then
        UI.widgetSound("Nav2")
        lua_cfg.save("DriftTires", DriftTires)
        lua_cfg.save("driftMode", false)
      end
    else
      ImGui.TextWrapped("\10You can only drift cars, trucks and quad bikes.\10\10")
    end

    ImGui.Separator(); ImGui.Spacing(); limitVehOptions, lvoUsed = ImGui.Checkbox(translateLabel("lvoCB"), limitVehOptions, true)
    UI.toolTip(false, translateLabel("lvo_tt"))
    if lvoUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("limitVehOptions", limitVehOptions)
    end

    launchCtrl, lctrlUsed = ImGui.Checkbox("Launch Control", launchCtrl, true)
    UI.toolTip(false, translateLabel("lct_tt"))
    if lctrlUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("launchCtrl", launchCtrl)
    end

    ImGui.SameLine(); ImGui.Dummy(31, 1); ImGui.SameLine(); speedBoost, spdbstUsed = ImGui.Checkbox("NOS", speedBoost,
      true)
    UI.toolTip(false, translateLabel("speedBoost_tt"))
    if spdbstUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("speedBoost", speedBoost)
    end
    if speedBoost then
      ImGui.SameLine(); nosvfx, nosvfxUsed = ImGui.Checkbox("VFX", nosvfx, true)
      UI.toolTip(false, translateLabel("vfx_tt"))
      if nosvfxUsed then
        UI.widgetSound("Nav2")
        lua_cfg.save("nosvfx", nosvfx)
      end
    end

    loud_radio, loudRadioUsed = ImGui.Checkbox("Big Subwoofer", loud_radio, true)
    UI.toolTip(false, translateLabel("loudradio_tt"))
    if loudRadioUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("loud_radio", loud_radio)
    end
    if loud_radio then
      script.run_in_fiber(function()
        AUDIO.SET_VEHICLE_RADIO_LOUD(current_vehicle, true)
      end)
    else
      script.run_in_fiber(function()
        AUDIO.SET_VEHICLE_RADIO_LOUD(current_vehicle, false)
      end)
    end

    ImGui.SameLine(); ImGui.Dummy(32, 1); ImGui.SameLine(); nosPurge, nosPurgeUsed = ImGui.Checkbox("NOS Purge", nosPurge,
      true)
    UI.toolTip(false, translateLabel("purge_tt"))
    if nosPurgeUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("nosPurge", nosPurge)
    end

    popsNbangs, pnbUsed = ImGui.Checkbox("Pops & Bangs", popsNbangs, true)
    UI.toolTip(false, translateLabel("pnb_tt"))
    if pnbUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("popsNbangs", popsNbangs)
    end
    if popsNbangs then
      ImGui.SameLine(); ImGui.Dummy(37, 1); ImGui.SameLine(); louderPops, louderPopsUsed = ImGui.Checkbox("Louder Pops",
        louderPops, true)
      UI.toolTip(false, translateLabel("louderpnb_tt"))
      if louderPopsUsed then
        UI.widgetSound("Nav2")
        lua_cfg.save("louderPops", louderPops)
      end
    end

    hornLight, hornLightUsed = ImGui.Checkbox("High Beams on Horn", hornLight, true)
    UI.toolTip(false, translateLabel("highbeams_tt"))
    if hornLightUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("hornLight", hornLight)
    end

    ImGui.SameLine(); autobrklight, autobrkUsed = ImGui.Checkbox("Auto Brake Lights", autobrklight, true)
    UI.toolTip(false, translateLabel("brakeLight_tt"))
    if autobrkUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("autobrklight", autobrklight)
    end

    holdF, holdFused = ImGui.Checkbox("Keep Engine On", holdF, true)
    UI.toolTip(false, translateLabel("engineOn_tt"))
    if holdFused then
      UI.widgetSound("Nav2")
      lua_cfg.save("holdF", holdF)
    end

    ImGui.SameLine(); ImGui.Dummy(25, 1); ImGui.SameLine(); noJacking, noJackingUsed = ImGui.Checkbox("Can't Touch This!", noJacking, true)
    UI.toolTip(false, translateLabel("canttouchthis_tt"))
    if noJackingUsed then
      UI.widgetSound("Nav2")
      lua_cfg.save("noJacking", noJacking)
    end

    rgbLights, rgbToggled = ImGui.Checkbox("RGB Headlights", rgbLights, true)
    if rgbToggled then
      UI.widgetSound("Nav2")
      lua_cfg.save("rgbLights", rgbLights)
      script.run_in_fiber(function()
        if not VEHICLE.IS_TOGGLE_MOD_ON(current_vehicle, 22) then
          has_xenon = false
        else
          has_xenon    = true
          defaultXenon = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle)
        end
      end)
    end
    if rgbLights then
      ImGui.SameLine();
      ImGui.PushItemWidth(120)
      lightSpeed, lightSpeedUsed = ImGui.SliderInt(translateLabel("rgbSlider"), lightSpeed, 1, 3)
      ImGui.PopItemWidth()
      if lightSpeedUsed then
        UI.widgetSound("Nav")
        lua_cfg.save("lightSpeed", lightSpeed)
      end
    end
    ImGui.Spacing()
    if ImGui.Button(translateLabel("engineSoundBtn")) then
      if is_car or is_bike or is_quad then
        open_sounds_window = true
      else
        open_sounds_window = false
        gui.show_error("Tokyo Drift", translateLabel("engineSoundErr"))
      end
    end
    if open_sounds_window then
      ImGui.SetNextWindowPos(740, 300, ImGuiCond.Appearing)
      ImGui.SetNextWindowSizeConstraints(100, 100, 600, 800)
      ImGui.Begin("Vehicle Sounds",
        ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoCollapse)
      if ImGui.Button(translateLabel("closeBtn")) then
        open_sounds_window = false
      end
      ImGui.Spacing(); ImGui.Spacing()
      ImGui.PushItemWidth(250)
      search_term, used = ImGui.InputTextWithHint("", translateLabel("searchVeh_hint"), search_term, 32)
      if ImGui.IsItemActive() then
        is_typing = true
      else
        is_typing = false
      end
      ImGui.PushItemWidth(270)
      displayVehNames()
      ImGui.PopItemWidth()
      local selected_name = filteredNames[vehSound_index + 1]
      ImGui.Spacing()
      if ImGui.Button(translateLabel("Use This Sound")) then
        script.run_in_fiber(function()
          AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(current_vehicle, selected_name)
        end)
      end
      ImGui.SameLine()
      if ImGui.Button(translateLabel("Restore Default")) then
        script.run_in_fiber(function()
          AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(current_vehicle,
            vehicles.get_vehicle_display_name(ENTITY.GET_ENTITY_MODEL(current_vehicle)))
        end)
      end
      ImGui.End()
    end

    ImGui.SameLine(); ImGui.Dummy(10, 1); ImGui.SameLine()
    local engineHealth = VEHICLE.GET_VEHICLE_ENGINE_HEALTH(current_vehicle)
    if engineHealth <= 300 then
      engineDestroyed = true
    else
      engineDestroyed = false
    end
    if engineDestroyed then
      engineButton_label = translateLabel("Fix Engine")
      engine_hp          = 1000
    else
      engineButton_label = translateLabel("Destroy Engine")
      engine_hp          = -4000
    end
    if ImGui.Button(engineButton_label) then
      script.run_in_fiber(function()
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(current_vehicle, engine_hp)
      end)
    end
  else
    ImGui.Text(translateLabel("getinveh"))
  end
end)


--[[
    *players*
]]
local players_tab     = Samurais_scripts:add_tab(translateLabel("playersTab"))

playerIndex           = 0
local targetPlayerPed = 0
local playerVeh       = 0
local player_name     = "STRING"
players_tab:add_imgui(function()
  if Game.isOnline() then
    UI.coloredText(translateLabel("temporarily disabled"), "yellow", 1, 20)
    -- local playerCount = Game.getPlayerCount()
    -- ImGui.Text("Total Players:  [ " .. playerCount .. " ]")
    -- ImGui.PushItemWidth(320)
    -- Game.displayPlayerList()
    -- ImGui.PopItemWidth()
    -- local selectedPlayer = filteredPlayers[playerIndex + 1]
    -- ImGui.Spacing()
    -- -- if ImGui.Button("Open Player Window") then
    -- targetPlayerPed   = selectedPlayer
    -- targetPlayerIndex = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(targetPlayerPed)
    -- player_name       = PLAYER.GET_PLAYER_NAME(targetPlayerIndex)
    -- --   ImGui.OpenPopup(tostring(player_name))
    -- -- end
    -- -- ImGui.SetNextWindowSizeConstraints(400, 100, 600, 800)
    -- -- if ImGui.BeginPopupModal(tostring(player_name), true, ImGuiWindowFlags.AlwaysAutoResize) then
    -- if NETWORK.NETWORK_IS_PLAYER_ACTIVE(targetPlayerIndex) then
    --   local playerWallet  = Game.getPlayerWallet(targetPlayerIndex)
    --   local playerBank    = Game.getPlayerBank(targetPlayerIndex)
    --   local playerCoords  = Game.getCoords(targetPlayerPed, false)
    --   local playerHeading = math.floor(Game.getHeading(targetPlayerPed))
    --   local playerHealth  = ENTITY.GET_ENTITY_HEALTH(targetPlayerPed)
    --   local playerArmour  = PED.GET_PED_ARMOUR(targetPlayerPed)
    --   local godmode       = PLAYER.GET_PLAYER_INVINCIBLE(targetPlayerIndex)
    --   if PED.IS_PED_SITTING_IN_ANY_VEHICLE(targetPlayerPed) then
    --     playerVeh = PED.GET_VEHICLE_PED_IS_IN(targetPlayerPed, true)
    --   end
    --   ImGui.Spacing()
    --   ImGui.Text("Cash:" .. "      " .. playerWallet)
    --   ImGui.Spacing()
    --   ImGui.Text("Bank:" .. "      " .. playerBank)
    --   ImGui.Spacing()
    --   ImGui.Text("Coords:" .. "      " .. tostring(playerCoords))
    --   if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
    --     log.debug(player_name .. "'s coords: " .. tostring(playerCoords))
    --     gui.show_message("Samurai's Scripts", player_name .. "'s coordinates logged to console.")
    --   end
    --   ImGui.Spacing()
    --   ImGui.Text("Heading:" .. "     " .. tostring(playerHeading))
    --   if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
    --     log.debug(player_name .. "'s heading: " .. tostring(playerHeading))
    --     gui.show_message("Samurai's Scripts", player_name .. "'s heading logged to console.")
    --   end
    --   ImGui.Spacing()
    --   ImGui.Text("Health:" .. "        " .. tostring(playerHealth))
    --   if playerArmour ~= nil then
    --     ImGui.Spacing()
    --     ImGui.Text("Armour:" .. "        " .. tostring(playerArmour))
    --   end
    --   ImGui.Spacing()
    --   ImGui.Text("God Mode:" .. "  " .. tostring(godmode))
    --   if PED.IS_PED_SITTING_IN_ANY_VEHICLE(targetPlayerPed) then
    --     ImGui.Spacing()
    --     ImGui.Text("Vehicle:" .. "  " .. tostring(vehicles.get_vehicle_display_name(ENTITY.GET_ENTITY_MODEL(playerVeh))))
    --     if ImGui.Button("Delete Vehicle") then
    --       script.run_in_fiber(function(del)
    --         local pvCTRL = entities.take_control_of(playerVeh, 350)
    --         if pvCTRL then
    --           ENTITY.SET_ENTITY_AS_MISSION_ENTITY(playerVeh, true, true)
    --           del:sleep(200)
    --           VEHICLE.DELETE_VEHICLE(playerVeh)
    --           gui.show_success("Samurai's Scripts", "" .. player_name .. "'s vehicle has been yeeted.")
    --         else
    --           gui.show_error("Samurai's Scripts",
    --             "Failed to delete the vehicle! " .. player_name .. " probably has protections on.")
    --         end
    --       end)
    --     end
    --   end
    --   -- ImGui.End()
    -- else
    --   ImGui.Text("Player left the session.")
    -- end
    -- -- end
  else
    ImGui.Text("You are currently in Single Player.")
  end
end)


--[[
    *world*
]]
local world_tab = Samurais_scripts:add_tab(translateLabel("worldTab"))

local pedGrabber         = false
local ped_grabbed        = false
local carpool            = false
local show_npc_veh_ctrls = false
local stop_searching     = false
local attached_ped       = 0
local thisVeh            = 0
local pedthrowF          = 10

local function playHandsUp()
  script.run_in_fiber(function()
    if Game.requestAnimDict("mp_missheist_countrybank@lift_hands") then
      TASK.TASK_PLAY_ANIM(self.get_ped(), "mp_missheist_countrybank@lift_hands", "lift_hands_in_air_outro", 4.0, -4.0, -1,
        50, 1.0, false, false, false)
    end
  end)
end

local function attachPed(ped)
  local myBone = PED.GET_PED_BONE_INDEX(self.get_ped(), 6286)
  script.run_in_fiber(function()
    if not ped_grabbed and not PED.IS_PED_A_PLAYER(ped) then
      if entities.take_control_of(ped, 300) then
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(ped, self.get_ped(), myBone, 0.35, 0.3, -0.04, 100.0, 90.0, -10.0, false, true,
          false, true, 1, true, 1)
        ped_grabbed = true
        attached_ped = ped
      else
        gui.show_error("Samurai's Scripts", translateLabel("failedToCtrlNPC"))
      end
    end
  end)
  return ped_grabbed, attached_ped
end

world_tab:add_imgui(function()
  pedGrabber, pgUsed = ImGui.Checkbox(translateLabel("pedGrabber"), pedGrabber, true)
  UI.helpMarker(false, translateLabel("pedGrabber_tt"))
  if pgUsed then
    UI.widgetSound("Nav2")
  end

  if pedGrabber then
    ImGui.Text(translateLabel("Throw Force"))
    ImGui.PushItemWidth(160)
    pedthrowF, ptfUsed = ImGui.SliderInt("##throw_force", pedthrowF, 10, 100, "%d", 0)
    ImGui.PopItemWidth()
    if ptfUsed then
      UI.widgetSound("Nav")
    end
  end

  carpool, carpoolUsed = ImGui.Checkbox(translateLabel("carpool"), carpool, true)
  UI.helpMarker(false, translateLabel("carpool_tt"))
  if carpoolUsed then
    UI.widgetSound("Nav2")
  end

  if carpool then
    if show_npc_veh_ctrls and thisVeh ~= 0 then
      if ImGui.Button("< " .. translateLabel("prevSeat")) then
        script.run_in_fiber(function()
          if PED.IS_PED_SITTING_IN_VEHICLE(self.get_ped(), thisVeh) then
            local numSeats = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(thisVeh)
            local mySeat   = Game.getPedVehicleSeat(self.get_ped())
            if mySeat <= 0 then
              mySeat = numSeats
            end
            mySeat = mySeat - 1
            if VEHICLE.IS_VEHICLE_SEAT_FREE(thisVeh, mySeat, true) then
              UI.widgetSound("Nav")
              PED.SET_PED_INTO_VEHICLE(self.get_ped(), thisVeh, mySeat)
            else
              mySeat = mySeat - 1
              return
            end
          end
        end)
      end
      ImGui.SameLine()
      if ImGui.Button(translateLabel("nextSeat") .. " >") then
        script.run_in_fiber(function()
          if PED.IS_PED_SITTING_IN_VEHICLE(self.get_ped(), thisVeh) then
            local numSeats = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(thisVeh)
            local mySeat   = Game.getPedVehicleSeat(self.get_ped())
            if mySeat > numSeats then
              mySeat = 0
            end
            mySeat = mySeat + 1
            if VEHICLE.IS_VEHICLE_SEAT_FREE(thisVeh, mySeat, true) then
              UI.widgetSound("Nav")
              PED.SET_PED_INTO_VEHICLE(self.get_ped(), thisVeh, mySeat)
            else
              mySeat = mySeat + 1
              return
            end
          end
        end)
      end
    end
  end
end)


--[[
    *settings*
]]
local settings_tab = Samurais_scripts:add_tab(translateLabel("settingsTab"))
lang_idx = lua_cfg.read("lang_idx")
local selected_lang
local lang_T       = {
  { name = 'English',               iso = 'en-US' },
  { name = 'French',                iso = 'fr-FR' },
  { name = 'German',                iso = 'de-DE' },
  { name = 'Chinese (Traditional)', iso = 'zh-TW' },
  { name = 'Chinese (Simplified)',  iso = 'zh-CH' },
  { name = 'Spanish',               iso = 'es-ES' },
  { name = 'Portuguese',            iso = 'pt-BR' },
}

function displayLangs()
  filteredLangs = {}
  for _, lang in ipairs(lang_T) do
    table.insert(filteredLangs, lang.name)
  end
  lang_idx, lang_idxUsed = ImGui.Combo("##langs", lang_idx, filteredLangs, #lang_T)
end

disableTooltips = lua_cfg.read("disableTooltips")
disableUiSounds = lua_cfg.read("disableUiSounds")
useGameLang     = lua_cfg.read("useGameLang")
settings_tab:add_imgui(function()
  disableTooltips, dtUsed = ImGui.Checkbox(translateLabel("Disable Tooltips"), disableTooltips, true)
  if dtUsed then
    lua_cfg.save("disableTooltips", disableTooltips)
    UI.widgetSound("Nav2")
  end

  disableUiSounds, duisndUsed = ImGui.Checkbox(translateLabel("DisableSound"), disableUiSounds, true)
  UI.toolTip(false, translateLabel("DisableSound_tt"))
  if duisndUsed then
    lua_cfg.save("disableUiSounds", disableUiSounds)
    UI.widgetSound("Nav2")
  end

  ImGui.Text(translateLabel("langTitle") .. " " .. current_lang)
  useGameLang, uglUsed = ImGui.Checkbox(translateLabel("gameLangCB"), useGameLang, true)
  UI.toolTip(false, translateLabel("gameLang_tt"))
  if useGameLang then
    LANG, current_lang = Game.GetLang()
  end
  if uglUsed then
    lua_cfg.save("useGameLang", useGameLang)
    lua_cfg.save("LANG", LANG)
    lua_cfg.save("lang_idx", 0)
  end

  if not useGameLang then
    ImGui.Text(translateLabel("customLangTxt"))
    displayLangs()
    selected_lang = lang_T[lang_idx + 1]
    ImGui.SameLine()
    if ImGui.Button(translateLabel("saveBtn") .. "##lang") then
      LANG         = selected_lang.iso
      current_lang = selected_lang.name
      lua_cfg.save("lang_idx", lang_idx)
      lua_cfg.save("LANG", LANG)
      lua_cfg.save("current_lang", current_lang)
      gui.show_success("Samurai's Scripts", "Language settings saved. Please restart the script to apply the changes.")
    end
  end

  ImGui.Dummy(10, 1)
  if UI.coloredButton(translateLabel("reset_settings_Btn"), "#FF0000", "#EE4B2B", "#880808", 1) then
    UI.widgetSound("Focus_In")
    ImGui.OpenPopup("Confirm")
  end
  ImGui.SetNextWindowPos(760, 400, ImGuiCond.Appearing)
  ImGui.SetNextWindowBgAlpha(0.6)
  if ImGui.BeginPopupModal("Confirm", ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoTitleBar) then
    UI.coloredText(translateLabel("confirm_txt"), "yellow", 1, 20)
    if ImGui.Button("  " .. translateLabel("yes") .. "  ") then
      UI.widgetSound("Select2")
      lua_cfg.reset(default_config)
      Regen             = false
      objectiveTP       = false
      disableTooltips   = false
      phoneAnim         = false
      sprintInside      = false
      lockpick          = false
      replaceSneakAnim  = false
      disableSound      = false
      disableActionMode = false
      Triggerbot        = false
      aimEnemy          = false
      disableUiSounds   = false
      driftMode         = false
      DriftTires        = false
      speedBoost        = false
      nosvfx            = false
      hornLight         = false
      nosPurge          = false
      rgbLights         = false
      loud_radio        = false
      launchCtrl        = false
      popsNbangs        = false
      limitVehOptions   = false
      louderPops        = false
      autobrklight      = false
      holdF             = false
      noJacking         = false
      useGameLang       = false
      DriftIntensity    = 0
      lightSpeed        = 1
      LANG              = "en-US"
      current_lang      = "English"
      ImGui.CloseCurrentPopup()
    end
    ImGui.SameLine(); ImGui.Spacing(); ImGui.SameLine()
    if ImGui.Button("  " .. translateLabel("no") .. "  ") then
      UI.widgetSound("Cancel")
      ImGui.CloseCurrentPopup()
    end
    ImGui.EndPopup()
  end
end)


--[[
    looped scripts
]]

-- Game Input
script.register_looped("GameInput", function()
  if HashGrabber then
    PAD.DISABLE_CONTROL_ACTION(0, 24, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 257, 1)
  end

  if replaceSneakAnim then
    PAD.DISABLE_CONTROL_ACTION(0, 36, 1)
  end

  if is_typing then
    PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
  end

  if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
    if validModel then
      if nosPurge then
        PAD.DISABLE_CONTROL_ACTION(0, 73, true)
      end
    end
    if speedBoost and PAD.IS_CONTROL_PRESSED(0, 71) and PAD.IS_CONTROL_PRESSED(0, tdBtn) then
      if validModel or is_boat or is_bike then
        -- prevent face planting when using NOS mid-air
        PAD.DISABLE_CONTROL_ACTION(0, 60, true)
        PAD.DISABLE_CONTROL_ACTION(0, 61, true)
        PAD.DISABLE_CONTROL_ACTION(0, 62, true)
      end
    end
    if holdF then
      if Game.Self.isDriving() and not is_typing then
        PAD.DISABLE_CONTROL_ACTION(0, 75, true)
      else
        timerB = 0
      end
    end
  end

  if pedGrabber and Game.Self.isOnFoot() then
    PAD.DISABLE_CONTROL_ACTION(0, 24, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 25, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 50, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 68, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 91, 1)
    PAD.DISABLE_CONTROL_ACTION(0, 257, 1)
  end
end)

-- self stuff
script.register_looped("auto-heal", function(ah)
  ah:yield()
  if Regen and Game.Self.isAlive() then
    local maxHp  = Game.Self.maxHealth()
    local myHp   = Game.Self.health()
    local myArmr = Game.Self.armour()
    if myHp < maxHp and myHp > 0 then
      if PED.IS_PED_IN_COVER(self.get_ped()) then
        ENTITY.SET_ENTITY_HEALTH(self.get_ped(), myHp + 20, 0, 0)
      else
        ENTITY.SET_ENTITY_HEALTH(self.get_ped(), myHp + 10, 0, 0)
      end
    end
    if myArmr == nil then
      PED.SET_PED_ARMOUR(self.get_ped(), 10)
    end
    if myArmr ~= nil and myArmr < 50 then
      PED.ADD_ARMOUR_TO_PED(self.get_ped(), 0.5)
    end
  end
end)

script.register_looped("objectiveTP", function()
  if objectiveTP then
    if PAD.IS_CONTROL_JUST_PRESSED(0, 57) then
      for _, n in pairs(objectives_T) do
        local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(n)
        if HUD.DOES_BLIP_EXIST(blip) then
          blipCoords = HUD.GET_BLIP_COORDS(blip)
          break
        end
      end
      if blipCoords ~= nil then
        Game.Self.teleport(true, blipCoords)
      else
        gui.show_warning("Objective Teleport", "No objective found!")
      end
    end
  end
end)
script.register_looped("self features", function(script)
  -- Crouch instead of sneak
  if Game.Self.isOnFoot() and not Game.Self.isInWater() then
    if replaceSneakAnim then
      if not isCrouched and PAD.IS_DISABLED_CONTROL_PRESSED(0, 36) then
        script:sleep(200)
        while not STREAMING.HAS_CLIP_SET_LOADED("move_ped_crouched") and not STREAMING.HAS_CLIP_SET_LOADED("move_aim_strafe_crouch_2h") do
          STREAMING.REQUEST_CLIP_SET("move_ped_crouched")
          STREAMING.REQUEST_CLIP_SET("move_aim_strafe_crouch_2h")
          coroutine.yield()
        end
        PED.SET_PED_MOVEMENT_CLIPSET(self.get_ped(), "move_ped_crouched", 0.3)
        PED.SET_PED_STRAFE_CLIPSET(self.get_ped(), "move_aim_strafe_crouch_2h")
        script:sleep(500)
        isCrouched = true
      end
    end
    if isCrouched and PAD.IS_DISABLED_CONTROL_PRESSED(0, 36) then
      script:sleep(200)
      PED.RESET_PED_MOVEMENT_CLIPSET(self.get_ped(), 0.3)
      script:sleep(500)
      isCrouched = false
    end
  end

  -- Online Phone Animations
  if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
    if phoneAnim and not ENTITY.IS_ENTITY_DEAD(self.get_ped()) then
      if not is_playing_anim and not is_playing_scenario and PED.COUNT_PEDS_IN_COMBAT_WITH_TARGET(self.get_ped()) == 0 then
        if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 242, 1) then
          PED.SET_PED_CONFIG_FLAG(self.get_ped(), 242, false)
        end
        if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 243, 1) then
          PED.SET_PED_CONFIG_FLAG(self.get_ped(), 243, false)
        end
        if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 244, 1) then
          PED.SET_PED_CONFIG_FLAG(self.get_ped(), 244, false)
        end
        if not PED.GET_PED_CONFIG_FLAG(self.get_ped(), 243, 1) and AUDIO.IS_MOBILE_PHONE_CALL_ONGOING() then
          if not STREAMING.HAS_ANIM_DICT_LOADED("anim@scripted@freemode@ig19_mobile_phone@male@") then
            STREAMING.REQUEST_ANIM_DICT("anim@scripted@freemode@ig19_mobile_phone@male@")
            return
          end
          TASK.TASK_PLAY_PHONE_GESTURE_ANIMATION(self.get_ped(), "anim@scripted@freemode@ig19_mobile_phone@male@", "base",
            "BONEMASK_HEAD_NECK_AND_R_ARM", 0.25, 0.25, true, false)
          repeat
            script:sleep(10)
          until
            AUDIO.IS_MOBILE_PHONE_CALL_ONGOING() == false
          TASK.TASK_STOP_PHONE_GESTURE_ANIMATION(self.get_ped(), 0.25)
        end
      else
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 242, true)
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 243, true)
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 244, true)
      end
    else
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 242, true)
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 243, true)
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 244, true)
    end
  else
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 242, 1) and PED.GET_PED_CONFIG_FLAG(self.get_ped(), 243, 1) and PED.GET_PED_CONFIG_FLAG(self.get_ped(), 244, 1) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 242, false)
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 243, false)
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 244, false)
    end
  end

  -- Sprint Inside
  if sprintInside then
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 427, 1) == false then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, true)
    end
  else
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 427, 1) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 427, false)
    end
  end

  -- Lockpick animation
  if lockPick then
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 426, 1) == false then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, true)
    end
  else
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 426, 1) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 426, false)
    end
  end

  -- Action mode
  if disableActionMode then
    PED.SET_PED_USING_ACTION_MODE(self.get_ped(), false, -1, 0)
  end
end)

-- Hash Grabber
script.register_looped("HashGrabber", function(hg)
  if HashGrabber then
    if PLAYER.IS_PLAYER_FREE_AIMING(self.get_id()) and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 24) then
      local ent  = Game.getAimedEntity()
      local hash = Game.getEntityModel(ent)
      local type = Game.getEntityTypeString(ent)
      log.info("Entity N°: " .. tostring(ent) .. " Entity Hash: " .. tostring(hash) .. " Entity Type: " .. tostring(type))
    end
  end
  hg:yield()
end)

-- Triggerbot loop
script.register_looped("TriggerBot", function(trgrbot)
  if Triggerbot then
    if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) then
      aimBool, Entity = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(PLAYER.PLAYER_ID(), Entity)
      if aimBool then
        if ENTITY.IS_ENTITY_A_PED(Entity) and PED.IS_PED_HUMAN(Entity) then
          local bonePos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(Entity, "head"))
          weapon = Game.Self.weapon()
          if WEAPON.IS_PED_WEAPON_READY_TO_SHOOT(self.get_ped()) and Game.Self.isOnFoot() and not PED.IS_PED_RELOADING(self.get_ped()) then
            if not ENTITY.IS_ENTITY_DEAD(Entity) then
              if PAD.IS_CONTROL_PRESSED(0, 21) then
                if aimEnemy then
                  if PED.IS_PED_IN_COMBAT(Entity, self.get_ped()) then
                    TASK.TASK_AIM_GUN_AT_COORD(self.get_ped(), bonePos.x, bonePos.y, bonePos.z, 250, true, false)
                    TASK.TASK_SHOOT_AT_COORD(self.get_ped(), bonePos.x, bonePos.y, bonePos.z, 250, 2556319013)
                  end
                else
                  TASK.TASK_AIM_GUN_AT_COORD(self.get_ped(), bonePos.x, bonePos.y, bonePos.z, 250, true, false)
                  TASK.TASK_SHOOT_AT_COORD(self.get_ped(), bonePos.x, bonePos.y, bonePos.z, 250, 2556319013)
                end
              end
            end
          end
        end
      else
        Entity = 0
      end
    else
      bool = false
    end
  end
  trgrbot:yield()
end)

script.register_looped("auto-kill-enemies", function(ak)
  if autoKill then
    local myCoords = self.get_pos()
    local gta_peds = entities.get_all_peds_as_handles()
    if (PED.COUNT_PEDS_IN_COMBAT_WITH_TARGET_WITHIN_RADIUS(self.get_ped(), myCoords.x, myCoords.y, myCoords.z, 100)) > 0 then
      for _, p in pairs(gta_peds) do
        if PED.IS_PED_HUMAN(p) and PED.IS_PED_IN_COMBAT(p, self.get_ped()) and not PED.IS_PED_A_PLAYER(p) then
          if PED.CAN_PED_IN_COMBAT_SEE_TARGET(p, self.get_ped()) then
            PED.APPLY_DAMAGE_TO_PED(p, 100000, 1, 0); PED.EXPLODE_PED_HEAD(p, 0x7FD62962)
          else
            ak:sleep(969) -- prevent kill spamming. It's fine, I just don't like it.
            PED.APPLY_DAMAGE_TO_PED(p, 100000, 1, 0); PED.EXPLODE_PED_HEAD(p, 0x7FD62962)
          end
          ak:yield()
        end
      end
    end
  end
  ak:yield()
end)

-- vehicle stuff
script.register_looped("TDFT", function(script)
  script:yield()
  if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
    _, _, current_vehicle, _ = onVehEnter()
    is_car                   = VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    is_quad                  = VEHICLE.IS_THIS_MODEL_A_QUADBIKE(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    is_bike                  = (VEHICLE.IS_THIS_MODEL_A_BIKE(ENTITY.GET_ENTITY_MODEL(current_vehicle)) and VEHICLE.GET_VEHICLE_CLASS(current_vehicle) ~= 13)
    is_boat                  = VEHICLE.IS_THIS_MODEL_A_BOAT(ENTITY.GET_ENTITY_MODEL(current_vehicle)) or
        VEHICLE.IS_THIS_MODEL_A_JETSKI(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    if is_car or is_quad then
      validModel = true
    else
      validModel = false
    end
    if validModel and DriftTires and PAD.IS_CONTROL_PRESSED(0, tdBtn) then
      VEHICLE.SET_DRIFT_TYRES(current_vehicle, true)
      VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
    else
      VEHICLE.SET_DRIFT_TYRES(current_vehicle, false)
      VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
    end
    script:yield()
    if validModel and driftMode and PAD.IS_CONTROL_PRESSED(0, tdBtn) and not DriftTires then
      VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, true)
      VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(current_vehicle, DriftIntensity)
      VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
    else
      VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, false)
      VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
    end
    if speedBoost then
      if validModel or is_boat or is_bike then
        if VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) then
          if PAD.IS_DISABLED_CONTROL_PRESSED(0, tdBtn) and PAD.IS_CONTROL_PRESSED(0, 71) then
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, 100.0)
            AUDIO.SET_VEHICLE_BOOST_ACTIVE(current_vehicle, true)
            using_nos = true
          end
        else
          if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
            if PAD.IS_DISABLED_CONTROL_PRESSED(0, tdBtn) and PAD.IS_CONTROL_PRESSED(0, 71) then
              if VEHICLE.GET_VEHICLE_ENGINE_HEALTH(current_vehicle) < 300 then
                failSound = AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Engine_fail", current_vehicle,
                  "DLC_PILOT_ENGINE_FAILURE_SOUNDS", true, 0)
                repeat
                  script:sleep(50)
                until
                  AUDIO.HAS_SOUND_FINISHED(failSound) and PAD.IS_CONTROL_PRESSED(0, tdBtn) == false and PAD.IS_CONTROL_PRESSED(0, 71) == false
                AUDIO.STOP_SOUND(failSound)
              end
            end
          end
        end
      end
      if using_nos and PAD.IS_DISABLED_CONTROL_RELEASED(0, tdBtn) then
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, -1)
        AUDIO.SET_VEHICLE_BOOST_ACTIVE(current_vehicle, false)
        using_nos = false
      end
    end
    if hornLight and Game.Self.isDriving() then
      if not VEHICLE.GET_BOTH_VEHICLE_HEADLIGHTS_DAMAGED(current_vehicle) then
        if PAD.IS_CONTROL_PRESSED(0, 86) then
          VEHICLE.SET_VEHICLE_LIGHTS(current_vehicle, 2)
          VEHICLE.SET_VEHICLE_FULLBEAM(current_vehicle, true)
          repeat
            script:sleep(50)
          until
            PAD.IS_CONTROL_PRESSED(0, 86) == false
          VEHICLE.SET_VEHICLE_FULLBEAM(current_vehicle, false)
          VEHICLE.SET_VEHICLE_LIGHTS(current_vehicle, 0)
        end
      else
        if PAD.IS_CONTROL_JUST_RELEASED(0, 86) then
          gui.show_warning("Tokyo Drift", "Your headlights are broken!")
        end
      end
    end
    if holdF then
      if PAD.IS_DISABLED_CONTROL_PRESSED(0, 75) then
        timerB = timerB + 1
        if timerB >= 15 then
          PED.SET_PED_CONFIG_FLAG(self.get_ped(), 241, false)
          TASK.TASK_LEAVE_VEHICLE(self.get_ped(), current_vehicle, 0)
          timerB = 0
        end
      end
      if timerB >= 1 and timerB <= 10 then
        if PAD.IS_DISABLED_CONTROL_RELEASED(0, 75) then
          PED.SET_PED_CONFIG_FLAG(self.get_ped(), 241, true)
          TASK.TASK_LEAVE_VEHICLE(self.get_ped(), current_vehicle, 0)
          timerB = 0
        end
      end
    else
      if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 241, 1) then
        PED.SET_PED_CONFIG_FLAG(self.get_ped(), 241, false)
      end
    end
  else
    current_vehicle = 0
    if started_lct then
      started_lct = false
    end
    if started_popSound then
      started_popSound = false
    end
    if started_popSound2 then
      started_popSound2 = false
    end
  end
end)

script.register_looped("LCTRL", function(lct)
  if launchCtrl and Game.Self.isDriving() then
    if limitVehOptions then
      if VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 4 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 6 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 7 then
        lct:yield()
        return
      end
    end
    local notif_sound, notif_ref
    if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
      notif_sound, notif_ref = "SELL", "GTAO_EXEC_SECUROSERV_COMPUTER_SOUNDS"
    else
      notif_sound, notif_ref = "MP_5_SECOND_TIMER", "HUD_FRONTEND_DEFAULT_SOUNDSET"
    end
    if validModel or is_bike or is_quad then
      if VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) and VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) and VEHICLE.GET_VEHICLE_ENGINE_HEALTH(current_vehicle) > 300 then
        if PAD.IS_CONTROL_PRESSED(0, 71) and PAD.IS_CONTROL_PRESSED(0, 72) then
          started_lct = true
          ENTITY.FREEZE_ENTITY_POSITION(current_vehicle, true)
          timerA = timerA + 1
          if timerA >= 150 then
            gui.show_success("TokyoDrift", "Launch Control Activated!")
            AUDIO.PLAY_SOUND_FRONTEND(-1, notif_sound, notif_ref, true)
            repeat
              lct:sleep(100)
            until PAD.IS_CONTROL_RELEASED(0, 72)
            launch_active = true
          end
        elseif started_lct and timerA > 0 and timerA < 150 then
          if PAD.IS_CONTROL_RELEASED(0, 71) or PAD.IS_CONTROL_RELEASED(0, 72) then
            timerA = 0
            ENTITY.FREEZE_ENTITY_POSITION(current_vehicle, false)
            started_lct = false
          end
        end
      end
      if launch_active then
        if PAD.IS_CONTROL_PRESSED(0, 71) and PAD.IS_CONTROL_RELEASED(0, 72) then
          PHYSICS.SET_IN_ARENA_MODE(true)
          VEHICLE.SET_VEHICLE_MAX_LAUNCH_ENGINE_REVS_(current_vehicle, -1)
          VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 10)
          VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, 100.0)
          ENTITY.FREEZE_ENTITY_POSITION(current_vehicle, false)
          VEHICLE.SET_VEHICLE_FORWARD_SPEED(current_vehicle, 9.3)
          lct:sleep(4269)
          VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, -1)
          VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
          VEHICLE.SET_VEHICLE_MAX_LAUNCH_ENGINE_REVS_(current_vehicle, 1.0)
          PHYSICS.SET_IN_ARENA_MODE(false)
          launch_active = false
          timerA = 0
        end
      end
    end
  end
  lct:yield()
end)

script.register_looped("Auto Brake Lights", function()
  if autobrklight and Game.Self.isDriving() then
    if VEHICLE.IS_VEHICLE_DRIVEABLE(current_vehicle) and VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) and VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) then
      VEHICLE.SET_VEHICLE_BRAKE_LIGHTS(current_vehicle, true)
    end
  end
end)

script.register_looped("NOS ptfx", function(spbptfx)
  if speedBoost and Game.Self.isDriving() then
    if validModel or is_boat or is_bike then
      if PAD.IS_DISABLED_CONTROL_PRESSED(0, tdBtn) and PAD.IS_CONTROL_PRESSED(0, 71) then
        if VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) then
          local effect  = "veh_xs_vehicle_mods"
          local counter = 0
          while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(effect) do
            STREAMING.REQUEST_NAMED_PTFX_ASSET(effect)
            spbptfx:yield()
            if counter > 100 then
              return
            else
              counter = counter + 1
            end
          end
          local exhaustCount = VEHICLE.GET_VEHICLE_MAX_EXHAUST_BONE_COUNT_() - 1
          for i = 0, exhaustCount do
            local retBool, boneIndex = VEHICLE.GET_VEHICLE_EXHAUST_BONE_(current_vehicle, i, retBool, boneIndex)
            if retBool then
              GRAPHICS.USE_PARTICLE_FX_ASSET(effect)
              nosPtfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("veh_nitrous", current_vehicle, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, boneIndex, 1.0, false, false, false, 0, 0, 0)
              table.insert(nosptfx_t, nosPtfx)
              if nosvfx then
                GRAPHICS.ANIMPOSTFX_PLAY("DragRaceNitrous", 0, false)
              end
              nos_started = true
            end
          end
          if nos_started then
            repeat
              spbptfx:sleep(50)
            until
              PAD.IS_DISABLED_CONTROL_RELEASED(0, tdBtn) or PAD.IS_CONTROL_RELEASED(0, 71)
            if nosvfx then
              GRAPHICS.ANIMPOSTFX_PLAY("DragRaceNitrousOut", 0, false)
            end
            if GRAPHICS.ANIMPOSTFX_IS_RUNNING("DragRaceNitrous") then
              GRAPHICS.ANIMPOSTFX_STOP("DragRaceNitrous")
            end
            if GRAPHICS.ANIMPOSTFX_IS_RUNNING("DragRaceNitrousOut") then
              GRAPHICS.ANIMPOSTFX_STOP("DragRaceNitrousOut")
            end
            for _, nos in ipairs(nosptfx_t) do
              if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(nos) then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(nos)
                GRAPHICS.REMOVE_PARTICLE_FX(nos)
                nos_started = false
              end
            end
          end
        end
      end
    end
  end
end)

script.register_looped("2-step", function(twostep)
  if launchCtrl and Game.Self.isDriving() then
    if limitVehOptions then
      if VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 4 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 6 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 7 then
        twostep:yield()
        return
      end
    end
    if validModel or is_bike or is_quad then
      if VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) and VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) and VEHICLE.GET_VEHICLE_ENGINE_HEALTH(current_vehicle) >= 300 then
        if PAD.IS_CONTROL_PRESSED(0, 71) and PAD.IS_CONTROL_PRESSED(0, 72) then
          local asset   = "core"
          local counter = 0
          while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
            STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
            twostep:yield()
            if counter > 100 then
              return
            else
              counter = counter + 1
            end
          end
          local exhaustCount = VEHICLE.GET_VEHICLE_MAX_EXHAUST_BONE_COUNT_() - 1
          for i = 0, exhaustCount do
            local retBool, boneIndex = VEHICLE.GET_VEHICLE_EXHAUST_BONE_(current_vehicle, i, retBool, boneIndex)
            if retBool then
              GRAPHICS.USE_PARTICLE_FX_ASSET(asset)
              lctPtfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("veh_backfire", current_vehicle, 0.0,
                0.0, 0.0, 0.0, 0.0, 0.0, boneIndex, 0.69420, false, false, false, 0, 0, 0)
              table.insert(lctPtfx_t, lctPtfx)
              twostep_started = true
            end
          end
          if twostep_started then
            repeat
              twostep:sleep(50)
            until PAD.IS_CONTROL_RELEASED(0, 72) or launch_active == false
            for _, bfire in ipairs(lctPtfx_t) do
              if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(bfire) then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(bfire)
                GRAPHICS.REMOVE_PARTICLE_FX(bfire)
              end
            end
            twostep_started = false
          end
        end
      end
    end
  end
end)

script.register_looped("LCTRL SFX", function(tstp)
  if Game.Self.isDriving() then
    if limitVehOptions then
      if VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 4 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 6 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 7 then
        tstp:yield()
        return
      end
    end

    if launchCtrl then
      if lctPtfx_t[1] ~= nil then
        local popSound
        if VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) and PAD.IS_CONTROL_PRESSED(0, 71) and PAD.IS_CONTROL_PRESSED(0, 72) then
          for _, p in ipairs(lctPtfx_t) do
            if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(p) then
              local randStime = math.random(60, 120)
              popSound = AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "BOOT_POP", current_vehicle, "DLC_VW_BODY_DISPOSAL_SOUNDS",
                true, 0)
              AUDIO.SET_AUDIO_SPECIAL_EFFECT_MODE(1)
              table.insert(popSounds_t, popSound)
              tstp:sleep(randStime)
              started_popSound = true
            end
          end
        end
        if started_popSound then
          if PAD.IS_CONTROL_RELEASED(0, 71) or PAD.IS_CONTROL_RELEASED(0, 72) then
            for _, s in ipairs(popSounds_t) do
              AUDIO.STOP_SOUND(s)
            end
          end
        end
      end
    end

    if popsNbangs then
      if VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) then
        rpmThreshold = 0.45
      else
        rpmThreshold = 0.69
      end
      if not louderPops then
        popsnd, sndRef = "BOOT_POP", "DLC_VW_BODY_DISPOSAL_SOUNDS"
        flame_size = 0.42069
      else
        popsnd, sndRef = "SNIPER_FIRE", "DLC_BIKER_RESUPPLY_MEET_CONTACT_SOUNDS"
        flame_size = 1.5
      end
      local currRPM  = VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(current_vehicle)
      local currGear = VEHICLE.GET_VEHICLE_CURRENT_DRIVE_GEAR_(current_vehicle)
      if PAD.IS_CONTROL_RELEASED(0, 71) and currRPM < 1.0 and currRPM > rpmThreshold and currGear ~= 0 then
        local popSound2
        local randStime = math.random(60, 200)
        popSound2 = AUDIO.PLAY_SOUND_FROM_ENTITY(-1, popsnd, current_vehicle, sndRef, true, 0)
        table.insert(popSounds_t, popSound2)
        tstp:sleep(randStime)
        started_popSound2 = true
      end
      if started_popSound2 then
        currRPM = VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(current_vehicle)
        if PAD.IS_CONTROL_PRESSED(0, 71) or currRPM < rpmThreshold then
          for _, s in ipairs(popSounds_t) do
            AUDIO.STOP_SOUND(s)
          end
        end
      end
    end
  else
    tstp:yield()
  end
end)

script.register_looped("pops&bangs", function(pnb)
  if Game.Self.isDriving() and VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(current_vehicle) then
    if is_car or is_bike or is_quad then
      if popsNbangs then
        if limitVehOptions then
          if VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 4 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 6 and VEHICLE.GET_VEHICLE_CLASS(self.get_veh()) ~= 7 then
            pnb:yield()
            return
          end
        end
        AUDIO.ENABLE_VEHICLE_EXHAUST_POPS(current_vehicle, false)
        local counter  = 0
        local asset    = "core"
        local currRPM  = VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(current_vehicle)
        local currGear = VEHICLE.GET_VEHICLE_CURRENT_DRIVE_GEAR_(current_vehicle)
        if VEHICLE.IS_VEHICLE_STOPPED(current_vehicle) then
          rpmThreshold = 0.45
        else
          rpmThreshold = 0.69
        end
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(asset) do
          STREAMING.REQUEST_NAMED_PTFX_ASSET(asset)
          pnb:yield()
          if counter > 100 then
            return
          else
            counter = counter + 1
          end
        end
        if PAD.IS_CONTROL_RELEASED(0, 71) and currRPM < 1.0 and currRPM > rpmThreshold and currGear ~= 0 then
          local exhaustCount = VEHICLE.GET_VEHICLE_MAX_EXHAUST_BONE_COUNT_() - 1
          for i = 0, exhaustCount do
            local retBool, boneIndex = VEHICLE.GET_VEHICLE_EXHAUST_BONE_(current_vehicle, i, retBool, boneIndex)
            if retBool then
              currRPM = VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(current_vehicle)
              if currRPM < 1.0 and currRPM > 0.55 then
                GRAPHICS.USE_PARTICLE_FX_ASSET(asset)
                popsPtfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("veh_backfire", current_vehicle,
                  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, boneIndex, flame_size, false, false, false, 0, 0, 0)
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(popsPtfx)
                table.insert(popsPtfx_t, popsPtfx)
                started_popSound2 = true
              end
            end
          end
        end
        if started_popSound2 then
          currRPM = VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(current_vehicle)
          if PAD.IS_CONTROL_PRESSED(0, 71) or currRPM < rpmThreshold then
            for _, bfire in ipairs(popsPtfx_t) do
              if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(bfire) then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(bfire)
                GRAPHICS.REMOVE_PARTICLE_FX(bfire)
              end
            end
            for _, s in ipairs(popSounds_t) do
              AUDIO.STOP_SOUND(s)
            end
          end
        end
      else
        AUDIO.ENABLE_VEHICLE_EXHAUST_POPS(current_vehicle, true)
      end
    end
  else
    pnb:yield()
  end
end)

script.register_looped("Purge", function(nosprg)
  if Game.Self.isDriving() then
    if nosPurge and validModel or nosPurge and is_bike then
      if PAD.IS_DISABLED_CONTROL_PRESSED(0, 73) then
        local dict       = "core"
        local purgeBones = { "suspension_lf", "suspension_rf" }
        if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(dict) then
          STREAMING.REQUEST_NAMED_PTFX_ASSET(dict)
          coroutine.yield()
        end
        for _, boneName in ipairs(purgeBones) do
          local purge_exit = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(current_vehicle, boneName)
          if boneName == "suspension_lf" then
            rotZ = -180.0
            posX = -0.3
          else
            rotZ = 0.0
            posX = 0.3
          end
          GRAPHICS.USE_PARTICLE_FX_ASSET(dict)
          purgePtfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("weap_extinguisher", current_vehicle,
            posX, -0.33, 0.2, 0.0, -17.5, rotZ, purge_exit, 0.4, false, false, false, 0, 0, 0)
          table.insert(purgePtfx_t, purgePtfx)
          purge_started = true
        end
        if purge_started then
          repeat
            nosprg:sleep(50)
          until
            PAD.IS_DISABLED_CONTROL_RELEASED(0, 73)
          for _, purge in ipairs(purgePtfx_t) do
            if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(purge) then
              GRAPHICS.STOP_PARTICLE_FX_LOOPED(purge)
              GRAPHICS.REMOVE_PARTICLE_FX(purge)
              purge_started = false
            end
          end
        end
      end
    end
  else
    nosprg:yield()
  end
end)

script.register_looped("rgbLights", function(rgb)
  if rgbLights then
    for i = 0, 14 do
      if rgbLights and not VEHICLE.GET_BOTH_VEHICLE_HEADLIGHTS_DAMAGED(current_vehicle) then
        if not has_xenon then
          VEHICLE.TOGGLE_VEHICLE_MOD(current_vehicle, 22, true)
        end
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.9)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.8)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.7)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.6)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.5)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.4)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.3)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.2)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.1)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.2)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.3)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.4)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.5)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.6)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.7)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.8)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.9)
        rgb:sleep(100 / lightSpeed)
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 1.0)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
        rgb:sleep(100 / lightSpeed)
      else
        if has_xenon then
          VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 1.0)
          VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, defaultXenon)
          break
        else
          VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 1.0)
          VEHICLE.TOGGLE_VEHICLE_MOD(current_vehicle, 22, false)
          break
        end
      end
    end
  else
    rgb:yield()
  end
end)

script.register_looped("no jacking", function(ctt)
  if noJacking then
    if not PED.GET_PED_CONFIG_FLAG(self.get_ped(), 398, 1) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 398, true)
    end
    if PED.GET_PED_CONFIG_FLAG(self.get_ped(), 177, 1) then
      PED.SET_PED_CONFIG_FLAG(self.get_ped(), 177, true)
    end
  end
  ctt:yield()
end)

-- World
script.register_looped("Ped Grabber", function(pg)
  if pedGrabber then
    if Game.Self.isOnFoot() then
      local nearestPed = Game.getClosestPed(self.get_ped(), 10)
      if not ped_grabbed and nearestPed ~= 0 then
        if PED.IS_PED_ON_FOOT(nearestPed) and not PED.IS_PED_A_PLAYER(nearestPed) then
          if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 24) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 257) then
            ped_grabbed, attached_ped = attachPed(nearestPed)
            pg:sleep(200)
            if attached_ped ~= 0 then
              playHandsUp()
              ENTITY.FREEZE_ENTITY_POSITION(attached_ped, true)
              ped_grabbed = true
            end
          end
        end
      end
      if ped_grabbed and attached_ped ~= 0 then
        PED.FORCE_PED_MOTION_STATE(attached_ped, 0x0EC17E58, 0, 0, 0)
        if PED.IS_PED_RAGDOLL(self.get_ped()) then
          repeat
            pg:sleep(100)
          until PED.IS_PED_RAGDOLL(self.get_ped()) == false
          playHandsUp()
        end
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, 25) then
          if PAD.IS_DISABLED_CONTROL_PRESSED(0, 24) or PAD.IS_DISABLED_CONTROL_PRESSED(0, 257) then
            local myFwdX = Game.getForwardX(self.get_ped())
            local myFwdY = Game.getForwardY(self.get_ped())
            ENTITY.FREEZE_ENTITY_POSITION(attached_ped, false)
            ENTITY.DETACH_ENTITY(attached_ped, true, true)
            TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attached_ped, false)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attached_ped, false)
            PED.SET_PED_TO_RAGDOLL(attached_ped, 1500, 0, 0, false)
            ENTITY.SET_ENTITY_VELOCITY(attached_ped, (pedthrowF * myFwdX), (pedthrowF * myFwdY), 0)
            TASK.CLEAR_PED_TASKS(self.get_ped())
            pg:sleep(200)
            attached_ped = 0
            ped_grabbed  = false
          end
        end
      end
    end
  end
  pg:yield()
end)

script.register_looped("Carpool", function(cp)
  if carpool then

    if PED.IS_PED_SITTING_IN_ANY_VEHICLE(self.get_ped()) then
      stop_searching = true
    else
      stop_searching = false
    end

    if not stop_searching then
      nearestVeh = Game.getClosestVehicle(self.get_ped(), 10)
    end
    local trying_to_enter = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(self.get_ped())
    if trying_to_enter ~= 0 and trying_to_enter == nearestVeh then
      driverPed = VEHICLE.GET_PED_IN_VEHICLE_SEAT(trying_to_enter, -1, true)
      if driverPed ~= nil and driverPed ~= self.get_ped() and not PED.IS_PED_A_PLAYER(driverPed) then
        thisVeh = trying_to_enter
        PED.SET_PED_CONFIG_FLAG(driverPed, 251, true)
        PED.SET_PED_CONFIG_FLAG(driverPed, 255, true)
        PED.SET_PED_CONFIG_FLAG(driverPed, 398, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driverPed, true)
      end
    end
    if PED.IS_PED_SITTING_IN_VEHICLE(self.get_ped(), thisVeh) then
      local ped_to_reset = VEHICLE.GET_PED_IN_VEHICLE_SEAT(thisVeh, -1, true)
      if ped_to_reset ~= nil and ped_to_reset ~= self.get_ped() and not PED.IS_PED_A_PLAYER(ped_to_reset) then
        show_npc_veh_ctrls = true
        stop_searching     = true
        repeat
          cp:sleep(100)
        until PED.IS_PED_SITTING_IN_VEHICLE(self.get_ped(), thisVeh) == false
        PED.SET_PED_CONFIG_FLAG(ped_to_reset, 251, false)
        PED.SET_PED_CONFIG_FLAG(ped_to_reset, 255, false)
        PED.SET_PED_CONFIG_FLAG(ped_to_reset, 398, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped_to_reset, false)
        show_npc_veh_ctrls = false
        stop_searching     = false
      else
        show_npc_veh_ctrls = false
      end
    end
  end
  cp:yield()
end)
