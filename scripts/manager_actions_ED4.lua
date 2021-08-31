-- Action Manager for Earthdawn 4th Edition. 
--  rSource, rRolls, aTargets = decodeActionFromDrag(draginfo, false);

-- This fixes table index being nil.
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
  --Register OOB Message Handlers
  
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);
	
	-- Register the result handlers - called after the dice have stopped rolling
  -- ActionStep.onResult(rSource, rTarget, rRoll); (from combo)
	-- ActionsManager.registerResultHandler("mytestaction", onRoll);
	ActionsManager.registerResultHandler("initroll", onResult);
	ActionsManager.registerResultHandler("strength", onResult);
	ActionsManager.registerResultHandler("dexterity", onResult);
	ActionsManager.registerResultHandler("toughness", onResult);
	ActionsManager.registerResultHandler("perception", onResult);
	ActionsManager.registerResultHandler("willpower", onResult);
	ActionsManager.registerResultHandler("charisma", onResult);
	ActionsManager.registerResultHandler("recovery", onResult);
	ActionsManager.registerResultHandler("heal", onResult);
	ActionsManager.registerResultHandler("damage", onResult);
	ActionsManager.registerResultHandler("mysticdamage", onResult);
	ActionsManager.registerResultHandler("stun", onResult);
	ActionsManager.registerResultHandler("attack", onResult);
	ActionsManager.registerResultHandler("mysticattack", onResult);
	ActionsManager.registerResultHandler("socialattack", onResult);
	ActionsManager.registerResultHandler("knockdown", onResult);
	ActionsManager.registerResultHandler("karma", onResult);
	ActionsManager.registerResultHandler("talent", onResult);
	ActionsManager.registerResultHandler("skill", onResult);
	ActionsManager.registerResultHandler("spell", onResult);
	ActionsManager.registerResultHandler("effectRoll", onResult);
	ActionsManager.registerResultHandler("spellcasting", onResult);
	ActionsManager.registerResultHandler("threadweaving", onResult);
	ActionsManager.registerResultHandler("stepRoll", onResult);
	ActionsManager.registerResultHandler("dice", onResult);
end

function getRoll(sType, rStep, rActor, bSecretRoll)
	-- Initialise a blank rRoll record
	local rRoll = {};
  rRoll.sDesc = "";
	-- the dice to roll. Set correct step dice based on rStep
  if not rStep then
    Debug.console("ActionManagerED4: Called getRoll, but rStep was nil.");
    rStep = 1;
  end
  if rStep then
    rRoll = StepLookup.getRoll(rStep, sType);
  end
  
  --Check KarmaWidget to see if we need to add Karma.
  if Global.KarmaWidgetValue then
    -- Make sure it's not a pure karma roll
    local useKarma = true;
    if sType == "karma" then
      useKarma = false;
    end
    if sType == "skill" then
      useKarma = false;
    end
    if useKarma then
      -- We need to see if the char has karma points left.
      local karmaValue = CharacterManager.getKarmaValue(rActor);
      if karmaValue > 0 then
        -- We need to add dice equal to the karma step (default Step 4/d6)
        rRoll.aDice.expr = rRoll.aDice.expr.."+d6e"
        rRoll.sDesc = rRoll.sDesc.." (with Karma) "
        -- If we calculate the new karma value here, and set it as part of the rRoll.
        -- We only deduct one point, regardless how many times it targets?
        karmaValue = karmaValue - 1;
        if karmaValue < 1 then
          karmaValue = 0;
        end
        rRoll.nKarmaLeft = karmaValue;
      end
    end
  end
	-- Action type.
  if sType then
    rRoll.sType = sType;
  end
	-- The description to show in the chat window
  if rRoll.sType == "initroll" then
    rRoll.sDesc = "Initiative: " .. rRoll.sDesc;
  elseif rRoll.sType == "strength" then
    rRoll.sDesc =  "Strength Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "dexterity" then
    rRoll.sDesc =  "Dexterity Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "toughness" then
    rRoll.sDesc =  "Toughness Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "perception" then
    rRoll.sDesc =  "Perception Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "willpower" then
    rRoll.sDesc =  "Willpower Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "charisma" then
    rRoll.sDesc =  "Charisma Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "recovery" then
    rRoll.sDesc =  "Recovery Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "knockdown" then
    rRoll.sDesc =  "Knockdown Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "karma" then
    rRoll.sDesc =  "Karma Die: " .. rRoll.sDesc;
  elseif rRoll.sType == "heal" then
    rRoll.sDesc =  "Heal: " .. rRoll.sDesc;
  elseif rRoll.sType == "damage" then
    rRoll.sDesc =  "Damage: " .. rRoll.sDesc;
  elseif rRoll.sType == "mysticdamage" then
    rRoll.sDesc =  "Mystic Damage: " .. rRoll.sDesc;
  elseif rRoll.sType == "stun" then
    rRoll.sDesc =  "Stun Damage: " .. rRoll.sDesc;
  elseif rRoll.sType == "attack" then
    rRoll.sDesc =  "Attack: " .. rRoll.sDesc;
  elseif rRoll.sType == "mysticattack" then
    rRoll.sDesc =  "Mystic Attack: " .. rRoll.sDesc;
  elseif rRoll.sType == "socialattack" then
    rRoll.sDesc =  "Social Attack: " .. rRoll.sDesc;
  elseif rRoll.sType == "talent" then
    rRoll.sDesc =  "Talent: " .. rRoll.sDesc;
  elseif rRoll.sType == "skill" then
    rRoll.sDesc =  "Skill: " .. rRoll.sDesc;
  elseif rRoll.sType == "effectRoll" then
    rRoll.sDesc =  "Spell Effect Test: " .. rRoll.sDesc;
  elseif rRoll.sType == "spell" then
    rRoll.sDesc =  "Spellcasting Test: " .. rRoll.sDesc;
  elseif rRoll.sType == "spellcasting" then
    rRoll.sDesc =  "Spellcasting Test: " .. rRoll.sDesc;
  elseif rRoll.sType == "threadweaving" then
    rRoll.sDesc =  "Thread Weaving Test: " .. rRoll.sDesc;
  elseif rRoll.sType == "stepRoll" then
    rRoll.sDesc =  "Manual Step Roll: " .. rRoll.sDesc;
  else
    rRoll.sDesc =  "Default Roll Description";
  end
	-- For GM secret rolls.
	rRoll.bSecret = bSecretRoll;
  -- Verify that the type matches description.
  rRoll = ActionManagerED4.checkDescType(rRoll);
	return rRoll;
