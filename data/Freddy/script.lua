function create()
	runHaxeCode([[
		import psychlua.LuaUtils;
		
		createCallback('finFunc', function(o, f, ?p) {
			var obj = LuaUtils.getObjectDirectly(o);
			obj.animation.finishCallback = function(n) { 
				parentLua.call(f, [n, obj.animation.curAnim.reversed, p]); 
			}
		});
	]]);
	
	makeAnimatedLuaSprite('static', 'gameAssets/global/static');
	addAnimationByPrefix('static', 'idle', 'Idle', 59.4);
	addLuaSprite('static');
	setAlpha('static', 0.00001);
	
	makeAnimatedLuaSprite('blip', 'gameAssets/global/blip');
	addAnimationByPrefix('blip', 'idle', 'Idle', 45, false);
	addLuaSprite('blip');
	setAlpha('blip', 0.00001);
	
	
	makeAnimatedLuaSprite('freddy', 'gameAssets/freddy/freddy');
	addAnimationByPrefix('freddy', 'scare', 'Scare', 36, false);
	addLuaSprite('freddy');
	finFunc('freddy', 'fredFin');
	
	killSounds();
	doSound('XSCREAM', 1, 'chan1');
	precacheSound('static');
	
	runTimer('toGameover', pl(12));
end

function fredFin()
	stopSound('chan1');
	doSound('static', 1, 'chan1');
	
	removeLuaSprite('freddy');
	setAlpha('static', 1);
	
	setAlpha('blip', 1);
	playAnim('blip', 'idle', true);
	hideOnFin('blip');
end

local timers = {
	['toGameover'] = function()
		stopGame();
		
		makeLuaSprite('bg', 'gameAssets/died/bg');
		addLuaSprite('bg');
		setAlpha('bg', 0);
		doTweenAlpha('bgIn', 'bg', 1, pl(1.1));
	end,
	['nextScreen'] = function()
		if Random(10000) == 0 then switchState('CreepyEnd');
		else switchState('Title'); end
	end
};
function onTimerCompleted(t)
	local a = timers[t];
	if a then a(); end
end

local tweens = {
	['bgIn'] = function() runTimer('nextScreen', pl(10)); end
};
function onTweenCompleted(t)
	local a = tweens[t];
	if a then a(); end
end
