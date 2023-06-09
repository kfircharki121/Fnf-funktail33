package games.flixel;

import flixel.addons.effects.FlxTrail;
import flixel.addons.ui.FlxUI9SliceSprite;
#if android
import android.flixel.FlxButton;
#else
import flixel.ui.FlxButton;
#end
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import haxe.EnumTools;

/**
 * Tweening demo.
 *
 * @author Gama11
 * @author Devolonter
 * @link https://github.com/devolonter/flixel-monkey-bananas/tree/master/tweening
 */
class FlxTweenState extends MusicBeatState {
	static inline var DURATION:Float = 1;

	var _easeInfo:Array<EaseInfo>;

	var _currentEaseIndex:Int = 0;
	var _currentEaseType:String = "quad";
	var _currentEaseDirection:String = "In";
	var _currentTween:TweenType = TWEEN; // Start with tween() tween, it's used most commonly.

	var _tween:FlxTween;
	var _sprite:FlxSprite;
	var _trail:FlxTrail;
	var _min:FlxPoint;
	var _max:FlxPoint;

	var _currentEase(get, never):EaseFunction;

	override public function create():Void {
		FlxG.autoPause = false;
		FlxG.mouse.visible = true;

		// Set up an array containing all the different ease functions there are
		_easeInfo = [
			{name: "quadIn", ease: FlxEase.quadIn},
			{name: "quadOut", ease: FlxEase.quadOut},
			{name: "quadInOut", ease: FlxEase.quadInOut},

			{name: "cubeIn", ease: FlxEase.cubeIn},
			{name: "cubeOut", ease: FlxEase.cubeOut},
			{name: "cubeInOut", ease: FlxEase.cubeInOut},

			{name: "quartIn", ease: FlxEase.quartIn},
			{name: "quartOut", ease: FlxEase.quartOut},
			{name: "quartInOut", ease: FlxEase.quartInOut},

			{name: "quintIn", ease: FlxEase.quintIn},
			{name: "quintOut", ease: FlxEase.quintOut},
			{name: "quintInOut", ease: FlxEase.quintInOut},

			{name: "sineIn", ease: FlxEase.sineIn},
			{name: "sineOut", ease: FlxEase.sineOut},
			{name: "sineInOut", ease: FlxEase.sineInOut},

			{name: "bounceIn", ease: FlxEase.bounceIn},
			{name: "bounceOut", ease: FlxEase.bounceOut},
			{name: "bounceInOut", ease: FlxEase.bounceInOut},

			{name: "circIn", ease: FlxEase.circIn},
			{name: "circOut", ease: FlxEase.circOut},
			{name: "circInOut", ease: FlxEase.circInOut},

			{name: "expoIn", ease: FlxEase.expoIn},
			{name: "expoOut", ease: FlxEase.expoOut},
			{name: "expoInOut", ease: FlxEase.expoInOut},

			{name: "backIn", ease: FlxEase.backIn},
			{name: "backOut", ease: FlxEase.backOut},
			{name: "backInOut", ease: FlxEase.backInOut},

			{name: "elasticIn", ease: FlxEase.elasticIn},
			{name: "elasticOut", ease: FlxEase.elasticOut},
			{name: "elasticInOut", ease: FlxEase.elasticInOut},

			{name: "smoothStepIn", ease: FlxEase.smoothStepIn},
			{name: "smoothStepOut", ease: FlxEase.smoothStepOut},
			{name: "smoothStepInOut", ease: FlxEase.smoothStepInOut},
			{name: "smootherStepIn", ease: FlxEase.smootherStepIn},

			{name: "smootherStepOut", ease: FlxEase.smootherStepOut},
			{name: "smootherStepInOut", ease: FlxEase.smootherStepInOut},

			{name: "none", ease: FlxEase.linear}
		];

		var title = new FlxText(0, 0, FlxG.width, "FlxTween", 64);
		title.alignment = CENTER;
		title.screenCenter();
		title.setFormat(Paths.font("bahnschrift.ttf"), 30, FlxColor.WHITE);
		title.alpha = 0.15;
		add(title);

		// Create the sprite to tween (flixel logo)
		_sprite = new FlxSprite();
		_sprite.loadGraphic(Paths.image("haxeflixel"));
		_sprite.scale.x = .3;
		_sprite.scale.y = .3;
		_sprite.antialiasing = true;

		_sprite.pixelPerfectRender = false;

		// Add a trail effect
		_trail = new FlxTrail(_sprite, "haxeflixel", 12, 0, 0.4, 0.02);

		add(_trail);
		add(_sprite);

		_min = FlxPoint.get(FlxG.width * 0.1, FlxG.height * 0.25);
		_max = FlxPoint.get(FlxG.width * 0.7, FlxG.height * 0.75);

		/*** From here on: UI setup ***/

		// First row

		var yOff = 10;

		var xOff = 10;
		var gutter = 10;
		var headerWidth = 100;

		add(new FlxText(xOff, yOff + 3, 200, "Tween:", 12));

		xOff = 80;

		var tweenTypes:Array<String> = [
			"tween",
			"angle",
			"color",
			"linearMotion",
			"linearPath",
			"circularMotion",
			"cubicMotion",
			"quadMotion",
			"quadPath"
		];

		var header = new FlxUIDropDownHeader(130);
		var tweenTypeDropDown = new FlxUIDropDownMenu(xOff, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(tweenTypes, true), onTweenChange, header);
		tweenTypeDropDown.header.text.text = "tween"; // Initialize header with correct value

		// Second row

		yOff += 30;
		xOff = 10;

		add(new FlxText(10, yOff + 3, 200, "Ease:", 12));

		xOff = Std.int(tweenTypeDropDown.x);

		var easeTypes:Array<String> = [
			"quad", "cube", "quart", "quint", "sine", "bounce", "circ", "expo", "back", "elastic", "smoothStep", "smootherStep", "none"
		];
		var header = new FlxUIDropDownHeader(headerWidth);
		var easeTypeDropDown = new FlxUIDropDownMenu(xOff, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(easeTypes), onEaseTypeChange, header);

		xOff += (headerWidth + gutter);

		var easeDirections:Array<String> = ["In", "Out", "InOut"];
		var header2 = new FlxUIDropDownHeader(headerWidth);
		var easeDirectionDropDown = new FlxUIDropDownMenu(xOff, yOff, FlxUIDropDownMenu.makeStrIdLabelArray(easeDirections), onEaseDirectionChange, header2);

		// Third row

		yOff += 30;
		xOff = 80;

		var trailToggleButton = new FlxButton(xOff, yOff, "Trail", onToggleTrail);

		// Add stuff in correct order - (lower y values first because of the dropdown menus)

		add(trailToggleButton);

		add(easeTypeDropDown);
		add(easeDirectionDropDown);

		add(tweenTypeDropDown);

		// Start the tween
		startTween();

		#if FLX_DEBUG
		FlxG.watch.add(this, "_currentEaseIndex");
		FlxG.watch.add(this, "_currentEaseType");
		FlxG.watch.add(this, "_currentEaseDirection");
		FlxG.watch.add(this, "_currentTween");
		#end
	}

