-- Updated to use formulaic step calculations to improve performance.

function getStep(attribute)
  local step = math.ceil(attribute/3)+1;
  if (step >= 1) then
    return step;
  else
    return 1;
  end
end

function getRoll(stepNum, sType)
  local stepDice, nMod, newStep, stepMod = getStepDice(stepNum, sType)
  --local stepDice = "d8e+d6e";
  --local nMod = 0;
  local stepExpr = { expr = stepDice };
  local rRoll = { sType = "dice", sDesc = " (Step "..newStep..") ", aDice = stepExpr, nMod = nMod, stepMod = stepMod };
  if rRoll.stepMod > 0 then
    rRoll.sDesc = rRoll.sDesc.."("..stepNum.."+"..stepMod..") ";
  end
  if rRoll.stepMod < 0 then
    rRoll.sDesc = rRoll.sDesc.."("..stepNum.."-"..stepMod..") ";
  end
  return rRoll;
end

function getStepFromString(sInput)
  --This function will attempt to find a step number from a string of type "step #'
  --Returns the step number and the dice string for that step.
  sInput = string.lower(sInput);
  local nStart, nEnd, sNumber = string.find(sInput, "%d+", 0, false);
  if nStart then
    local rStep = tonumber(sNumber);
    local sDice, nMod = getStepDice(rStep);
    return sDice, nMod, rStep;
  else
    return false;
  end
end

function getStepDice(stepNum, sType)
  local stepDice = "";
  local nMod = 0;
  local stepMod = 0;
  -- Check modifierstack to see if we need to modify the step number before rolling.
  -- Don't add to karma rolls
  if sType == "karma" then
    stepMod = 0;
  else
    stepMod = ModifierStack.getSum();
  end
  stepNum = stepNum + stepMod;
  -- Make sure we're only retrieving positive integers. (stepNum can't be 0 or negative)
	if stepNum < 1 then
		stepNum = 1
	end
  
  -- Get dice based on new formulaic step lookup.
  stepDice = getFormulaicStep(stepNum);
  
  -- set modifiers for steps 1 and 2.
  if stepNum == 1 then
    nMod = -2;
  end
  if stepNum == 2 then
    nMod = -1;
  end
  
  return stepDice, nMod, stepNum, stepMod;
end

function getStepsSingles(stepNum)
	if stepNum <= 1 then
		return "d4e", -2;
	elseif stepNum == 2 then
		return "d4e", -1;
	elseif stepNum == 3 then
		return "d4e", 0;
	elseif stepNum == 4 then
		return "d6e", 0;
	elseif stepNum == 5 then
		return "d8e", 0;
	elseif stepNum == 6 then
		return "d10e", 0;
	elseif stepNum == 7 then 
		return "d12e", 0;
	elseif stepNum == 8 then 
		return "2d6e", 0;
	elseif stepNum == 9 then 
		return "d8e+d6e", 0;
  end
end

function getFormulaicStep(stepNum)
  local stepDice = "";
  local d20Dice = "";
  if stepNum < 8 then
    stepDice = getStepsSingles(stepNum)
  else
    -- (Subtract 7, mod 11, plus Floor(d20/11, -1)
    -- First check for the number of d20's
    local numD20s = math.floor((stepNum-8)/11);
    if numD20s > 0 then
      d20Dice = numD20s.."d20e+";
    end
    --Now check for remaining pattern of dice.
    local patternDice = getPatternDice(stepNum);
    stepDice = d20Dice..patternDice
  end
  return stepDice;
end

function getPatternDice(stepNum)
  local patternDice = "";
  local pStep = (stepNum-7)%11;
  
	if pStep == 1 then
		patternDice = "2d6e", 0;
	elseif pStep == 2 then
		patternDice = "d8e+d6e", 0;
	elseif pStep == 3 then
		patternDice = "2d8e", 0;
	elseif pStep == 4 then
		patternDice = "d10e+d8e", 0;
	elseif pStep == 5 then
		patternDice = "2d10e", 0;
	elseif pStep == 6 then
		patternDice = "d12e+d10e", 0;
	elseif pStep == 7 then
		patternDice = "2d12e", 0;
	elseif pStep == 8 then
		patternDice = "d12e+2d6e", 0;
	elseif pStep == 9 then
		patternDice = "d12e+d8e+d6e", 0;
	elseif pStep == 10 then
		patternDice = "d12e+2d8e", 0;
	elseif pStep == 0 then
		patternDice = "d12e+d10e+d8e", 0;
  end
  return patternDice
end

function getMaxCarry(nStrength)
  if not nStrength then
    return 0;
  end
  if nStrength < 1 then
    return 0;
  elseif nStrength == 1 then
    return 10;
  elseif nStrength == 2 then
    return 15;
  elseif nStrength == 3 then
    return 20;
  elseif nStrength == 4 then
    return 25;
  elseif nStrength == 5 then
    return 30;
  elseif nStrength == 6 then
    return 40;
  elseif nStrength == 7 then
    return 50;
  elseif nStrength == 8 then
    return 60;
  elseif nStrength == 9 then
    return 70;
  elseif nStrength == 10 then
    return 80;
  elseif nStrength == 11 then
    return 95;
  elseif nStrength == 12 then
    return 110;
  elseif nStrength == 13 then
    return 125;
  elseif nStrength == 14 then
    return 140;
  elseif nStrength == 15 then
    return 155;
  elseif nStrength == 16 then
    return 175;
  elseif nStrength == 17 then
    return 195;
  elseif nStrength == 18 then
    return 215;
  elseif nStrength == 19 then
    return 235;
  elseif nStrength == 20 then
    return 255;
  elseif nStrength == 21 then
    return 280;
  elseif nStrength == 22 then
    return 305;
  elseif nStrength == 23 then
    return 330;
  elseif nStrength == 24 then
    return 355;
  elseif nStrength == 25 then
    return 380;
  elseif nStrength == 26 then
    return 410;
  elseif nStrength == 27 then
    return 440;
  elseif nStrength == 28 then
    return 470;
  elseif nStrength == 29 then
    return 500;
  elseif nStrength == 30 then
    return 530;
  end
end