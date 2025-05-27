local r = {
	ai = 0,
	
	pic = 1,
	cam = 1,
	dir = 1,
	
	muted = false,
	
	hitZone = false,
	lastZone = false,
	camZones = {[4] = true, [5] = true, [6] = true, [50] = true},
	
	camsTime = 0,
	
	moveTree = {
		[1] = {9, 2},
		[2] = {9, 4},
		[4] = {6, 5},
		[5] = {6, 50},
		[6] = {50, 4},
		[9] = {2, 4},
		[50] = {100, 100}
	},
	stepVol = {
		[1] = 0.1,
		[2] = 0.2,
		[4] = 0.3,
		[5] = 0.4,
		[6] = 0.3,
		[9] = 0.1,
		[50] = 0.3
	},
	
	nightAi = {
		[2] = 3,
		[3] = 0,
		[4] = 2,
		[5] = 5,
		[6] = 10
	}
};
function onCreate()
	luaDebugMode = true;
	runMainFunc('setRoomSlot', {r.cam, 2, 'BONNIE'});
	loadAI();
end

function moveTo(i)
	local was = r.cam;
	if was < 50 then runMainFunc('setRoomSlot', {was, 2, ''}); end
	if was == 5 then runMainFunc('robotVol'); end
	
	if i == 50 then 
		playAnim('left', 'bonnie'); 
		runMainFunc('disableLights'); 
		setMainVar('leftSnd', true);
	else
		local s = 'BONNIE';
		if i == 2 then s = 'BONNIE' .. r.pic; end
		runMainFunc('setRoomSlot', {i, 2, s});
	end
	r.cam = i;
	
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
	if getVar('moveWho') == 1 then
		if r.cam == 50 then tryIn();
		elseif r.cam < 50 then
			makeMove();
			setVar('moveWho', 0);
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
		doSound('deep steps', r.stepVol[prev], 'chan8');
	end
end

function moveIn()
	leaveLight();
	setVar('moveWho', 0);
	setMainVar('bonnieIn', {true});
	runMainFunc('stuckDoor', {'left'});
	r.cam = 100;
	checkZone();
end

function goBack()
	leaveLight();
	setVar('moveWho', 0);
	moveTo(2);
end

function leaveLight()
	playAnim('left', 'idle');
	runMainFunc('disableLights');
	setMainVar('leftSnd', false);
end

function tryIn()
	local d = getMainVar('left');
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
	if n == 7 then r.ai = getDataFromSave(sv, 'bonnieAI', 0); else
		local a = r.nightAi[n];
		if a then r.ai = a; end
	end
end

function onHour(h)
	if h >= 2 and h <= 4 then r.ai = r.ai + 1; end
end

local timers = {
	['moveBonnie'] = function()
		if getRandomInt(1, 20) <= r.ai then setMainVar('bonMove', true); end
	end,
	['sec'] = function() r.dir = getRandomInt(1, 2); end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end
