import psychlua.LuaUtils; // this whole script was rudy's doing, i just removed some parts that made .hx scripts load to commit to the bit
import backend.Paths;
import lime.app.Application;
import lime.graphics.Image;
import backend.DiscordClient;
import openfl.Lib;
import backend.Mods;
import flixel.util.FlxSave;
import backend.CoolUtil;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import haxe.format.JsonParser;
import sys.FileSystem;
import llua.Lua_helper;
import haxe.ds.StringMap;
import flixel.FlxCamera;
import psychlua.FunkinLua;

final autoPause:Bool = ClientPrefs.data.autoPause;

FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;

final saveName:String = 'FNAF1';
final title:String = "Five Nights at Freddy's";

final trueSave:String = 'save_' + saveName;

var debugCam;
var moverObj:FlxSprite = new FlxSprite();

final luaFunctions:StringMap<Dynamic> = [ // Rudy cried here
	'switchState' => function(name) nextState(name)
	'exitGame' => function() exit()
	
	'killSounds' => function() killSounds()
	'stopAnims' => function() stopAnims()
	'stopTmrTwn' => function() stopTmrTwn()
	'stopGame' => function() stopGame()
	
	'bound' => function(x, a, b) return FlxMath.bound(x, a, b)
	'wrap' => function(x, a, b) return FlxMath.wrap(x, a, b)
	'lerp' => function(x, y, a) return FlxMath.lerp(x, y, a)
	
	'clAlph' => function(a) return 1. - (a / 255.)
	
	'Random' => function(n) return FlxG.random.int(1, n) - 1
	'pl' => function(n) return n / game.playbackRate
	
	'mouseOverlaps' => function(o, ?c) {
		var cam;
		if (c != null) cam = getVar(c);
		else cam = debugCam;
		
		return FlxG.mouse.overlaps(LuaUtils.getObjectDirectly(o, false), cam);
	},
	
	'setCam' => function(o, ?c) {
		c ??= 'mainCam';
		var cam = getVar(c);
		LuaUtils.getObjectDirectly(o).camera = cam;
	},
	
	'camScroll' => function(?c) {
		c ??= 'mainCam';
		var cam = getVar(c).scroll;
		return [cam.x, cam.y];
	},
	
	'setScroll' => function(?c, x, y) {
		var o = getVar(c);
		o ??= FlxG.camera;
		o.scroll.set(x, y);
	},
	
	'setBounds' => function(w, h) {
		FlxG.worldBounds.width = w + 20;
		FlxG.worldBounds.height = h + 20;
	},
	
	'camMouseX' => function() return FlxG.mouse.getScreenPosition(debugCam).x
	'camMouseY' => function() return FlxG.mouse.getScreenPosition(debugCam).y
	
	'getX' => function(o) return LuaUtils.getObjectDirectly(o).x
	'getY' => function(o) return LuaUtils.getObjectDirectly(o).y
	
	'setX' => function(o, x) LuaUtils.getObjectDirectly(o).x = x
	'setY' => function(o, y) LuaUtils.getObjectDirectly(o).y = y
	
	'getWidth' => function(o) return LuaUtils.getObjectDirectly(o).width
	'getHeight' => function(o) return LuaUtils.getObjectDirectly(o).height
	
	'addX' => function(o, x) {
		var obj = LuaUtils.getObjectDirectly(o);
		obj.x += x;
		obj.last.x = obj.x;
	},
	'addY' => function(o, y) {
		var obj = LuaUtils.getObjectDirectly(o);
		obj.y += y;
		obj.last.y = obj.y;
	},
	
	'setPos' => function(o, x, y) {
		var obj = LuaUtils.getObjectDirectly(o);
		if (obj != null) obj.setPosition(x, y); obj.last.set(x, y);
	},
	
	'getPos' => function(o) {
		var obj = LuaUtils.getObjectDirectly(o);
		return [obj.x, obj.y];
	},
	
	'setExists' => function(o, e) LuaUtils.getObjectDirectly(o).exists = e
	'setActive' => function(o, a) LuaUtils.getObjectDirectly(o).active = a
	
	'setAlpha' => function(o, a) {
		var obj = LuaUtils.getObjectDirectly(o);
		if (obj != null) obj.alpha = a;
	},
	'getAlpha' => function(o) return LuaUtils.getObjectDirectly(o).alpha
	
	'setColor' => function(o, c) LuaUtils.getObjectDirectly(o).color = c
	
	'getVis' => function(o) return LuaUtils.getObjectDirectly(o).visible
	'setVis' => function(o, v) LuaUtils.getObjectDirectly(o).visible = v
	
	'setFlipX' => function(o, x) LuaUtils.getObjectDirectly(o).flipX = x
	'setAnimFlipX' => function(o, a, x) LuaUtils.getObjectDirectly(o).animation.getByName(a).flipX = x
	
	'setFrame' => function(o, f) LuaUtils.getObjectDirectly(o).animation.curAnim.curFrame = f
	'getFrame' => function(o) return LuaUtils.getObjectDirectly(o).animation.curAnim.curFrame
	
	'addToOffsets' => function(o, x, y) {
		var obj = LuaUtils.getObjectDirectly(o, false).offset;
		obj.x += x;
		obj.y += y;
	},
	
	'hideOnFin' => function(o) {
		var obj = LuaUtils.getObjectDirectly(o, false);
		obj.animation.finishCallback = function() { obj.alpha = 0; }
	},
	
	'doSound' => function(s, ?v, ?t, ?l) {
		if (s == null || s.length == 0) return;
		
		v ??= 1;
		l ??= false;
		
		var so = FlxG.sound.load(Paths.sound(s), v, l, null, true, false, null, function() {
			if (t != null && !l) {
				var realSnd = 'sound_' + t;
				var s = game.variables.get(realSnd);
				if (s != null) game.variables.remove(realSnd);
				
				game.callOnLuas('onSoundFinished', [t]);
			}
		});
		so.pitch = game.playbackRate;
		so.persist = true;
		if (t != null) {
			var realSnd = 'sound_' + t;
			if (game.variables.exists(realSnd)) game.variables.get(realSnd).stop();
			game.variables.set(realSnd, so);
		}
		so.play();
	}
];

