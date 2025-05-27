local dir = 'gameAssets/nextday/';
local sv = 'FNAF1';

local min = math.min;

local curNight = 1;
function create()
	makeLuaSprite('amTxt', dir .. 'am', 645, 296);
	addLuaSprite('amTxt');
	
	makeLuaSprite('5Txt', dir .. '5', 549, 298);
	addLuaSprite('5Txt');
	doTweenY('5TxtUp', '5Txt', 298 - 112, pl(5.0909));
	setProperty('5Txt.antialiasing', false);
	
	makeLuaSprite('6Txt', dir .. '6', 549 + 4 + 5, 408);
	addLuaSprite('6Txt');
	setProperty('6Txt.antialiasing', false);
	
	
	makeLuaSprite('topClip', nil, 572 - 74, 224 - 55);
	makeGraphic('topClip', 1, 1, '000001');
	scaleObject('topClip', 158, 118);
	addLuaSprite('topClip');
	
	makeLuaSprite('botClip', nil, 573 - 74, 440 - 55);
	makeGraphic('botClip', 1, 1, '000001');
	scaleObject('botClip', 158, 118);
	addLuaSprite('botClip');
	
	makeLuaSprite('fade');
	makeGraphic('fade', 1, 1, '000000');
	scaleObject('fade', 1280, 720);
	addLuaSprite('fade');
	setAlpha('fade', 0);
	
	precacheSound('CROWD_SMALL_CHIL_EC049202');
	
	updateSave();
end

function onUpdatePost() setProperty('6Txt.y', getProperty('5Txt.y') + 110); end

function updateSave()
	curNight = getDataFromSave(sv, 'nightPlay', 1) + 1;
	local svNight = min(curNight, 5);
	setDataFromSave(sv, 'night', svNight);
	
	if curNight == 7 then setDataFromSave(sv, 'beat6', true);
	elseif curNight == 8 then
		local all20 = true;
		for _, s in pairs({'freddy', 'bonnie', 'chica'}) do
			if getDataFromSave(sv, s .. 'AI', 1) ~= 20 then all20 = false; break; end
		end
		
		if all20 then setDataFromSave(sv, 'beat7', true); end
	end
end

local timers = {
	['endWin'] = function() doTweenAlpha('fadeOut', 'fade', 1, pl(0.9)); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['5TxtUp'] = function()
		runTimer('endWin', pl(20 / 6));
		doSound('CROWD_SMALL_CHIL_EC049202', 1, 'chan2'); 
	end,
	['fadeOut'] = function()
		setDataFromSave(sv, 'nightPlay', curNight);
		if getDataFromSave(sv, 'isDemo', true) then
			if curNight > 2 then switchState('EndOfDemo');
			else switchState('WhatDay'); end
		elseif curNight <= 5 then switchState('WhatDay'); else
			setDataFromSave(sv, 'whichWin', curNight - 5);
			switchState('TheEnd');
		end
	end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
