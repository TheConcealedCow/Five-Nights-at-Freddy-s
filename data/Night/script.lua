local dir = 'gameAssets/night/';
local hud = dir .. 'hud/';
local off = dir .. 'office/';
local panel = dir .. 'panel/';
local pHud = panel .. 'hud/';
local cams = panel .. 'cams/';

local HITBOX = 'hitbox';

local sv = 'FNAF1';

local floor = math.floor;
local min = math.min;
local max = math.max;

local ins = table.insert;

local curHour = 12;
local curMin = 0;
curNight = 1;
curCam = 1;

lastOn = '';
local sides = {'left', 'right'};
for i = 1, 2 do
	local s = sides[i];
	_G[s] = {
		clicked = false,
		lightOn = false,
		
		side = s,
		
		stuck = false,
		canPress = true,
		closed = false,
		open = true,
		
		drain = 0
	};
end

local doorFinBool = {[true] = 'closed', [false] = 'open'};

local inOffice = true;
inCams = false;
gotYou = false;

local clickCool = 0;

local powerout = false;
local powerLeft = 999;
local curUsage = 1;
local lightDrain = 0;
local panelDrain = 0;

local cameraBugs = {};
for i = 1, 11 do cameraBugs[i] = 0; end

cameraProps = {};
local panelTrig = true;
local canPanel = true;
local panelFlip = false;
local randPic = 0;
local feedX = 0;

local canMute = false;

local itsMe = false;
local cornerVol = 0;

foxPhase = 0;
local pirateVol = 0;

local staticRand = 0;
local camFlickRand = true;
local camBugRand = 0;

local kitchenVol = 0;
local musicVol = 0;

bonMove = false;
chiMove = false;

freddyIn = false;
bonnieIn = false;
chicaIn = false;

local bugTimeB1 = 0;
local bugTimeB2 = 0;
local bugTimeC1 = 0;
local bugTimeC2 = 0;

local scare = '';

local startedMus = false;
local randFredPic = true;
local startedFlicker = false;
local flickering = true;

local yellowSpawn = true;
local yellowActive = false;
local yellowIn = false;
local yellowSee = false;
local yellowLook = 0;

local gameStopped = false;
function create()
	luaDebugMode = true;
	runHaxeCode([[
		import psychlua.LuaUtils;
		
		var shad = game.createRuntimeShader('panorama');
		var panoShader = new ShaderFilter(shad);
		
		var mainCam = FlxG.cameras.add(new FlxCamera(-22, -22, 1324, 754), false);
		mainCam.setFilters([panoShader]);
		mainCam.pixelPerfectRender = true;
		mainCam.antialiasing = false;
		setVar('mainCam', mainCam);
		mainCam.scroll.y = -22;
		mainCam.scroll.x = -22;
		
		
		var camsCam = FlxG.cameras.add(new FlxCamera(-22, -22, 1324, 754), false);
		camsCam.setFilters([panoShader]);
		camsCam.pixelPerfectRender = true;
		camsCam.antialiasing = false;
		setVar('camsCam', camsCam);
		camsCam.scroll.y = -22;
		camsCam.scroll.x = -22;
		camsCam.alpha = 0.00001;
		
		var pTopCam = FlxG.cameras.add(new FlxCamera(), false);
		pTopCam.pixelPerfectRender = true;
		pTopCam.antialiasing = false;
		pTopCam.bgColor = 0x00000000;
		setVar('pTopCam', pTopCam);
		pTopCam.alpha = 0.00001;
		
		var topCam = FlxG.cameras.add(new FlxCamera(), false);
		topCam.pixelPerfectRender = true;
		topCam.antialiasing = false;
		topCam.bgColor = 0x00000000;
		setVar('topCam', topCam);
		
		var meCam = FlxG.cameras.add(new FlxCamera(), false);
		meCam.pixelPerfectRender = true;
		meCam.antialiasing = false;
		meCam.bgColor = 0xff000000;
		setVar('meCam', meCam);
		meCam.alpha = 0.00001;
		
		var winCam = FlxG.cameras.add(new FlxCamera(), false);
		winCam.pixelPerfectRender = true;
		winCam.antialiasing = false;
		winCam.bgColor = 0x00000000;
		setVar('winCam', winCam);
		winCam.alpha = 0.00001;
		
		createGlobalCallback('getMainVar', function(v) {
			return parentLua.call('varMain', [v]);
		});
		
		createGlobalCallback('setMainVar', function(v, f) {
			parentLua.call('varSetMain', [v, f]);
		});
		
		createGlobalCallback('runMainFunc', function(v, ?n) {
			n ??= [];
			return parentLua.call(v, n);
		});
		
		createCallback('finFunc', function(o, f, ?p) {
			var obj = LuaUtils.getObjectDirectly(o);
			obj.animation.finishCallback = function(n) { 
				parentLua.call(f, [n, obj.animation.curAnim.reversed, p]); 
			}
		});
		
		createCallback('frameFunc', function(o, f) {
			var obj = LuaUtils.getObjectDirectly(o);
			obj.animation.callback = function(n, fr) {
				parentLua.call(f, [n, fr]);
			}
		});
	]]);
	
	addLuaScript('scripts/objects/COUNTERDOUBDIGIT');
	randPic = Random(100) + 1;
	setVar('moveWho', 0);
	curNight = getDataFromSave(sv, 'nightPlay', 1);
	
	checkHalloween();
	makeOffice();
	makeCams();
	makeHud();
	makeHitboxes();
	makeWin();
	
	staticRand = Random(3);
	
	killSounds();
	doSound('Buzz_Fan_Florescent2', 0.25, 'chan1', true);
	doSound('ColdPresc B', 0.5, 'chan2', true);
	doSound('BallastHumMedium2', 0, 'chan3', true);
	if curNight < 6 then doSound('voiceover' .. curNight, 1, 'chan19'); end
	doSound('robotvoice', 0, 'chan21', true);
	doSound('EerieAmbienceLargeSca_MV005', 0, 'chan18', true);
	cacheSounds();
	
	runTimer('hideStuff', 0.1);
	if curNight > 3 then runTimer('randBug', pl(0.05), 0); end
	runTimer('sec', pl(1), 0);
	runTimer('fiv', pl(5), 0);
	runTimer('ten', pl(10), 0);
	if curNight > 1 then runTimer('takePower', pl(max(8 - curNight, 3)), 0); end
	
	runTimer('moveBonnie', pl(4.97), 0);
	runTimer('moveChica', pl(4.98), 0);
	
	for _, a in pairs({'freddy', 'bonnie', 'chica', 'foxy'}) do addLuaScript('scripts/game/night/animatronics/' .. a); end
	
	updateUsage();
end