	function startTween():Void {
		var options:TweenOptions = {type: PINGPONG, ease: _currentEase};

		_sprite.screenCenter(FlxAxes.Y);
		_sprite.x = _min.x;

		_sprite.angle = 0;
		_sprite.color = FlxColor.WHITE;
		_sprite.alpha = 0.8; // Lowered alpha looks neat

		// Cancel the old tween
		if (_tween != null) {
			_tween.cancel();
		}

		switch (_currentTween) {
			case TWEEN:
				_tween = FlxTween.tween(_sprite, {x: _max.x, angle: 180}, DURATION, options);

			case ANGLE:
				_tween = FlxTween.angle(_sprite, 0, 90, DURATION, options);
				_sprite.screenCenter(FlxAxes.X);

			case COLOR:
				_tween = FlxTween.color(_sprite, DURATION, FlxColor.BLACK, FlxColor.fromRGB(0, 0, 255, 0), options);
				_sprite.screenCenter(FlxAxes.X);

			case LINEAR_MOTION:
				_tween = FlxTween.linearMotion(_sprite, _sprite.x, _sprite.y, _max.x, _sprite.y, DURATION, true, options);

			case LINEAR_PATH:
				_sprite.y = (_max.y - _sprite.height);
				var path:Array<FlxPoint> = [
					FlxPoint.get(_sprite.x, _sprite.y),
					FlxPoint.get(_sprite.x + (_max.x - _min.x) * 0.5, _min.y),
					FlxPoint.get(_max.x, _sprite.y)
				];
				_tween = FlxTween.linearPath(_sprite, path, DURATION, true, options);

			case CIRCULAR_MOTION:
				_tween = FlxTween.circularMotion(_sprite, (FlxG.width * 0.5) - (_sprite.width / 2), (FlxG.height * 0.5) - (_sprite.height / 2), _sprite.width,
					359, true, DURATION, true, options);

			case CUBIC_MOTION:
				_sprite.y = _min.y;
				_tween = FlxTween.cubicMotion(_sprite, _sprite.x, _sprite.y, _sprite.x + (_max.x - _min.x) * 0.25, _max.y,
					_sprite.x + (_max.x - _min.x) * 0.75, _max.y, _max.x, _sprite.y, DURATION, options);

			case QUAD_MOTION:
				var rangeModifier = 100;
				_tween = FlxTween.quadMotion(_sprite, _sprite.x, // start x
					_sprite.y
					+ rangeModifier, // start y
					_sprite.x
					+ (_max.x - _min.x) * 0.5, // control x
					_min.y
					- rangeModifier, // control y
					_max.x, // end x
					_sprite.y
					+ rangeModifier, // end y
					DURATION, true, options);

			case QUAD_PATH:
				var path:Array<FlxPoint> = [
					FlxPoint.get(_sprite.x, _sprite.y),
					FlxPoint.get(_sprite.x + (_max.x - _min.x) * 0.5, _max.y),
					FlxPoint.get(_max.x - (_max.x / 2) + (_sprite.width / 2), _sprite.y),
					FlxPoint.get(_max.x - (_max.x / 2) + (_sprite.width / 2), _min.y),
					FlxPoint.get(_max.x, _sprite.y)
				];
				_tween = FlxTween.quadPath(_sprite, path, DURATION, true, options);
		}

		_trail.resetTrail();
	}

