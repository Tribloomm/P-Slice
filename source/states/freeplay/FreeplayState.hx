package states.freeplay;

import openfl.utils.AssetCache;
import backend.FreeplayMeta;
import lime.app.Future;
import haxe.Exception;
import openfl.media.Sound;
import funkin.util.flixel.sound.FlxPartialSound;
import flixel.graphics.FlxGraphic;
import funkin.Scoring;
import funkin.AtlasText;
import shaders.PureColor;
import backend.Song;
import shaders.HSVShader;
import shaders.StrokeShader;
import shaders.AngleMask;
import backend.Highscore;
import funkin.MathUtil;
import funkin.IntervalShake;
import backend.WeekData;
import backend.animation.FlxAtlasSprite;
import substates.StickerSubState;
import funkin.Scoring.ScoringRank;
import objects.TypedAlphabet;
import backend.PsychCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import openfl.display.BlendMode;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.utils.Assets;

using funkin.FunkinTools;
using funkin.ArrayTools;

/**
 * Parameters used to initialize the FreeplayState.
 */
typedef FreeplayStateParams =
{
	?character:String,

	?fromResults:FromResultsParams,
};

/**
 * A set of parameters for transitioning to the FreeplayState from the ResultsState.
 */
typedef FromResultsParams =
{
	/**
	 * The previous rank the song hand, if any. Null if it had no score before.
	 */
	var ?oldRank:ScoringRank;

	/**
	 * Whether or not to play the rank animation on returning to freeplay.
	 */
	var playRankAnim:Bool;

	/**
	 * The new rank the song has.
	 */
	var newRank:ScoringRank;

	/**
	 * The song ID to play the animation on.
	 */
	var songId:String;

	/**
	 * The difficulty ID to play the animation on.
	 */
	var difficultyId:String;
};

/**
 * The state for the freeplay menu, allowing the player to select any song to play.
 */
class FreeplayState extends MusicBeatSubstate
{
	//
	// Params
	//

	/**
	 * The current character for this FreeplayState.
	 * You can't change this without transitioning to a new FreeplayState.
	 */
	final currentCharacter:String;

	/**
	 * For the audio preview, the duration of the fade-in effect.
	 */
	public static final FADE_IN_DURATION:Float = 2;

	/**
	 * For the audio preview, the duration of the fade-out effect.
	 *
	 */
	public static final FADE_OUT_DURATION:Float = 0.25;

	/**
	 * For the audio preview, the volume at which the fade-in starts.
	 */
	public static final FADE_IN_START_VOLUME:Float = 0;

	/**
	 * For the audio preview, the volume at which the fade-in ends.
	 */
	public static final FADE_IN_END_VOLUME:Float = 0.8;

	/**
	 * For the audio preview, the time to wait before attempting to load a song preview.
	 */
	 public static final FADE_IN_DELAY:Float = 0.25;

	/**
	 * For the audio preview, the volume at which the fade-out starts.
	 */
	public static final FADE_OUT_END_VOLUME:Float = 0.0;

	var songs:Array<Null<FreeplaySongData>> = [];

	var diffIdsCurrent:Array<String> = [];
	var diffIdsTotal:Array<String> = ['easy', "normal", "hard"];

	var curSelected:Int = 0;
	var currentDifficulty:String = "hard";

	
	var colorTween:FreeplayColorTweener;

	var fp:FreeplayScore;
	var txtCompletion:AtlasText;
	var lerpCompletion:Float = 0;
	var intendedCompletion:Float = 0;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var grpDifficulties:FlxTypedSpriteGroup<DifficultySprite>;
	var grpFallbackDifficulty:FlxText;

	var coolColors:Array<Int> = [
		0xFF9271FD,
		0xFF9271FD,
		0xFF223344,
		0xFF941653,
		0xFFFC96D7,
		0xFFA0D1FF,
		0xFFFF78BF,
		0xFFF6B604
	];

	var grpSongs:FlxTypedGroup<Alphabet>;
	var grpCapsules:FlxTypedGroup<SongMenuItem>;
	var curCapsule:SongMenuItem;
	var curPlaying:Bool = false;

	var dj:DJBoyfriend;

	var ostName:FlxText;

	var letterSort:LetterSort;
	var exitMovers:ExitMoverData = new Map();

	var stickerSubState:StickerSubState;

	public static var rememberedDifficulty:Null<String> = "hard";
	public static var rememberedSongId:Null<String> = 'tutorial';

	var funnyCam:PsychCamera;
	var rankCamera:PsychCamera;
	var rankBg:FlxSprite;
	var rankVignette:FlxSprite;

	var backingTextYeah:FlxAtlasSprite;
	public var orangeBackShit:FlxSprite;
	public var alsoOrangeLOL:FlxSprite;
	public var pinkBack:FlxSprite;
	var confirmGlow:FlxSprite;
	var confirmGlow2:FlxSprite;
	var confirmTextGlow:FlxSprite;

	public var moreWays:BGScrollingText;
	public var funnyScroll:BGScrollingText;
	public var txtNuts:BGScrollingText;
	public var funnyScroll2:BGScrollingText;
	public var moreWays2:BGScrollingText;
	public var funnyScroll3:BGScrollingText;

	var bgDad:FlxSprite;
	var cardGlow:FlxSprite;

	var fromResultsParams:Null<FromResultsParams> = null;

	var prepForNewRank:Bool = false;

	public function new(?params:FreeplayStateParams, ?stickers:StickerSubState)
	{
		super();
		currentCharacter = params?.character ?? "bf";

		fromResultsParams = params?.fromResults;

		if (fromResultsParams?.playRankAnim == true)
		{
			prepForNewRank = true;
		}

		if (stickers != null)
		{
			stickerSubState = stickers;
		}
	}

