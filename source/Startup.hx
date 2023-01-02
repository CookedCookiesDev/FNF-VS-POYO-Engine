package;

import openfl.media.Sound;
import title.*;
import config.*;
import transition.data.*;
import flixel.FlxState;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import openfl.system.System;
#if sys
import sys.thread.Thread;
#end

// import openfl.utils.Future;
// import flixel.addons.util.FlxAsyncLoop;
using StringTools;

class Startup extends FlxState
{
	var nextState:FlxState = new TitleVideo();

	var splash:FlxSprite;
	// var dummy:FlxSprite;
	var loadingText:FlxText;

	public static var thing = false;

	override function create()
	{
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.mouse.visible = false;
		FlxG.sound.muteKeys = null;

		FlxG.save.bind('data');
		Highscore.load();
		KeyBinds.keyCheck();
		PlayerSettings.init();

		PlayerSettings.player1.controls.loadKeyBinds();
		Config.configCheck();

		UIStateExt.defaultTransIn = ScreenWipeIn;
		UIStateExt.defaultTransInArgs = [1.2];
		UIStateExt.defaultTransOut = ScreenWipeOut;
		UIStateExt.defaultTransOutArgs = [0.6];

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		splash = new FlxSprite(0, 0);
		splash.frames = Paths.getSparrowAtlas('fpsPlus/rozeSplash');
		splash.animation.addByPrefix('start', 'Splash Start', 24, false);
		splash.animation.addByPrefix('end', 'Splash End', 24, false);
		splash.animation.play("start");
		splash.updateHitbox();
		splash.screenCenter();
		add(splash);

		loadingText = new FlxText(5, FlxG.height - 32, 0, "", 24);
		loadingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound("splashSound"));
			loadingText.text = "FNF: VS POYO is a mod of the game Friday Night Funkin'.\nWe do not plan to harm the original game in any shape or form.";
		});
		super.create();
	}

	override function update(elapsed)
	{
		if (splash.animation.curAnim.finished
			&& !(splash.animation.curAnim.name == "end"))
		{
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound("loadComplete"));
				splash.animation.play("end");
				splash.updateHitbox();
				splash.screenCenter();
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.switchState(nextState);
				});
			});
		}

		super.update(elapsed);
	}
}
