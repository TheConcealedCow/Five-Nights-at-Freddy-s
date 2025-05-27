function create()
	makeLuaSprite('demo', 'gameAssets/txt/demo', 452, 222);
	addLuaSprite('demo');
	setAlpha('demo', 0);
	doTweenAlpha('demoIn', 'demo', 1, pl(1.13));
	
	killSounds();
	doSound('music box', 1, 'chan1');
end

local timers = { ['go'] = function() doTweenAlpha('demoOut', 'demo', 0, pl(1.1)); end };
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = { 
	['demoIn'] = function() runTimer('go', pl(15)); end,
	['demoOut'] = function() switchState('Title'); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