	override function create():Void
	{
		if(ClientPrefs.data.vsliceFreeplayColors) colorTween = new FreeplayColorTweener(this);
		BPMCache.instance.clearCache(); // for good measure
		

		super.create();
		var diffIdsTotalModBinds:Map<String, String> = ["easy" => "", "normal" => "", "hard" => ""];

		FlxG.state.persistentUpdate = false;

		FlxTransitionableState.skipNextTransIn = true;

		// dedicated camera for the state so we don't need to fuk around with camera scrolls from the mainmenu / elsewhere
		funnyCam = new PsychCamera(0, 0, FlxG.width, FlxG.height);
		funnyCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(funnyCam, false);
		this.cameras = [funnyCam];

		if (stickerSubState != null)
		{
			this.persistentUpdate = true;
			this.persistentDraw = true;

			openSubState(stickerSubState);
			stickerSubState.degenStickers();
		}

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence('In the Menus', null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// if (prepForNewRank == false)
		// {
		//   //FlxG.sound.playMusic(Paths.music('freakyMenu'));
		// }

		// Add a null entry that represents the RANDOM option
		songs.push(null);
		// Init psych's weeks
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		// programmatically adds the songs via LevelRegistry and SongRegistry
		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]); // TODO tweak this

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				// trace("pushing "+song);
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				var sngCard = new FreeplaySongData(i, song[0], song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				// songName, weekNum, songCharacter, color
				if (sngCard.songDifficulties.length == 0)
					continue;

				songs.push(sngCard);
				for (difficulty in sngCard.songDifficulties)
				{
					diffIdsTotal.pushUnique(difficulty);
					if (!diffIdsTotalModBinds.exists(difficulty))
						diffIdsTotalModBinds.set(difficulty, leWeek.folder);
				}
			}
		}
		//

		// LOAD MUSIC

		// LOAD CHARACTERS

		trace(FlxG.width);
		trace(FlxG.camera.zoom);
		trace(FlxG.camera.initialZoom);
		trace(FlxCamera.defaultZoom);

		pinkBack = new FlxSprite(0, 0, Paths.image('freeplay/pinkBack'));
		pinkBack.color = 0xFFFFD4E9; // sets it to pink!
		pinkBack.x -= pinkBack.width;
		add(pinkBack);
		FlxTween.tween(pinkBack, {x: 0}, 0.6, {ease: FlxEase.quartOut});
		

		orangeBackShit = new FlxSprite(84, 440).makeSolidColor(Std.int(pinkBack.width), 75, FlxColor.WHITE);
		orangeBackShit.color = 0xFFFEDA00;
		add(orangeBackShit);

		alsoOrangeLOL = new FlxSprite(0, orangeBackShit.y).makeSolidColor(100, Std.int(orangeBackShit.height), FlxColor.WHITE);
		alsoOrangeLOL.color = 0xFFFFD400;
		add(alsoOrangeLOL);

		exitMovers.set([pinkBack, orangeBackShit, alsoOrangeLOL], {
			x: -pinkBack.width,
			y: pinkBack.y,
			speed: 0.4,
			wait: 0
		});

		//FlxSpriteUtil.alphaMaskFlxSprite(orangeBackShit, pinkBack, orangeBackShit);
		// TODO ALPHA issue
		orangeBackShit.visible = false;
		alsoOrangeLOL.visible = false;

		confirmTextGlow = new FlxSprite(-8, 115).loadGraphic(Paths.image('freeplay/glowingText'));
		confirmTextGlow.blend = BlendMode.ADD;
		confirmTextGlow.visible = false;

		confirmGlow = new FlxSprite(-30, 240).loadGraphic(Paths.image('freeplay/confirmGlow'));
		confirmGlow.blend = BlendMode.ADD;

		confirmGlow2 = new FlxSprite(confirmGlow.x, confirmGlow.y).loadGraphic(Paths.image('freeplay/confirmGlow2'));

		confirmGlow.visible = false;
		confirmGlow2.visible = false;

		add(confirmGlow2);
		add(confirmGlow);

		add(confirmTextGlow);

		var grpTxtScrolls:FlxGroup = new FlxGroup();
		add(grpTxtScrolls);
		grpTxtScrolls.visible = false;

		FlxG.debugger.addTrackerProfile(new TrackerProfile(BGScrollingText, ['x', 'y', 'speed', 'size']));

		moreWays = new BGScrollingText(0, 160, 'VOTE EM OUT', FlxG.width, true, 43);
		moreWays.funnyColor = 0xFFFFF383;
		moreWays.speed = 6.8;
		grpTxtScrolls.add(moreWays);

		exitMovers.set([moreWays], {
			x: FlxG.width * 2,
			speed: 0.4,
		});

		funnyScroll = new BGScrollingText(0, 220, 'BOYFRIEND', FlxG.width / 2, false, 60);
		funnyScroll.funnyColor = 0xFFFF9963;
		funnyScroll.speed = -3.8;
		grpTxtScrolls.add(funnyScroll);

		exitMovers.set([funnyScroll], {
			x: -funnyScroll.width * 2,
			y: funnyScroll.y,
			speed: 0.4,
			wait: 0
		});

		txtNuts = new BGScrollingText(0, 285, 'PROTECT YO NUTS', FlxG.width / 2, true, 43);
		txtNuts.speed = 3.5;
		grpTxtScrolls.add(txtNuts);
		exitMovers.set([txtNuts], {
			x: FlxG.width * 2,
			speed: 0.4,
		});

		funnyScroll2 = new BGScrollingText(0, 335, 'BOYFRIEND', FlxG.width / 2, false, 60);
		funnyScroll2.funnyColor = 0xFFFF9963;
		funnyScroll2.speed = -3.8;
		grpTxtScrolls.add(funnyScroll2);

		exitMovers.set([funnyScroll2], {
			x: -funnyScroll2.width * 2,
			speed: 0.5,
		});

		moreWays2 = new BGScrollingText(0, 397, 'VOTE EM OUT', FlxG.width, true, 43);
		moreWays2.funnyColor = 0xFFFFF383;
		moreWays2.speed = 6.8;
		grpTxtScrolls.add(moreWays2);

		exitMovers.set([moreWays2], {
			x: FlxG.width * 2,
			speed: 0.4
		});

		funnyScroll3 = new BGScrollingText(0, orangeBackShit.y + 10, 'BOYFRIEND', FlxG.width / 2, 60);
		funnyScroll3.funnyColor = 0xFFFEA400;
		funnyScroll3.speed = -3.8;
		grpTxtScrolls.add(funnyScroll3);

		exitMovers.set([funnyScroll3], {
			x: -funnyScroll3.width * 2,
			speed: 0.3
		});

		backingTextYeah = new FlxAtlasSprite(640, 370, Paths.getSharedPath("images/freeplay/backing-text-yeah"), {
			FrameRate: 24.0,
			Reversed: false,
			// ?OnComplete:Void -> Void,
			ShowPivot: false,
			Antialiasing: true,
			ScrollFactor: new FlxPoint(1, 1),
		});

		add(backingTextYeah);

		cardGlow = new FlxSprite(-30, -30).loadGraphic(Paths.image('freeplay/cardGlow'));
		cardGlow.blend = BlendMode.ADD;
		cardGlow.visible = false;

		add(cardGlow);

		dj = new DJBoyfriend(640, 366);
		exitMovers.set([dj], {
			x: -dj.width * 1.6,
			speed: 0.5
		});

		// TODO: Replace this.
		if (currentCharacter == 'pico')
			dj.visible = false;

		add(dj);

		bgDad = new FlxSprite(pinkBack.width * 0.74, 0).loadGraphic(Paths.image('freeplay/freeplayBGdad'));
		bgDad.shader = new AngleMask();
		bgDad.visible = false;

		var blackOverlayBullshitLOLXD:FlxSprite = new FlxSprite(FlxG.width,0,Paths.image("back"));
		blackOverlayBullshitLOLXD.alpha = 1;
		add(blackOverlayBullshitLOLXD); // used to mask the text lol!
		
		
		// this makes the texture sizes consistent, for the angle shader
		bgDad.setGraphicSize(0, FlxG.height);
		blackOverlayBullshitLOLXD.setGraphicSize(0, FlxG.height);

		bgDad.updateHitbox();
		blackOverlayBullshitLOLXD.updateHitbox();

		exitMovers.set([blackOverlayBullshitLOLXD, bgDad], {
			x: FlxG.width * 1.5,
			speed: 0.4,
			wait: 0
		});
		
		add(bgDad);
		FlxTween.tween(blackOverlayBullshitLOLXD, {x: (pinkBack.width * 0.74)-37}, 0.7, {ease: FlxEase.quintOut});

		blackOverlayBullshitLOLXD.shader = bgDad.shader;

		rankBg = new FlxSprite(0, 0);
		rankBg.makeSolidColor(FlxG.width, FlxG.height, 0xD3000000);
		add(rankBg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		grpCapsules = new FlxTypedGroup<SongMenuItem>();
		add(grpCapsules);

		grpFallbackDifficulty = new FlxText(70,90,250,"AAAAAAAAAAAAAA");
		grpFallbackDifficulty.setFormat("VCR OSD Mono",60,FlxColor.WHITE,CENTER,OUTLINE,FlxColor.BLACK);
		grpFallbackDifficulty.borderSize = 2;
		add(grpFallbackDifficulty);

		grpDifficulties = new FlxTypedSpriteGroup<DifficultySprite>(-300, 80);
		add(grpDifficulties);

		exitMovers.set([grpDifficulties], {
			x: -300,
			speed: 0.25,
			wait: 0
		});

		for (diffId in diffIdsTotal)
		{
			Mods.currentModDirectory = diffIdsTotalModBinds.get(diffId);
			var diffSprite:DifficultySprite = new DifficultySprite(diffId);
			diffSprite.difficultyId = diffId;
			diffSprite.x = -((diffSprite.width/2)-106);
			grpDifficulties.add(diffSprite);
		}

		grpDifficulties.group.forEach(function(spr)
		{
			spr.visible = false;
		});

		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty)
				diffSprite.visible = true;
		}

		// albumRoll = new AlbumRoll();
		// albumRoll.albumId = null;
		// add(albumRoll);

		// albumRoll.applyExitMovers(exitMovers);

		var overhangStuff:FlxSprite = new FlxSprite().makeSolidColor(FlxG.width, 64, FlxColor.BLACK);
		overhangStuff.y -= overhangStuff.height;
		add(overhangStuff);
		FlxTween.tween(overhangStuff, {y: 0}, 0.3, {ease: FlxEase.quartOut});

		var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
		fnfFreeplay.font = 'VCR OSD Mono';
		fnfFreeplay.visible = false;

		ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);
		ostName.font = 'VCR OSD Mono';
		ostName.alignment = RIGHT;
		ostName.visible = false;

		exitMovers.set([overhangStuff, fnfFreeplay, ostName], {
			y: -overhangStuff.height,
			x: 0,
			speed: 0.2,
			wait: 0
		});

		var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);
		fnfFreeplay.shader = sillyStroke;
		ostName.shader = sillyStroke;
		add(fnfFreeplay);
		add(ostName);

		var fnfHighscoreSpr:FlxSprite = new FlxSprite(860, 70);
		fnfHighscoreSpr.frames = Paths.getSparrowAtlas('freeplay/highscore');
		fnfHighscoreSpr.animation.addByPrefix('highscore', 'highscore small instance 1', 24, false);
		fnfHighscoreSpr.visible = false;
		fnfHighscoreSpr.setGraphicSize(0, Std.int(fnfHighscoreSpr.height * 1));
		fnfHighscoreSpr.updateHitbox();
		add(fnfHighscoreSpr);

		new FlxTimer().start(FlxG.random.float(12, 50), function(tmr)
		{
			fnfHighscoreSpr.animation.play('highscore');
			tmr.time = FlxG.random.float(20, 60);
		}, 0);

		fp = new FreeplayScore(460, 60, 7, 100);
		fp.visible = false;
		add(fp);

		var clearBoxSprite:FlxSprite = new FlxSprite(1165, 65).loadGraphic(Paths.image('freeplay/clearBox'));
		clearBoxSprite.visible = false;
		add(clearBoxSprite);

		txtCompletion = new AtlasText(1185, 87, '69', AtlasFont.FREEPLAY_CLEAR);
		txtCompletion.visible = false;
		add(txtCompletion);

		letterSort = new LetterSort(400, 75);
		add(letterSort);
		letterSort.visible = false;

		exitMovers.set([letterSort], {
			y: -100,
			speed: 0.3
		});

		letterSort.changeSelectionCallback = (str) ->
		{
			switch (str)
			{
				case 'fav':
					generateSongList({filterType: FAVORITE}, true);
				case 'ALL':
					generateSongList(null, true);
				case '#':
					generateSongList({filterType: REGEXP, filterData: '0-9'}, true);
				default:
					generateSongList({filterType: REGEXP, filterData: str}, true);
			}

			// We want to land on the first song of the group, rather than random song when changing letter sorts
			// that is, only if there's more than one song in the group!
			if (grpCapsules.members.length > 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				curSelected = 1;
				changeSelection();
			}
		};

		exitMovers.set([fp, txtCompletion, fnfHighscoreSpr, txtCompletion, clearBoxSprite], {
			x: FlxG.width,
			speed: 0.3
		});

		var diffSelLeft:DifficultySelector = new DifficultySelector(20, grpDifficulties.y - 10, false, controls);
		var diffSelRight:DifficultySelector = new DifficultySelector(325, grpDifficulties.y - 10, true, controls);
		diffSelLeft.visible = false;
		diffSelRight.visible = false;
		add(diffSelLeft);
		add(diffSelRight);

		// be careful not to "add()" things in here unless it's to a group that's already added to the state
		// otherwise it won't be properly attatched to funnyCamera (relavent code should be at the bottom of create())
		dj.onIntroDone.add(function()
		{
			// when boyfriend hits dat shiii

			// albumRoll.playIntro();

			FlxTween.tween(grpDifficulties, {x: 90}, 0.6, {ease: FlxEase.quartOut});

			diffSelLeft.visible = true;
			diffSelRight.visible = true;
			letterSort.visible = true;

			exitMovers.set([diffSelLeft, diffSelRight], {
				x: -diffSelLeft.width * 2,
				speed: 0.26
			});

			new FlxTimer().start(1 / 24, function(handShit)
			{
				fnfHighscoreSpr.visible = true;
				fnfFreeplay.visible = true;
				ostName.visible = true;
				fp.visible = true;
				fp.updateScore(0);

				clearBoxSprite.visible = true;
				txtCompletion.visible = true;
				intendedCompletion = 0;

				new FlxTimer().start(1.5 / 24, function(bold)
				{
					sillyStroke.width = 0;
					sillyStroke.height = 0;
					changeSelection();
				});
			});

			if(colorTween == null) pinkBack.color = 0xFFFFD863;
			bgDad.visible = true;
			pinkBack.visible = true;
			orangeBackShit.visible = true;
			alsoOrangeLOL.visible = true;
			grpTxtScrolls.visible = true;

			// render optimisation
			if (_parentState != null)
				_parentState.persistentDraw = false;

			cardGlow.visible = true;
			FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});

			if (prepForNewRank)
			{
				rankAnimStart(fromResultsParams);
			}
		});

		generateSongList(null, false);

		// dedicated camera for the state so we don't need to fuk around with camera scrolls from the mainmenu / elsewhere
		funnyCam = new PsychCamera(0, 0, FlxG.width, FlxG.height);
		funnyCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(funnyCam, false);

		rankVignette = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/rankVignette'));
		rankVignette.scale.set(2, 2);
		rankVignette.updateHitbox();
		rankVignette.blend = BlendMode.ADD;
		// rankVignette.cameras = [rankCamera];
		add(rankVignette);
		rankVignette.alpha = 0;

		forEach(function(bs)
		{
			bs.cameras = [funnyCam];
		});

		rankCamera = new PsychCamera(0, 0, FlxG.width, FlxG.height);
		rankCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(rankCamera, false);
		rankBg.cameras = [rankCamera];
		rankBg.alpha = 0;

		if (prepForNewRank)
		{
			rankCamera.fade(0xFF000000, 0, false, null, true);
		}
	}

	var currentFilter:SongFilter = null;
	var currentFilteredSongs:Array<FreeplaySongData> = [];

	/**
	 * Given the current filter, rebuild the current song list.
	 *
	 * @param filterStuff A filter to apply to the song list (regex, startswith, all, favorite)
	 * @param force Whether the capsules should "jump" back in or not using their animation
	 * @param onlyIfChanged Only apply the filter if the song list has changed
	 */
	public function generateSongList(filterStuff:Null<SongFilter>, force:Bool = false, onlyIfChanged:Bool = true):Void
	{
		var tempSongs:Array<FreeplaySongData> = songs;

		// Remember just the difficulty because it's important for song sorting.
		if (rememberedDifficulty != null)
		{
			currentDifficulty = rememberedDifficulty;
		}

		if (filterStuff != null)
			tempSongs = sortSongs(tempSongs, filterStuff);

		// Filter further by current selected difficulty.
		if (currentDifficulty != null)
		{
			tempSongs = tempSongs.filter(song ->
			{
				if (song == null)
					return true; // Random
				return song.songDifficulties.contains(currentDifficulty);
			});
		}

		if (onlyIfChanged)
		{
			// == performs equality by reference
			if (tempSongs.isEqualUnordered(currentFilteredSongs))
				return;
		}

		// Only now do we know that the filter is actually changing.

		// If curSelected is 0, the result will be null and fall back to the rememberedSongId.
		rememberedSongId = grpCapsules.members[curSelected]?.songData?.songId ?? rememberedSongId;

		for (cap in grpCapsules.members)
		{
			cap.songText.resetText();
			cap.kill();
		}

		currentFilter = filterStuff;

		currentFilteredSongs = tempSongs;
		curSelected = 0;

		var hsvShader:HSVShader = new HSVShader();

		var randomCapsule:SongMenuItem = grpCapsules.recycle(SongMenuItem);
		randomCapsule.init(FlxG.width, 0, null);
		randomCapsule.onConfirm = function()
		{
			capsuleOnConfirmRandom(randomCapsule);
		};
		randomCapsule.y = randomCapsule.intendedY(0) + 10;
		randomCapsule.targetPos.x = randomCapsule.x;
		randomCapsule.alpha = 0;
		randomCapsule.songText.visible = false;
		randomCapsule.favIcon.visible = false;
		randomCapsule.favIconBlurred.visible = false;
		randomCapsule.ranking.visible = false;
		randomCapsule.blurredRanking.visible = false;
		randomCapsule.initJumpIn(0, force);
		randomCapsule.hsvShader = hsvShader;
		grpCapsules.add(randomCapsule);

		for (i in 0...tempSongs.length)
		{
			if (tempSongs[i] == null)
				continue;
			//TODO
			var funnyMenu:SongMenuItem = grpCapsules.recycle(SongMenuItem); 

			funnyMenu.init(FlxG.width, 0, tempSongs[i]);
			funnyMenu.onConfirm = function()
			{
				capsuleOnConfirmDefault(funnyMenu);
			};
			funnyMenu.y = funnyMenu.intendedY(i + 1) + 10;
			funnyMenu.targetPos.x = funnyMenu.x;
			funnyMenu.ID = i;
			funnyMenu.capsule.alpha = 0.5;
			funnyMenu.songText.visible = false;
			funnyMenu.favIcon.visible = tempSongs[i].isFav;
			funnyMenu.favIconBlurred.visible = tempSongs[i].isFav;
			funnyMenu.hsvShader = hsvShader;

			funnyMenu.newText.animation.curAnim.curFrame = 45 - ((i * 4) % 45);
			funnyMenu.checkClip();
			funnyMenu.forcePosition();

			grpCapsules.add(funnyMenu);
		}

		FlxG.console.registerFunction('changeSelection', changeSelection);

		rememberSelection();

		changeSelection();
		changeDiff(0, true);
	}

	/**
	 * Filters an array of songs based on a filter
	 * @param songsToFilter What data to use when filtering
	 * @param songFilter The filter to apply
	 * @return Array<FreeplaySongData>
	 */
	public function sortSongs(songsToFilter:Array<FreeplaySongData>, songFilter:SongFilter):Array<FreeplaySongData>
	{
		var filterAlphabetically = function(a:FreeplaySongData, b:FreeplaySongData):Int
		{
			if (a?.songName.toLowerCase() < b?.songName.toLowerCase())
				return -1;
			else if (a?.songName.toLowerCase() > b?.songName.toLowerCase())
				return 1;
			else
				return 0;
		};

		switch (songFilter.filterType)
		{
			case REGEXP:
				// filterStuff.filterData has a string with the first letter of the sorting range, and the second one
				// this creates a filter to return all the songs that start with a letter between those two

				// if filterData looks like "A-C", the regex should look something like this: ^[A-C].*
				// to get every song that starts between A and C
				var filterRegexp:EReg = new EReg('^[' + songFilter.filterData + '].*', 'i');
				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return filterRegexp.match(str.songName);
				});

				songsToFilter.sort(filterAlphabetically);

			case STARTSWITH:
				// extra note: this is essentially a "search"

				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return str.songName.toLowerCase().startsWith(songFilter.filterData);
				});
			case ALL:
			// no filter!
			case FAVORITE:
				songsToFilter = songsToFilter.filter(str ->
				{
					if (str == null)
						return true; // Random
					return str.isFav;
				});

				songsToFilter.sort(filterAlphabetically);

			default:
				// return all on default
		}

		return songsToFilter;
	}

	var sparks:FlxSprite;
	var sparksADD:FlxSprite;

	function rankAnimStart(fromResults:Null<FromResultsParams>):Void
	{
		busy = true;
		grpCapsules.members[curSelected].sparkle.alpha = 0;
		// grpCapsules.members[curSelected].forcePosition();

		if (fromResults != null)
		{
			rememberedSongId = fromResults.songId;
			rememberedDifficulty = fromResults.difficultyId;
			changeSelection();
			changeDiff();
		}

		dj.fistPump();
		// rankCamera.fade(FlxColor.BLACK, 0.5, true);
		rankCamera.fade(0xFF000000, 0.5, true, null, true);
		if (FlxG.sound.music != null)
			FlxG.sound.music.volume = 0;
		rankBg.alpha = 1;

		if (fromResults?.oldRank != null)
		{
			grpCapsules.members[curSelected].fakeRanking.rank = fromResults.oldRank;
			grpCapsules.members[curSelected].fakeBlurredRanking.rank = fromResults.oldRank;

			sparks = new FlxSprite(0, 0);
			sparks.frames = Paths.getSparrowAtlas('freeplay/sparks');
			sparks.animation.addByPrefix('sparks', 'sparks', 24, false);
			sparks.visible = false;
			sparks.blend = BlendMode.ADD;
			sparks.setPosition(517, 134);
			sparks.scale.set(0.5, 0.5);
			add(sparks);
			sparks.cameras = [rankCamera];

			sparksADD = new FlxSprite(0, 0);
			sparksADD.visible = false;
			sparksADD.frames = Paths.getSparrowAtlas('freeplay/sparksadd');
			sparksADD.animation.addByPrefix('sparks add', 'sparks add', 24, false);
			sparksADD.setPosition(498, 116);
			sparksADD.blend = BlendMode.ADD;
			sparksADD.scale.set(0.5, 0.5);
			add(sparksADD);
			sparksADD.cameras = [rankCamera];

			switch (fromResults.oldRank)
			{
				case SHIT:
					sparksADD.color = 0xFF6044FF;
				case GOOD:
					sparksADD.color = 0xFFEF8764;
				case GREAT:
					sparksADD.color = 0xFFEAF6FF;
				case EXCELLENT:
					sparksADD.color = 0xFFFDCB42;
				case PERFECT:
					sparksADD.color = 0xFFFF58B4;
				case PERFECT_GOLD:
					sparksADD.color = 0xFFFFB619;
			}
			// sparksADD.color = sparks.color;
		}

		grpCapsules.members[curSelected].doLerp = false;

		// originalPos.x = grpCapsules.members[curSelected].x;
		// originalPos.y = grpCapsules.members[curSelected].y;

		originalPos.x = 320.488;
		originalPos.y = 235.6;
		trace(originalPos);

		grpCapsules.members[curSelected].ranking.visible = false;
		grpCapsules.members[curSelected].blurredRanking.visible = false;

		rankCamera.zoom = 1.85;
		FlxTween.tween(rankCamera, {"zoom": 1.8}, 0.6, {ease: FlxEase.sineIn});

		funnyCam.zoom = 1.15;
		FlxTween.tween(funnyCam, {"zoom": 1.1}, 0.6, {ease: FlxEase.sineIn});

		grpCapsules.members[curSelected].cameras = [rankCamera];
		// grpCapsules.members[curSelected].targetPos.set((FlxG.width / 2) - (grpCapsules.members[curSelected].width / 2),
		//  (FlxG.height / 2) - (grpCapsules.members[curSelected].height / 2));

		grpCapsules.members[curSelected].setPosition((FlxG.width / 2) - (grpCapsules.members[curSelected].width / 2),
			(FlxG.height / 2) - (grpCapsules.members[curSelected].height / 2));

		new FlxTimer().start(0.5, _ ->
		{
			rankDisplayNew(fromResults);
		});
	}

	function rankDisplayNew(fromResults:Null<FromResultsParams>):Void
	{
		grpCapsules.members[curSelected].ranking.visible = true;
		grpCapsules.members[curSelected].blurredRanking.visible = true;
		grpCapsules.members[curSelected].ranking.scale.set(20, 20);
		grpCapsules.members[curSelected].blurredRanking.scale.set(20, 20);

		if (fromResults?.newRank != null)
		{
			grpCapsules.members[curSelected].ranking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}

		FlxTween.tween(grpCapsules.members[curSelected].ranking, {"scale.x": 1, "scale.y": 1}, 0.1);

		if (fromResults?.newRank != null)
		{
			grpCapsules.members[curSelected].blurredRanking.animation.play(fromResults.newRank.getFreeplayRankIconAsset(), true);
		}
		FlxTween.tween(grpCapsules.members[curSelected].blurredRanking, {"scale.x": 1, "scale.y": 1}, 0.1);

		new FlxTimer().start(0.1, _ ->
		{
			if (fromResults?.oldRank != null)
			{
				grpCapsules.members[curSelected].fakeRanking.visible = false;
				grpCapsules.members[curSelected].fakeBlurredRanking.visible = false;

				sparks.visible = true;
				sparksADD.visible = true;
				sparks.animation.play('sparks', true);
				sparksADD.animation.play('sparks add', true);

				sparks.animation.finishCallback = anim ->
				{
					sparks.visible = false;
					sparksADD.visible = false;
				};
			}

			switch (fromResultsParams?.newRank)
			{
				case SHIT:
					FlxG.sound.play(Paths.sound('ranks/rankinbad'));
				case PERFECT:
					FlxG.sound.play(Paths.sound('ranks/rankinperfect'));
				case PERFECT_GOLD:
					FlxG.sound.play(Paths.sound('ranks/rankinperfect'));
				default:
					FlxG.sound.play(Paths.sound('ranks/rankinnormal'));
			}
			rankCamera.zoom = 1.3;

			FlxTween.tween(rankCamera, {"zoom": 1.5}, 0.3, {ease: FlxEase.backInOut});

			grpCapsules.members[curSelected].x -= 10;
			grpCapsules.members[curSelected].y -= 20;

			FlxTween.tween(funnyCam, {"zoom": 1.05}, 0.3, {ease: FlxEase.elasticOut});

			grpCapsules.members[curSelected].capsule.angle = -3;
			FlxTween.tween(grpCapsules.members[curSelected].capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

			IntervalShake.shake(grpCapsules.members[curSelected].capsule, 0.3, 1 / 30, 0.1, 0, FlxEase.quadOut);
		});

		new FlxTimer().start(0.4, _ ->
		{
			FlxTween.tween(funnyCam, {"zoom": 1}, 0.8, {ease: FlxEase.sineIn});
			FlxTween.tween(rankCamera, {"zoom": 1.2}, 0.8, {ease: FlxEase.backIn});
			FlxTween.tween(grpCapsules.members[curSelected], {x: originalPos.x - 7, y: originalPos.y - 80}, 0.8 + 0.5, {ease: FlxEase.quartIn});
		});

		new FlxTimer().start(0.6, _ ->
		{
			rankAnimSlam(fromResults);
		});
	}

	function rankAnimSlam(fromResultsParams:Null<FromResultsParams>)
	{
		// FlxTween.tween(rankCamera, {"zoom": 1.9}, 0.5, {ease: FlxEase.backOut});
		FlxTween.tween(rankBg, {alpha: 0}, 0.5, {ease: FlxEase.expoIn});

		// FlxTween.tween(grpCapsules.members[curSelected], {angle: 5}, 0.5, {ease: FlxEase.backIn});

		switch (fromResultsParams?.newRank)
		{
			case SHIT:
				FlxG.sound.play(Paths.sound('ranks/loss'));
			case GOOD:
				FlxG.sound.play(Paths.sound('ranks/good'));
			case GREAT:
				FlxG.sound.play(Paths.sound('ranks/great'));
			case EXCELLENT:
				FlxG.sound.play(Paths.sound('ranks/excellent'));
			case PERFECT:
				FlxG.sound.play(Paths.sound('ranks/perfect'));
			case PERFECT_GOLD:
				FlxG.sound.play(Paths.sound('ranks/perfect'));
			default:
				FlxG.sound.play(Paths.sound('ranks/loss'));
		}

		FlxTween.tween(grpCapsules.members[curSelected], {"targetPos.x": originalPos.x, "targetPos.y": originalPos.y}, 0.5, {ease: FlxEase.expoOut});
		new FlxTimer().start(0.5, _ ->
		{
			funnyCam.shake(0.0045, 0.35);

			if (fromResultsParams?.newRank == SHIT)
			{
				dj.pumpFistBad();
			}
			else
			{
				dj.pumpFist();
			}

			rankCamera.zoom = 0.8;
			funnyCam.zoom = 0.8;
			FlxTween.tween(rankCamera, {"zoom": 1}, 1, {ease: FlxEase.elasticOut});
			FlxTween.tween(funnyCam, {"zoom": 1}, 0.8, {ease: FlxEase.elasticOut});

			for (index => capsule in grpCapsules.members)
			{
				var distFromSelected:Float = Math.abs(index - curSelected) - 1;

				if (distFromSelected < 5)
				{
					if (index == curSelected)
					{
						FlxTween.cancelTweensOf(capsule);
						// capsule.targetPos.x += 50;
						capsule.fadeAnim();

						rankVignette.color = capsule.getTrailColor();
						rankVignette.alpha = 1;
						FlxTween.tween(rankVignette, {alpha: 0}, 0.6, {ease: FlxEase.expoOut});

						capsule.doLerp = false;
						capsule.setPosition(originalPos.x, originalPos.y);
						IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12, 0, FlxEase.quadOut, function(_)
						{
							capsule.doLerp = true;
							capsule.cameras = [funnyCam];

							// NOW we can interact with the menu
							busy = false;
							grpCapsules.members[curSelected].sparkle.alpha = 0.7;
							
							
							playCurSongPreview(capsule);
						}, null);

						// FlxTween.tween(capsule, {"targetPos.x": capsule.targetPos.x - 50}, 0.6,
						//   {
						//     ease: FlxEase.backInOut,
						//     onComplete: function(_) {
						//       capsule.cameras = [funnyCam];
						//     }
						//   });
						FlxTween.tween(capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});
					}
					if (index > curSelected)
					{
						// capsule.color = FlxColor.RED;
						new FlxTimer().start(distFromSelected / 20, _ ->
						{
							capsule.doLerp = false;

							capsule.capsule.angle = FlxG.random.float(-10 + (distFromSelected * 2), 10 - (distFromSelected * 2));
							FlxTween.tween(capsule.capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

							IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12 / (distFromSelected + 1), 0, FlxEase.quadOut, function(_)
							{
								capsule.doLerp = true;
							});
						});
					}

					if (index < curSelected)
					{
						// capsule.color = FlxColor.BLUE;
						new FlxTimer().start(distFromSelected / 20, _ ->
						{
							capsule.doLerp = false;

							capsule.capsule.angle = FlxG.random.float(-10 + (distFromSelected * 2), 10 - (distFromSelected * 2));
							FlxTween.tween(capsule.capsule, {angle: 0}, 0.5, {ease: FlxEase.backOut});

							IntervalShake.shake(capsule, 0.6, 1 / 24, 0.12 / (distFromSelected + 1), 0, FlxEase.quadOut, function(_)
							{
								capsule.doLerp = true;
							});
						});
					}
				}

				index += 1;
			}
		});

		new FlxTimer().start(2, _ ->
		{
			// dj.fistPump();
			prepForNewRank = false;
		});
	}

	var touchY:Float = 0;
	var touchX:Float = 0;
	var dxTouch:Float = 0;
	var dyTouch:Float = 0;
	var velTouch:Float = 0;

	var veloctiyLoopShit:Float = 0;
	var touchTimer:Float = 0;

	var initTouchPos:FlxPoint = new FlxPoint();

	var spamTimer:Float = 0;
	var spamming:Bool = false;

	/**
	 * If true, disable interaction with the interface.
	 */
	var busy:Bool = false;

	var originalPos:FlxPoint = new FlxPoint();

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		#if debug
		if (FlxG.keys.justPressed.T)
		{
			rankAnimStart(fromResultsParams);
		}

		// if (FlxG.keys.justPressed.H)
		// {
		//   rankDisplayNew(fromResultsParams);
		// }

		// if (FlxG.keys.justPressed.G)
		// {
		//   rankAnimSlam(fromResultsParams);
		// }
		#end

		if (controls.FAVORITE && !busy)
		{
			var targetSong = grpCapsules.members[curSelected]?.songData;
			if (targetSong != null)
			{
				var realShit:Int = curSelected;
				var isFav = targetSong.toggleFavorite();
				if (isFav)
				{
					grpCapsules.members[realShit].favIcon.visible = true;
					grpCapsules.members[realShit].favIconBlurred.visible = true;
					grpCapsules.members[realShit].favIcon.animation.play('fav');
					grpCapsules.members[realShit].favIconBlurred.animation.play('fav');
					FlxG.sound.play(Paths.sound('fav'), 1);
					grpCapsules.members[realShit].checkClip();
					grpCapsules.members[realShit].selected = grpCapsules.members[realShit].selected; // set selected again, so it can run it's getter function to initialize movement
					busy = true;

					grpCapsules.members[realShit].doLerp = false;
					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y - 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y + 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							grpCapsules.members[realShit].doLerp = true;
							busy = false;
						}
					});
				}
				else
				{
					grpCapsules.members[realShit].favIcon.animation.play('fav', true, true, 9);
					grpCapsules.members[realShit].favIconBlurred.animation.play('fav', true, true, 9);
					FlxG.sound.play(Paths.sound('unfav'), 1);
					new FlxTimer().start(0.2, _ ->
					{
						grpCapsules.members[realShit].favIcon.visible = false;
						grpCapsules.members[realShit].favIconBlurred.visible = false;
						grpCapsules.members[realShit].checkClip();
					});

					busy = true;
					grpCapsules.members[realShit].doLerp = false;
					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y + 5}, 0.1, {ease: FlxEase.expoOut});

					FlxTween.tween(grpCapsules.members[realShit], {y: grpCapsules.members[realShit].y - 5}, 0.1, {
						ease: FlxEase.expoIn,
						startDelay: 0.1,
						onComplete: function(_)
						{
							grpCapsules.members[realShit].doLerp = true;
							busy = false;
						}
					});
				}
			}
		}
		lerpScore = MathUtil.smoothLerp(lerpScore, intendedScore, elapsed, 0.5);
		lerpCompletion = MathUtil.smoothLerp(lerpCompletion, intendedCompletion, elapsed, 0.5);

		if (Math.isNaN(lerpScore))
		{
			lerpScore = intendedScore;
		}

		if (Math.isNaN(lerpCompletion))
		{
			lerpCompletion = intendedCompletion;
		}

		fp.updateScore(Std.int(lerpScore));

		txtCompletion.text = '${Math.floor(lerpCompletion * 100)}';

		// Right align the completion percentage
		switch (txtCompletion.text.length)
		{
			case 3:
				txtCompletion.offset.x = 10;
			case 2:
				txtCompletion.offset.x = 0;
			case 1:
				txtCompletion.offset.x = -24;
			default:
				txtCompletion.offset.x = 0;
		}

		handleInputs(elapsed);
	}

	function handleInputs(elapsed:Float):Void
	{
		if (busy)
			return;

		var upP:Bool = controls.UI_UP_P && !FlxG.keys.pressed.CONTROL;
		var downP:Bool = controls.UI_DOWN_P && !FlxG.keys.pressed.CONTROL;
		var accepted:Bool = controls.ACCEPT && !FlxG.keys.pressed.CONTROL;

		if (FlxG.onMobile)
		{
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					initTouchPos.set(touch.screenX, touch.screenY);
				}
				if (touch.pressed)
				{
					var dx:Float = initTouchPos.x - touch.screenX;
					var dy:Float = initTouchPos.y - touch.screenY;

					var angle:Float = Math.atan2(dy, dx);
					var length:Float = Math.sqrt(dx * dx + dy * dy);

					FlxG.watch.addQuick('LENGTH', length);
					FlxG.watch.addQuick('ANGLE', Math.round(FlxAngle.asDegrees(angle)));
				}
			}

			if (FlxG.touches.getFirst() != null)
			{
				if (touchTimer >= 1.5)
					accepted = true;

				touchTimer += elapsed;
				var touch:FlxTouch = FlxG.touches.getFirst();

				velTouch = Math.abs((touch.screenY - dyTouch)) / 50;

				dyTouch = touch.screenY - touchY;
				dxTouch = touch.screenX - touchX;

				if (touch.justPressed)
				{
					touchY = touch.screenY;
					dyTouch = 0;
					velTouch = 0;

					touchX = touch.screenX;
					dxTouch = 0;
				}

				if (Math.abs(dxTouch) >= 100)
				{
					touchX = touch.screenX;
					if (dxTouch != 0)
						dxTouch < 0 ? changeDiff(1) : changeDiff(-1);
				}

				if (Math.abs(dyTouch) >= 100)
				{
					touchY = touch.screenY;

					if (dyTouch != 0)
						dyTouch < 0 ? changeSelection(1) : changeSelection(-1);
				}
			}
			else
			{
				touchTimer = 0;
			}
		}

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				// accepted = true;
			}
		}
		#end

		if (!FlxG.keys.pressed.CONTROL && (controls.UI_UP || controls.UI_DOWN))
		{
			if (spamming)
			{
				if (spamTimer >= 0.07)
				{
					spamTimer = 0;

					if (controls.UI_UP)
					{
						changeSelection(-1);
					}
					else
					{
						changeSelection(1);
					}
				}
			}
			else if (spamTimer >= 0.9)
			{
				spamming = true;
			}
			else if (spamTimer <= 0)
			{
				if (controls.UI_UP)
				{
					changeSelection(-1);
				}
				else
				{
					changeSelection(1);
				}
			}

			spamTimer += elapsed;
			dj.resetAFKTimer();
		}
		else
		{
			spamming = false;
			spamTimer = 0;
		}

		#if !html5
		if (FlxG.mouse.wheel != 0)
		{
			dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel));
		}
		#else
		if (FlxG.mouse.wheel < 0)
		{
			dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel / 8));
		}
		else if (FlxG.mouse.wheel > 0)
		{
			dj.resetAFKTimer();
			changeSelection(-Math.round(FlxG.mouse.wheel / 8));
		}
		#end

		if (controls.UI_LEFT_P && !FlxG.keys.pressed.CONTROL)
		{
			trace("Left");
			dj.resetAFKTimer();
			changeDiff(-1);
			generateSongList(currentFilter, true);
		}
		if (controls.UI_RIGHT_P && !FlxG.keys.pressed.CONTROL)
		{
			trace("Right");
			dj.resetAFKTimer();
			changeDiff(1);
			generateSongList(currentFilter, true);
		}

		if (controls.BACK)
		{
			busy = true;
			FlxTween.globalManager.clear();
			FlxTimer.globalManager.clear();
			BPMCache.instance.clearCache();	
			FlxG.signals.postStateSwitch.dispatch(); // for the screenshot plugin to clean itself
			dj.onIntroDone.removeAll();

			//While exiting make sure that we aren't tweeneng a color rn
			if(colorTween != null) {
				colorTween.cancelTween();
			}

			FlxG.sound.play(Paths.sound('cancelMenu'));
			Mods.loadTopMod();

			var longestTimer:Float = 0;

			// FlxTween.color(bgDad, 0.33, 0xFFFFFFFF, 0xFF555555, {ease: FlxEase.quadOut});
			FlxTween.color(pinkBack, 0.25, pinkBack.color, 0xFFFFD0D5, {ease: FlxEase.quadOut});

			cardGlow.visible = true;
			cardGlow.alpha = 1;
			cardGlow.scale.set(1, 1);
			FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.25, {ease: FlxEase.sineOut});

			orangeBackShit.visible = false;
			alsoOrangeLOL.visible = false;

			moreWays.visible = false;
			funnyScroll.visible = false;
			txtNuts.visible = false;
			funnyScroll2.visible = false;
			moreWays2.visible = false;
			funnyScroll3.visible = false;

			for (grpSpr in exitMovers.keys())
			{
				var moveData:MoveData = exitMovers.get(grpSpr);

				for (spr in grpSpr)
				{
					if (spr == null)
						continue;

					var funnyMoveShit:MoveData = moveData;

					if (moveData.x == null)
						funnyMoveShit.x = spr.x;
					if (moveData.y == null)
						funnyMoveShit.y = spr.y;
					if (moveData.speed == null)
						funnyMoveShit.speed = 0.2;
					if (moveData.wait == null)
						funnyMoveShit.wait = 0;

					FlxTween.tween(spr, {x: funnyMoveShit.x, y: funnyMoveShit.y}, funnyMoveShit.speed, {ease: FlxEase.expoIn});

					longestTimer = Math.max(longestTimer, funnyMoveShit.speed + funnyMoveShit.wait);
				}
			}

			for (caps in grpCapsules.members)
			{
				caps.doJumpIn = false;
				caps.doLerp = false;
				caps.doJumpOut = true;
			}

			if (Type.getClass(_parentState) == MainMenuState)
			{
				_parentState.persistentUpdate = false;
				_parentState.persistentDraw = true;
			}

			new FlxTimer().start(longestTimer, (_) ->
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (Type.getClass(_parentState) == MainMenuState)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu')); // TODO
					FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
					close();
				}
				else
				{
					FlxG.switchState(() -> new MainMenuState());
				}
			});
		}
		else if (accepted)
		{
			grpCapsules.members[curSelected].onConfirm();
		}
	}

	public override function destroy():Void
	{
		super.destroy();
		var daSong:Null<FreeplaySongData> = currentFilteredSongs[curSelected];
		if (daSong != null)
		{
			clearDaCache(daSong.songName);
		}
		// remove and destroy freeplay camera
		FlxG.cameras.remove(funnyCam);
	}

	function changeDiff(change:Int = 0, force:Bool = false):Void
	{
		touchTimer = 0;

		var currentDifficultyIndex:Int = diffIdsCurrent.indexOf(currentDifficulty);

		if (currentDifficultyIndex == -1)
			currentDifficultyIndex = diffIdsCurrent.indexOf("normal");

		currentDifficultyIndex += change;

		if (currentDifficultyIndex < 0)
			currentDifficultyIndex = diffIdsCurrent.length - 1;
		if (currentDifficultyIndex >= diffIdsCurrent.length)
			currentDifficultyIndex = 0;

		currentDifficulty = diffIdsCurrent[currentDifficultyIndex];

		var daSong:Null<FreeplaySongData> = grpCapsules.members[curSelected].songData;
		if (daSong != null)
		{
			daSong.currentDifficulty = currentDifficulty;
			var diffId = daSong.loadAndGetDiffId();//12
			var songScore:Int = Highscore.getScore(daSong.songId,
				diffId); // Save.instance.getSongScore(grpCapsules.members[curSelected].songData.songId, suffixedDifficulty);
			intendedScore = songScore ?? 0;
			intendedCompletion = Highscore.getRating(daSong.songId, diffId);
			rememberedDifficulty = currentDifficulty;
		}
		else
		{
			intendedScore = 0;
			intendedCompletion = 0.0;
		}

		if (intendedCompletion == Math.POSITIVE_INFINITY || intendedCompletion == Math.NEGATIVE_INFINITY || Math.isNaN(intendedCompletion))
		{
			intendedCompletion = 0;
		}

		grpDifficulties.group.forEach(function(diffSprite)
		{
			diffSprite.visible = false;
		});

		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty)
			{
				grpFallbackDifficulty.text = "";
				if(diffSprite.hasValidTexture){
					if (change != 0)
					{
						diffSprite.visible = true;
						diffSprite.offset.y += 5;
						diffSprite.alpha = 0.5;
						new FlxTimer().start(1 / 24, function(swag)
						{
							diffSprite.alpha = 1;
							diffSprite.updateHitbox();
						});
					}
					else { diffSprite.visible = true; }
				}
				else{
					grpFallbackDifficulty.text = diffSprite.difficultyId;
					grpFallbackDifficulty.updateHitbox();
				}
				
			}
		}

		if (change != 0 || force)
		{
			// Update the song capsules to reflect the new difficulty info.
			for (songCapsule in grpCapsules.members)
			{
				if (songCapsule == null)
					continue;
				if (songCapsule.songData != null)
				{
					songCapsule.songData.currentDifficulty = currentDifficulty;
					songCapsule.init(null, null, songCapsule.songData);
					songCapsule.checkClip();
				}
				else
				{
					songCapsule.init(null, null, null);
				}
			}
		}

		// Set the album graphic and play the animation if relevant.
		// var newAlbumId:String = daSong?.albumId;
		// if (albumRoll.albumId != newAlbumId)
		// {
		//   albumRoll.albumId = newAlbumId;
		//   albumRoll.skipIntro();
		// }

		// // Set difficulty star count.
		// albumRoll.setDifficultyStars(daSong?.difficultyRating);
	}

	// Clears the cache of songs, frees up memory, they' ll have to be loaded in later tho function clearDaCache(actualSongTho:String)
	function clearDaCache(actualSongTho:String):Void
	{
		trace("Purging song previews!");
		var cacheObj = cast(openfl.Assets.cache,AssetCache);
		@:privateAccess
		var list = cacheObj.sound.keys();
		for (song in list)
		{
			if (song == null)
				continue;
			if (!song.contains(actualSongTho) && song.contains(".partial")) //.partial
			{
				trace('trying to remove: ' + song);
				openfl.Assets.cache.clear(song);
			}
		}
	}

	function capsuleOnConfirmRandom(randomCapsule:SongMenuItem):Void
	{
		trace('RANDOM SELECTED');
		trace('"' + currentDifficulty + '"');
		busy = true;
		letterSort.inputEnabled = false;

		var availableSongCapsules:Array<SongMenuItem> = grpCapsules.members.filter(function(cap:SongMenuItem)
		{
			// Dead capsules are ones which were removed from the list when changing filters.
			return cap.alive && cap.songData != null;
		});

		trace('Available songs: ${availableSongCapsules.map(function(cap) {
      return cap.songData.songName;
    })}');

		if (availableSongCapsules.length == 0)
		{
			trace('No songs available!');
			busy = false;
			letterSort.inputEnabled = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		var targetSong:SongMenuItem = FlxG.random.getObject(availableSongCapsules);

		// Seeing if I can do an animation...
		curSelected = grpCapsules.members.indexOf(targetSong);
		changeSelection(0); // Trigger an update.

		// Act like we hit Confirm on that song.
		capsuleOnConfirmDefault(targetSong);
	}

	function capsuleOnConfirmDefault(cap:SongMenuItem):Void
	{
		busy = true;
		letterSort.inputEnabled = false;

		PlayState.isStoryMode = false;

		var targetSong = cap.songData;
		if (targetSong == null)
		{
			FlxG.log.warn('WARN: could not find song with id (${cap.songData.songId})');
			return;
		}
		// Disabling color tweener
		colorTween?.cancelTween();
		//colorTween = null;
		var targetDifficultyId:String = currentDifficulty;
		PlayState.storyWeek = cap.songData.levelId;

		//Find current difficulty sprite
		PlayState.storyDifficultyColor = FlxColor.GRAY;
		for (diffSprite in grpDifficulties.group.members)
		{
			if (diffSprite == null)
				continue;
			if (diffSprite.difficultyId == currentDifficulty){
				PlayState.storyDifficultyColor = diffSprite.difficultyColor;
				break;
			}	
		}

		// Visual and audio effects.
		FlxG.sound.play(Paths.sound('confirmMenu'));
		dj.confirm();

		grpCapsules.members[curSelected].forcePosition();
		grpCapsules.members[curSelected].songText.flickerText();

		// FlxTween.color(bgDad, 0.33, 0xFFFFFFFF, 0xFF555555, {ease: FlxEase.quadOut});
		FlxTween.color(pinkBack, 0.33, 0xFFFFD0D5, 0xFF171831, {ease: FlxEase.quadOut});
		orangeBackShit.visible = false;
		alsoOrangeLOL.visible = false;

		confirmGlow.visible = true;
		confirmGlow2.visible = true;

		backingTextYeah.anim.play("BF back card confirm raw", false, false, 0);
		confirmGlow2.alpha = 0;
		confirmGlow.alpha = 0;

		FlxTween.tween(confirmGlow2, {alpha: 0.5}, 0.33, {
			ease: FlxEase.quadOut,
			onComplete: function(_)
			{
				confirmGlow2.alpha = 0.6;
				confirmGlow.alpha = 1;
				confirmTextGlow.visible = true;
				confirmTextGlow.alpha = 1;
				FlxTween.tween(confirmTextGlow, {alpha: 0.4}, 0.5);
				FlxTween.tween(confirmGlow, {alpha: 0}, 0.5);
			}
		});

		// confirmGlow

		moreWays.visible = false;
		funnyScroll.visible = false;
		txtNuts.visible = false;
		funnyScroll2.visible = false;
		moreWays2.visible = false;
		funnyScroll3.visible = false;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			// FunkinSound.emptyPartialQueue();

			// Paths.setCurrentLevel(cap.songData.levelId);
			persistentUpdate = false;
			Mods.currentModDirectory = cap.songData.folder;

			var diffId = cap.songData.loadAndGetDiffId();
			if (diffId == -1)
			{
				trace("SELECTED DIFFICULTY IS MISSING: " + currentDifficulty);
				diffId = 0;
			}

			var songLowercase:String = Paths.formatToSongPath(cap.songData.songId);
			var poop:String = Highscore.formatSong(songLowercase, diffId); // TODO //currentDifficulty);
			/*#if MODS_ALLOWED
				if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				#else
				if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = diffId;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch (e:Dynamic)
			{
				trace('ERROR! $e');
				busy = false;
				letterSort.inputEnabled = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				return;
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;

			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		});
	}

	function rememberSelection():Void
	{
		if (rememberedSongId != null)
		{
			curSelected = currentFilteredSongs.findIndex(function(song)
			{
				if (song == null)
					return false;
				return song.songId == rememberedSongId;
			});

			if (curSelected == -1)
				curSelected = 0;
		}

		if (rememberedDifficulty != null)
		{
			currentDifficulty = rememberedDifficulty;
		}
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function changeSelection(change:Int = 0):Void
	{
		var prevSelected:Int = curSelected;

		curSelected += change;

		if (!prepForNewRank && curSelected != prevSelected)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = grpCapsules.countLiving() - 1;
		if (curSelected >= grpCapsules.countLiving())
			curSelected = 0;

		var daSongCapsule:SongMenuItem = grpCapsules.members[curSelected];
		if (daSongCapsule.songData != null)
		{

			//Difficulty.loadFromWeek(WeekData.weeksLoaded.get(daSongCapsule.songData.levelName));
			//var diffId = Difficulty.list.findIndex(s -> s.trim().toLowerCase() == currentDifficulty);

			//var songScore:Int = Highscore.getScore(daSongCapsule.songData.songId, diffId);
			//intendedScore = songScore ?? 0;
			//intendedCompletion = Highscore.getRating(daSongCapsule.songData.songId, diffId);
			diffIdsCurrent = daSongCapsule.songData.songDifficulties;
			rememberedSongId = daSongCapsule.songData.songId;
			changeDiff();
		}
		else
		{
			intendedScore = 0;
			intendedCompletion = 0.0;
			diffIdsCurrent = diffIdsTotal;
			rememberedSongId = null;
			rememberedDifficulty = null;
			// albumRoll.albumId = null;
		}

		for (index => capsule in grpCapsules.members)
		{
			index += 1;

			capsule.selected = index == curSelected + 1;

			capsule.targetPos.y = capsule.intendedY(index - curSelected);
			capsule.targetPos.x = 270 + (60 * (Math.sin(index - curSelected)));

			if (index < curSelected)
				capsule.targetPos.y -= 100; // another 100 for good measure
		}

		if (grpCapsules.countLiving() > 0 && !prepForNewRank)
		{
			if (daSongCapsule.songData != null)
			{
				Mods.currentModDirectory = daSongCapsule.songData.folder;
				PlayState.storyWeek = daSongCapsule.songData.levelId; // TODO
				Difficulty.loadFromWeek();
			}

			FlxG.sound.music.pause(); // muting previous track must be done NOW
			FlxTimer.wait(FADE_IN_DELAY,playCurSongPreview.bind(daSongCapsule)); // Wait a little before trying to pull a Inst file
			
			if (colorTween != null) tweenCurSongColor(daSongCapsule);
			grpCapsules.members[curSelected].selected = true;
		}
		else if (prepForNewRank && colorTween != null) tweenCurSongColor(daSongCapsule);
	}

	public function playCurSongPreview(daSongCapsule:SongMenuItem):Void
	{
		if (curSelected == 0)
		{
			FlxG.sound.playMusic(Paths.music('freeplayRandom'), 0);
			FlxG.sound.music.fadeIn(2, 0, 0.8);
		}
		else
		{
			if(!daSongCapsule.selected) return;
			var potentiallyErect:String = (currentDifficulty == "erect") || (currentDifficulty == "nightmare") ? "-erect" : "";
			var instPath = "";
			
			try{
				var songData = daSongCapsule.songData;
				Mods.currentModDirectory = songData.folder;

				instPath = 'assets/songs/${Paths.formatToSongPath(songData.songId)}/Inst.${Paths.SOUND_EXT}';
				#if MODS_ALLOWED
				var modsInstPath = Paths.modFolders('songs/${Paths.formatToSongPath(songData.songId)}/Inst.${Paths.SOUND_EXT}');
				if(FileSystem.exists(modsInstPath)) instPath = modsInstPath;
				#end
				
				var future = FlxPartialSound.partialLoadFromFile(instPath, songData.freeplayPrevStart,songData.freeplayPrevEnd);
				if(future == null){
					trace('Internal failure loading instrumentals for ${songData.songName} "${instPath}"');
					return;
				}
				future.future.onComplete(function(sound:Sound)
					{
						if(!daSongCapsule.selected || busy) return;
						trace("Playing preview!");
						FlxG.sound.playMusic(sound,0);
						var endVolume = dj.playingCartoon? 0.1 : FADE_IN_END_VOLUME;
						FlxG.sound.music.fadeIn(FADE_IN_DURATION, FADE_IN_START_VOLUME, endVolume);
					});
			}
			catch (x){
				var targetPath = instPath == "" ? "" : "from "+instPath;
				trace('Failed to parialy load instrumentals for ${daSongCapsule.songData.songName} ${targetPath}');
			}
			
		}
	}
	public function tweenCurSongColor(daSongCapsule:SongMenuItem) { //H1
		var newColor:FlxColor = (curSelected == 0)? 0xFFFFD863 : daSongCapsule.songData.color;
		colorTween.tweenColor(newColor);
	}

	/**
	 * Build an instance of `FreeplayState` that is above the `MainMenuState`.
	 * @return The MainMenuState with the FreeplayState as a substate.
	 */
	public static function build(?params:FreeplayStateParams, ?stickers:StickerSubState):MusicBeatState
	{
		var result:MainMenuState;
		
		if (params?.fromResults.playRankAnim)
			result = new MainMenuState(true);
		else
			result = new MainMenuState(false);

		result.openSubState(new FreeplayState(params, stickers));
		result.persistentUpdate = false;
		result.persistentDraw = true;
		return result;
	}
}