local isHalloween = false;
function checkHalloween()
	local d = os.date('*t');
	local month = d.month;
	local day = d.day;
	
	isHalloween = (month == 10 and day == 31); -- this is halloween
end

function makeOffice()
	makeLuaSprite('office', off .. 'office');
	setCam('office');
	addLuaSprite('office');
	
	makeOfficeAnims();
	
	makeAnimatedLuaSprite('fan', off .. 'o/fan', 868 - 88, 400 - 97);
	addAnimationByPrefix('fan', 'idle', 'Idle', 59.4);
	setCam('fan');
	addLuaSprite('fan');
	
	makeDoors();
	makeOfficeObjs();
end

function makeOfficeAnims()
	makeAnimatedLuaSprite('out', off .. 'p/out');
	addAnimationByPrefix('out', 'idle', 'Idle', 0, false);
	addAnimationByPrefix('out', 'freddy', 'On', 0, false);
	setCam('out');
	addLuaSprite('out');
	setAlpha('out', 0.00001);
	
	
	makeAnimatedLuaSprite('left', off .. 'p/s/l');
	addAnimationByPrefix('left', 'idle', 'Idle', 0, false);
	addAnimationByPrefix('left', 'bonnie', 'On', 0, false);
	setCam('left');
	addLuaSprite('left');
	setAlpha('left', 0.00001);
	
	makeAnimatedLuaSprite('right', off .. 'p/s/r');
	addAnimationByPrefix('right', 'idle', 'Idle', 0, false);
	addAnimationByPrefix('right', 'chica', 'On', 0, false);
	setCam('right');
	addLuaSprite('right');
	setAlpha('right', 0.00001);
	
	makeScares();
end

function makeScares()
	makeAnimatedLuaSprite('bonnieScare', dir .. 'scares/bonnie');
	addAnimationByPrefix('bonnieScare', 'scare', 'Scare', 45);
	setCam('bonnieScare');
	addLuaSprite('bonnieScare');
	setAlpha('bonnieScare', 0.00001);
	
	makeAnimatedLuaSprite('chicaScare', dir .. 'scares/chica');
	addAnimationByPrefix('chicaScare', 'scare', 'Scare', 59.4);
	setCam('chicaScare');
	addLuaSprite('chicaScare');
	setAlpha('chicaScare', 0.00001);
	
	makeAnimatedLuaSprite('foxyScare', dir .. 'scares/foxy');
	addAnimationByPrefix('foxyScare', 'scare', 'Scare', 30, false);
	setCam('foxyScare');
	addLuaSprite('foxyScare');
	setAlpha('foxyScare', 0.00001);
	
	makeAnimatedLuaSprite('freddyScare', dir .. 'scares/freddy');
	addAnimationByPrefix('freddyScare', 'scare', 'Scare', 30, false);
	setCam('freddyScare');
	addLuaSprite('freddyScare');
	setAlpha('freddyScare', 0.00001);
end

function makeDoors()
	makeAnimatedLuaSprite('leftDoor', off .. 'o/d/d/l', 72, -1);
	addAnimationByPrefix('leftDoor', 'open', 'Open', 0, false);
	addAnimationByPrefix('leftDoor', 'closed', 'Closed', 0, false);
	addAnimationByPrefix('leftDoor', 'closing', 'Closing', 30, false);
	playAnim('leftDoor', 'open', true);
	finFunc('leftDoor', 'doorFin', 'left');
	setCam('leftDoor');
	addLuaSprite('leftDoor');
	
	makeAnimatedLuaSprite('rightDoor', off .. 'o/d/d/r', 1270, -2);
	addAnimationByPrefix('rightDoor', 'open', 'Open', 0, false);
	addAnimationByPrefix('rightDoor', 'open', 'Open', 0, false);
	addAnimationByPrefix('rightDoor', 'closed', 'Closed', 0, false);
	addAnimationByPrefix('rightDoor', 'closing', 'Closing', 30, false);
	playAnim('rightDoor', 'open', true);
	finFunc('rightDoor', 'doorFin', 'right');
	setCam('rightDoor');
	addLuaSprite('rightDoor');
	
	
	makeAnimatedLuaSprite('leftButton', off .. 'o/d/b/l', 48 - 42, 390 - 127);
	addAnimationByPrefix('leftButton', '', 'Idle', 0, false);
	addAnimationByPrefix('leftButton', 'door', 'Door', 0, false);
	addAnimationByPrefix('leftButton', 'light', 'Light', 0, false);
	addAnimationByPrefix('leftButton', 'doorlight', 'Both', 0, false);
	playAnim('leftButton', '', true);
	setCam('leftButton');
	addLuaSprite('leftButton');
	
	makeAnimatedLuaSprite('rightButton', off .. 'o/d/b/r', 1546 - 49, 400 - 127);
	addAnimationByPrefix('rightButton', '', 'Idle', 0, false);
	addAnimationByPrefix('rightButton', 'door', 'Door', 0, false);
	addAnimationByPrefix('rightButton', 'light', 'Light', 0, false);
	addAnimationByPrefix('rightButton', 'doorlight', 'Both', 0, false);
	playAnim('rightButton', '', true);
	setCam('rightButton');
	addLuaSprite('rightButton');
end

function makeOfficeObjs()
	if isHalloween then
		makeAnimatedLuaSprite('pumpkin', off .. 'o/h/pumpkin', 734 - 71, 485 - 130);
		addAnimationByPrefix('pumpkin', 'idle', 'Idle', 15);
		setCam('pumpkin');
		addLuaSprite('pumpkin');
		
		makeLuaSprite('lights', off .. 'o/h/lights', 0, -78);
		setCam('lights');
		addLuaSprite('lights');
	end
	
	makeLuaSprite('yellowBear', off .. 'o/yellowBear', 660 - 270, 478 - 260);
	setCam('yellowBear');
	addLuaSprite('yellowBear');
	setAlpha('yellowBear', 0.00001);
end

function makeCams()
	for i = 1, 11 do
		if i ~= 10 then
			local t = 'cam' .. i;
			makeAnimatedLuaSprite(t, panel .. 'cams/cams/' .. i);
			addAnimationByPrefix(t, 'idle', 'Idle', 0, false);
			setCam(t, 'camsCam');
			addLuaSprite(t);
			setAlpha(t, 0.00001);
		end
		cameraProps[i] = {'', '', '', ''};
	end
	
	makeAnimatedLuaSprite('foxyRun', panel .. 'cams/cams/foxy');
	addAnimationByPrefix('foxyRun', 'idle', 'Idle', 39);
	setProperty('foxyRun.animation.curAnim.loopPoint', 31);
	setCam('foxyRun', 'camsCam');
	addLuaSprite('foxyRun');
	setAlpha('foxyRun', 0.00001);
end

