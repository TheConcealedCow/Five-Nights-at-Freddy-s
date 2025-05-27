function onCreate()
	luaDebugMode = true;
	runHaxeCode([=[
		import psychlua.LuaUtils;
		import flixel.group.FlxTypedSpriteGroup;
		
		createGlobalCallback('makeCounterSpr', function(t, ?x, ?y, ?s, ?d) {
			d ??= 'gameAssets/nightnum/';
			s ??= 0;
			var grp:FlxTypedSpriteGroup<FlxSprite>;
			grp = new FlxTypedSpriteGroup(x, y);
			grp.camera = FlxG.camera;
			setVar(t, grp);
			setVar(t + '_PROPERTIES', ['curNum' => 0, 'dir' => d]);
			
			updateCounter(t, s, true);
		});
		
		createGlobalCallback('updateCounterSpr', function(t, c) {
			updateCounter(t, c);
		});
		
		function updateCounter(count, num, ?force = false) { // removes all numbers and refreshes it
			var curCount = getVar(count + '_PROPERTIES');
			var grp = getVar(count);
			
			if (curCount['curNum'] != num || force) {
				curCount['curNum'] = num;
				clearCounter(count);
				insertNumbersToGrp(grp, num, curCount['dir']);
			}
		}
		
		function insertNumbersToGrp(g, n, d) {
			var allNum = Std.string(Std.int(n));
			
			for (i in 0...allNum.length) {
				var numer = (allNum.length - i) - 1;
				makeNumAndInsert(g, allNum.charAt(numer), d);
			}
		}
		
		function makeNumAndInsert(g, i, d) {
			var spr = new FlxSprite().loadGraphic(Paths.image(d + i));
			spr.x = -spr.width - g.width;
			spr.y = -spr.height;
			g.add(spr);
		}
		
		function clearCounter(count) { // should delete all numbers in the counter
			var grp = getVar(count);
			var wh = [];
			
			for (obj in grp) wh.push(obj);
			
			for (o in wh) {
				grp.remove(o, true);
				o.kill();
				LuaUtils.getTargetInstance().remove(o, true);
				o.destroy();
			}
		}
	]=]);
end