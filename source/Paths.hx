package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import flixel.util.FlxDestroyUtil;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.system.System;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	private static var assetsCache:Map<String, Map<String, Any>> = [
		"graphics" => [],
		"sounds" => []
	];

	public static var trackedAssets:Map<String, Array<String>> = [
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
					#if desktop
					GPUBitmap.dispose(KEY(key));
					#end
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

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (Assets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (Assets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		var json = new haxe.Http('https://raw.githubusercontent.com/CookedCookiesDev/FNF-VS-POYO-Engine/main/assets/preload/data/$key.json');
		
		json.onData = function(data:String)
		{
		  var result = haxe.Json.parse(data);
		  return result;
		}
		
		json.onError = function(error)
		{
		  return 'whoops';
		}
		
		//return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var path = getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		return loadSound(path);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		var path = getPath('music/$key.$SOUND_EXT', MUSIC, library);
		return loadSound(path);
	}

	inline static public function voices(song:String, ?returnString:Bool = false)
	{
		var path = 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		return loadSound(path);
	}

	inline static public function inst(song:String)
	{
		var path = 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		return loadSound(path);
	}

	inline static public function voicesS(song:String)
	{
		var path = 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		return path;
	}

	inline static public function instS(song:String)
	{
		var path = 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		return path;
	}

	inline static public function image(key:String, ?library:String)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		return loadImage(path);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	public static function loadImage(path:String, ?addToCache:Bool = true):Any
	{
		if (Assets.exists(path, IMAGE))
		{
			if (addToCache && !assetsCache["graphics"].exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(#if desktop GPUBitmap.create(path) #else Assets.getBitmapData(path) #end);
				graphic.persist = true;
				assetsCache["graphics"].set(path, graphic);

				return assetsCache["graphics"].get(path);
			}
			else if (assetsCache["graphics"].exists(path))
			{
				trace('$path is already loaded to the cache!');
				return assetsCache["graphics"].get(path);
			}
			else
			{
				if (!trackedAssets["graphics"].contains(path))
					trackedAssets["graphics"].push(path);

				return path;
			}
		}
		else
			trace('$path is null!');

		return null;
	}

	public static function loadSound(path:String, ?addToCache:Bool = true):Sound
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
