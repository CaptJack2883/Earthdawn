local karmaControl = nil;
local isKarmaRoll = false;

function onInit()
  --Debug.chat("Karma widget is initialized.");
end

function onUpdate()
  --Debug.chat(karmaControl.getValue());
  isChecked = karmaControl.getValue();
  if isChecked == 1 then
    Global.KarmaWidgetValue = true;
  else
    Global.KarmaWidgetValue = false;
  end
  --Debug.chat(Global.KarmaWidgetValue);
end

function reset()
  --Debug.chat("Resetting Karma Widget...");
  karmaControl.setValue(0);
  Global.KarmaWidgetValue = false;
end


function registerControl(ctrl)
	karmaControl = ctrl;
end