function makeHud()
	makePanelHud();
	
	makeAnimatedLuaSprite('fredOutCache', 'gameAssets/freddy/freddy');
	setCam('fredOutCache', 'topCam');
	addLuaSprite('fredOutCache');
	setAlpha('fredOutCache', 0.00001);
	
	
	makeLuaSprite('amTxt', hud .. 'txt/am', 1198 + 2, 31);
	setCam('amTxt', 'topCam');
	addLuaSprite('amTxt');
	
	makeCounterSpr('hour', 1185, 59, curHour, hud .. 'hour/');
	setCam('hour', 'topCam');
	addLuaSprite('hour');
	
	
	makeLuaSprite('nightTxt', hud .. 'txt/night', 754 + 394, 74);
	setCam('nightTxt', 'topCam');
	addLuaSprite('nightTxt');
	
	makeCounterSpr('night', 1237, 89, curNight);
	setCam('night', 'topCam');
	addLuaSprite('night');
	
	
	
	makeLuaSprite('leftTxt', hud .. 'txt/powerLeft', 106 - 68, 638 - 7);
	setCam('leftTxt', 'topCam');
	addLuaSprite('leftTxt');
	
	makeCounterSpr('powerLeft', 221, 646, getPower(), hud .. 'power/');
	setCam('powerLeft', 'topCam');
	addLuaSprite('powerLeft');
	
	makeLuaSprite('percentTxt', hud .. 'txt/percent', -196 + 420, 632);
	setCam('percentTxt', 'topCam');
	addLuaSprite('percentTxt');
	
	
	makeLuaSprite('usageTxt', hud .. 'txt/usage', 74 - 36, 674 - 7);
	setCam('usageTxt', 'topCam');
	addLuaSprite('usageTxt');
	
	makeAnimatedLuaSprite('usage', hud .. 'usage', 120, 657);
	addAnimationByPrefix('usage', 'idle', 'Idle', 0, false);
	setCam('usage', 'topCam');
	addLuaSprite('usage');
	
	
	makeLuaSprite('flip', hud .. 'flip', 554 - 299, 668 - 30);
	setCam('flip', 'topCam');
	addLuaSprite('flip');
	
	if curNight < 6 then
		makeLuaSprite('mute', hud .. 'mute', 87 - 60, 37 - 15);
		setCam('mute', 'topCam');
		addLuaSprite('mute');
		setAlpha('mute', 0.00001);
		
		startCall();
	end
	
	
	makeAnimatedLuaSprite('panel', panel .. 'panel');
	addAnimationByPrefix('panel', 'idle', 'Idle', 30, false);
	finFunc('panel', 'panelFin');
	setCam('panel', 'topCam');
	addLuaSprite('panel');
	setAlpha('panel', 0.00001);
	
	makeAnimatedLuaSprite('itsMe', dir .. 'fx/itsMe');
	addAnimationByPrefix('itsMe', 'idle', 'Idle', 45);
	setCam('itsMe', 'meCam');
	addLuaSprite('itsMe');
end

function makePanelHud()
	makeAnimatedLuaSprite('static', 'gameAssets/global/static');
	addAnimationByPrefix('static', 'idle', 'Idle', 60);
	setCam('static', 'pTopCam');
	addLuaSprite('static');
	
	makeAnimatedLuaSprite('blip', 'gameAssets/global/blip');
	addAnimationByPrefix('blip', 'idle', 'Idle', 45, false);
	setCam('blip', 'pTopCam');
	addLuaSprite('blip');
	setAlpha('blip', 0.00001);
	hideOnFin('blip');
	
	
	makeLuaSprite('frame', pHud .. 'frame', 0, -1);
	setCam('frame', 'pTopCam');
	addLuaSprite('frame');
	
	makeAnimatedLuaSprite('rec', pHud .. 'dot', 92 - 24, 76 - 24);
	addAnimationByPrefix('rec', 'idle', 'Idle', 1.2);
	setCam('rec', 'pTopCam');
	addLuaSprite('rec');
	
	makeAnimatedLuaSprite('map', pHud .. 'map', 848, 313);
	addAnimationByPrefix('map', 'idle', 'Idle', 1.2);
	setCam('map', 'pTopCam');
	addLuaSprite('map');
	
	makeAnimatedLuaSprite('roomName', panel .. 'cams/names/rooms', 832, 292);
	addAnimationByPrefix('roomName', 'idle', 'Idle', 0, false);
	setCam('roomName', 'pTopCam');
	addLuaSprite('roomName');
	setFrame('roomName', curCam - 1);
	
	makeLuaSprite('noCam', pHud .. 'audioOnly', 384 + 80, 69);
	setCam('noCam', 'pTopCam');
	addLuaSprite('noCam');
	setAlpha('noCam', 0.00001);
	
	makeMarkers();
end

local markerPos = {
	{{983, 353}, {961, 341}},
	{{963, 409}, {939, 397}},
	{{931, 487}, {908, 475}},
	{{983, 603}, {960, 590}},
	{{983, 643}, {960, 630}},
	{{899, 585}, {877, 574}},
	{{1089, 604}, {1066, 592}},
	{{1089, 644}, {1066, 632}},
	{{857, 436}, {834, 424}},
	{{1186, 568}, {1163, 556}},
	{{1195, 437}, {1172, 424}}
};
function makeMarkers()
	for i = 1, 11 do
		local t, p = 'marker' .. i, markerPos[i][1];
		makeAnimatedLuaSprite(t, pHud .. 'marker', p[1] - 29, p[2] - 19);
		addAnimationByPrefix(t, 'idle', 'Idle', 0, false);
		addAnimationByPrefix(t, 'sel', 'Sel', 1.8);
		setCam(t, 'pTopCam');
		addLuaSprite(t);
		
		t, p = 'nameMark' .. i, markerPos[i][2];
		makeLuaSprite(t, cams .. 'names/markers/' .. i, p[1] + 1, p[2]);
		setCam(t, 'pTopCam');
		addLuaSprite(t);
	end
end

function makeHitboxes()
	makeLuaSprite('leftBDoor', HITBOX, 54 - 29, 307 - 56);
	scaleObject('leftBDoor', 62, 120);
	setCam('leftBDoor');
	
	makeLuaSprite('leftBLight', HITBOX, 54 - 29, 449 - 56);
	scaleObject('leftBLight', 62, 120);
	setCam('leftBLight');
	
	
	makeLuaSprite('rightBDoor', HITBOX, 1548 - 29, 323 - 56);
	scaleObject('rightBDoor', 62, 120);
	setCam('rightBDoor');
	
	makeLuaSprite('rightBLight', HITBOX, 1548 - 29, 454 - 56);
	scaleObject('rightBLight', 62, 120);
	setCam('rightBLight');
	
	
	makeLuaSprite('nose', HITBOX, 678 - 4, 240 - 4);
	scaleObject('nose', 8, 8);
	setCam('nose');
	
	
	makeLuaSprite('resetBox', HITBOX, 589 - 496, 599 - 38);
	scaleObject('resetBox', 1070, 82);
	setCam('resetBox', 'topCam');
	
	makeLuaSprite('flipBox', HITBOX, 442 - 367, 691 - 38);
	scaleObject('flipBox', 792, 82);
	setCam('flipBox', 'topCam');
