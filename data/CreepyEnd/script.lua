function create()
	makeLuaSprite('creepy', 'gameAssets/creepy/end');
	addLuaSprite('creepy');
	
	killSounds();
	doSound('XSCREAM2', 1, 'chan29');
	runTimer('end', pl(1));
end

local timers = {
	['end'] = function() exitGame(); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end
