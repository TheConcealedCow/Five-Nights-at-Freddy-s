local r = {
	ai = 0,
	phase = 0,
	
	moveTime = 0,
	stallTime = 0,
	hits = 0,
	
	running = false,
	runTime = 0,
	
	waitForce = 0,
	
	nightAi = {
		[2] = 1,
		[3] = 2,
		[4] = 6,
		[5] = 5,
		[6] = 6
	}
};
function onCreate() 
	luaDebugMode = true;
	runMainFunc('setRoomSlot', {3, 4, 'FOXY' .. r.phase});
	loadAI();
end

local lastCams = false;
function updateFunc(e, t, _, n, c)
	if lastCams ~= n then
		lastCams = n;
		if not n then r.stallTime = 50 + Random(1000); end
	end
	
	if c ~= 3 and r.phase < 3 then
		r.moveTime = r.moveTime + e;
		while r.moveTime >= 5.01 do
			r.moveTime = r.moveTime - 5.01;
			if not n then addPhase(); end
		end
	end
	
	if r.running then
		r.runTime = r.runTime + t;
		if r.runTime > 100 then
			r.running = false;
			r.phase = 5;
		end
	end
	
	if r.phase == 3 then
		r.waitForce = r.waitForce + t;
		if r.waitForce > 1500 then
			r.waitForce = 0;
			r.phase = 5;
		end
	end
	
	if r.phase == 5 then
		local d = getMainVar('left');
		if d.open then getIn();
		elseif d.closed then goBack(n, c); end
	end
	
	if not n and r.stallTime > 0 then r.stallTime = r.stallTime - t; end
end

function addPhase()
	if getRandomInt(1, 20) <= r.ai and r.stallTime <= 0 then
		r.phase = r.phase + 1;
		setMainVar('foxPhase', r.phase);
		runMainFunc('setRoomSlot', {3, 4, 'FOXY' .. r.phase});
		if r.phase == 3 then setMainVar('foxRun', true); end
	end
end

function onFoxyRun()
	r.phase = 4;
	r.running = true;
	r.runTime = 0;
end

function getIn()
	r.phase = 6;
	runMainFunc('triggerScare', {3});
end

function goBack(n, c)
	r.phase = Random(2);
	runMainFunc('setRoomSlot', {3, 4, 'FOXY' .. r.phase});
	setMainVar('foxPhase', r.phase);
	
	doSound('knock2', 1, 'chan9');
	runMainFunc('disableLights');
	runMainFunc('subPower', {10 + (50 * r.hits)});
	r.hits = r.hits + 1;
	
	if getMainVar('inCams') then runMainFunc('triggerPanel'); end
end

local sv = 'FNAF1';
function loadAI()
	local n = getMainVar('curNight');
	if n == 7 then r.ai = getDataFromSave(sv, 'foxyAI', 0); else
		local a = r.nightAi[n];
		if a then r.ai = a; end
	end
end

function onHour(h)
	if h == 3 or h == 4 then r.ai = r.ai + 1; end
end