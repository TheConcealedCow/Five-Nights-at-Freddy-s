function create()
	local w = getDataFromSave('FNAF1', 'whichWin', 1);
	makeLuaSprite('win', 'gameAssets/end/' .. w);
	addLuaSprite('win');
	
	makeLuaSprite('fade');
	makeGraphic('fade', 1, 1, '000000');
	scaleObject('fade', 1280, 720);
	addLuaSprite('fade');
	doTweenAlpha('fadeIn', 'fade', 0, pl(1.01));
	
	doSound('music box', 1, 'chan1');
	setDataFromSave('FNAF1', 'beatGame', true);
end

local timers = { ['toTitle'] = function() doTweenAlpha('fadeOut', 'fade', 1, pl(0.9)); end };
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['fadeIn'] = function() runTimer('toTitle', pl(15)); end,
	['fadeOut'] = function() switchState('Title'); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