end

function dragRoll(draginfo, sType, rStep, rActor, rRoll, bSecretRoll)
  --[[
  if draginfo then
    rActor, _, vTargets = ActionsManager.decodeActionFromDrag(draginfo, false);
  end
  ]]--
  if not rRoll then
    rRoll = ActionManagerED4.getRoll(sType, rStep, rActor, bSecretRoll);
  end
  if rRoll.sType == "dice" then
    rRoll = ActionManagerED4.checkDescType(rRoll);
  end
  if rActor then
    rActor, rRoll = CharacterManager.verifyActor(rActor, rRoll);
  end
  ActionsManager.performAction(draginfo, rActor, rRoll);
end

function pushRoll(sType, rStep, rActor, rRoll, bSecretRoll)
  if not rRoll then
    rRoll = ActionManagerED4.getRoll(sType, rStep, rActor, bSecretRoll)
  end
  if rRoll.sType == "dice" then
    rRoll = ActionManagerED4.checkDescType(rRoll);
  end
  rActor, rRoll = CharacterManager.verifyActor(rActor, rRoll);
  if not rRoll.bSecretRoll and OptionsManager.isOption("MANUALROLL", "on") then
    local wManualRoll = Interface.openWindow("manualrolls", "");
    wManualRoll.addRoll(rRoll, rActor, vTargets);
  else
    ActionsManager.performAction(draginfo, rActor, rRoll);
  end
end

function checkDescType(rRoll)
  if not rRoll then
    return
  end
  if rRoll.sType then
    local sType = rRoll.sType;
  end
  
  if rRoll.sDesc then
    local sDescLower = string.lower(rRoll.sDesc);
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "attack");
    if sDesc == "attack" then
      rRoll.sType = "attack"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "mystic attack");
    if sDesc == "mystic attack" then
      rRoll.sType = "mysticattack"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "social attack");
    if sDesc == "social attack" then
      rRoll.sType = "socialattack"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "damage");
    if sDesc == "damage" then
      rRoll.sType = "damage"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "stun");
    if sDesc == "stun" then
      rRoll.sType = "stun"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "mystic damage");
    if sDesc == "mystic damage" then
      rRoll.sType = "mysticdamage"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "heal");
    if sDesc == "heal" then
      rRoll.sType = "heal"
      sDesc = nil;
    end
  end
  return rRoll;
