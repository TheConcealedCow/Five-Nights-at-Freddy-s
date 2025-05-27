local r = {
	ai = 0,
	
	pic = 1,
	cam = 1,
	dir = 1,
	
	muted = false,
	
	inKitchen = false,
	kitchenTime = 0,
	
	hitZone = false,
	lastZone = false,
	camZones = {[7] = true, [8] = true, [50] = true},
	
	camsTime = 0,
	
	moveTree = {
		[1] = {2, 2},
		[2] = {11, 10},
		[7] = {2, 8},
		[8] = {7, 50},
		[10] = {11, 7},
		[11] = {10, 7}
	},
	stepVol = {
		[1] = {0.1, 0.1},
		[2] = {0.1, 0.1},
		[7] = {0.3, 0.3},
		[8] = {0.4, 0.4},
		[10] = {0.1, 0.2},
		[11] = {0.2, 0.2},
		[50] = {0.3, 0.3}
	},
	
	nightAi = {
		[2] = 1,
		[3] = 5,
		[4] = 4,
		[5] = 7,
		[6] = 12
	}
};
function onCreate()
	luaDebugMode = true;
	runMainFunc('setRoomSlot', {r.cam, 3, 'CHICA'});
	loadAI();
end

local randCams = {[2] = true, [7] = true, [11] = true};
function moveTo(i)
	local was = r.cam;
	if was < 50 then runMainFunc('setRoomSlot', {was, 3, ''}); end
	if was == 8 then runMainFunc('robotVol'); end
	
	if i == 50 then 
		playAnim('right', 'chica'); 
		runMainFunc('disableLights');
		setMainVar('rightSnd', true);
	else
		local s = 'CHICA';
		if randCams[i] then s = 'CHICA' .. r.pic; end
		runMainFunc('setRoomSlot', {i, 3, s});
	end
	r.cam = i;
	
	if r.cam == 10 or was == 10 then runMainFunc('updateKitchenVol'); end
	
	checkZone();
	runMainFunc('setCamBug', {was, i});
end

function checkZone()
	r.hitZone = (r.camZones[i] == true);
	if r.lastZone ~= r.hitZone then
		r.lastZone = r.hitZone;
		if r.hitZone then runMainFunc('addToEerie', {1});
		else runMainFunc('addToEerie', {-1}); end
	end
end

function updateFunc(e, t, _, n, c)
	if getVar('moveWho') == 2 then
		if r.cam == 50 then tryIn();
		elseif r.cam < 50 then
			makeMove(n, c);
			setVar('moveWho', 0);
		end
	end
	
	if r.cam == 10 then
		r.kitchenTime = r.kitchenTime + e;
		while r.kitchenTime >= 4 do
			r.kitchenTime = r.kitchenTime - 4;
			runMainFunc('kitchenSounds');
		end
	end
	
	if n and r.cam == 100 then
		r.camsTime = r.camsTime + e;
		if r.camsTime >= 30 then runMainFunc('triggerPanel'); end
	end
end

function makeMove(n, c)
	local prev = r.cam;
	local m = r.moveTree[r.cam][r.dir];
	r.pic = getRandomInt(1, 2);
	moveTo(m);
	
	if n and m == c then
		r.muted = true;
		setSoundVolume('chan8', 0);
	else
		r.muted = false;
		doSound('deep steps', r.stepVol[prev][r.dir], 'chan8');
	end
end

function moveIn()
	leaveLight();
	setVar('moveWho', 0);
	setMainVar('chicaIn', true);
	runMainFunc('stuckDoor', {'right'});
	r.cam = 100;
	checkZone();
end

function goBack()
	leaveLight();
	setVar('moveWho', 0);
	moveTo(7);
end

function leaveLight()
	playAnim('right', 'idle');
	runMainFunc('disableLights');
	setMainVar('rightSnd', false);
end

function tryIn()
	local d = getMainVar('right');
	if d.open then moveIn();
	elseif d.closed then goBack(); end
end

function onChangeCam(i)
	r.muted = (r.cam == i);
	if r.muted then setSoundVolume('chan8', 0); end
end

local sv = 'FNAF1';
function loadAI()
	local n = getMainVar('curNight');
	if n == 7 then r.ai = getDataFromSave(sv, 'chicaAI', 0); else
		local a = r.nightAi[n];
		if a then r.ai = a; end
	end
end

function onHour(h)
	if h == 3 or h == 4 then r.ai = r.ai + 1; end
end

local timers = {
	['moveChica'] = function()
		if getRandomInt(1, 20) <= r.ai then setMainVar('chiMove', true); end
	end,
	['sec'] = function() r.dir = getRandomInt(1, 2); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end