end

local dir = 'gameAssets/nextday/';
function makeWin()
	makeLuaSprite('winScreen', dir .. 'screen');
	setCam('winScreen', 'winCam');
	addLuaSprite('winScreen');
	
	
	makeLuaSprite('5Txt', dir .. '5');
	setCam('5Txt', 'winCam');
	addLuaSprite('5Txt');
	setAlpha('5Txt', 0.00001);
	
	makeLuaSprite('6Txt', dir .. '6');
	setCam('6Txt', 'winCam');
	addLuaSprite('6Txt');
	setAlpha('6Txt', 0.00001);
	
	makeLuaSprite('amWTxt', dir .. 'am');
	setCam('amWTxt', 'winCam');
	addLuaSprite('amWTxt');
	setAlpha('amWTxt', 0.00001);
end

function startCall()
	canMute = true;
	runTimer('showMute', pl(20));
	runTimer('hideMute', pl(40));
end

local tickRate = 0;
function onUpdatePost(e)
	if gameStopped then return; end
	
	e = e * playbackRate;
	local ti = (e * 60);
	
	checkCode();
	local ticks = 0;
	tickRate = tickRate + ti;
	while tickRate >= 1 do
		tickRate = tickRate - 1;
		ticks = ticks + 1;
		onTick();
	end
	
	moveCam(ti);
	updateCams(ti);
	otherUpdate(e, ti);
	
	local c = curCam;
	if not inCams then c = -1; end
	callOnLuas('updateFunc', {e, ti, ticks, inCams, c});
	return Function_StopLua;
end

local lastCamFlick = camFlickRand;

local skipTickMove = true;
function onTick()
	if itsMe then tryMeVis(); end
	if lastOn ~= '' then tryLightVis(lastOn); end
	if inCams then updateStatic(); end
	if startedFlicker then tryFlicker(); end
	
	camFlickRand = getRandomInt(1, 10) <= 3;
	if lastCamFlick ~= camFlickRand then
		lastCamFlick = camFlickRand;
		if inCams and curCam == 4 then updateACam(); end
	end
	
	if skipTickMove and (chiMove or bonMove) then
		skipTickMove = false;
		return;
	end
	
	if chiMove then
		skipTickMove = true;
		chiMove = false;
		bonMove = false;
		setVar('moveWho', 2);
	elseif bonMove then
		skipTickMove = true;
		bonMove = false;
		chiMove = false;
		setVar('moveWho', 1);
	end	
end

function tryMeVis() setVis('meCam', Random(10) == 1); end

function checkCode()
	if keyboardPressed('C') and keyboardPressed('D') and keyboardJustPressed('NUMPADPLUS') then winNight(); end
end

local xCam = 640;
local camMoves = {
	{x = 153, p = -7},
	{x = 315, p = -2},
	
	{x = 539, p = 0},
	
	{x = 759, p = 2},
	{x = 999, p = 7},
	{x = 1143, p = 12}
};
function moveCam(t)
	if clickCool > 0 then clickCool = clickCool - t; end
	
	checkPanel();
	
	if inOffice then
		local camSpd = -12; -- so we can ignore the first one :)
		local m = camMouseX();
		
		for i = 1, 6 do
			if m > camMoves[i].x then camSpd = camMoves[i].p;
			else break; end
		end
		
		if camSpd ~= 0 then
			xCam = bound(xCam + (camSpd * t), 640, 960);
			setProperty('mainCam.scroll.x', -22 + (xCam - 640));
		end
		
		if mouseClicked() then onClickOffice(); end
	elseif inCams and mouseClicked() then onClickCams(); end
end

function checkPanel()
	if powerout or gotYou then return; end
	
	if panelTrig then
		if canPanel and mouseOverlaps('flipBox') then
			canPanel = false;
			panelTrig = false;
			setAlpha('flip', 0);
			triggerPanel();
		end
	elseif mouseOverlaps('resetBox') then panelTrig = true; setAlpha('flip', 1); end
end

function onClickOffice()
	if powerout or gotYou then return; end
	if clickCool <= 0 then
		for i = 1, 2 do
			local s = sides[i];
			if mouseOverlaps(s .. 'BDoor', 'mainCam') then
				clickCool = 10;
				clickDoor(s);
				return;
			end
			if mouseOverlaps(s .. 'BLight', 'mainCam') then
				clickCool = 10;
				clickLight(s);
				return;
			end
		end
	end
	
	checkMute();
	if mouseOverlaps('nose', 'mainCam') then doSound('PartyFavorraspyPart_AC01__3', 1, 'chan9'); end
end

function checkMute()
	if canMute and mouseOverlaps('mute') then
		canMute = false;
		removeLuaSprite('mute');
		cancelTimer('hideMute');
		stopSound('chan19');
	end
end

function onClickCams()
	for i = 1, 11 do
		if mouseOverlaps('marker' .. i) then
			blip();
			if curCam ~= i then switchCam(i); end
			break;
		end
	end
	checkMute();
end

function switchCam(i)
	playAnim('marker' .. curCam, 'idle');
	if curCam ~= 10 then setAlpha('cam' .. curCam, 0); end
	leaveCam(curCam);
	
	curCam = i;
	
	playAnim('marker' .. i, 'sel');
	setFrame('roomName', i - 1);
	if i ~= 10 then setAlpha('cam' .. i, 1); end
	enterCam(i);
	updateACam();
end

local buggingTime = 0;
local didBug = false;
local garble = {'COMPUTER_DIGITAL_L2076505', 'garble1', 'garble2', 'garble3'};
function triggerCamBug()
	buggingTime = 300;
	if didBug then return; end
	didBug = true;
	
	blip();
	setAlpha('camsCam', 0);
	doSound(garble[getRandomInt(1, 4)], 1, 'chan5');
end

local leaveFuncs = {
	[3] = function() pirateVol = 0.05; setSoundVolume('chan13', pirateVol); end,
	[4] = function() setAlpha('foxyRun', 0); end,
	[10] = function() setKitVol(0.2); setMusVol(0.05); setAlpha('noCam', 0); end
};
function leaveCam(i)
	local a = leaveFuncs[i];
	if a then a(); end
end