/**
 * The difficulty selector arrows to the left and right of the difficulty.
 */
class DifficultySelector extends FlxSprite
{
	var controls:Controls;
	var whiteShader:PureColor;

	public function new(x:Float, y:Float, flipped:Bool, controls:Controls)
	{
		super(x, y);

		this.controls = controls;

		frames = Paths.getSparrowAtlas('freeplay/freeplaySelector');
		animation.addByPrefix('shine', 'arrow pointer loop', 24);
		animation.play('shine');

		whiteShader = new PureColor(FlxColor.WHITE);

		shader = whiteShader;

		flipX = flipped;
	}

	override function update(elapsed:Float):Void
	{
		if (flipX && controls.UI_RIGHT_P && !FlxG.keys.pressed.CONTROL)
			moveShitDown();
		if (!flipX && controls.UI_LEFT_P && !FlxG.keys.pressed.CONTROL)
			moveShitDown();

		super.update(elapsed);
	}

	function moveShitDown():Void
	{
		offset.y -= 5;

		whiteShader.colorSet = true;

		scale.x = scale.y = 0.5;

		new FlxTimer().start(2 / 24, function(tmr)
		{
			scale.x = scale.y = 1;
			whiteShader.colorSet = false;
			updateHitbox();
		});
	}
}

/**
 * Structure for the current song filter.
 */