	inline function get__currentEase():EaseFunction {
		return _easeInfo[_currentEaseIndex].ease;
	}

	function onEaseTypeChange(ID:String):Void {
		_currentEaseType = ID;
		updateEaseIndex();
	}

	function onEaseDirectionChange(ID:String):Void {
		_currentEaseDirection = ID;
		updateEaseIndex();
	}

	function updateEaseIndex():Void {
		var curEase = _currentEaseType + _currentEaseDirection;
		var foundEase:Bool = false;

		// Find the ease info in the array with the right name
		for (i in 0..._easeInfo.length) {
			if (curEase == _easeInfo[i].name) {
				_currentEaseIndex = i;
				foundEase = true;
			}
		}

		if (!foundEase) {
			_currentEaseIndex = _easeInfo.length - 1; // last entry is "none"
		}

		// Need to restart the tween now
		startTween();
	}

	function onTweenChange(ID:String):Void {
		_currentTween = EnumTools.createByIndex(TweenType, Std.parseInt(ID));
		startTween();
	}

	function onToggleTrail():Void {
		_trail.visible = !_trail.visible;
		_trail.resetTrail();
	}

	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end) {
			MusicBeatState.switchState(new games.flixel.FlixelDemosMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
	}
}

typedef EaseInfo = {
	name:String,
	ease:EaseFunction
}

enum TweenType {
	TWEEN;
	ANGLE;
	COLOR;
	LINEAR_MOTION;
	LINEAR_PATH;
	CIRCULAR_MOTION;
	CUBIC_MOTION;
	QUAD_MOTION;
	QUAD_PATH;
}