local enterFuncs = {
	[3] = function() pirateVol = 0.15; setSoundVolume('chan13', pirateVol); end,
	[4] = function()
		if foxPhase == 3 then
			setAlpha('foxyRun', 1);
			setAlpha('cam4', 0);
			if foxRun then
				foxRun = false;
				playAnim('foxyRun', 'idle', true);
				doSound('run', 1, 'chan16');
			end
			callOnLuas('onFoxyRun');
		end
	end,
	[6] = function() cenFeed(0); end,
	[10] = function()
		setKitVol(0.75);
		setMusVol(0.5);
		setAlpha('noCam', 1); 
	end
};
function enterCam(i)
	local a = enterFuncs[i];
	if a then a(); end
	if cameraBugs[i] > 0 then triggerCamBug(); end
	callOnLuas('onChangeCam', {i});
end

local yellowSound = true;
foxRun = false;
local nameToFrame = { -- FREDDY, BONNIE, CHICA, FOXY
	{ -- 1
		[''] = 0,
		['FREDDY'] = 1,
		['FREDDYBONNIE'] = 2,
		['FREDDYCHICA'] = 3,
		['FREDDYBONNIECHICA'] = 4,
		['FREDDYSPECIAL'] = 5,
		-- ['FREDDYBONNIECHICASPECIAL'] = 6 -- never actually used in game!
	},
	{ -- 2
		[''] = 0,
		['BONNIE1'] = 1,
		['BONNIE2'] = 2,
		['CHICA1'] = 3,
		['CHICA2'] = 4,
		['FREDDY'] = 5
	},
	{ -- 3
		[''] = 0,
		['FOXY0'] = 0,
		['FOXY1'] = 1,
		['FOXY2'] = 2,
		['FOXY3'] = 3,
		['FOXY3SPECIAL'] = 4
	},
	{ -- 4
		[''] = 0,
		['LIT'] = 1,
		['BONNIELIT'] = 2
	},
	{ -- 5
		[''] = 0,
		['BONNIE'] = 1,
		['BONNIEBUG1'] = 2,
		['BONNIEBUG2'] = 3,
		['SPECIAL'] = 4,
		['YELLOW'] = 5
	},
	{ -- 6
		[''] = 0,
		['BONNIE'] = 1,
	},
	{ -- 7
		[''] = 0,
		['CHICA1'] = 1,
		['CHICA2'] = 2,
		['FREDDY'] = 3,
		['SPECIAL1'] = 4,
		['SPECIAL2'] = 5
	},
	{ -- 8
		[''] = 0,
		['CHICA'] = 1,
		['CHICABUG1'] = 2,
		['CHICABUG2'] = 3,
		['FREDDY'] = 8,
		['SPECIAL1'] = 4,
		['SPECIAL2'] = 5,
		['SPECIAL3'] = 6,
		['SPECIAL4'] = 7
	},
	{ -- 9
		[''] = 0,
		['BONNIE'] = 1,
		['BONNIESPECIAL'] = 2,
		['SPECIAL'] = 3
	},
	[11] = {
		[''] = 0,
		['CHICA1'] = 1,
		['CHICA2'] = 2,
		['FREDDY'] = 3
	}
};
local specialAdd = {
	[1] = function(s)
		if s == 'FREDDY' and randPic < 11 then s = s .. 'SPECIAL'; end
		return s;
	end,
	[3] = function(s)
		if s == 'FOXY3' and randPic < 11 then s = s .. 'SPECIAL'; end
		return s;
	end,
	[4] = function(s)
		if foxPhase == 3 then s = '';
		elseif camFlickRand then s = s .. 'LIT'; end
		return s;
	end,
	[5] = function(s)
		if s == 'BONNIE' then
			if camBugRand == 1 then s = s .. 'BUG1';
			elseif camBugRand == 2 then s = s .. 'BUG2'; end
		elseif yellowActive then
			if yellowSound then
				yellowSound = false;
				yellowIn = true;
				doSound('Laugh_Giggle_Girl_1', 1, 'chan27');
			end
			s = 'YELLOW';
		elseif randPic < 2 then s = 'SPECIAL'; end
		return s;
	end,
	[7] = function(s)
		if s == '' and randPic > 98 then s = 'SPECIAL' .. (randPic - 98); end
		return s;
	end,
	[8] = function(s)
		if s == 'CHICA' then
			if camBugRand == 1 then s = s .. 'BUG1';
			elseif camBugRand == 2 then s = s .. 'BUG2'; end
		elseif s == '' and randPic > 96 then s = 'SPECIAL' .. (randPic - 96); end
		return s;
	end,
	[9] = function(s)
		if s == '' then
			if randPic < 6 then s = s .. 'SPECIAL'; end
		elseif randPic < 11 then s = s .. 'SPECIAL'; end
		return s;
	end
};
function updateACam()
	if curCam == 10 then return; end -- no kitchen update
	
	local at = 0;
	local str = '';
	local fr = nil;
	local pr = cameraProps[curCam];
	while fr == nil and at < 7 do
		str = '';
		at = at + 1;
		for i = at, 4 do str = str .. pr[i]; end
		if at < 6 then
			local a = specialAdd[curCam];
			if a then str = a(str); end
		end
		
		fr = nameToFrame[curCam][str];
	end
	if fr == nil then fr = 0; end
	
	setFrame('cam' .. curCam, fr);
end

function setRoomSlot(c, s, r) cameraProps[c][s] = r; end
function setCamBug(f, i)
	if inCams then
		if curCam == f then triggerCamBug();
		elseif curCam == i then triggerCamBug(); end
	else cameraBugs[i] = 10; end
end

local camFollow = {
	phase = 0,
	totTime = 0
};
local camTriggers = {};
for i = 1, 11 do camTriggers[i] = 0; end
function updateCams(t)
	updateCamMove(t);
	if inCams and (curCam ~= 6 and curCam ~= 10) then cenFeed(feedX); end
	
	for i = 1, 11 do
		if cameraBugs[i] > 0 then cameraBugs[i] = cameraBugs[i] - t; end
	end
	
	if buggingTime > 0 then
		buggingTime = buggingTime - t;
		if buggingTime <= 0 then
			didBug = false;
			setAlpha('camsCam', 1);
			updateACam();
		end
	end
end

local camLim = 320;
function updateCamMove(t)
	local moving = (camFollow.phase % 2 == 0);
	camFollow.totTime = camFollow.totTime + t;
	
	if moving then
		local back, x = (camFollow.phase == 2), 0;
		if back then back = -1; x = 320; else back = 1; end
		feedX = ((bound(camFollow.totTime, 0, 320) * back)) + x;
	end
	
	if camFollow.totTime >= camLim then
		camFollow.totTime = 0;
		camFollow.phase = (camFollow.phase + 1) % 4;
		if moving then camLim = 100; else camLim = 320; end
	end
end

