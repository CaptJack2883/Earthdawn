-- Separated sets of 10 steps into separate functions to improve performance. (i.e. getStepNumTens, getStepNumTwentys, etc.)

function getStep(attribute)
  local step = math.ceil(attribute/3)+1;
  if (step >= 1) then
    return step;
  else
    return 1;
  end
end

function getStepFromString(sInput)
  --This function will attempt to find a step number from a string of type "step #'
  --Returns the step number and the dice string for that step.
  sInput = string.lower(sInput);
  local nStart, nEnd, sNumber = string.find(sInput, "%d+", 0, false);
  if nStart then
    local rStep = tonumber(sNumber);
    local sDice = getStepDice(rStep);
    return rStep, sDice;
  else
    return false;
  end
end

function getStepDice(stepNum)
  local nMod = 0;
	stepNum = stepNum + ModifierStack.getSum();
  ModifierStack.reset();
  local stepDice = "";
	if stepNum < 1 then
		stepNum = 1
	end
	if stepNum > 100 then
		stepNum = 100;
    stepDice = getStepsHundreds(stepNum);
  return stepDice, nMod, stepNum;
	end
  if stepNum <=9 then
  --Step is Less than or equal to 9.
    stepDice, nMod = getStepsSingles(stepNum);
  elseif stepNum <=19 then
  --Step is Less than or equal to 19.
    stepDice = getStepsTens(stepNum);
  elseif stepNum <=29 then
  --Step is Less than or equal to 29.
    stepDice = getStepsTwenties(stepNum);
  elseif stepNum <=39 then
  --Step is Less than or equal to 39.
    stepDice = getStepsThirties(stepNum);
  elseif stepNum <=49 then
  --Step is Less than or equal to 49.
    stepDice = getStepsForties(stepNum);
  elseif stepNum <=59 then
  --Step is Less than or equal to 59.
    stepDice = getStepsFifties(stepNum);
  elseif stepNum <=69 then
  --Step is Less than or equal to 69.
    stepDice = getStepsSixties(stepNum);
  elseif stepNum <=79 then
  --Step is Less than or equal to 79.
    stepDice = getStepsSeventies(stepNum);
  elseif stepNum <=89 then
  --Step is Less than or equal to 89.
    stepDice = getStepsEighties(stepNum);
  elseif stepNum <=99 then
  --Step is Less than or equal to 99.
    stepDice = getStepsNineties(stepNum);
  end
  return stepDice, nMod, stepNum;
end

function getStepsSingles(stepNum)
	if stepNum <= 1 then
		return {"d4"}, -2;
	elseif stepNum == 2 then
		return {"d4"}, -1;
	elseif stepNum == 3 then
		return {"d4"}, 0;
	elseif stepNum == 4 then
		return {"d6"}, 0;
	elseif stepNum == 5 then
		return {"d8"}, 0;
	elseif stepNum == 6 then
		return {"d10"}, 0;
	elseif stepNum == 7 then 
		return {"d12"}, 0;
	elseif stepNum == 8 then 
		return {"d6","d6"}, 0;
	elseif stepNum == 9 then 
		return {"d8","d6"}, 0;
  end
end

function getStepsTens(stepNum)
  if stepNum == 10 then 
		return {"d8","d8"}, 0;
	elseif stepNum == 11 then 
		return {"d10","d8"}, 0;
	elseif stepNum == 12 then 
		return {"d10","d10"}, 0;
	elseif stepNum == 13 then 
		return {"d12","d10"}, 0;
	elseif stepNum == 14 then 
		return {"d12","d12"}, 0;
	elseif stepNum == 15 then 
		return {"d12","d6","d6"}, 0;
	elseif stepNum == 16 then 
		return {"d12","d8","d6"}, 0;
	elseif stepNum == 17 then 
		return {"d12","d8","d8"}, 0;
	elseif stepNum == 18 then 
		return {"d12","d10","d8"}, 0;
	elseif stepNum == 19 then 
		return {"d20","d6","d6"}, 0;
  end
end


function getStepsTwenties(stepNum)
  if stepNum == 20 then 
		return {"d20","d8","d6"}, 0;
	elseif stepNum == 21 then 
		return {"d20","d8","d8"}, 0;
	elseif stepNum == 22 then 
		return {"d20","d10","d8"}, 0;
	elseif stepNum == 23 then 
		return {"d20","d10","d10"}, 0;
	elseif stepNum == 24 then 
		return {"d20","d12","d10"}, 0;
	elseif stepNum == 25 then 
		return {"d20","d12","d12"}, 0;
	elseif stepNum == 26 then 
		return {"d20","d12","d6","d6"}, 0;
	elseif stepNum == 27 then 
		return {"d20","d12","d8","d6"}, 0;
	elseif stepNum == 28 then 
		return {"d20","d12","d8","d8"}, 0;
	elseif stepNum == 29 then 
		return {"d20","d12","d10","d8"}, 0;
  end
end
  
function getStepsThirties(stepNum)
  if stepNum == 30 then 
		return {"d20","d20","d6","d6"}, 0;
	elseif stepNum == 31 then 
		return {"d20","d20","d8","d6"}, 0;
	elseif stepNum == 32 then 
		return {"d20","d20","d8","d8"}, 0;
	elseif stepNum == 33 then 
		return {"d20","d20","d10","d8"}, 0;
	elseif stepNum == 34 then 
		return {"d20","d20","d10","d10"}, 0;
	elseif stepNum == 35 then 
		return {"d20","d20","d12","d10"}, 0;
	elseif stepNum == 36 then 
		return {"d20","d20","d12","d12"}, 0;
	elseif stepNum == 37 then 
		return {"d20","d20","d12","d6","d6"}, 0;
	elseif stepNum == 38 then 
		return {"d20","d20","d12","d8","d6"}, 0;
	elseif stepNum == 39 then 
		return {"d20","d20","d12","d8","d8"}, 0;
  end
