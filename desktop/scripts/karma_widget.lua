
function onInit()
  --Debug.chat("Karma widget is initialized.");
  WidgetManager.registerControl(self);
end

function onClose()
  WidgetManager.registerControl(nil);
end

function onUpdate()
  WidgetManager.onUpdate();
end

function reset()
  WidgetManager.reset();
end

function getValue()
  return karmaCheckbox.getValue();
end

function setValue(num)
  karmaCheckbox.setValue(num);
end