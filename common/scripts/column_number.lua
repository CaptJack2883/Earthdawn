-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if super and super.onInit then
		super.onInit();
	end
	
	if isReadOnly() then
		self.update(true);
	else
		local node = getDatabaseNode();
		if not node or node.isReadOnly() then
			self.update(true);
		end
    DB.addHandler(DB.getPath(node, "name"), "onValueChanged", onValueChanged);
	end
end

function update(bReadOnly, bForceHide)
	local bLocalShow;
	if bForceHide then
		bLocalShow = false;
	else
		bLocalShow = true;
		if bReadOnly and not nohide and getValue() == 0 then
			bLocalShow = false;
		end
	end

	setReadOnly(bReadOnly);
	setVisible(bLocalShow);
	
	local sLabel = getName() .. "_label";
	if window[sLabel] then
		window[sLabel].setVisible(bLocalShow);
	end
	
	if self.onUpdate then
		self.onUpdate(bLocalShow);
	end
	
	return bLocalShow;
end

function onValueChanged()
  Debug.chat("Updating column_number Value");
	if isVisible() then
		if window.VisDataCleared then
			if getValue() == 0 then
				window.VisDataCleared();
			end
		end
	else
		if window.InvisDataAdded then
			if getValue() ~= 0 then
				window.InvisDataAdded();
			end
		end
	end
  if super and super.onUpdate then
    Debug.chat("Calling super.onUpdate");
    super.onUpdate();
  end
end