typedef SongFilter =
{
	var filterType:FilterType;
	var ?filterData:Dynamic;
}

/**
 * Possible types to use for the song filter.
 */
enum abstract FilterType(String)
{
	/**
	 * Filter to songs which start with a string
	 */
	public var STARTSWITH;

	/**
	 * Filter to songs which match a regular expression
	 */
	public var REGEXP;

	/**
	 * Filter to songs which are favorited
	 */
	public var FAVORITE;

	/**
	 * Filter to all songs
	 */
	public var ALL;
}

/**
 * Data about a specific song in the freeplay menu.
 */
class FreeplaySongData
{
	/**
	 * Whether or not the song has been favorited.
	 */
	public var isFav:Bool = false;

	public var isNew:Bool = false;
	public var folder:String = "";
	public var color:Int = -7179779;

	public var levelId(default, null):Int = 0;
	public var levelName(default, null):String = "";
	public var songId(default, null):String = '';

	public var songDifficulties(default, null):Array<String> = [];

	public var songName(default, null):String = '';
	public var songCharacter(default, null):String = '';
	public var songStartingBpm(default, null):Float = 0;
	public var difficultyRating(default, null):Int = 0;

	public var freeplayPrevStart(default, null):Float = 0;
	public var freeplayPrevEnd(default, null):Float = 0;
	public var currentDifficulty(default, set):String = "normal";