function onCreate() {}

function onCreatePost() {
	game.inCutscene = true;
	game.canPause = false;
	
	// kills every object in playstate so that the draw and update calls are reduced
	for (obj in game.members) {
		obj.active = false;
		obj.alive = false;
		obj.exists = false;
	}
	
	FlxG.autoPause = false;
	FlxG.mouse.visible = true;
	FlxG.mouse.useSystemCursor = true;
	
	// in case you wanna add your own event listeners for key pressing
	FlxG.stage.removeEventListener("keyDown", game.onKeyPress);
	FlxG.stage.removeEventListener("keyUp", game.onKeyRelease);
	
	// would check if the image i want to change to is different than the one already as the icon but
	// you can't grab the application's icon image to my knowledge
	
	// common lime L :sob:
	//final img:Image = Image.fromFile(Paths.modFolders('images/fnafIcon.png'));
	// Application.current.window.setIcon(img);
	
	// resets the game to have only one camera
	FlxG.cameras.reset();
	FlxG.camera.active = true;
	FlxG.camera.bgColor = 0xFF000000;
	
	game.luaDebugGroup.revive();
	game.luaDebugGroup.active = true;
	
	FlxG.worldBounds.x = -20;
	FlxG.worldBounds.y = -20;
	
	// initializes the main save
	if (!game.variables.exists(trueSave)) {
		final save:FlxSave = new FlxSave();
		save.bind(saveName, CoolUtil.getSavePath() + '/conCowPorts');
		game.variables.set(trueSave, save);
	}
	
	//if (Lib.application.window.title != title) Lib.application.window.title = title;
	
	for (func in luaFunctions.keys()) createGlobalCallback(func, luaFunctions.get(func));
	
	callStateFunction('create');
	
	debugCam = FlxG.cameras.add(new FlxCamera(), false);
	debugCam.bgColor = 0x00000000;
	game.luaDebugGroup.cameras = [debugCam];
}

function nextState(name:String) {
	game.variables.get(trueSave).flush();
	
	PlayState.SONG = new JsonParser('{
		"notes": [],
		"events": [],
		"song": "' + name + '",
		"needsVoices": false
	}').doParse();
	
	FlxG.resetState();
}

function onUpdate(elapsed:Float) if (FlxG.keys.justPressed.ESCAPE) exit();

function exit() {
	killSounds();
	game.variables.get(trueSave).flush();
	FlxG.autoPause = autoPause;
	FlxTransitionableState.skipNextTransIn = false;
	
	//Application.current.window.setIcon(Image.fromFile(Paths.modFolders('images/fnfIcon.png')));
	// Lib.application.window.title = "Friday Night Funkin': Psych Engine";
	FlxG.mouse.visible = false;
	
	Mods.loadTopMod();
	FlxG.switchState(new states.FreeplayState());
	DiscordClient.resetClientID();
	FlxG.sound.playMusic(Paths.music('freakyMenu'));
	game.transitioning = true;
}

function stopGame() { // copy pasted this part from Rudy!!
	stopTmrTwn();
	stopAnims();
	killSounds();
}

function stopTmrTwn() {
	FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.active = false);
	FlxTween.globalManager.forEach(function(twn:FlxTween) twn.active = false);
}

function stopAnims() for (obj in game.members) if (Std.isOfType(obj, FlxSprite) && obj.active) obj.active = false;

function killSounds() {
	// manually destroying all of the sounds cuz `FlxG.sound.destroy(true);` crashes the game
	while (FlxG.sound.list.members.length > 0) {
		final sound:FlxSound = FlxG.sound.list.members[FlxG.sound.list.members.length - 1];
		
		if (sound == null) {
			FlxG.sound.list.members.remove(sound);
			continue;
		}
		
		sound.stop();
		FlxG.sound.list.members.pop();
	}
}

function callStateFunction(name:String, ?args:Array<Dynamic>) {
	args ??= [];
	for (script in game.luaArray) script.call(name, args);
}
