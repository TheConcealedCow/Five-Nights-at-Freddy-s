function create()
	killSounds();
	
	makeLuaSprite('creepy', 'gameAssets/creepy/start');
	addLuaSprite('creepy');
	
	
	local eyes = 'gameAssets/creepy/dot';
	makeLuaSprite('eyes1', eyes, 510 - 15, 192 - 15);
	addLuaSprite('eyes1');
	setAlpha('eyes1', 0.00001);
	
	makeLuaSprite('eyes2', eyes, 804 - 15, 196 - 15);
	addLuaSprite('eyes2');
	setAlpha('eyes2', 0);
	
	runTimer('eyes', pl(9.5));
	runTimer('end', pl(10));
end

local timers = {
	['eyes'] = function()
		setAlpha('eyes1', 1);
		setAlpha('eyes2', 1);
	end,
	['end'] = function() switchState('Title'); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end