	public var scoringRank:Null<ScoringRank> = null;

	function set_currentDifficulty(value:String):String
	{
		currentDifficulty = value;
		updateValues();
		return value;
	}

	public function new(levelId:Int, songId:String, songCharacter:String, color:FlxColor)
	{
		this.levelId = levelId;
		this.songName = songId.replace("-", " ");
		this.songCharacter = songCharacter;
		this.color = color;
		this.songId = songId;

		var meta = FreeplayMeta.getMeta(songId);
		difficultyRating = meta.songRating;
		freeplayPrevStart = meta.freeplayPrevStart;
		freeplayPrevEnd = meta.freeplayPrevEnd;

		updateValues();

		this.isFav = ClientPrefs.data.favSongIds.contains(songId+this.levelName);//Save.instance.isSongFavorited(songId);
	}

	/**
	 * Toggle whether or not the song is favorited, then flush to save data.
	 * @return Whether or not the song is now favorited.
	 */
	public function toggleFavorite():Bool
	{
		isFav = !isFav;
		if (isFav)
		{
			ClientPrefs.data.favSongIds.pushUnique(this.songId+this.levelName);
		}
		else
		{
			ClientPrefs.data.favSongIds.remove(this.songId+this.levelName);
		}
		ClientPrefs.saveSettings();
		return isFav;
	}

