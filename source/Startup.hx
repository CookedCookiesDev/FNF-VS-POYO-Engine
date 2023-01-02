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

	var songsCached:Bool;

	public static final songs:Array<String> = [
		"Tutorial", "Bopeebo", "Fresh", "Dadbattle", "Spookeez", "South", "Monster", "Pico", "Philly", "Blammed", "Satin-Panties", "High", "Milf", "Cocoa",
		"Eggnog", "Winter-Horrorland", "Senpai", "Roses", "Thorns", "klaskiiLoop", "freakyMenu"
	]; // Start of the non-gameplay songs.

	// List of character graphics and some other stuff.
	// Just in case it want to do something with it later.
	var charactersCached:Bool;
	var startCachingCharacters:Bool = false;
	var charI:Int = 0;

	public static final characters:Array<String> = [
		"BOYFRIEND",
		"bfCar",
		"christmas/bfChristmas",
		"weeb/bfPixel",
		"weeb/bfPixelsDEAD",
		"GF_assets",
		"gfCar",
		"christmas/gfChristmas",
		"weeb/gfPixel",
		"DADDY_DEAREST",
		"spooky_kids_assets",
		"Monster_Assets",
		"Pico_FNF_assetss",
		"Mom_Assets",
		"momCar",
		"christmas/mom_dad_christmas_assets",
		"christmas/monsterChristmas",
		"weeb/senpai",
		"weeb/spirit",
		"weeb/senpaiCrazy"
	];

	var graphicsCached:Bool;
	var startCachingGraphics:Bool = false;
	var gfxI:Int = 0;

	public static final graphics:Array<String> = [
		"logoBumpin", "logoBumpin2", "titleBG", "gfDanceTitle", "gfDanceTitle2", "titleEnter", "stageback", "stagefront", "stagecurtains", "halloween_bg",
		"philly/sky", "philly/city", "philly/behindTrain", "philly/train", "philly/street", "philly/win0", "philly/win1", "philly/win2", "philly/win3",
		"philly/win4", "limo/bgLimo", "limo/fastCarLol", "limo/limoDancer", "limo/limoDrive", "limo/limoSunset", "christmas/bgWalls", "christmas/upperBop",
		"christmas/bgEscalator", "christmas/christmasTree", "christmas/bottomBop", "christmas/fgSnow", "christmas/santa", "christmas/evilBG",
		"christmas/evilTree", "christmas/evilSnow", "weeb/weebSky", "weeb/weebSchool", "weeb/weebStreet", "weeb/weebTreesBack", "weeb/weebTrees",
		"weeb/petals", "weeb/bgFreaks", "weeb/animatedEvilSchool"
	];

	var cacheStart:Bool = false;

	public static var thing = false;

	var gtfo:Bool = false;
	var StringText:String = "FNF: VS POYO is a fanmade mod for the game Friday Night Funkin'"

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

		loadingText = new FlxText(5, FlxG.height - 30, 0, StringText, 24);
		loadingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadingText);

		#if web
		FlxG.sound.play(Paths.sound("tick"), 0);
		#end

		new FlxTimer().start(1.1, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound("splashSound"));
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				gtfo = true;
			});
		});

		super.create();
	}

	override function update(elapsed)
	{
		if (splash.animation.curAnim.finished && splash.animation.curAnim.name == "end")
		{
			FlxG.switchState(nextState);
		}

		if (splash.animation.curAnim.finished
			&& gtfo
			&& !(splash.animation.curAnim.name == "end"))
		{
			FlxG.sound.play(Paths.sound("loadComplete"));
			splash.animation.play("end");
			splash.updateHitbox();
			splash.screenCenter();
		}

		super.update(elapsed);
	}
}