function triggerPanel()
	inOffice = panelFlip;
	panelFlip = not panelFlip;
	
	setAlpha('panel', 1);
	playAnim('panel', 'idle', true, not panelFlip);
	
	if panelFlip then doSound('CAMERA_VIDEO_LOA_60105303', 1, 'chan7');
	else doSound('put down', 1, 'chan7'); end
	
	if panelFlip then
		setVis('fan', false);
	else closeCams(); end
end

function panelFin()
	setAlpha('panel', 0);
	canPanel = true;
	
	if panelFlip then initCams(); end
end

function initCams()
	if powerout then
		triggerPanel();
		return;
	end
	
	killYellow();
	
	inCams = true;
	disableLights(true);
	panelDrain = 1;
	updateUsage();
	updateStatic();
	updateACam();
	enterCam(curCam);
	blip();
	setKitVol(0.2);
	
	playAnim('marker' .. curCam, 'sel', true);
	
	setSoundVolume('chan1', 0.1);
	doSound('MiniDV_Tape_Eject_1', 1, 'chan6');
	
	setVis('mainCam', false);
	setVis('camsCam', true);
	setVis('pTopCam', true);
end

function closeCams()
	inCams = false;
	panelDrain = 0;
	updateUsage();
	leaveCam(curCam);
	
	setKitVol(0.1);
	randPic = Random(100) + 1;
	
	if yellowIn then
		yellowSee = true;
		setAlpha('yellowBear', 1);
		triggerItsMe();
	end
	
	stopSound('chan6');
	setSoundVolume('chan1', 0.25);
	
	setVis('fan', true);
	setVis('mainCam', true);
	setVis('camsCam', false);
	setVis('pTopCam', false);
	
	if not gotYou then
		if chicaIn then triggerScare(2);
		elseif bonnieIn then triggerScare(1); end
	end
end

function updateStatic()
	local a = 150 + Random(50) + (staticRand * 15);
	setAlpha('static', clAlph(a));
end

function blip()
	doSound('blip3', 1, 'chan9');
	setAlpha('blip', 1);
	playAnim('blip', 'idle', true);
end

function cenFeed(x) setProperty('camsCam.scroll.x', -22 + x); end

local foxEl = 0;
function otherUpdate(e, t)
	if foxPhase == 0 then
		foxEl = foxEl + e;
		while foxEl >= 4 do
			foxEl = foxEl - 4;
			if Random(30) + 1 == 1 then doSound('pirate song2', pirateVol, 'chan13'); end
		end
	end
	
	if yellowSee then
		yellowLook = yellowLook + t;
		if yellowLook >= 300 then switchState('CreepyEnd'); end
	end
	
	updateVoice(e, t);
end

local totEerie = 0;
function addToEerie(i)
	totEerie = totEerie + i;
	checkEerie();
end

local eerieLevels = {0.3, 0.5, 0.75};
function checkEerie()
	if freddyIn then setSoundVolume('chan18', 1); 
	elseif totEerie == 0 then setSoundVolume('chan18', 0); 
	else setSoundVolume('chan18', eerieLevels[totEerie]); end
end

function updateVoice(e, t)
	if curNight < 4 then return; end
	
	local bonnie = (cameraProps[5][2] == 'BONNIE');
	local chica = (cameraProps[8][3] == 'CHICA');
	if inCams then
		if curCam == 5 then
			if bonnie then
				bugTimeB1 = bugTimeB1 + e;
				while bugTimeB1 >= 0.1 do
					bugTimeB1 = bugTimeB1 - 0.1;
					randRobotVoice(20);
				end
			end
		elseif curCam == 8 then
			if chica then
				bugTimeC1 = bugTimeC1 + e;
				while bugTimeC1 >= 0.1 do
					bugTimeC1 = bugTimeC1 - 0.1;
					randRobotVoice(20);
				end
			end
		else nonCamsAddVoice(e, bonnie, chica); end
	else nonCamsAddVoice(e, bonnie, chica); end
end

function nonCamsAddVoice(e, b, c)
	if b then
		bugTimeB2 = bugTimeB2 + e;
		while bugTimeB2 >= 0.1 do
			bugTimeB2 = bugTimeB2 - 0.1;
			randRobotVoice(5);
		end
	end
	if c then
		bugTimeC2 = bugTimeC2 + e;
		while bugTimeC2 >= 0.1 do
			bugTimeC2 = bugTimeC2 - 0.1;
			randRobotVoice(5);
		end
	end
end

function randRobotVoice(m)
	cornerVol = (1 + (Random(5) * m)) / 100;
	robotVol();
end

function disableLights(t)
	if lastOn ~= '' then clickLight(lastOn, t); end
end

function clickLight(s, i)
	local d = _G[s];
	if not d.stuck then
		d.lightOn = not d.lightOn;
		setAlpha(s, d.lightOn);
		if d.lightOn then
			disableLights(true);
			tryLightVis(s);
			lastOn = s;
			lightDrain = 1;
		else lastOn = ''; lightDrain = 0; setSoundVolume('chan3', 0); end
		if not i then updateUsage(); end
		updateAPanel(d);
	else doSound('error', 1, 'chan12'); end
end

leftSnd = false;
rightSnd = false;
function tryLightVis(s) -- check for sound here
	local a = (Random(10) > 1);
	setVis(s, a);
	setSoundVolume('chan3', a);
	
	if a and _G[s .. 'Snd'] then
		_G[s .. 'Snd'] = false;
		doSound('windowscare', 1, 'chan9');
	end
end

function clickDoor(s)
	local d = _G[s];
	if d.canPress then
		if not d.stuck then doorClicked(d, s);
		else doSound('error', 1, 'chan12'); end
	end
end

function doorClicked(d, s)
	d.clicked = not d.clicked;
	d.canPress = false;
	d.open = false;
	d.closed = false;
	d.drain = 0;
	
	playAnim(s .. 'Door', 'closing', true, not d.clicked);
	doSound('SFXBible_12478', 1, 'chan4');
	
	updateUsage();
	updateAPanel(d);
end

function doorFin(n, r, s)
	if n == 'closing' then
		local d = _G[s];
		d.canPress = true;
		d.closed = d.clicked;
		d.open = not d.clicked;
		
		if powerout and d.closed then doorClicked(d, s); else
			if d.clicked then d.drain = 1; end
			
			playAnim(s .. 'Door', doorFinBool[d.clicked]);
			updateUsage();
		end
	end
end

function stuckDoor(d) _G[d].stuck = true; end

local lastLight = 0;
function updateAPanel(d)
	local str = '';
	if d.clicked then str = 'door'; end
	if d.lightOn then str = str .. 'light'; end
	playAnim(d.side .. 'Button', str);
end