	function updateValues():Void
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);

		levelName = leWeek.weekName;
		this.songDifficulties = leWeek.difficulties.extractWeeks();
		this.folder = leWeek.folder;

		Mods.currentModDirectory = this.folder;
		var fileSngName = Paths.formatToSongPath(songId);
		var sngDataPath = Paths.getSharedPath("data/"+fileSngName);

		#if MODS_ALLOWED
		var mod_path = Paths.modFolders("data/"+fileSngName);
		if(FileSystem.exists(mod_path)) sngDataPath = mod_path;
		#end
		
		//if(sngDataPath == null) return;
		
		if(this.songDifficulties.length == 0){
			if(FileSystem.exists(sngDataPath)){
				var chartFiles = FileSystem.readDirectory(sngDataPath)
				.filter(s -> s.toLowerCase().startsWith(fileSngName) && s.endsWith(".json"));

				var diffNames = chartFiles.map(s -> s.substring(fileSngName.length+1,s.length-5));
				// Regrouping difficulties
				if(diffNames.remove(".")) diffNames.insert(1,"normal");
				if(diffNames.remove("easy")) diffNames.insert(0,"easy");
				if(diffNames.remove("hard")) diffNames.insert(2,"hard");
				this.songDifficulties = diffNames;
			}
			else{
				this.songDifficulties = ['normal'];
				trace('Directory $sngDataPath does not exist! $songName has no charts (difficulties)!');
				trace('Forcing "normal" difficulty. Expect issues!!');
			}
			
		}
		if (!this.songDifficulties.contains(currentDifficulty))
			currentDifficulty = songDifficulties[0]; // TODO
		
		songStartingBpm = BPMCache.instance.getBPM(sngDataPath,fileSngName);
		
		// this.songStartingBpm = songDifficulty.getStartingBPM();
		// this.songName = songDifficulty.songName;
		// this.difficultyRating = songDifficulty.difficultyRating;
		this.scoringRank = Scoring.calculateRank(Highscore.formatSong(songId, loadAndGetDiffId()));

		this.isNew = false; // song.isSongNew(currentDifficulty);
	}
	public function loadAndGetDiffId() {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[levelId]);
		Difficulty.loadFromWeek(leWeek);
		return Difficulty.list.findIndex(s -> s.trim().toLowerCase() == currentDifficulty);
	}
}

/**
 * The map storing information about the exit movers.
 */
typedef ExitMoverData = Map<Array<FlxSprite>, MoveData>;

/**
 * The data for an exit mover.
 */
typedef MoveData =
{
	var ?x:Float;
	var ?y:Float;
	var ?speed:Float;
	var ?wait:Float;
}

/**
 * The sprite for the difficulty
 */
class DifficultySprite extends FlxSprite
{
	/**
	 * The difficulty id which this sprite represents.
	 */
	public var difficultyId:String;
	public var hasValidTexture = true;
	public var difficultyColor:FlxColor;

	public function new(diffId:String)
	{
		super();

		difficultyId = diffId;
		var tex:FlxGraphic = null;
		if(["easy", "normal", "hard", "erect", "nightmare"].contains(difficultyId)){
			tex = Paths.image('freeplay/freeplay' + diffId,null,false);
		}
		else{
			tex = Paths.image('menudifficulties/' + diffId,null,false);
		}
		hasValidTexture = (tex != null);
		if(hasValidTexture) this.loadGraphic(tex);
		
		difficultyColor = hasValidTexture ? CoolUtil.dominantColor(this) : FlxColor.GRAY;
	}
}
