import flixel.text.FlxText;
// script by subpurr [[discord: subpurrowo]]
// please do not use without credit.
// no explicit permission needed to use

// CONFIG:
final IMPOSTORM:Bool = true; // true if Impostor V4 style (rating position depends on gf position), false for base game style
final START_AFTER:Int = 10; // Combo will not show until you are at least this value [default: 10]
final IGNORE_OFFSET:Bool = true; // If the script should ignore your Combo Offset settings [default: true]

var veloAdd:Array<Float> = [0, 0, 0, 0];
function onCreatePost():Void {
    if (IMPOSTORM) { // don't mind me LMAO
        switch (PlayState.curStage) {
            case 'ejected':
                veloAdd[3] = -1100;
            case 'airship':
                veloAdd[0] = -250;
                veloAdd[2] = -550;
        }
    }

    game.comboGroup.cameras = [game.camGame];
}

var processed:Array = [];
function goodNoteHit(n):Void {
    // yea this is really inefficient 3: couldn't find a different way as
    // signals don't work on FlxSpriteGroups apparently and destroyed
    // objects don't really leave arrays + psych engine devs didn't
    // remove finished comboGroup members from the group... which is
    // really annoying 3:
    processed = processed.filter(function(e) {
        if (game.comboGroup.members.contains(e)) {
            if (e.alpha > 0 && e.visible && e.velocity != null) {
                return true;
            }
            game.comboGroup.remove(e, true);
        }
        e.destroy();
        return false;
    });

    for (member in game.comboGroup) {
        if (!processed.contains(member) && member != null) {
            processed.push(member);
            final isMemCombo:Bool = member.height > member.width / 2; // ahhh whatever

            if (!isMemCombo || game.combo >= START_AFTER) {
                if (IMPOSTORM)
                    reposImpostor(member, isMemCombo);
                else
                    reposVanilla(member, isMemCombo);

                member.velocity.x += veloAdd[0];
                member.velocity.y += veloAdd[1];
                member.acceleration.x += veloAdd[2];
                member.acceleration.y += veloAdd[3];
            } else {
                member.visible = false;
            }
        }
    }
}

function reposImpostor(member, isMemCombo) {
    final char = game.gf != null ? gf : boyfriend;
    final placement:Float = FlxG.width * 0.35;
    final yCorrect:Float = FlxG.height * 0.5 - member.height;
    if (!isMemCombo) {
        member.x -= placement;
        member.y -= yCorrect + 30;
        member.x += char.x - 40;
        member.y += char.y - 60;

        if (IGNORE_OFFSET) {
            member.x += - ClientPrefs.data.comboOffset[0] + 40;
            member.y += ClientPrefs.data.comboOffset[1] + 60;
        }
    } else {
        member.x -= placement;
        member.y -= yCorrect + 30;
        member.x += char.x - 90;
        member.y += char.y + 70;

        if (IGNORE_OFFSET) {
            member.x += - ClientPrefs.data.comboOffset[2] + 90;
            member.y += ClientPrefs.data.comboOffset[3] - 80;
        }
    }
}

function reposVanilla(member, isMemCombo) {
    var placement:String = Std.string(combo);

    var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
    coolText.screenCenter();
    coolText.x = FlxG.width * 0.55;

    var char = game.gf != null ? gf : boyfriend;
    var placement:Float = FlxG.width * 0.35;
    var yCorrect:Float = FlxG.height * 0.5 - member.height;
    if (!isMemCombo) {
        member.x -= placement;
        member.y -= yCorrect + 30;

        ycenterish(member);
        member.x += coolText.x - 40;
        member.y -= 60;

        if (IGNORE_OFFSET) {
            member.x += - ClientPrefs.data.comboOffset[0] + 40;
            member.y += ClientPrefs.data.comboOffset[1] + 60;
        }
    } else {
        member.x -= placement;
        member.y -= yCorrect + 30;

        ycenterish(member);
        member.x += coolText.x - 90;
        member.y += 80;

        if (IGNORE_OFFSET) {
            member.x += - ClientPrefs.data.comboOffset[2] + 90;
            member.y += ClientPrefs.data.comboOffset[3] - 80;
        }
    }
}

function ycenterish(obj) {
    final actPos:Float = obj.y;
    obj.screenCenter(0x10);
    obj.y += actPos;
}

// function centerish(obj) {
//     final actPos:Array<Float> = [obj.x, obj.y];
//     obj.screenCenter();
//     obj.x, obj.y += actPos[0], actPos[1];
// }