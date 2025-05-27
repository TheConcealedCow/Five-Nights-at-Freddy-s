local curNight = 1;
local nightOff = {
	{113, 48},
	{115, 48},
	{115, 48},
	{115, 48},
	{115, 48},
	{116, 48},
	{120, 50},
};
function create()
	curNight = getDataFromSave('FNAF1', 'nightPlay', 1);
	local off = nightOff[curNight];
	makeLuaSprite('day', 'gameAssets/whatday/day/' .. curNight, 646 - off[1], 318 - off[2]);
	addLuaSprite('day');
	
	makeAnimatedLuaSprite('blip', 'gameAssets/global/blip');
	addAnimationByPrefix('blip', 'idle', 'Idle', 45, false);
	addLuaSprite('blip');
	hideOnFin('blip');
	
	makeLuaSprite('fade');
	makeGraphic('fade', 1, 1, '000000');
	scaleObject('fade', 1280, 720);
	addLuaSprite('fade');
	setAlpha('fade', 0);
	
	makeLuaSprite('clock', 'gameAssets/whatday/clock', 1226 - 20, 675 - 18);
	addLuaSprite('clock');
	setAlpha('clock', 0.00001);
	
	
	killSounds();
	doSound('blip3', 1, 'chan1');
	runTimer('next', pl(13 / 6));
end

local timers = {
	['next'] = function() doTweenAlpha('fadeOut', 'fade', 1, pl(1.1)); end,
	['toNight'] = function() switchState('Night'); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['fadeOut'] = function() setAlpha('clock', 1); runTimer('toNight', pl(0.1)); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