function updateTime()
	curMin = curMin + 1;
	if curMin >= 90 then 
		curMin = 1;
		curHour = (curHour % 12) + 1;
		if not powerout then updateCounterSpr('hour', curHour); end
		callOnLuas('onHour', {curHour});
		
		if curHour == 6 then winNight(); end
	end
end

function winNight()
	gameStopped = true;
	stopGame();
	
	setProperty('winCam.active', true);
	doTweenAlpha('winIn', 'winCam', 1, pl(1.1));
	doSound('chimes 2', 1);
end

function updateUsage()
	local newUse = 1 + left.drain + right.drain + lightDrain + panelDrain;
	if curUsage ~= newUse then
		curUsage = newUse;
		if not powerout then setFrame('usage', curUsage - 1); end
	end
end

local lastPer = 99;
function subPower(i)
	if powerLeft > 0 then
		powerLeft = max(powerLeft - i, 0);
		
		local new = getPower();
		if lastPer ~= new then
			lastPer = new;
			if not powerout then updateCounterSpr('powerLeft', new); end
		end
		
		if powerLeft == 0 and not powerout then onPowerout(); end
	end
end

function onPowerout()
	powerout = true;
	canMute = false;
	
	callOnLuas('triggerPowerout');
	
	killSounds();
	doSound('powerdown', 1, 'chan1');
	doSound('ambience2', 1, 'chan2', true);
	
	if inCams then triggerPanel(); end
	
	for i = 1, 2 do
		local s = sides[i];
		if _G[s].closed then clickDoor(s); end
	end
	
	disableLights();
	
	if scare ~= '' then setAlpha(scare, 0); end
	
	removeLuaSprite('pumpkin');
	removeLuaSprite('lights');
	
	removeLuaSprite('left');
	removeLuaSprite('right');
	removeLuaSprite('office');
	setAlpha('fan', 0);
	
	
	removeLuaSprite('amTxt');
	removeLuaSprite('hour');
	removeLuaSprite('nightTxt');
	removeLuaSprite('night');
	removeLuaSprite('leftTxt');
	removeLuaSprite('powerLeft');
	removeLuaSprite('percentTxt');
	removeLuaSprite('usageTxt');
	removeLuaSprite('usage');
	removeLuaSprite('flip');
	
	setVis('leftButton', false);
	setVis('rightButton', false);
	
	
	setAlpha('out', 1);
	runTimer('fredFace', pl(0.05), 0);
	runTimer('forceFredOut', pl(20));
end

function onStartMus()
	startedMus = true;
	callOnLuas('killFreddy');
	doSound('music box', 1, 'chan30');
	
	runTimer('fredTryEnd', pl(5), 0);
	runTimer('fredForceEnd', pl(20), 0);
end

function startFlicker()
	startedFlicker = true;
	randFredPic = false;
	
	killSounds();
	doSound('Buzz_Fan_Florescent2', 0.5, 'chan2');
	tryFlicker();
	
	runTimer('completeDark', pl(2 / 6));
end

function tryFlicker()
	if flickering then
		local r = getRandomBool();
		if r then playAnim('out', 'idle'); setSoundVolume('chan2', 0.5);
		else setSoundVolume('chan2', 0); end
		setVis('out', r);
	end
end

function getPower() return floor(powerLeft / 10); end

function triggerItsMe()
	if not itsMe then
		itsMe = true;
		tryMeVis();
		robotVol();
		runTimer('stopMe', pl(10 / 6));
	end
end

function setKitVol(v)
	kitchenVol = v;
	updateKitchenVol();
end

function updateKitchenVol()
	local v = kitchenVol;
	if cameraProps[10][3] == '' then v = 0; end
	setSoundVolume('chan10', v);
end

function setMusVol(v)
	musicVol = v;
	updateMusicVol();
end

function updateMusicVol()
	local v = musicVol;
	if cameraProps[10][1] == '' then v = 0; end
	setSoundVolume('chan22', v);
end

function robotVol()
	if itsMe then setSoundVolume('chan21', 1); else
		if curNight >= 4 and animsInCorner() then
			setSoundVolume('chan21', cornerVol);
		else setSoundVolume('chan21', 0); end
	end
end

function animsInCorner() return (cameraProps[5][2] == 'BONNIE' or cameraProps[8][3] == 'CHICA'); end

local kitSnds = {'OVEN-DRA_1_GEN-HDF18119', 'OVEN-DRA_2_GEN-HDF18120', 'OVEN-DRA_7_GEN-HDF18121', 'OVEN-DRA_7_GEN-HDF18121', 'OVEN-DRAWE_GEN-HDF18122'};
function kitchenSounds() doSound(kitSnds[getRandomInt(1, 5)], kitchenVol, 'chan10'); end
function musicSound() doSound('music box', musicVol, 'chan22'); end

local vocals = {'06', '08', '12', '14'};
function randVocals()
	if not inCams then return; end
	local r = getRandomInt(1, 4);
	local a = vocals[r];
	if a then doSound('Vocals_Breaths_S_359720' .. a, 0.5, 'chan14'); end
	vocals[r] = nil;
end


--[[
	Foxy gets first picks
	then chica
	then bonnie
	then freddy
]]
local scares = {'bonnie', 'chica', 'foxy', 'freddy'};
local scareFunc = {
	[1] = function()
		runTimer('screamSnd', pl(9 / 60));
		runTimer('toGameover', pl(39 / 60));
		
		xCam = 800;
		setProperty('mainCam.scroll.x', 800 - 640);
	end,
	[2] = function()
		runTimer('screamSnd', pl(9 / 60));
		runTimer('toGameover', pl(39 / 60));
		
		xCam = 800;
		setProperty('mainCam.scroll.x', 800 - 640);
	end,
	[3] = function()
		finFunc('foxyScare', 'scareFin');
		doSound('XSCREAM', 1, 'chan9');
		killPanel();
	end,
	[4] = function()
		finFunc('freddyScare', 'scareFin');
		frameFunc('freddyScare', 'fredFrame');
		killPanel();
	end
};
function triggerScare(i)
	if gotYou or powerout then return; end
	gotYou = true;
	
	if inCams then triggerPanel(); end
	disableLights();
	
	local t = scares[i] .. 'Scare';
	setAlpha(t, 1);
	playAnim(t, 'scare', true);
	scareFunc[i]();
	scare = t;
	
	if i ~= 3 then
		removeLuaSprite('pumpkin');
		removeLuaSprite('lights');
		setAlpha('fan', 0);
		killYellow();
	end
	
	setAlpha('left', 0);
	setAlpha('right', 0);
	setAlpha('leftDoor', 0);
	setAlpha('rightDoor', 0);
	
	removeLuaSprite('office');
	
	setVis('leftButton', false);
	setVis('rightButton', false);
end

function killPanel()
	if getAlpha('panel') == 1 and panelFlip then 
		setActive('panel', false);
		setVis('panel', 0);
	end
