
function onInit()
	ActionsManager.registerResultHandler("step", onResult);
	ActionsManager.registerResultHandler("dice", onResult);
	ActionsManager.registerModHandler("step", modRoll);
end

function performSRoll(draginfo, rActor, nodeWin, skillType)
	local sSkillName = DB.getValue(nodeWin, "name", "");
    local nSkillMod = 0;
    local npcSkillTemp = nil;
	
--	print("Path before If = " .. nodeWin.getPath("..."));
	if string.find(nodeWin.getPath("..."), "npc") or string.find(nodeWin.getPath("..."), "combattracker") then	
		npcSkillTemp = npcSkillType(nodeWin); -- if it is an npc then get the skill that is rolled
	end
	
	local nSkillTemp = nil;
	local talentNodeTemp = nil; -- Used to get talent or skill node

	
	nSkillTemp = nodeWin.getValue(0);
	local nodeWinTemp = nodeWin.getParent().getParent(); -- Move up 2 levels to get Strain amount from Talent
	
	if nodeWinTemp.getName("...") == "step" then -- if you are not high enough in the nodes, go one more.
		nodeWinTemp = nodeWinTemp.getParent();
	end
	
    local nStrain = DB.getValue(nodeWinTemp, "strain", 0); -- Now that we are at the right level, go get the Strain number from the Talent

	if string.find(nodeWinTemp.getPath("..."), "talents") or string.find(nodeWinTemp.getPath("..."), "skills") or string.find(nodeWinTemp.getPath("..."), "spells") then
		talentNodeTemp = true;

	end
	
	if skillType == nil and talentNodeTemp == nil then	

		skillType = nodeWin.getParent().getName(); -- Get name of field calling for a die roll

		if skillType == "step" then					-- If the name of the field is 2 nodes deep, get the parent of the parent node (2 up)	
			skillType = nodeWin.getParent().getParent().getName();
		end
	
		if skillType == "init" then     			-- Node is abbreviated so we expand the name for clarity in the Chat box
			skillType = "initiative";
		end
	else
		skillType = nodeWin.getParent().getName();
	end
	
	if npcSkillTemp then  -- if an npc skill was found then make skillType = to that skill
		skillType = npcSkillTemp;
	end
	
--	print("skillType before performRoll = " .. skillType);
	
	performRoll(draginfo, skillType, rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll, nStrain);
end

function performRoll(draginfo, skillType, rActor, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll, nStrain)
	local rRoll = getRoll(rActor, skillType, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll, nStrain);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, skillType, sSkillName, nSkillMod, sSkillStat, nSkillTemp, nSkillTarget, bSecretRoll, nStrain)
	local rRoll = {};
	rRoll.sType = "step";
	local sStackDesc, nStackMod = ModifierStack.getStack(true);
	ModifierStack.reset();
	rRoll.aDice, rRoll.nMod = StepLookup.getStepDice(nSkillTemp + nStackMod);	
