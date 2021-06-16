-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bParsed = false;
local aComponents = {};

local bClicked = false;
local bDragging = false;
local nDragIndex = nil;

function parseComponents()
	aComponents = {};
	
	-- Get the comma-separated strings
	local aClauses, aClauseStats = StringManager.split(getValue(), ",;\r", true);
	
	-- Check each comma-separated string for a potential skill roll or auto-complete opportunity.
	for i = 1, #aClauses do
    --Look for Step # first.
		local nStarts, nEnds, sMod = string.find(aClauses[i], "Step %d+");
    --Looking for Step # in NPC skills.
    local sStep, sDesc = StringManager.extractPattern(aClauses[i], "Step %d+");
		if sStep then
      local stepNum, sVerify = StringManager.extractPattern(sStep, "%d+");
      if sVerify == "Step " then
        stepNum = tonumber(stepNum);
        local rRoll = StepLookup.getRoll(stepNum);
        --local stepDice, nMod, stepNum = StepLookup.getStepDice(stepNum);
        --local stepDice = rRoll.aDice;
        --local nMod = rRoll.nMod;
        rRoll.sDesc = sDesc .. rRoll.sDesc;
        -- Insert the possible skill into the skill list
        --table.insert(aComponents, {nStart = aClauseStats[i].startpos, nLabelEnd = aClauseStats[i].startpos + nEnds, nEnd = aClauseStats[i].endpos, sLabel = sLabel, aDice = stepDice, nMod = nMod, rStep = stepNum });
        table.insert(aComponents, {nStart = aClauseStats[i].startpos, nLabelEnd = aClauseStats[i].startpos + nEnds, nEnd = aClauseStats[i].endpos, rRoll = rRoll });
      else --look for "2d6+5" type dice.
        local nStarts, nEnds, sMod = string.find(aClauses[i], "([d%dF%+%-]+)%s*$");
        if nStarts then
          local sLabel = "";
          if nStarts > 1 then
            sLabel = StringManager.trim(aClauses[i]:sub(1, nStarts - 1));
          end
          local aDice, nMod = StringManager.convertStringToDice(sMod);
          -- Insert the possible skill into the skill list
          table.insert(aComponents, {nStart = aClauseStats[i].startpos, nLabelEnd = aClauseStats[i].startpos + nEnds, nEnd = aClauseStats[i].endpos, sLabel = sLabel, aDice = aDice, nMod = nMod });
        end
      end
    end
    
  end
	
	bParsed = true;
end

function onValueChanged()
	bParsed = false;
end

-- Reset selection when the cursor leaves the control
function onHover(bOnControl)
	if bOnControl then
		return;
	end

	if not bDragging then
		onDragEnd();
	end
end

-- Hilight skill hovered on
function onHoverUpdate(x, y)
	if bDragging or bClicked then
		return;
	end

	if not bParsed then
		parseComponents();
	end
	local nMouseIndex = getIndexAt(x, y);

	for i = 1, #aComponents, 1 do
		if aComponents[i].nStart <= nMouseIndex and aComponents[i].nEnd > nMouseIndex then
			setCursorPosition(aComponents[i].nStart);
			setSelectionPosition(aComponents[i].nEnd);

			nDragIndex = i;
			setHoverCursor("hand");
			return;
		end
	end
	
	nDragIndex = nil;
	setHoverCursor("arrow");
end

function action(draginfo)
	if nDragIndex then
		if draginfo then
      --This is for drag rolls.
			if aComponents[nDragIndex].rRoll then
        --We found a complete roll, so this is a Step Roll.
				--local rRoll = { sType = "dice", sDesc = aComponents[nDragIndex].sLabel, aDice = aComponents[nDragIndex].aDice, nMod = aComponents[nDragIndex].nMod, rStep = aComponents[nDragIndex].rStep };
        local rRoll = aComponents[nDragIndex].rRoll;
        local rStep = rRoll.rStep;
        local bSecretRoll = true;
        --need to make sure rActor has the NPC actor node.
        local nodeChar = window.getDatabaseNode();
        local rActor = ActorManager.resolveActor(nodeChar);
        ActionManagerED4.dragRoll(draginfo, rRoll.sType, rStep, rActor, bSecretRoll, rRoll);
				--ActionsManager.performAction(draginfo, rActor, rRoll);
			elseif #(aComponents[nDragIndex].aDice) > 0 then
        --We found non-step roll.
				local rRoll = { sType = "dice", sDesc = aComponents[nDragIndex].sLabel, aDice = aComponents[nDragIndex].aDice, nMod = aComponents[nDragIndex].nMod, rStep = aComponents[nDragIndex].rStep };
        local rStep = rRoll.rStep;
        local bSecretRoll = true;
        --need to make sure rActor has the NPC actor node.
        local nodeChar = window.getDatabaseNode();
        local rActor = ActorManager.resolveActor(nodeChar);
        ActionManagerED4.dragRoll(draginfo, rRoll.sType, rStep, rActor, bSecretRoll, rRoll);
				--ActionsManager.performAction(draginfo, rActor, rRoll);        
      else
				draginfo.setType("number");
				draginfo.setDescription(aComponents[nDragIndex].sLabel);
				draginfo.setStringData(aComponents[nDragIndex].sLabel);
				draginfo.setNumberData(aComponents[nDragIndex].nMod);
			end
		else
      --This is for doubleclick rolls.
			if aComponents[nDragIndex].rRoll then
        --We found a complete roll, so this is a Step Roll.
        local rRoll = aComponents[nDragIndex].rRoll;
        local rStep = rRoll.rStep;
        local bSecretRoll = true;
        --need to make sure nodeChar has the NPC actor node.
        local nodeChar = window.getDatabaseNode();
        local rActor = ActorManager.resolveActor(nodeChar);
        ActionManagerED4.pushRoll(rRoll.sType, rRoll.rStep, nodeChar, bSecretRoll, rRoll);
				--ActionsManager.performAction(draginfo, rActor, rRoll);
			elseif #(aComponents[nDragIndex].aDice) > 0 then
        --We found non-step roll.
				local rRoll = { sType = "dice", sDesc = aComponents[nDragIndex].sLabel, aDice = aComponents[nDragIndex].aDice, nMod = aComponents[nDragIndex].nMod, rStep = aComponents[nDragIndex].rStep };
        local bSecretRoll = true;
        --need to make sure nodeChar has the NPC actor node.
        local nodeChar = window.getDatabaseNode();
        local rActor = ActorManager.resolveActor(nodeChar);
        ActionManagerED4.pushRoll(rRoll.sType, rRoll.rStep, nodeChar, bSecretRoll, rRoll);
				--ActionsManager.performAction(draginfo, rActor, rRoll);
			else
				ModifierStack.addSlot(aComponents[nDragIndex].sLabel, aComponents[nDragIndex].nMod);
			end
		end
	end
end

function onDoubleClick(x, y)
	action();
	return true;
end

function onDragStart(button, x, y, draginfo)
	action(draginfo);

	bClicked = false;
	bDragging = true;
	
	return true;
end

function onDragEnd(draginfo)
	bClicked = false;
	bDragging = false;
	nDragIndex = nil;
	setHoverCursor("arrow");
	setCursorPosition(0);
	setSelectionPosition(0);
end

-- Suppress default processing to support dragging
function onClickDown(button, x, y)
	bClicked = true;
	return true;
end

-- On mouse click, set focus, set cursor position and clear selection
function onClickRelease(button, x, y)
	bClicked = false;
	setFocus();
	
	local n = getIndexAt(x, y);
	setSelectionPosition(n);
	setCursorPosition(n);
	
	return true;
end
