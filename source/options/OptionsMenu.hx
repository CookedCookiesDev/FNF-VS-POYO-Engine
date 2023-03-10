package options;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if mobile
import ui.FlxVirtualPad;
#end
import Config;
import WebViewVideo;

import flixel.util.FlxSave;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var insubstate:Bool = false;

	//var controlsStrings:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [
		'downscroll',
		'middlescroll',
		'set fps',
		'About'
	];

	#if mobile
	var _pad:FlxVirtualPad;
	#end
	var saveTxt:FlxText;

	var UP_P:Bool;
	var DOWN_P:Bool;
	var BACK:Bool;
	var ACCEPT:Bool;

	var _saveconrtol:FlxSave;

	var config:Config = new Config();

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		//controlsStrings = CoolUtil.coolTextFile('assets/data/controls.txt');
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		saveTxt = new FlxText(0, 0, FlxG.width, '', 64);
		saveTxt.alignment = FlxTextAlign.RIGHT;
		saveTxt.screenCenter();
		saveTxt.x -= 100;
		add(saveTxt);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...menuItems.length)
		{ 
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		#if mobile
		_pad = new FlxVirtualPad(UP_DOWN, A_B);
		_pad.alpha = 0.75;
		this.add(_pad);
		#end
		
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var daSelected:String = menuItems[curSelected];

		if (daSelected == 'downscroll') {
			saveTxt.visible = true;
			saveTxt.text = (FlxG.save.data.downscroll ? 'Enabled' : 'Disabled');
		} else if (daSelected == 'middlescroll') {
			saveTxt.visible = true;
			saveTxt.text = (FlxG.save.data.middlescroll ? 'Enabled' : 'Disabled');
		} else {
			saveTxt.visible = false;
		}

		if (!insubstate){
			#if mobile
			UP_P = _pad.buttonUp.justReleased;
			DOWN_P = _pad.buttonDown.justReleased;
			BACK = _pad.buttonB.justPressed || FlxG.android.justReleased.BACK;
			ACCEPT = _pad.buttonA.justReleased;
			#else
			UP_P = controls.UP_P;
			DOWN_P = controls.DOWN_P;
			ACCEPT = controls.ACCEPT;
			BACK = controls.BACK;
			#end
		}
		
		if (ACCEPT)
		{
			switch (daSelected)
			{
				case "config":
					trace("hello");
				case "downscroll":
					if (FlxG.save.data.downscroll)
						FlxG.save.data.downscroll = false;
					else
						FlxG.save.data.downscroll = true;
				case "middlescroll":
					if (FlxG.save.data.middlescroll)
						FlxG.save.data.middlescroll = false;
					else
						FlxG.save.data.middlescroll = true;
				case "set fps":
					insubstate = true;
					openSubState(new options.SetFpsSubState());
				case "About":
					FlxG.switchState(new options.AboutState());
				case "test cutscene":
					//webview.openHTML(Assets.getBytes('assets/index.html'));
					//webview.openURLfromAssets('index.html');
					#if extension-webview
					WebViewVideo.openVideo('ughCutscene');
					#end
			}
		}

		if (isSettingControl)
			waitingInput();
		else
		{
			if (BACK)
				FlxG.switchState(new MainMenuState());
			if (UP_P)
				changeSelection(-1);
			if (DOWN_P)
				changeSelection(1);
		}
	}

	function waitingInput():Void
	{
		if (false)// fix this FlxG.keys.getIsDown().length > 0
		{
			//PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
		/* #if !switch
		NGio.logEvent('Fresh');
		#end
		*/
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	// (this function is not working)
	function changeLabel(i:Int, text:String) {
		var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, text, true, false);
		controlLabel.isMenuItem = true;
		controlLabel.targetY = i;
		
		grpControls.forEach((basic)->{
			trace(basic.text);
			if (basic.text == menuItems[i])
			{
				grpControls.remove(basic);
			}
		});
		grpControls.insert(i, controlLabel);	
		menuItems[i] = text;
	}

	override function closeSubState()
		{
			insubstate = false;
			super.closeSubState();
		}
	// Remove refrences that can interfere with GC on switch state //
    override function switchTo(nextState:FlxState):Bool
    {
        clearDefines();
        return super.switchTo(nextState);
    }

    function clearDefines()
    {
        // Reset Defines //
        flixel.graphics.FlxGraphic.defaultPersist = false;
        FlxG.keys.preventDefaultKeys = []; // Prevents Arrow key input drops;
        // Handle Refrences //
				menuItems = [];
				grpControls.clear();
        //characters.clear(); // yall don't have that :tro:
    }

}