--    rRoll.sDesc = "[" .. StringManager.capitalize(skillType); -- Original statement (needed a little more precision in the message sent to the chat)
	rRoll.sDesc = "["; -- Open the bracket for the message to chat
	if skillType == "step" then
		rRoll.sDesc = rRoll.sDesc .. StringManager.capitalize(skillType) .. ": " .. (nSkillTemp + nStackMod) .. " ]"; -- If the skillType is step, we don't need the "step" label (talents, skills or combat)
	else
		rRoll.sDesc = rRoll.sDesc .. StringManager.capitalize(skillType) .. ": (Step: " .. (nSkillTemp + nStackMod) .. ") ]";	-- if it is not step then add the "step" label (attributes, knockdown or initiative 
	end
    if nStrain > 0 then
            rRoll.sDesc = rRoll.sDesc .. " [Strain Damage: " .. nStrain .. "]"; -- if there is strain, then add the "strain" label to the message in chat
    end
	rRoll.bSecret = bSecretRoll;
    rRoll.nStrain = nStrain;
	
	return rRoll;
end


function serializeTable(val)
  local tmp = ""

-- Used ipairs instead of pairs to avoid issues with non numeric keys
-- which cause v.result and v.type to be set to nil

  for k, v in ipairs(val) do
    tmp =  tmp .. v.result .. "," .. v.type .. ";"
  end
  
  return tmp
end


function deserializeTable(val)
  local result = {}
  for k,i in string.gmatch(val, "(%w+),(%w+)") do
    local vvv = {}
    vvv.result = k
    vvv.type = i
    table.insert(result, vvv)
  end
  return result
end

function getReRoll(aDice, iRoll)
	local rRoll = {}
  rRoll.aDice = aDice
  rRoll.nMod = iRoll.nMod 
  rRoll.sType = iRoll.sType
  rRoll.bSecret = iRoll.bSecret 
  rRoll.nStrain = iRoll.nStrain
  rRoll.sDesc = iRoll.sDesc
  
  rRoll.rPreviousResult = serializeTable(iRoll.aDice)
  return rRoll
end

function onResult(rSource, rTarget, rRoll)
  local nodeChar = ActorManager.getCreatureNode(rSource);
	local isMaxResult = function(rDie)
		if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
			return rDie.result
		else
			return 0
		end
	end
	
--	rSource gets erased during an explode/reroll so this is to assign hdtemp as a precaution
	if rSource then
		hdtemp = DB.getParent(DB.getParent(rSource.sCreatureNode));
    charCTNode = ActorManager.resolveActor(DB.getParent(rSource.sCreatureNode));
	end
  
  explode = {}
	for i,die in ipairs(rRoll.aDice) do
		local reroll = isMaxResult(die)
		if reroll>0 then
      table.insert(explode, die.type)
		end
	end
  if rRoll.rPreviousResult then
    prev = deserializeTable(rRoll.rPreviousResult)
    for i,roll in ipairs(prev) do
        table.insert(rRoll.aDice, 1, roll)
    end
  end
  if table.getn(explode) > 0 then
    if rSource then
      rMessageTemp = ActionsManager.createActionMessage(rSource, rRoll);
    end
      
    ActionsManager.performAction(draginfo, rActor, getReRoll(explode, rRoll)); 
      
    return false;
  end
	

--		This if statement is to change the current damage by the strain of the talent, skill or whatever has strain attached to it 
  if rRoll.nStrain then
    if tonumber(rRoll.nStrain) > 0 then
      local st = tonumber(rRoll.nStrain);
      --local hdtemp = DB.getParent(DB.getParent(rSource.sCreatureNode)); -- moves up 2 levels from rSource.sCreatureNode to get the Damage Taken field
      --local hd = DB.getChild(rSource.sCreatureNode, "health.damage.base"); -- Orginal statement.. It was 2 levels to low to get to health.damage.base (Damage Taken field)
      local hd = DB.getChild(hdtemp, ".health.damage.base");
      local newHealth = tonumber(hd.getValue() + st);
      hd.setValue(newHealth);
    end
  end
	
  --Color dice for 1's and Explosions.
	ActionManagerED4.decodeDiceResults(rRoll);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
  
  --We have our roll, and our total, after explosions. Now we can check for roll types to apply appropriate actions.
  
  local rollType, sRemainder = StringManager.extractPattern(rRoll.sDesc, "Initiative");
  if rollType == "Initiative" then
    --We found an init roll, we need to add to combat tracker.
    --local nodeName = charCTNode.sName;
    if charCTNode then
      ActionManagerED4.notifyApplyInit(charCTNode, nTotal);
    end
  end
	
	if not rSource then
    if rMessageTemp then
      rMessage.sender = rMessageTemp.sender;
    end
	end
	
	Comm.deliverChatMessage(rMessage); -- Send the message to the chat. (Description, step, strain, dice graphic and total roll)
end


function modRoll(rSource, rTarget, rRoll)	
end

function npcSkillType(nodeWin)
	
	local npcSkillTemp = nil; -- Used to get npc node
	
-- 		Checking to see what path was sent to the function
--		print("npcNodeTemp Path = " .. nodeWin.getPath("...")); 
		
--		Print statements sre for debugging 
		if string.find(nodeWin.getPath("..."), "attackstep1") or string.find(nodeWin.getPath("..."), "damagestep1") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".attack1");
			npcSkillTemp = skillTypeTemp.getText();
--			print("skillType 1 = " .. npcSkillTemp);
		elseif string.find(nodeWin.getPath("..."), "attackstep2") or string.find(nodeWin.getPath("..."), "damagestep2") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".attack2");
			npcSkillTemp = skillTypeTemp.getText();
--			print("skillType 2 = " .. npcSkillTemp);
		elseif string.find(nodeWin.getPath("..."), "attackstep3") or string.find(nodeWin.getPath("..."), "damagestep3") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".attack3");
			npcSkillTemp = skillTypeTemp.getText();
--			print("skillType 3 = " .. npcSkillTemp);
		elseif string.find(nodeWin.getPath("..."), "attackstep4") or string.find(nodeWin.getPath("..."), "damagestep4") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".attack4");
			npcSkillTemp = skillTypeTemp.getText();
--			print("skillType 3 = " .. npcSkillTemp);
		elseif string.find(nodeWin.getPath("..."), "attackstep5") or string.find(nodeWin.getPath("..."), "damagestep5") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".attack5");
			npcSkillTemp = skillTypeTemp.getText();
--			print("skillType 3 = " .. npcSkillTemp);
		elseif string.find(nodeWin.getPath("..."), "props") then
			local pathTemp = nodeWin.getParent();
			local skillTypeTemp = pathTemp.getChild(".property");
			npcSkillTemp = skillTypeTemp.getText();
--			print("Property in Other Tab = " .. npcSkillTemp);
		end
		
		if string.find(nodeWin.getPath("..."), "attackstep") then
			npcSkillTemp = npcSkillTemp .. " Attack";
		elseif string.find(nodeWin.getPath("..."), "damagestep") then
			npcSkillTemp = npcSkillTemp .. " Damage";
		end
		
		if string.find(nodeWin.getPath("..."), "dexstep") then
			npcSkillTemp = "Dexterity";
		elseif  string.find(nodeWin.getPath("..."), "strstep") then
			npcSkillTemp = "Strength";
		elseif  string.find(nodeWin.getPath("..."), "toustep") then
			npcSkillTemp = "Toughness";
		elseif  string.find(nodeWin.getPath("..."), "perstep") then
			npcSkillTemp = "Perception";
		elseif  string.find(nodeWin.getPath("..."), "wilstep") then
			npcSkillTemp = "Willpower";
		elseif  string.find(nodeWin.getPath("..."), "chastep") then
			npcSkillTemp = "Charisma";
		elseif  string.find(nodeWin.getPath("..."), "init") then
			npcSkillTemp = "Initiative";
		elseif  string.find(nodeWin.getPath("..."), "knockdown") then
			npcSkillTemp = "Knockdown";
		end
	
	return npcSkillTemp;
end
