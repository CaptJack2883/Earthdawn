-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onUpdate();
	updateIDState();
end

function onUpdate()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	name.setReadOnly(bReadOnly);
  --print("Skills Header OnUpdate");
end

function updateIDState()
	if User.isHost() then return; end
	local bID = LibraryData.getIDState("npc", getDatabaseNode());
	name.setVisible(bID);
end

function notify()
	if window.parentcontrol and window.parentcontrol.window.onLockChanged then
		window.parentcontrol.window.onLockChanged();
	elseif window.onLockChanged then
		window.onLockChanged();
	end
end