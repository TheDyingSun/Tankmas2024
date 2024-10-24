package entities;

import data.types.TankmasDefs.CostumeDef;
import data.types.TankmasEnums.Costumes;
import data.types.TankmasEnums.UnlockCondition;

class Player extends FlxSpriteExt
{
	var costume:CostumeDef = Costumes.PACO;

	var move_acl:Int = 30;
	var move_speed:Int = 500;

	var move_reverse_mod:Float = 3;

	var shadow:FlxSpriteExt;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		PlayState.self.players.add(this);

		PlayState.self.player_shadows.add(shadow = new FlxSpriteExt().one_line("player-shadow"));

		loadAllFromAnimationSet(costume.name);

		maxVelocity.set(move_speed, move_speed);

		drag.set(300, 300);

		sstate(NEUTRAL);

		screenCenter();
	}

	override function updateMotion(elapsed:Float)
	{
		shadow.center_on_bottom(this);
		super.updateMotion(elapsed);
	}
	
	override function kill()
	{
		PlayState.self.players.remove(this, true);

		super.kill();
	}

	override function update(elapsed:Float)
	{
		fsm();
		super.update(elapsed);
	}

	function fsm()
		switch (cast(state, State))
		{
			case NEUTRAL:
				general_movement();
				detect_presents();
			case JUMPING:
			case EMOTING:
		}

	function general_movement()
	{
		final UP:Bool = Ctrl.up[1];
		final DOWN:Bool = Ctrl.down[1];
		final LEFT:Bool = Ctrl.left[1];
		final RIGHT:Bool = Ctrl.right[1];
		final NO_KEYS:Bool = !UP && !DOWN && !LEFT && !RIGHT;

		if (UP)
			velocity.y -= move_speed / move_acl * (velocity.y > 0 ? 1 : move_reverse_mod);
		else if (DOWN)
			velocity.y += move_speed / move_acl * (velocity.y < 0 ? 1 : move_reverse_mod);

		if (LEFT)
			velocity.x -= move_speed / move_acl * (velocity.x > 0 ? 1 : move_reverse_mod);
		else if (RIGHT)
			velocity.x += move_speed / move_acl * (velocity.x < 0 ? 1 : move_reverse_mod);

		if (!LEFT && !RIGHT)
			velocity.x = velocity.x * .95;
		else
			flipX = velocity.x < 0;

		if (!UP && !DOWN)
			velocity.y = velocity.y * .95;

		final MOVING:Bool = velocity.x.abs() + velocity.y.abs() > 0;
		final DO_MOVE_ANIMATION:Bool = MOVING && !NO_KEYS;

		switch (animation.name)
		{
			case "idle":
				if (DO_MOVE_ANIMATION)
					animProtect("start-stop");
			case "start-stop":
				if (animation.finished)
					animProtect(DO_MOVE_ANIMATION ? "moving" : "idle");
			case "moving":
				if (!DO_MOVE_ANIMATION)
					animProtect("start-stop");
		}
	}
	function detect_presents()
	{
		var present:Present = Present.find_present_in_detect_range(this);

		Present.un_mark_all_presents();

		if (present == null)
			return;

		present.mark_target(true);
	}
}

private enum abstract State(String) from String to String
{
	final NEUTRAL;
	final JUMPING;
	final EMOTING;
}
