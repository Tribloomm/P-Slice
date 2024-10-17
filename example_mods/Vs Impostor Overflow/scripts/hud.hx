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

var fakeTrayY = 0;
var fakeTrayAlpha = 0;
var trayLerpY = 0;
var trayAlphaTarget = 0;
var oldVolume:Float = 0;

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
	
	var appTitle:String = FlxG.stage.window.title;
	if (StringTools.trim(appTitle) != '' && appTitle != 'Friday Night Funkin\'') oldTitle = appTitle;
	FlxG.stage.window.title = 'Friday Night Funkin\'';
	
	FlxTransitionableState.skipNextTransOut = true;
	psychFps = Main.fpsVar.updateText; //custom fps display
	Main.fpsVar.defaultTextFormat = new TextFormat('_sans', 12, 0xffffff, false, false, false, '', '', 'left', 0, 0, 0, -4); //lol!
	Main.fpsVar.updateText = () -> {
        memPeak = Math.max(memPeak, Main.fpsVar.memoryMegas);
        Main.fpsVar.text = 'FPS: ' + Main.fpsVar.currentFPS + (showRam ? ('\nRAM: ' + FlxStringUtil.formatBytes(Main.fpsVar.memoryMegas).toLowerCase() + ' / ' + FlxStringUtil.formatBytes(memPeak).toLowerCase()) : '');

	}
	game.updateIconsScale = () -> {};
}

function onDestroy() {
	FlxG.stage.window.title = oldTitle;
	Main.fpsVar.defaultTextFormat = new TextFormat('_sans', 14, 0xffffff, false, false, false, '', '', 'left', 0, 0, 0, 0);
	Main.fpsVar.updateText = psychFps;
	return Function_Continue;
}
function onStartCountdown() {
	skipTween = game.skipArrowStartTween;
	game.skipArrowStartTween = true;
	return Function_Continue;
}

function onCountdownStarted() {
	game.remove(game.uiGroup);
	game.insert(0, game.uiGroup);
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
function onCountdownTick(_, t) {
	if (t % 4 == 0) boom();
	game.iconP1.setGraphicSize(game.iconP1.width * 1.2);
	game.iconP2.setGraphicSize(game.iconP2.width * 1.2);
	game.iconP1.updateHitbox();
	game.iconP2.updateHitbox();
}
function coolLerp(base, target, ratio) { //funkin mathutil
	return base + (ratio * FlxG.elapsed / (1 / 60)) * (target - base);
}
function onUpdatePost(e) {
	game.camZooming = false;
	
	lerpHealth = FlxMath.lerp(lerpHealth, game.health, .15); //WHY IS EVERYTHING TIED TO FPS
	game.healthBar.percent = lerpHealth * 50;
	
	game.iconP1.setGraphicSize(coolLerp(game.iconP1.width, 150, .15));
	game.iconP2.setGraphicSize(coolLerp(game.iconP2.width, 150, .15));
	game.iconP1.updateHitbox();
	game.iconP2.updateHitbox();
	game.updateIconsPosition();
	
	if (forceHBColors && (game.healthBar.leftBar.color != 0xff0000 || game.healthBar.rightBar.color != 0x66ff33)) game.healthBar.setColors(0xff0000, 0x66ff33);
	//uhh!
	return;
}