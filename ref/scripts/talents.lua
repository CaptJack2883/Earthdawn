-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onUpdate();
end

function onUpdate()
  if getDatabaseNode then
    local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
    text.setReadOnly(bReadOnly);
    --print("Talents OnUpdate");
  end
end

function notify()
	if window.parentcontrol and window.parentcontrol.window.onLockChanged then
		window.parentcontrol.window.onLockChanged();
	elseif window.onLockChanged then
		window.onLockChanged();
	end
end