end

function scareFin()
	if powerout then return; end
	switchState('died');
end

local fredScream = true;
function fredFrame(n, f)
	if powerout then return; end
	
	if fredScream and f >= 7 then
		fredScream = false;
		doSound('XSCREAM', 1, 'chan9');
	end
end

function tryYellow()
	if yellowSpawn and Random(32768) == 1 then -- due to Clickteam fusion limitations, the number overflows at 65535 and also has some devitation due to innacuracy
		yellowSpawn = false;
		yellowActive = true;
		
		if inCams and curCam == 5 and cameraProps[5][2] ~= 'BONNIE' then updateACam(); end
	end
end

function killYellow()
	if yellowSee then
		yellowActive = false;
		yellowSee = false;
		removeLuaSprite('yellowBear');
	end
end

local lastBug = 0;
local timers = {
	['hideStuff'] = function()
		setAlpha('fredOutCache', 0);
		
		setAlpha('bonnieScare', 0);
		setAlpha('chicaScare', 0);
		setAlpha('foxyScare', 0);
		setAlpha('freddyScare', 0);
		
		setAlpha('winCam', 0);
		setAlpha('5Txt', 0);
		setAlpha('6Txt', 0);
		setAlpha('amWTxt', 0);
		
		setAlpha('foxyRun', 0);
		
		setAlpha('meCam', 1);
		setVis('meCam', false);
		
		setAlpha('pTopCam', 1);
		setVis('pTopCam', false);
		
		setAlpha('camsCam', 1);
		setVis('camsCam', false);
		
		setAlpha('yellowBear', 0);
		setAlpha('out', 0);
		
		
		setAlpha('left', 0);
		setVis('left', false);
		
		setAlpha('right', 0);
		setVis('right', false);
		
		setAlpha('noCam', 0);
		if curNight < 6 then setAlpha('mute', 0); end
		
		for i = 1, 11 do
			if i ~= 10 then
				if i == curCam then setAlpha('cam' .. i, 1);
				else setAlpha('cam' .. i, 0); end
			end
		end
	end,
	
	['randBug'] = function()
		local r = getRandomInt(1, 30);
		if r < 25 then camBugRand = 0;
		elseif r < 29 then camBugRand = 1;
		else camBugRand = 2; end
		
		if lastBug ~= camBugRand then
			lastBug = camBugRand;
			if inCams and (curCam == 5 or curCam == 8) then updateACam(); end
		end
	end,
	['sec'] = function()
		if Random(1000) == 1 then triggerItsMe(); end
		subPower(curUsage);
		staticRand = Random(3);
		
		tryYellow();
		updateTime();
	end,
	['fiv'] = function()
		if Random(30) == 0 then doSound('circus', 0.05, 'chan15'); end
		if powerout and not startedMus and Random(5) == 0 then onStartMus(); end
		
		if bonnieIn and Random(3) == 0 then randVocals(); end
		if chicaIn and Random(3) == 0 then randVocals(); end
	end,
	['ten'] = function()
		if Random(30) == 0 then doSound('DOOR_POUNDING_ME_D0291401', (10 + Random(40)) / 100, 'chan20'); end
	end,
	['takePower'] = function() subPower(1); end,
	['stopMe'] = function()
		itsMe = false;
		setVis('meCam', false);
		robotVol();
	end,
	
	['forceFredOut'] = function()
		if not startedMus then onStartMus(); end
	end,
	
	['fredFace'] = function()
		if startedMus and randFredPic then
			if Random(4) == 0 then playAnim('out', 'freddy');
			else playAnim('out', 'idle'); end
		end
	end,
	
	['fredTryEnd'] = function()
		if Random(5) == 0 and not startedFlicker then
			cancelTimer('fredForceEnd');
			startFlicker();
		end
	end,
	['fredForceEnd'] = function()
		if not startedFlicker then
			cancelTimer('fredTryEnd');
			startFlicker();
		end
	end,
	
	['completeDark'] = function()
		flickering = false;
		removeLuaSprite('out');
		setVis('topCam', false);
		
		killSounds();
		runTimer('tryOutScare', pl(2), 0);
		runTimer('forceOutScare', pl(20));
	end,
	['tryOutScare'] = function()
		if Random(5) == 0 then switchState('Freddy'); end
	end,
	['forceOutScare'] = function() switchState('Freddy'); end,
	
	['screamSnd'] = function() doSound('XSCREAM', 1, 'chan9'); end,
	['toGameover'] = function() if not powerout then switchState('died'); end end,
	
	['showMute'] = function() setAlpha('mute', 1); end,
	['hideMute'] = function() setAlpha('mute', 0); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {['winIn'] = function() switchState('NextDay'); end};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end

function cacheSounds()
	precacheSound('PartyFavorraspyPart_AC01__3');
	
	precacheSound('SFXBible_12478');
	precacheSound('error');
	
	precacheSound('windowscare');
	
	precacheSound('CAMERA_VIDEO_LOA_60105303');
	precacheSound('put down');
	precacheSound('MiniDV_Tape_Eject_1');
	precacheSound('blip3');
	
	precacheSound('COMPUTER_DIGITAL_L2076505');
	precacheSound('garble1');
	precacheSound('garble2');
	precacheSound('garble3');
	
	precacheSound('circus');
	precacheSound('pirate song2');
	precacheSound('DOOR_POUNDING_ME_D0291401');
	
	precacheSound('deep steps');
	
	precacheSound('run');
	precacheSound('knock2');
	
	precacheSound('OVEN-DRA_1_GEN-HDF18119');
	precacheSound('OVEN-DRA_2_GEN-HDF18120');
	precacheSound('OVEN-DRA_7_GEN-HDF18121');
	precacheSound('OVEN-DRAWE_GEN-HDF18122');
	
	precacheSound('powerdown');
	precacheSound('ambience2');
	precacheSound('music box');
	
	precacheSound('Vocals_Breaths_S_35972006');
	precacheSound('Vocals_Breaths_S_35972008');
	precacheSound('Vocals_Breaths_S_35972012');
	precacheSound('Vocals_Breaths_S_35972014');
	
	precacheSound('running fast3');
	
	precacheSound('whispering2');
	precacheSound('Laugh_Giggle_Girl_1d');
	precacheSound('Laugh_Giggle_Girl_2d');
	precacheSound('Laugh_Giggle_Girl_8d');
	
	precacheSound('Laugh_Giggle_Girl_1');
	precacheSound('XSCREAM');
	precacheSound('XSCREAM2');
	
	precacheSound('static');
	
	precacheSound('chimes 2');
	precacheSound('CROWD_SMALL_CHIL_EC049202');
end

function varMain(v) return _G[v]; end
function varSetMain(v, n) _G[v] = n; end
