local r = {
	ai = 0,
	
	cam = 1,
	
	gotMove = false,
	moveTime = 0,
	maxMove = 0,
	
	gotIn = false,
	scareTime = 0,
	
	kitTime = 0,
	
	makingMove = false,
	extraCheck = {
		[1] = function()
			local p = getMainVar('cameraProps')[1];
			return (p[2] == '' and p[3] == '');
		end,
		[7] = function() return not getMainVar('right').lightOn; end,
		[8] = function()
			fredCheckOffice();
			return false;
		end
	},
	moveTree = {
		[1] = 2,
		[2] = 11,
		[7] = 8,
		[8] = 100,
		[10] = 7,
		[11] = 10,
		[100] = 100
	},
	stepVol = {
		[1] = {0.15, 0.3},
		[2] = {0.2, 0.35},
		[7] = {0.6, 0.75},
		[8] = {0.6, 0.75}, -- 0.8, 1
		[10] = {0.4, 0.6},
		[11] = {0.3, 0.4},
	},
	
	nightAi = {
		[3] = 1,
		[5] = 3,
		[6] = 4
	}
};
function onCreate()
	luaDebugMode = true;
	runMainFunc('setRoomSlot', {1, 1, 'FREDDY'});
	runTimer('freddyMove', pl(3.02), 0);
	loadAI();
	r.maxMove = 1000 - (r.ai * 100);
end

function moveTo(i)
	local was = r.cam;
	runMainFunc('setRoomSlot', {was, 1, ''});
	r.cam = i;
	if i < 100 then runMainFunc('setRoomSlot', {i, 1, 'FREDDY'}); end
	if i == 10 then runMainFunc('musicSound'); else setSoundVolume('chan22', 0); end
end

function updateFunc(e, t, _, n, c)
	if r.gotMove then
		r.moveTime = r.moveTime + t;
		if r.moveTime >= r.maxMove and not n then
			r.gotMove = false;
			r.makingMove = true;
			r.moveTime = 0;
		end
	end
	
	if r.cam == c then r.moveTime = 0; end
	if r.cam == 10 then
		r.kitTime = r.kitTime + e;
		while r.kitTime >= 300 do
			r.kitTime = r.kitTime - 300;
			runMainFunc('musicSound');
		end
	end
	
	if r.makingMove then
		local ex = r.extraCheck[r.cam];
		if not ex or ex() then
			r.makingMove = false;
			makeMove();
		end
	end
	
	if r.gotIn and not n then
		r.scareTime = r.scareTime + e;
		while r.scareTime >= 1 do
			r.scareTime = r.scareTime - 1;
			if Random(4) == 1 then runMainFunc('triggerScare', {4}); end
		end
	end
end

function makeMove()
	local to = r.moveTree[r.cam];
	if to < 100 then
		local vol = r.stepVol[r.cam];
		fredNoise(vol[1], vol[2]);
		moveTo(to);
	end
end

local laughs = {'Laugh_Giggle_Girl_1d', 'Laugh_Giggle_Girl_2d', 'Laugh_Giggle_Girl_8d'};
function fredNoise(a, b)
	doSound(laughs[getRandomInt(1, 3)], a, 'chan16');
	doSound('running fast3', b, 'chan24');
end

function fredCheckOffice()
	local c = getMainVar('curCam');
	if getMainVar('inCams') and c ~= 8 then
		local d = getMainVar('right');
		if d.open then
			r.makingMove = false;
			fredNoise(0.8, 1);
			moveTo(100);
			moveIn();
		elseif c ~= 7 and d.closed then
			r.makingMove = false;
			fredNoise(0.6, 0.75);
			moveTo(7);
		end
	end		
end

function moveIn()
	setMainVar('freddyIn', true);
	runMainFunc('checkEerie');
	doSound('whispering2', 1, 'chan25');
	r.gotIn = true;
end

function killFreddy()
	r.ai = 0;
	r.moveTime = 0;
	r.gotMove = false;
	r.makingMove = false;
	r.gotIn = false;
end

local sv = 'FNAF1';
function loadAI()
	local n = getMainVar('curNight');
	if n == 7 then r.ai = getDataFromSave(sv, 'freddyAI', 0);
	elseif n == 4 then r.ai = 1 + Random(2);
	else
		local a = r.nightAi[n];
		if a then r.ai = a; end
	end
end

local timers = {
	['freddyMove'] = function()
		if not getMainVar('inCams') and getRandomInt(1, 20) <= r.ai then r.gotMove = true; r.makingMove = false; end
	end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end
