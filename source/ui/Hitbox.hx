package ui;

import flixel.graphics.FlxGraphic;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.ui.FlxVirtualPad;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// copyed from flxvirtualpad
class Hitbox extends FlxSpriteGroup
{
    public var hitbox:FlxSpriteGroup;

    var sizex:Float = 320;

    var screensizey:Int = 720;

    public var left:FlxButton;
    public var down:FlxButton;
    public var up:FlxButton;
    public var right:FlxButton;
    
    public function new(?widghtScreen:Int, ?heightScreen:Int)
    {
        super(widghtScreen, heightScreen);

        sizex = FlxG.width / 4;
        
        //add graphic
        hitbox = new FlxSpriteGroup();
        hitbox.scrollFactor.set();
        hitbox.add(add(left = createhitbox(0, "left")));
        hitbox.add(add(down = createhitbox(sizex, "down")));
        hitbox.add(add(up = createhitbox(sizex * 2, "up")));
        hitbox.add(add(right = createhitbox(sizex * 3, "right")));
    }

    public function createhitbox(X:Float, framestring:String) {
        var button = new FlxButton(X, 0);
        button.setGraphicSize(Std.int(sizex), FlxG.height);
        button.updateHitbox();
        button.alpha = 0;
        return button;
    }

    override public function destroy():Void
        {
            super.destroy();
    
            left = null;
            down = null;
            up = null;
            right = null;
        }
}