end
  
function getStepsForties(stepNum)
  if stepNum == 40 then 
		return {"d20","d20","d12","d10","d8"}, 0;
	elseif stepNum == 41 then 
		return {"d20","d20","d10","d8","d6","d6"}, 0;
	elseif stepNum == 42 then 
		return {"d20","d20","d10","d8","d8","d6"}, 0;
	elseif stepNum == 43 then 
		return {"d20","d20","d10","d10","d8","d6"}, 0;
	elseif stepNum == 44 then 
		return {"d20","d20","d10","d10","d8","d8"}, 0;
	elseif stepNum == 45 then 
		return {"d20","d20","d10","d10","d10","d8"}, 0;
	elseif stepNum == 46 then 
		return {"d20","d20","d12","d10","d10","d8"}, 0;
	elseif stepNum == 47 then 
		return {"d20","d20","d10","d10","d8","d8","d4"}, 0;
	elseif stepNum == 48 then 
		return {"d20","d20","d10","d10","d8","d8","d6"}, 0;
	elseif stepNum == 49 then 
		return {"d20","d20","d10","d10","d8","d8","d8"}, 0;
  end
end
  
function getStepsFifties(stepNum)
  if stepNum == 50 then 
		return {"d20","d20","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 51 then 
		return {"d20","d20","d12","d10","d10","d8","d8"}, 0;
	elseif stepNum == 52 then 
		return {"d20","d20","d10","d10","d8","d8","d6","d6"}, 0;
	elseif stepNum == 53 then 
		return {"d20","d20","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 54 then 
		return {"d20","d20","d10","d10","d10","d8","d8","d6"}, 0;
	elseif stepNum == 55 then 
		return {"d20","d20","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 56 then 
		return {"d20","d20","d10","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 57 then 
		return {"d20","d20","d12","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 58 then 
		return {"d20","d20","d20","d10","d10","d8","d8","d4"}, 0;
	elseif stepNum == 59 then 
		return {"d20","d20","d20","d10","d10","d8","d8","d6"}, 0;
  end
end
  
function getStepsSixties(stepNum)
  if stepNum == 60 then 
		return {"d20","d20","d20","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 61 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 62 then 
		return {"d20","d20","d20","d12","d10","d10","d8","d8"}, 0;
	elseif stepNum == 63 then 
		return {"d20","d20","d20","d10","d10","d8","d8","d6","d6"}, 0;
	elseif stepNum == 64 then 
		return {"d20","d20","d20","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 65 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d6"}, 0;
	elseif stepNum == 66 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 67 then 
		return {"d20","d20","d20","d10","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 68 then 
		return {"d20","d20","d20","d12","d10","d10","d10","d8","d8"}, 0;
	elseif stepNum == 69 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8","d4"}, 0;
  end
end
  
function getStepsSeventies(stepNum)
  if stepNum == 70 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 71 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 72 then 
		return {"d20","d20","d20","d10","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 73 then 
		return {"d20","d20","d20","d12","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 74 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8","d6","d6"}, 0;
	elseif stepNum == 75 then 
		return {"d20","d20","d20","d10","d10","d10","d8","d8","d8","d8","d6"}, 0;
	elseif stepNum == 76 then 
		return {"d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 77 then 
		return {"d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 78 then 
		return {"d20","d20","d20","d10","d10","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 79 then 
		return {"d20","d20","d20","d12","d10","d10","d10","d10","d8","d8","d8"}, 0;
  end
end
  
function getStepsEighties(stepNum)
  if stepNum == 80 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d8","d8","d8","d4"}, 0;
	elseif stepNum == 81 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 82 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 83 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 84 then 
		return {"d20","d20","d20","d20","d12","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 85 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d8","d8","d8","d6","d6"}, 0;
	elseif stepNum == 86 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d8","d8","d8","d8","d6"}, 0;
	elseif stepNum == 87 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d6"}, 0;
	elseif stepNum == 88 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 89 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d10","d8","d8","d8"}, 0;
  end
end
  
function getStepsNineties(stepNum)
  if stepNum == 90 then 
		return {"d20","d20","d20","d20","d12","d10","d10","d10","d10","d8","d8","d8"}, 0;
	elseif stepNum == 91 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8","d4"}, 0;
	elseif stepNum == 92 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8","d6"}, 0;
	elseif stepNum == 93 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8","d8"}, 0;
	elseif stepNum == 94 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 95 then 
		return {"d20","d20","d20","d20","d12","d10","d10","d10","d10","d8","d8","d8","d8"}, 0;
	elseif stepNum == 96 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8","d6","d6"}, 0;
	elseif stepNum == 97 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d8","d8","d8","d8","d8","d6"}, 0;
	elseif stepNum == 98 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d10","d8","d8","d8","d8","d6"}, 0;
	elseif stepNum == 99 then 
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d10","d8","d8","d8","d8","d8"}, 0;
  end
end

function getStepsHundreds(stepNum)
  if stepNum == 100 then
    Debug.console("Step is equal to 100.");
		return {"d20","d20","d20","d20","d10","d10","d10","d10","d10","d10","d8","d8","d8","d8"}, 0;
  end
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