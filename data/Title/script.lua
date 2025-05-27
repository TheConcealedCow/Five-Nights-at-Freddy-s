local dir = 'gameAssets/title/';
local sv = 'FNAF1';

local min = math.min;

local isDemo = true;
local beatGame = false;
local beat6 = false;
local night = 1;

local didDelete = false;

freddyAI = 1;
bonnieAI = 3;
chicaAI = 3;
foxyAI = 1;
local numToName = {'freddy', 'bonnie', 'chica', 'foxy'};

local went = false;
function create()
	luaDebugMode = true;
	if Random(1000) == 1 then switchState('CreepyStart'); went = true; return; end
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	
	isDemo = getDataFromSave(sv, 'isDemo', true);
	beatGame = getDataFromSave(sv, 'beatGame', true);
	beat6 = getDataFromSave(sv, 'beat6', true);
	night = getDataFromSave(sv, 'night', 1);
	if isDemo then night = min(night, 2); end
	night = min(night, 5);
	
	if night > 1 then curSel = 2; end
	
	makeBG();
	makeInfo();
	makeStars();
	makeSelection();
	makeAd();
	
	killSounds();
	doSound('static2', 1, 'chan1');
	doSound('darkness music', 1, 'chan2', true);
	precacheSound('blip3');
	
	runTimer('hideStuff', 0.1);
	runTimer('otherRand', pl(0.08), 0);
	runTimer('staticRand', pl(0.09), 0);
	runTimer('lessRand', pl(0.3), 0);
end

function makeBG()
	makeAnimatedLuaSprite('freddy', dir .. 'freddy');
	addAnimationByPrefix('freddy', 'idle', 'Idle', 0, false);
	addAnimationByPrefix('freddy', '1', 'BugA', 0, false);
	addAnimationByPrefix('freddy', '2', 'BugB', 0, false);
	addAnimationByPrefix('freddy', '3', 'BugC', 0, false);
	addLuaSprite('freddy');
	setAlpha('freddy', clAlph(200));
	
	makeAnimatedLuaSprite('static', 'gameAssets/global/static');
	addAnimationByPrefix('static', 'idle', 'Idle', 59.4);
	addLuaSprite('static');
	setBlendMode('static', 'add');
	setAlpha('static', clAlph(50));
	
	makeAnimatedLuaSprite('blip', dir .. 'blip');
	addAnimationByPrefix('blip', 'idle', 'Idle', 6);
	addLuaSprite('blip');
	setAlpha('blip', 0);
	setVis('blip', false);
	
	makeLuaSprite('scanline', nil, 0, -38);
	makeGraphic('scanline', 1280, 32, 'fffffe');
	setAlpha('scanline', clAlph(200));
	addLuaSprite('scanline');
	startTween('lineDown', 'scanline', {y = 768 - 38}, pl(20.75675675), {type = 'LOOPING'});
end

function makeInfo()
	makeLuaSprite('title', dir .. 'main/title', 172 + 3, 68 + 11);
	addLuaSprite('title');
	
	makeLuaSprite('ver', dir .. 'main/ver', 26 + 1, 682 + 7);
	addLuaSprite('ver');
	
	makeLuaSprite('copy', dir .. 'main/copy', 1044, 686 + 5);
	addLuaSprite('copy');
	
	if isDemo then
		makeLuaSprite('demo', dir .. 'extra/demo', 171 + 3, 292 + 13);
		addLuaSprite('demo');
	end
end

function makeStars()
	if isDemo then return; end
	
	local st = dir .. 'extra/star';
	if beatGame then
		makeLuaSprite('star1', st, 200 - 28, 338 - 27);
		addLuaSprite('star1');
	end
	
	if beat6 then
		makeLuaSprite('star2', st, 277 - 28, 338 - 27);
		addLuaSprite('star2');
	end
	
	if getDataFromSave(sv, 'beat7', true) then
		makeLuaSprite('star3', st, 352 - 28, 338 - 27);
		addLuaSprite('star3');
	end
end

local curSel = 1;
local maxSel = 2;
function makeSelection()
	makeLuaSprite('new', dir .. 'sel/sel/new', 275 - 101, 420 - 16);
	addLuaSprite('new');
	
	makeLuaSprite('cont', dir .. 'sel/sel/cont', 275 - 102, 492 - 17);
	addLuaSprite('cont');
	
	makeLuaSprite('nightTxt', dir .. 'sel/night', 174 + 1, 512 + 5);
	addLuaSprite('nightTxt');
	setVis('nightTxt', false);
	
	makeLuaSprite('nightNum', 'gameAssets/nightNum/' .. night, 263 - 14, 535 - 17);
	addLuaSprite('nightNum');
	setVis('nightNum', false);
	
	if beatGame and not isDemo then
		makeLuaSprite('sixth', dir .. 'sel/sel/sixth', 285 - 113, 571 - 22);
		addLuaSprite('sixth');
		maxSel = 3;
		
		if beat6 then
			makeLuaSprite('custom', dir .. 'sel/sel/custom', 324 - 153, 639 - 22);
			addLuaSprite('custom');
			maxSel = 4;
			
			runHaxeCode([[
				var customCam = FlxG.cameras.add(new FlxCamera(), false);
				customCam.pixelPerfectRender = true;
				customCam.antialiasing = false;
				setVar('customCam', customCam);
				customCam.alpha = 0.00001;
			]]);
			makeCustom();
		end
	end
	
	makeLuaSprite('sel', dir .. 'sel/sel', 132, 493);
	addToOffsets('sel', 21, 13);
	addLuaSprite('sel');
	
	updateSel();
