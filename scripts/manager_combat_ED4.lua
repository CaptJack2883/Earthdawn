-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


--
-- CUSTOM EARTHDAWN RULESET FUNCTIONS
--

function ctRestOvernight()
  CombatManager.resetInit();
  for _,v in pairs(CombatManager.getCombatantNodes()) do
    local rActor = ActorManager.resolveActor(v);
    if ActorManager.isPC(rActor) then
      local rActor = ActorManager.resolveActor(v);
      local sClass, sRecord = DB.getValue(v, "link", "", "");
			local nodeActor = DB.findNode(sRecord);
      CharacterManager.overnightRest(nodeActor);
    end
	end
end

function rollAllInit()
  for _,v in pairs(CombatManager.getCombatantNodes()) do
    local rActor = ActorManager.resolveActor(v);
    if ActorManager.isPC(rActor) then
      local sClass, sRecord = DB.getValue(v, "link", "", "");
      local nodeActor = DB.findNode(sRecord);
      CharacterManager.rollInit(nodeActor, false);
    else
      local nodeNPC = ActorManager.getCreatureNode(rActor);
      CharacterManager.rollInit(nodeNPC, true);
    end
  end
end

function rollNPCInit()
  for _,v in pairs(CombatManager.getCombatantNodes()) do
    local rActor = ActorManager.resolveActor(v);
    if not ActorManager.isPC(rActor) then
      local nodeNPC = ActorManager.getCreatureNode(rActor);
      CharacterManager.rollInit(nodeNPC, true);
    end
  end
end

function rollPCInit()
  for _,v in pairs(CombatManager.getCombatantNodes()) do
    local rActor = ActorManager.resolveActor(v);
    if ActorManager.isPC(rActor) then
      local sClass, sRecord = DB.getValue(v, "link", "", "");
      local nodeActor = DB.findNode(sRecord);
      CharacterManager.rollInit(nodeActor, false);
    end
  end
end