end

function onResult(rSource, rTarget, rRoll, nTotal)
  -- Make sure the modifierstack is cleared.
  ModifierStack.reset();
  -- Reset the Karma Widget
  WidgetManager.reset();
  
  --Look for targets after confirming rSource has character/CT node.
  local rActor = ActorManager.resolveActor(rSource);
  local aTargetNodes = {};
  local aTargets;
  if not rTarget then
		if rRoll.bSelfTarget then
			aTargets = { rActor };
		else
			aTargets = TargetingManager.getFullTargets(rActor);
		end
		for _,v in ipairs(aTargets) do
			local sCTNode = ActorManager.getCTNodeName(v);
			if sCTNode ~= "" then
				table.insert(aTargetNodes, sCTNode);
			end
		end
		
		if #aTargetNodes > 0 then
			rRoll.aTargets = table.concat(aTargetNodes, "|");
		end
  end
  
  --We need to make sure that rRoll.sType has the correct info for the below functions to work.
  --We also need to check if karma was added to the roll so that we can deduct a karma point.
  --Extract the type of roll from the rRoll.sDesc. (if the sType is not already set?)
  if rRoll.sType == "dice" then
    rRoll = ActionManagerED4.checkDescType(rRoll);
  end
  if rRoll.sDesc then
    local sDescLower = string.lower(rRoll.sDesc);
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "karma");
    if sDesc == "karma" then
      if rRoll.nKarmaLeft then
        local kValue = rRoll.nKarmaLeft;
        CharacterManager.setKarmaValue(rActor, kValue);
      end
      sDesc = nil;
    end
  end
  
  --Color dice for 1's and Explosions.
	ActionManagerED4.decodeDiceResults(rRoll);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
  if rRoll.sType == "initroll" then
    local nTotal = ActionsManager.total(rRoll);
    if nTotal < 1 then
      nTotal = 1;
    end
    notifyApplyInit(rSource, nTotal);
  end
  if rRoll.sType == "recovery" then
    local nodeChar = ActorManager.getCreatureNode(rSource);
    -- First we need to see if the char has recovery tests left.
    local recTests = CharacterManager.getRecoveryTests(nodeChar) or 0;
    if recTests > 0 then
      -- check for damage/stun and heal it.
      local oldDamage = DB.getValue(nodeChar, "health.damage.value", 0);
      local oldStun = DB.getValue(nodeChar, "health.damage.stun", 0);
      local wounds = DB.getValue(nodeChar, "health.wounds.value", 0);
      local healValue = 0;
      local nTotal = ActionsManager.total(rRoll);
      if nTotal > 0 then
        healValue = healValue + nTotal - wounds;
      end
      if healValue < 1 then
        healValue = 1;
      end
      local newDamage = oldDamage - healValue;
      local newStun = oldStun - healValue;
      if newDamage < 0 then
        newDamage = 0;
      end
      if newStun < 0 then
        newStun = 0;
      end
      DB.setValue(nodeChar, "health.damage.value", "number", newDamage);
      DB.setValue(nodeChar, "health.damage.stun", "number", newStun);
      -- Now we deduct the point we just used.
      recTests = recTests -1
      if recTests < 1 then
        recTests = 0;
      end
      CharacterManager.setRecoveryTests(nodeChar, recTests);
    else
      -- char had no recovery tests, let them know why they weren't healed.
      local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
      rMessage.text = rSource.sName.." tried to use a recovery test, but had none available.";
      Comm.deliverChatMessage(rMessage);
    end
  end
  
  if rRoll.sType == "heal" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveHeal(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveHeal(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "damage" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveDamage(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveDamage(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "mysticdamage" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveMysticDamage(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveMysticDamage(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "stun" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveStunDamage(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveStunDamage(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "attack" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveAttack(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveAttack(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "mysticattack" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveMysticAttack(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveMysticAttack(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "socialattack" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveSocialAttack(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveSocialAttack(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "spell" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveSpellcasting(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveSpellcasting(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "effectRoll" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveEffectRoll(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveEffectRoll(ctActor, ctTarget, rRoll);
    end
  end
  if rTarget then
    rTarget = nil;
  end
  if nodeTarget then
    nodeTarget = nil;
  end
  if targetCTNode then
    targetCTNode = nil;
  end
  if ctTarget then
    ctTarget = nil;
  end
end

function resolveAttack(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDefense = DB.getValue(nodeTarget, "defenses.physical.value", 0);
  local hitOrMiss = "missed.";
  rMessage.icon = "poll_negative";
  if nTotal >= targetDefense then
    hitOrMiss = "hits.";
    rMessage.icon = "iconSword";
  end
  rMessage.text = "Attacking "..rTarget.sName.." with a physical attack. The attack "..hitOrMiss;
	Comm.deliverChatMessage(rMessage);
end

function resolveMysticAttack(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDefense = DB.getValue(nodeTarget, "defenses.mystic.value", 0);
  local hitOrMiss = "missed.";
  rMessage.icon = "poll_negative";
  if nTotal >= targetDefense then
    hitOrMiss = "hits.";
    rMessage.icon = "iconSword";
  end
  rMessage.text = "Attacking "..rTarget.sName.." with a mystic attack. The attack "..hitOrMiss;
	Comm.deliverChatMessage(rMessage);
end

function resolveSocialAttack(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDefense = DB.getValue(nodeTarget, "defenses.social.value", 0);
  local hitOrMiss = "missed.";
  rMessage.icon = "poll_negative";
  if nTotal >= targetDefense then
    hitOrMiss = "hits.";
    rMessage.icon = "iconSword";
  end
  rMessage.text = "Attacking "..rTarget.sName.." with a social attack. The attack "..hitOrMiss;
	Comm.deliverChatMessage(rMessage);
end

function resolveSpellcasting(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
  if rRoll.vs then
    local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
    local sVS = rRoll.vs;
    local versusLower = string.lower(sVS);
    local defenseVS = nil
    local vsDefense, sRemain;
    vsDefense, sRemain = StringManager.extractPattern(versusLower, "phys");
    if vsDefense and vsDefense == "phys" then
      defenseVS = "physical";
      vsDefense = nil;
    end
    vsDefense, sRemain = StringManager.extractPattern(versusLower, "myst");
    if vsDefense and vsDefense == "myst" then
      defenseVS = "mystic";
      vsDefense = nil;
    end
    vsDefense, sRemain = StringManager.extractPattern(versusLower, "soci");
    if vsDefense and vsDefense == "soci" then
      defenseVS = "social";
      vsDefense = nil;
    end
    if defenseVS then
      local targetDefense = DB.getValue(nodeTarget, "defenses."..defenseVS..".value", 0);
      local hitOrMiss = "missed.";
      rMessage.icon = "poll_negative";
      if nTotal >= targetDefense then
        hitOrMiss = "hits.";
      rMessage.icon = "iconSword";
      end
      rMessage.text = "Attacking "..rTarget.sName.." with a "..defenseVS.." spell. The spell "..hitOrMiss;
      Comm.deliverChatMessage(rMessage);
    end
  end
end

function resolveEffectRoll(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local sVS = rRoll.vs;
  local versusLower = string.lower(sVS);
  local vsArmor, sRemain;
  vsArmor, sRemain = StringManager.extractPattern(versusLower, "phys");
  if vsArmor and vsArmor == "phys" then
    resolveDamage(rSource, rTarget, rRoll);
    vsArmor = nil;
  end
  vsArmor, sRemain = StringManager.extractPattern(versusLower, "myst");
  if vsArmor and vsArmor == "myst" then
    resolveMysticDamage(rSource, rTarget, rRoll);
    vsArmor = nil;
  end
end

function resolveDamage(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.value", 0);
  local targetArmor = DB.getValue(nodeTarget, "armor.physical.value", 0);
  local newTotal = nTotal - targetArmor;
  if newTotal < 1 then
    newTotal = 0;
  end
  local newDamage = targetDamage + newTotal;
  DB.setValue(nodeTarget, "health.damage.value", "number", newDamage);
  rMessage.text = "Damaging "..rTarget.sName.." for "..newTotal.." Lethal Damage.";
  if newTotal < nTotal then
    if newTotal == 0 then
      rMessage.text = rMessage.text.." (fully absorbed) ";
    else
      rMessage.text = rMessage.text.." (partially absorbed) ";
    end
  end
  rMessage.icon = "iconDamage";
	Comm.deliverChatMessage(rMessage);  
end

function resolveMysticDamage(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.value", 0);
  local targetArmor = DB.getValue(nodeTarget, "armor.mystic.value", 0);
  local newTotal = nTotal - targetArmor;
  if newTotal < 1 then
    newTotal = 0;
  end
  local newDamage = targetDamage + newTotal;
  DB.setValue(nodeTarget, "health.damage.value", "number", newDamage);
  rMessage.icon = "iconDamage";
  rMessage.text = "Damaging "..rTarget.sName.." for "..newTotal.." Mystic Damage.";
  if newTotal < nTotal then
    if newTotal == 0 then
      rMessage.text = rMessage.text.." (fully absorbed) ";
      rMessage.icon = "poll_negative";
    else
      rMessage.text = rMessage.text.." (partially absorbed) ";
    end
  end
	Comm.deliverChatMessage(rMessage);  
end

function resolveStunDamage(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.stun", 0);
  local targetArmor = DB.getValue(nodeTarget, "armor.physical.value", 0);
  local newTotal = nTotal - targetArmor;
  if newTotal < 1 then
    newTotal = 0;
  end
  local newDamage = targetDamage + newTotal;
  DB.setValue(nodeTarget, "health.damage.stun", "number", newDamage);
  rMessage.icon = "iconDamage";
  rMessage.text = "Damaging "..rTarget.sName.." for "..newTotal.." Stun Damage.";
  if newTotal < nTotal then
    if newTotal == 0 then
      rMessage.text = rMessage.text.." (fully absorbed) ";
      rMessage.icon = "poll_negative";
    else
      rMessage.text = rMessage.text.." (partially absorbed) ";
    end
  end
	Comm.deliverChatMessage(rMessage);
end

function resolveHeal(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.value", 0);
  local targetStun = DB.getValue(nodeTarget, "health.damage.stun", 0);
  local newDamage = targetDamage - nTotal;
  local newStun = targetStun - nTotal;
  if newDamage < 0 then
    newDamage = 0;
  end
  if newStun < 0 then
    newStun = 0;
  end
  DB.setValue(nodeTarget, "health.damage.value", "number", newDamage);
  DB.setValue(nodeTarget, "health.damage.stun", "number", newStun);
  rMessage.text = "Healing "..rTarget.sName.." for "..nTotal;
  rMessage.icon = "iconHeal";
	Comm.deliverChatMessage(rMessage);
end

function notifyApplyInit(rSource, nTotal)
	if not rSource then
		return;
	end
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYINIT;
	
	msgOOB.nTotal = nTotal;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyInit(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local nTotal = tonumber(msgOOB.nTotal) or 0;

	DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
end

function decodeDiceResults(rRoll)
  --Copied from 5e. Need to update with Earthdawn rules for exploding dice (nDieSides == Max then "green") and Rule of One (v.result == 1 then "Red")
  for i,v in ipairs(rRoll.aDice) do
    if v.result then      
      --Check for explosions.
      local vResult = tonumber(v.result);
      local nDieSides = tonumber(v.type:match("[dgpr](%d+)")) or 0;
      if vResult >= nDieSides then
        -- Found Explosion! We need to color Green!
				rRoll.aDice[i].type = "g" .. string.sub(rRoll.aDice[i].type, 2);
      end
      --Check for result of 1.
      if vResult == 1 then       
        -- Found Rule of One! We need to color Red! 
				rRoll.aDice[i].type = "r" .. string.sub(rRoll.aDice[i].type, 2);
      end
    end
  end
end


--[[ PROBABLY DEPRECATED ]]--
--[[

--Copied from 5e.
function onTargeting(rSource, aTargeting, rRolls)
  --This doesn't seem to get called?
	local bRemoveOnMiss = false;
	local sOptRMMT = OptionsManager.getOption("RMMT");
	if sOptRMMT == "on" then
		bRemoveOnMiss = true;
	elseif sOptRMMT == "multi" then
		bRemoveOnMiss = (#aTargeting > 1);
	end
	
	if bRemoveOnMiss then
		for _,vRoll in ipairs(rRolls) do
			vRoll.bRemoveOnMiss = "true";
		end
	end

	return aTargeting;
end


--Old explosion function (mine)

function explodeDie(nDieSides)
  -- This works, don't break it. Needed to explode dice.
  newResult = genRandNum(nDieSides);
  newResult = genRandNum(nDieSides);
  if newResult == nDieSides then
    -- This means we exploded again, keep rolling.
    newResult = explodeDie(nDieSides)
  end
  newResult = newResult + nDieSides;
  return newResult;
end

function genRandNum(nDieSides)
  -- This works, don't change it. Needed for explodeDie(nDieSides);
  local r = 0;
  r=math.random(nDieSides);
  return r;  
end
 ]]--
 
 