end

function makeAd()
	makeLuaSprite('ad', 'gameAssets/ad/ad');
	addLuaSprite('ad');
	setAlpha('ad', 0.00001);
	
	makeLuaSprite('fadeAd');
	makeGraphic('fadeAd', 1, 1, '000000');
	scaleObject('fadeAd', 1280, 720);
	addLuaSprite('fadeAd');
	setAlpha('fadeAd', 0);
end

function makeCustom()
	local d = 'gameAssets/custom/';
	
	makeLuaSprite('customTxt', d .. 'custom', 448 + 2, 29 + 11);
	setCam('customTxt', 'customCam');
	addLuaSprite('customTxt');
	
	makeLuaSprite('lvlTxt', d .. 'lvl', 116, 654);
	setCam('lvlTxt', 'customCam');
	addLuaSprite('lvlTxt');
	
	
	for i, x in pairs({140 + 5, 425 + 4, 714 + 2, 1004 + 5}) do
		local t = 'name' .. i;
		makeLuaSprite(t, d .. 'icons/names/' .. i, x, 108 + (i == 4 and 13 or 11));
		setCam(t, 'customCam');
		addLuaSprite(t);
	end
	
	for i, x in pairs({118, 403, 682, 957}) do
		local t = 'icon' .. i;
		makeLuaSprite(t, d .. 'icons/icons/' .. i, x, 187);
		setCam(t, 'customCam');
		addLuaSprite(t);
	end
	
	local count = d .. 'aiNum/';
	makeCounterSpr('freddyAI', 267, 532, freddyAI, count);
	setCam('freddyAI', 'customCam');
	addLuaSprite('freddyAI');
	
	makeCounterSpr('bonnieAI', 550, 532, bonnieAI, count);
	setCam('bonnieAI', 'customCam');
	addLuaSprite('bonnieAI');
	
	makeCounterSpr('chicaAI', 832, 532, chicaAI, count);
	setCam('chicaAI', 'customCam');
	addLuaSprite('chicaAI');
	
	makeCounterSpr('foxyAI', 1112, 532, foxyAI, count);
	setCam('foxyAI', 'customCam');
	addLuaSprite('foxyAI');
	
	
	makeLuaSprite('sub1', d .. 'arrows/left', 122 - 5, 470);
	setCam('sub1', 'customCam');
	addLuaSprite('sub1');
	makeLuaSprite('add1', d .. 'arrows/right', 311 - 28, 470);
	setCam('add1', 'customCam');
	addLuaSprite('add1');
	
	makeLuaSprite('sub2', d .. 'arrows/left', 406 - 5, 470);
	setCam('sub2', 'customCam');
	addLuaSprite('sub2');
	makeLuaSprite('add2', d .. 'arrows/right', 593 - 28, 470);
	setCam('add2', 'customCam');
	addLuaSprite('add2');
	
	makeLuaSprite('sub3', d .. 'arrows/left', 690 - 5, 470);
	setCam('sub3', 'customCam');
	addLuaSprite('sub3');
	makeLuaSprite('add3', d .. 'arrows/right', 876 - 28, 470);
	setCam('add3', 'customCam');
	addLuaSprite('add3');
	
	makeLuaSprite('sub4', d .. 'arrows/left', 969 - 5, 470);
	setCam('sub4', 'customCam');
	addLuaSprite('sub4');
	makeLuaSprite('add4', d .. 'arrows/right', 1154 - 28, 470);
	setCam('add4', 'customCam');
	addLuaSprite('add4');
	
	
	makeLuaSprite('ready', d .. 'ready', 1044 + 5, 603 + 25);
	setCam('ready', 'customCam');
	addLuaSprite('ready');
end

local justPressed = keyboardJustPressed;
local lastMouseSel = -1;
local toSel = {'new', 'cont', 'sixth', 'custom'};

local delTime = 0;

local selected = false;
local checkAd = false;
local inCustom = false;
function onUpdatePost(e)
	e = e * playbackRate;
	if went then return; end
	
	if inCustom then
		if mouseClicked() then
			for i = 1, 4 do
				if mouseOverlaps('sub' .. i) then changeAI(i, -1); return; end
				if mouseOverlaps('add' .. i) then changeAI(i, 1); return; end
			end
			
			if mouseOverlaps('ready') then ready(); end
		end
	else
		if not selected then
			if justPressed('UP') then shiftSel(curSel - 1); end
			if justPressed('DOWN') then shiftSel(curSel + 1); end
			
			local touching = false;
			for i = 1, maxSel do
				if mouseOverlaps(toSel[i]) then
					touching = true;
					if lastMouseSel ~= i then
						lastMouseSel = i;
						if curSel ~= i then shiftSel(i); end
					end
				end
			end
			if not touching then lastMouseSel = -1; end
		
			if mouseClicked() and mouseOverlaps(toSel[curSel]) then confirmSel(); return; end
			if justPressed('ENTER') then confirmSel(); end
			
			if not didDelete and keyboardPressed('DELETE') then
				delTime = delTime + e;
				while delTime >= 1 do
					delTime = delTime - 1;
					deleteSave();
				end
			end
		end
		
		if checkAd then
			if mouseClicked() or justPressed('ENTER') then goAd(); end
		end
	end
