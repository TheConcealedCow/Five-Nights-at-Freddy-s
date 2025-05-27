function create()
	makeAnimatedLuaSprite('static', 'gameAssets/global/static');
	addAnimationByPrefix('static', 'idle', 'Idle', 59.4);
	addLuaSprite('static');
	
	makeAnimatedLuaSprite('blip', 'gameAssets/global/blip');
	addAnimationByPrefix('blip', 'idle', 'Idle', 45, false);
	addLuaSprite('blip');
	hideOnFin('blip');
	
	killSounds();
	doSound('static', 1, 'chan1');
	
	runTimer('toGameover', pl(10));
end

local timers = {
	['toGameover'] = function()
		stopGame();
		
		makeLuaSprite('bg', 'gameAssets/died/bg');
		addLuaSprite('bg');
		setAlpha('bg', 0);
		doTweenAlpha('bgIn', 'bg', 1, pl(1.1));
	end,
	['nextScreen'] = function()
		if Random(10000) == 0 then switchState('CreepyEnd');
		else switchState('Title'); end
	end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['bgIn'] = function() runTimer('nextScreen', pl(10)); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
