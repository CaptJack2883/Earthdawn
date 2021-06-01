
function onInit()  
  Global.cmUpdating = false;
  onUpdate();    
end

function onUpdate()
  --We are checking the correct value for "encumbrance.max" and inputting it.
  nodeChar = getDatabaseNode();
  CharacterManager.updateMaxCarry(nodeChar);
end



