end

function shiftSel(i)
	doSound('blip3', 1, 'chan3');
	checkSel(i);
	updateSel();
end

function checkSel(i)
	if curSel == 2 then 
		setVis('nightTxt', false);
		setVis('nightNum', false);
	end
	
	curSel = i;
	if curSel > maxSel then curSel = 1; end
	if curSel < 1 then curSel = maxSel; end
	
	if curSel == 2 then 
		setVis('nightTxt', true);
		setVis('nightNum', true);
	end
end

local selPos = {{275 - 150, 420}, {275 - 150, 492}, {285 - 165, 571}, {324 - 192, 639}};
function updateSel()
	local p = selPos[curSel];
	setPos('sel', p[1], p[2]);
end

function confirmSel()
	selected = true;
	runTimer('toSelect', pl(2 / 6));
end

function startAd()
	stopTmrTwn();
	stopAnims();
	
	doTweenAlpha('adIn', 'ad', 1, pl(2));
end

function goAd()
	if not checkAd then return; end
	checkAd = false;
	doTweenAlpha('adFadeOut', 'fadeAd', 1, pl(2));
end

function fredRand()
	local a = Random(100);
	if a > 96 then playAnim('freddy', a - 96);
	else playAnim('freddy', 'idle'); end
end

function toCustom()
	stopTmrTwn();
	stopAnims();
	
	for i = 1, 4 do
		local c = numToName[i];
		local a = getDataFromSave(sv, c .. 'AI', -1);
		if a ~= -1 then _G[c .. 'AI'] = a; end
		updateCounterSpr(c .. 'AI', _G[c .. 'AI']);
	end
	
	doTweenAlpha('customIn', 'customCam', 1, pl(0.56));
end

function changeAI(s, i)
	local c = numToName[s];
	local g = c .. 'AI';
	_G[g] = bound(_G[g] + i, 0, 20);
	
	local n = _G[g];
	updateCounterSpr(c .. 'AI', n);
end

function ready()
	if freddyAI == 1 and bonnieAI == 9 and chicaAI == 8 and foxyAI == 7 then switchState('CreepyEnd'); else
		for i = 1, 4 do
			local c = numToName[i];
			setDataFromSave(sv, c .. 'AI', _G[c .. 'AI']);
		end
		
		setDataFromSave(sv, 'nightPlay', 7);
		switchState('WhatDay');
	end
end

local selToDo = {
	[1] = function() startAd(); end,
	[2] = function()
		setDataFromSave(sv, 'nightPlay', night);
		switchState('WhatDay');
	end,
	[3] = function()
		setDataFromSave(sv, 'nightPlay', 6);
		switchState('WhatDay');
	end,
	[4] = function() toCustom(); end
};
local timers = {
	['hideStuff'] = function() 
		setAlpha('ad', 0);
		if getVar('customCam') then setAlpha('customCam', 0); end
	end,
	
	['otherRand'] = function()
		fredRand();
		setAlpha('blip', clAlph(100 + Random(100)));
	end,
	['lessRand'] = function()
		setAlpha('freddy', clAlph(Random(250)));
		setVis('blip', Random(3) == 1);
	end,
	['staticRand'] = function() setAlpha('static', clAlph(50 + Random(100))); end,
	
	['toSelect'] = function()
		local a = selToDo[curSel];
		if a then a(); end
	end,
	
	['adGo'] = function() goAd(); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['adIn'] = function()
		removeLuaSprite('freddy');
		removeLuaSprite('static');
		
		checkAd = true;
		runTimer('adGo', pl(5));
	end,
	['adFadeOut'] = function()
		setDataFromSave(sv, 'nightPlay', 1);
		switchState('WhatDay');
	end,
	
	['customIn'] = function() inCustom = true; end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end

function deleteSave()
	if didDelete then return; end
	didDelete = true;
	maxSel = 2;
	
	beatGame = false;
	beat6 = false;
	beat7 = false;
	
	checkSel(curSel);
	updateSel();
	night = 1;
	loadGraphic('nightNum', 'gameAssets/nightNum/1');
	
	doSound('blip3', 1, 'chan3');
	setDataFromSave(sv, 'night', 1);
	setDataFromSave(sv, 'beatGame', false);
	setDataFromSave(sv, 'beat6', false);
	setDataFromSave(sv, 'beat7', false);
	
	for i = 1, 3 do removeLuaSprite('star' .. i); end
	
	removeLuaSprite('sixth');
	removeLuaSprite('custom');
end
