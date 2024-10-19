import Main;
import openfl.text.TextFormat;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;
import flixel.group.FlxTypedSpriteGroup;

var forceHBColors:Bool = false;
var lerpHealth:Float = 1;
var cameraBopMultiplier:Float = 1;
var combo:Int = 0;
var doMiss:Bool = false;
var missRating:Bool = false;
var skipTween:Bool = false;
var comboGroup:FlxTypedSpriteGroup<FlxSprite>;

var oldTitle = 'Friday Night Funkin\': Psych Engine';
var psychFps = null;
var memPeak = 0;

//constants
var c_PIXELARTSCALE:Float = 6;

function getSetting(setting, def) {
	var setting = game.callOnHScript('getScrSetting', [setting, def]);
	return setting;
}
function onCreate() {
	comboGroup = new FlxTypedSpriteGroup();
	game.add(comboGroup);
	
	doMiss = getSetting('missbutlikeactually', false);
	missRating = getSetting('miss', false);
	var showRam:Bool = getSetting('showram', false);
}

function onUpdatePost() {
	comboGroup.cameras = [game.camHUD];
	
	game.healthBar.y = FlxG.height * (ClientPrefs.data.downScroll ? .1 : .9);
	
	game.healthBar.y = FlxG.height * (ClientPrefs.data.downScroll ? .1 : .9);

	var relayer:Array = [game.scoreTxt, game.healthBar, game.iconP1, game.iconP2];
	for (item in relayer) game.uiGroup.remove(item);
	for (item in relayer) game.uiGroup.add(item); //:p
	
	return Function_Continue;
}
function oncountdownStarted() {
	skipTween = game.skipArrowStartTween;
	game.skipArrowStartTween = false;
	return Function_Continue;
}
function onCountdownStarted() {
	var m:Int = (ClientPrefs.data.downScroll ? -1 : 1);
	var i:Int = 0;
	for (strum in game.strumLineNotes.members) {
		var player = (i >= game.opponentStrums.length);
		if (!ClientPrefs.data.middleScroll) strum.x = Note.swagWidth * (i % game.opponentStrums.length) + 45 + (player ? FlxG.width * .5 : 0);
		strum.y = (ClientPrefs.data.downScroll ? FlxG.height - 150 : 48);
		
		if (!skipTween && PlayState.startOnTime <= 0 && (player || ClientPrefs.data.opponentStrums)) {
			strum.y -= m * 10;
			strum.alpha = 0;
			FlxTween.tween(strum, {y: strum.y + m * 10, alpha: ((ClientPrefs.data.middleScroll && i < game.opponentStrums.length) ? 0.35 : 1)}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * (i % game.opponentStrums.length))});
		}
		
		i += 1; //++ isnt implemented sobbing rn
	}
	return Function_Continue;
}

function boom() {
	if (game.camZoomingDecay > 0 && FlxG.camera.zoom < 1.35 * FlxCamera.defaultZoom && ClientPrefs.data.camZooms) {
		FlxG.camera.zoom = game.defaultCamZoom * (1 + .015 * game.camZoomingMult);
		game.camHUD.zoom = .03 + 1;
	}
}