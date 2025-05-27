local isDemo = false;

local went = true;
function create()
	makeLuaSprite('warn', 'gameAssets/txt/warn', 388 + 38, 242 + 7);
	addLuaSprite('warn');
	setAlpha('warn', 0);
	doTweenAlpha('warnIn', 'warn', 1, pl(1.1));
	
	setDataFromSave('FNAF1', 'isDemo', isDemo);
	for _, s in pairs({'freddy', 'bonnie', 'chica', 'foxy'}) do setDataFromSave('FNAF1', s .. 'AI', -1); end
end

function onUpdatePost()
	if not went and mouseClicked() or keyboardJustPressed('ENTER') then go(); end
end

function go()
	if went then return; end
	went = true;
	doTweenAlpha('warnOut', 'warn', 0, pl(1.1));
end

local timers = { ['forceGo'] = function() go(); end };
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['warnIn'] = function()
		went = false;
		runTimer('forceGo', pl(2));
	end,
	['warnOut'] = function() switchState('Title'); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
