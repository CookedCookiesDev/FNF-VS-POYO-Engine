package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import openfl.Lib;

class Paths
{
	public static final extensions:Map<String, String> = ["image" => "png", "audio" => "ogg", "video" => "mp4"];

	private static var assetsCache:Map<String, Map<String, Any>> = [
		"graphics" => [],
		"sounds" => []
	];

	private static var trackedAssets:Map<String, Array<String>> = [
		"graphics" => [],
		"sounds" => []
	];

	public static function clearAssets(type:String = 'none', cached:Bool = false):Void
	{
		if (type == 'graphics')
		{
			if (!cached)
			{
				@:privateAccess
				for (key in FlxG.bitmap._cache.keys())
				{
					var obj:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
					if (obj != null && !assetsCache["graphics"].exists(key))
					{
						if (Assets.cache.hasBitmapData(key))
							Assets.cache.removeBitmapData(key);

						FlxG.bitmap._cache.remove(key);
						obj = FlxDestroyUtil.destroy(obj);
					}
				}
			}
			else
			{
				@:privateAccess
				for (key in FlxG.bitmap._cache.keys())
				{
					var obj:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
					if (obj != null && assetsCache["graphics"].exists(key))
					{
						#if desktop
						GPUBitmap.dispose(KEY(key));
						#end

						if (Assets.cache.hasBitmapData(key))
							Assets.cache.removeBitmapData(key);

						FlxG.bitmap._cache.remove(key);

						if (assetsCache["graphics"].exists(key)) // duble check
							assetsCache["graphics"].remove(key);

						obj = FlxDestroyUtil.destroy(obj);
					}
				}
			}
		}
		else if (type == 'sounds')
		{
			if (!cached)
			{
				for (key in Assets.cache.getSoundKeys())
				{
					var obj:Sound = Assets.cache.getSound(key);
					if (obj != null && !assetsCache["sounds"].exists(key))
					{
						Assets.cache.removeSound(key);
						obj.close();
					}
				}
			}
			else
			{
				for (key in Assets.cache.getSoundKeys())
				{
					var obj:Sound = Assets.cache.getSound(key);
					if (obj != null && assetsCache["sounds"].exists(key))
					{
						Assets.cache.removeSound(key);
						assetsCache["sounds"].remove(key);
						obj.close();
					}
				}
			}
		}
		else if (type == 'none')
			trace('no assets clearing!');

		if (type == 'graphics' || type == 'sounds')
			System.gc();
	}

	inline static public function file(key:String, location:String, extension:String):String
	{
		var path:String = 'assets/$location/$key.$extension';
		return path;
	}

	inline static public function font(key:String, ?extension:String = "ttf"):String
	{
		var path:String = file(key, "fonts", extension);
		return path;
	}

	inline static public function xml(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "xml");
		return path;
	}

	inline static public function text(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "txt");
		return path;
	}

	inline static public function json(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "json");
		return path;
	}

	inline static public function image(key:String, ?location:String = "images"):Any
	{
		return returnGraphic(key, library, gpurender);
	}

	inline static public function sound(key:String, ?location:String = "sounds"):Sound
	{
		var path:String = file(key, location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function music(key:String, ?location:String = "music"):Sound
	{
		var path:String = file(key, location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function voices(key:String, ?location:String = "songs"):Sound
	{
		var path:String = file('$key/Voices', location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function inst(key:String, ?location:String = "songs"):Sound
	{
		var path:String = file('$key/Inst', location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function video(key:String, ?location:String = "videos"):String
	{
		var path:String = file(key, location, extensions.get("video"));
		return path;
	}

	inline static public function getSparrowAtlas(key:String, ?location:String = "images"):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, location), xml(key, location));

	inline static public function getPackerAtlas(key:String, ?location:String = "images"):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, location), text(key, location));

	public static function returnGraphic(key:String, ?library:String, ?gpurender:Bool = false):FlxGraphic
	{
		var path:String = getPath('images/$key.png', IMAGE, library);
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = null;
				var bitmap:BitmapData = Assets.getBitmapData(path);

				if (gpurender)
				{
					switch (FlxG.save.data.render)
					{
						case 1:
							var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
							texture.uploadFromBitmapData(bitmap);
							currentTrackedTextures.set(path, texture);
							bitmap.dispose();
							bitmap.disposeImage();
							bitmap = null;
							newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
						case 2:
							var texture = Lib.current.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
							texture.uploadFromBitmapData(bitmap);
							currentTrackedTextures.set(path, texture);
							bitmap.dispose();
							bitmap.disposeImage();
							bitmap = null;
							newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
						default:
							newGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);
					}
				}
				else
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);

				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('oh no its returning null NOOOO');
		return null;
	}

	public static function loadSound(path:String, ?addToCache:Bool = false):Sound
	{
		if (Assets.exists(path, SOUND))
		{
			if (addToCache && !assetsCache["sounds"].exists(path))
			{
				assetsCache["sounds"].set(path, Assets.getSound(path));
				return assetsCache["sounds"].get(path);
			}
			else if (assetsCache["sounds"].exists(path))
			{
				trace('$path is already loaded to the cache!');
				return assetsCache["sounds"].get(path);
			}
			else
			{
				if (!trackedAssets["sounds"].contains(path))
					trackedAssets["sounds"].push(path);

				return Assets.getSound(path);
			}
		}
		else
			trace('$path is null!');

		return null;
	}
}
