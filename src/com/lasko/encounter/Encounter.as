package com.lasko.encounter {
	import com.lasko.util.CustomEvent;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.text.TextField;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.events.*;
	import mx.accessibility.UIComponentAccProps;

	import com.lasko.ui.DialogBox;
	import com.lasko.ui.UIBar;
	import com.lasko.ui.Screen;
	import com.lasko.util.Utils;
	import com.lasko.entity.Character;
	import com.lasko.entity.Party;
	import com.lasko.Global;
	import com.lasko.GameGraphics;
	import com.lasko.input.GameInputEncounter;
	import com.lasko.map.Map;
   
	public class Encounter extends TopLevel {
		public static const STATE_CHOOSING_TARGET:int = 0;
		public static const STATE_CHOOSING_MEMBER:int = 1;
		public static const STATE_CHOOSING_ACTION:int = 2;
		public static const STATE_CHOOSING_SCIENCE:int = 3;
		public static const STATE_CHOOSING_THING:int = 4;
		public static const STATE_EXECUTING_TURN:int = 0;
		private static const COMBATMENU_W:int = 400;
		private static const COMBATMENU_H:int = 100;
		private static const PADDING_LEFT:int = 50;
		private static const PADDING_RIGHT:int = 50;
		private static const PADDING_TOP:int = 50;
		private static const PADDING_BOTTOM:int = 50;
		private static const CHARACTER_SCALE:int = 1;
		private static const PARTY_SELECTOR_SPEED:int = 60;
		private static const ENEMY_SELECTOR_SPEED:int = 160;
		
		private static var map:Map = Global.game.getActiveMap();
		[Embed(source="../../../../gfx/plane-fight-background.png")]
		private static var BackgroundClass:Class;

		private var background:Bitmap;
		private var goodEntities:Array = new Array();
		private var badEntities:Array = new Array();
		private var goodParty:Party, badParty:Party;
		private var goodClip:MovieClip = new MovieClip();
		private var badClip:MovieClip = new MovieClip();
		private var selectedTarget:int = -1;
		private var selectedMember:int = -1;
		private var state:int;
		
		private var turn:Turn;

		private var input:GameInputEncounter;
		private var menus:Screen = new Screen(false);

		private var pointer:Bitmap;
		private var partySelector:Sprite = new Sprite();
		private var partySelectorTimer:Timer = new Timer(PARTY_SELECTOR_SPEED, 0);
		private var enemySelector:Bitmap;
		private var enemySelectorTimer:Timer = new Timer(ENEMY_SELECTOR_SPEED, 0);
		private var enemySelectorFrame:int = 0;

		public function Encounter(goodies:Party, baddies:Party) 
		{
			var entity:EncounterEntity;
			var sprite:Sprite;
			
			mouseEnabled = false;
			addEventListener(Event.ADDED_TO_STAGE, newTurn);
			goodParty = goodies;
			badParty = baddies;
			this.input = new GameInputEncounter(this);
         
			//set up party array
			for each(var goodCharacter:Character in goodies.characters) {
				entity = new EncounterEntity(goodCharacter, EncounterEntity.TYPE_GOOD);
				this.goodEntities.push(entity);
			}
         
			//set up enemies array
			for each(var badCharacter:Character in baddies.characters) {
				entity = new EncounterEntity(badCharacter, EncounterEntity.TYPE_BAD);
				this.badEntities.push(entity);
			}
         
			//Set up frames for party selector animation
			var frameIndexes:Array = [350, 351, 352, 353, 354, 355, 337,336, 335, 334, 333];
			for (var i:int = 0; i < frameIndexes.length; i++) {
				var bitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
				bitmap.bitmapData.copyPixels(
				   GameGraphics.tileset48, 
				   new Rectangle((frameIndexes[i] % 17) * 48, (int(frameIndexes[i]/17)) * 48, 48, 48*2),
				   new Point(0, 0)
				);
				bitmap.visible = false;
				partySelector.addChild(bitmap);
			}
			partySelector.visible = false;
			partySelectorTimer.addEventListener(TimerEvent.TIMER, partySelectorTimerFired);

			//Set up frames for enemy selector animation
			enemySelector = new Bitmap(new BitmapData(Global.game.pointer[0].width, Global.game.pointer[0].height, true));
			enemySelector.bitmapData.copyPixels(
				Global.game.pointer[0].bitmapData, 
				new Rectangle(0, 0, Global.game.pointer[0].width, Global.game.pointer[0].height),
				new Point(0, 0)
			);
			enemySelector.visible = false;
			enemySelector.scaleX = -1;
			enemySelectorTimer.addEventListener(TimerEvent.TIMER, enemySelectorTimerFired);

			//Background
			background = new BackgroundClass();
			Utils.resizeMe(background, Global.gameWidth, Global.gameHeight);
			addChild(background);
         
			//place sprites
			for each(entity in goodEntities) {
				sprite = entity.getSprite();
				entity.setPosition(0, sprite.height * entity.getIndex());
				entity.setScale(CHARACTER_SCALE, CHARACTER_SCALE);
				goodClip.addChild(sprite);
				debugOut('added sprite for ' + entity.getCharacter().name + ' (y='+sprite.y+')');
			}
			goodClip.x = width - PADDING_RIGHT - goodClip.width;
			goodClip.y = height / 2 - goodClip.height / 2;
			addChild(goodClip);
			goodClip.addChild(partySelector);
         
			for each(entity in badEntities) {
				sprite = entity.getSprite();
				entity.setPosition(0, sprite.height * entity.getIndex());
				entity.setScale(CHARACTER_SCALE, CHARACTER_SCALE);
				badClip.addChild(sprite);
				debugOut('added sprite for ' + entity.getCharacter().name + ' (y='+sprite.y+')');
			}
			badClip.x = PADDING_LEFT;
			badClip.y = height / 2 - badClip.height / 2;
			addChild(badClip);
			badClip.addChild(enemySelector);

			//new bottom menu
			var heads:MovieClip = new MovieClip();
			var HEAD_WIDTH:int = 90, HEAD_HEIGHT:int = 90, BOTTOM_BAR_WIDTH:int = width - 20, 
				BARS_HEIGHT:int = 25, HEAD_PADDING:int = 15, BOTTOM_Y:int = height - 135,
				count:int = 0;
			menus.addBox( { x:10, y:BOTTOM_Y, width:BOTTOM_BAR_WIDTH, height:128, label:"party", layout:"free", columns:0, color:0xffffff } );
			
			for each(var member:EncounterEntity in goodEntities) {
				var headClip:MovieClip = new MovieClip();
				var char:Character = member.getCharacter();
				
				//faces
				var headBmp:Bitmap = new Bitmap(new BitmapData(char.width, char.height));
				//var currentFrame:int = char.anim.getCurrentFrame();
				var currentFrame:int = 1;
				headBmp.bitmapData.copyPixels(
					GameGraphics.tileset48, new Rectangle((currentFrame % 17) * 48, (int(currentFrame / 17)) * 48, char.width, char.height), new Point(0, 0)
				);
				headBmp.bitmapData = Utils.autoCrop(headBmp.bitmapData);
				headBmp.bitmapData = Utils.crop(headBmp.bitmapData, new Rectangle(0, 0, headBmp.bitmapData.width, char.head_cutoff_y));			
				Utils.resizeMe(headBmp, HEAD_WIDTH, HEAD_HEIGHT);
				//headBmp.x = HEAD_PADDING * count + HEAD_WIDTH * count + HEAD_WIDTH / 2 - headBmp.width / 2 + 5;
				//headBmp.y = HEAD_HEIGHT / 2 - headBmp.height / 2;
				//headClip.x = HEAD_PADDING * count + HEAD_WIDTH * count + HEAD_WIDTH / 2 - headBmp.width / 2 + 5;
				//headClip.y = HEAD_HEIGHT / 2 - headBmp.height / 2;
				//heads.addChild(headBmp);
				headClip.addChild(headBmp);
				
				//mp+sp bars
				var hpBar:UIBar = new UIBar(Global.BAR_COLOR_HP, char.getMaxHP(), '');
				var spBar:UIBar = new UIBar(Global.BAR_COLOR_SP, char.getMaxMP(), '');
				hpBar.y = 90;
				//hpBar.x = HEAD_PADDING * count + count * HEAD_WIDTH + 9;
				hpBar.x = 9;
				spBar.y = 100;
				//spBar.x = HEAD_PADDING * count + count * HEAD_WIDTH;
				//heads.addChild(hpBar);
				//heads.addChild(spBar);
				headClip.addChild(hpBar);
				headClip.addChild(spBar);	
				member.setHpBar(hpBar);
				member.setMpBar(spBar);
				
				menus.addMenuItem("party", headClip, {
					x: 290 + HEAD_PADDING * count + HEAD_WIDTH * count + HEAD_WIDTH / 2 - headBmp.width / 2 + 5, 
					y: 0,//HEAD_HEIGHT / 2 - headBmp.height / 2,
					callback: partySelected,
					callbackParams: member
				});
				
				count++;
			}

			//add party menu
			menus.addMenuChangeCallback("party", partyChanged);
			addChild(menus);

			//little dialog bubble indicator
			pointer = new Bitmap(new BitmapData(48, 48));
			pointer.bitmapData.copyPixels(
				GameGraphics.tileset48, 
				new Rectangle((68 % 17) * 48, (int(68/17)) * 48, 48, 48*2),
				new Point(0, 0)
			);
			pointer.visible = false;
			this.addChild(pointer);
		}

		public function getState():int {
			return state;
		}
		
		public function getSelectedTarget():int {
			return selectedTarget;
		}

		public function getSelectedMember():int {
			return selectedMember;
		}
		
		public function getMenus():Screen {
			return menus;
		}
		
		private function newTurn(e:Event=null):void {
			stage.focus = this;
			this.turn = new Turn(goodEntities, badEntities);
			this.turn.addEventListener(Turn.EVENT_TURN_DONE, turnFinishedEvent);
			
			//give player control for picking party actions
			menus.switchBox("party");
			selectNextMember();
			state = Encounter.STATE_CHOOSING_MEMBER;

			this.menus.visible = true;
			this.menus.enable();
		}
		
		private function turnFinishedEvent(e:CustomEvent):void {
			debugOut('TURN DONE EVENT!');
			if (this.turn.getAllEnemiesKilled()) {
				endCombat();
			} else {
				newTurn();
			}
		}

		private function partySelected(entity:EncounterEntity):void
		{
			var partyBox:Object = menus.getBox("party");
			var ACTIONS_W:int = 92;
			var ACTIONS_H:int = 114;
			debugOut(entity.getCharacter().name + " selected, giving action choices...");
			selectedMember = entity.getIndex();

			menus.addBox({x:partyBox.x + 10, y:partyBox.y + partyBox.height/2 - ACTIONS_H/2, width:ACTIONS_W, height:ACTIONS_H, label:"actions"});
			menus.addMenuText("actions", {label:"Attack", callback:attackSelected, callbackParams:entity, exitCallback:function():void { menus.removeBox("actions"); menus.switchBox("party"); } });
			menus.addMenuText("actions", {label:"Science", callback:scienceSelected, callbackParams:entity, exitCallback:function():void { menus.removeBox("actions"); menus.switchBox("party"); } });
			menus.addMenuText("actions", {label:"Things", callback:thingsSelected, callbackParams:entity, exitCallback:function():void { menus.removeBox("actions"); menus.switchBox("party"); } } );
			menus.addMenuText("actions", {label:"Pass", callback:passSelected, callbackParams:entity, exitCallback:function():void { menus.removeBox("actions"); menus.switchBox("party"); } });
			state = Encounter.STATE_CHOOSING_ACTION;
			menus.switchBox("actions");
		}

		public function targetSelected(params:Object=null):void {
			menus.removeBox("actions");
			menus.removeBox("science");
			menus.removeBox("enemies");
			menus.switchBox("party");

			var character:Character = goodEntities[selectedMember].getCharacter();
			var action:CombatActionBase = goodEntities[selectedMember].getAction();
			var targetEntity:EncounterEntity = selectedTarget > 0 ? badEntities[selectedTarget - 1] : goodEntities[Math.abs(selectedTarget) - 1];
			action.addTarget(targetEntity);
			debugOut(character.name + ' (' + selectedMember + ') targets: ' + targetEntity.getCharacter().name + ' (' + selectedTarget + ')');
			selectTarget('enemy', -1);

			//if all party members have chosen an action + target, do turn
			var actionCount:int = 0;
			for (var i:int = 0; i < goodEntities.length; i++) {
				action = goodEntities[i].getAction();
				if (action != null && action.hasTargets()) { 
					actionCount++; 
				} else {
					selectNextMember();
					break;
				}
			}
			
			//EXECUTE THE TURN!!!!
			if (actionCount == goodEntities.length) {
				this.menus.disable();
				//menus.visible = false;
				state = Encounter.STATE_EXECUTING_TURN;
				this.turn.execute();
				partySelector.visible = false;
				return;
			}
			
			input.disable();
			menus.enable();
		}

		/************ MENU OPTIONS WHEN SELECTING A PARTY MEMBER ************/
		private function attackSelected(object:Object):void 
		{
			debugOut("attack selected, choosing enemy...");
			var actionsBox:Object = menus.getBox("actions");
			var selectedEntity:EncounterEntity = goodEntities[selectedMember];
			var selectedCharacter:Character = selectedEntity.getCharacter();
			var action:CombatActionWeapon = new CombatActionWeapon();
			action.setWeapon(selectedCharacter.combat.getEquippedWeapon());
			action.setSource(selectedEntity);
			action.setTargetCandidates(badEntities);
			selectedEntity.setAction(action);
			
			menus.switchBox(null);
			selectFirstTarget();
		 
			menus.addBox( {
				x:actionsBox.x + actionsBox.width + 10, y:actionsBox.y, width:117, height:115, 
				label:"enemies", defaultExitCallback: function():void {
					menus.removeBox("enemies");
					menus.switchBox("actions");
				}
			});
			for each(var badEntity:EncounterEntity in badEntities) {
				menus.addMenuText("enemies", {label:badEntity.getCharacter().name, callback:targetSelected, enabled:badEntity.getState() != EncounterEntity.STATE_DEAD});
			}
			menus.addMenuChangeCallback("enemies", function(index:int):void {
				selectTarget('enemy', index+1);
			});
			menus.switchBox("enemies");
         
			state = Encounter.STATE_CHOOSING_TARGET;
		}
      
		private function scienceSelected(object:Object):void {
			debugOut("science selected, choosing spell...");
			var actionsBox:Object = menus.getBox("actions");
			state = Encounter.STATE_CHOOSING_SCIENCE;

			menus.addBox( {
				x:actionsBox.x + actionsBox.width + 10, y:actionsBox.y, width:117, height:115, 
				label:"science"
			});
			var char:Character = goodEntities[selectedMember].getCharacter();
			var spells:Array = char.getSpells();

			for each(var spell:Spell in spells) {
				menus.addMenuText("science", {label:spell.name, callback:spellSelected, callbackParams:spell, exitCallback:function():void { menus.removeBox("science"); menus.switchBox("actions"); } });
			}

			menus.switchBox("science");
		}
      
		private function thingsSelected(object:Object):void 
		{
			debugOut("things selected, choosing inventory item...");
			var char:Character = goodEntities[selectedMember].getCharacter();
			state = Encounter.STATE_CHOOSING_THING;
			if (goodParty.inventory.hasCombatItem()) {
				menus.addBox({x:60, y:height - 200, width:500, height:100, label:"things"});
				var inventory:Object = goodParty.inventory.getCombatItems();

				for each(var item:Item in inventory) {
				   menus.addMenuText("things", {label:item.name, callback:itemSelected, callbackParams:item, exitCallback:function():void { menus.removeBox("things"); menus.switchBox("actions"); } });
				}

				menus.switchBox("things");
			} else {
				debugOut("no combat items");
			}
		}
      
		private function spellSelected(spell:Spell):void
		{
			debugOut("spell " + spell.name + " selected, choosing target...");
			var action:CombatActionSpell = new CombatActionSpell();
			action.setSpell(spell);
			action.setSource(goodEntities[selectedMember]);
			action.setTargetCandidates(badEntities);
			goodEntities[selectedMember].setAction(action);
			
			menus.switchBox(null);
			menus.disable();
			selectFirstTarget();
			input.enable();
			
			state = Encounter.STATE_CHOOSING_TARGET;
		}
      
		private function passSelected(entity:EncounterEntity):void
		{
			debugOut("pass selected");
			var action:CombatActionPass = new CombatActionPass();
			action.setSource(goodEntities[selectedMember]);
			goodEntities[selectedMember].setAction(action);
			
			this.targetSelected();
		}
      
		private function itemSelected(item:Item):void
		{
			debugOut("item " + item.name + " selected, choosing target...");
			var action:CombatActionItem = new CombatActionItem();
			action.setItem(item);
			goodEntities[selectedMember].setAction(action);
			
			menus.switchBox(null);
			selectFirstTarget();
         
			state = Encounter.STATE_CHOOSING_TARGET;
		}
      
      
      
      
		/********************** FUNCTIONS FOR CHOOSING AN ENEMY / PARTY MEMBER ***************************/
		public function selectTarget(type:String, index:int):void
		{
			if (index == -1) {
				pointer.visible = false;
				return;
			}
			
			var sprite:Sprite;
			if (type == 'enemy') {	//targetting enemy
				sprite = badEntities[index - 1].getSprite();
				pointer.x = badClip.x + sprite.x;
				pointer.y = badClip.y + sprite.y - pointer.height - 5;
				selectedTarget = index;
			} else {				//targetting ally
				sprite = goodEntities[index - 1].getSprite();
				pointer.x = goodClip.x + sprite.x;
				pointer.y = goodClip.y + sprite.y - pointer.height - 5;
				selectedTarget = -index;
			}

			pointer.visible = true;
		}

		private function selectFirstTarget():void
		{
			for (var i:int = 0; i < badEntities.length; i++) {
				if (badEntities[i].getState() != EncounterEntity.STATE_DEAD) {
					selectTarget('enemy', i+1);
					return;
				}
			}
		}
      
		public function selectNextTarget():void
		{
			var checkedCount:int = 0;
			var index:int = Math.abs(selectedTarget) - 1;
			
			if(selectedTarget > 0) { //selecting an enemey
				while (checkedCount < badEntities.length) {
					if (++index > badEntities.length - 1) { index = 0; }
					if (badEntities[index].getState() != EncounterEntity.STATE_DEAD) {
						selectTarget('enemy', index+1);
						return;
					}
					checkedCount++;
				}
			} else {					//selecting an ally
				while (checkedCount < goodEntities.length) {
					if (++index > goodEntities.length - 1) { index = 0; }
					if (goodEntities[index].getState() != EncounterEntity.STATE_DEAD) {
						selectTarget('ally', index+1);
						return;
					}
					checkedCount++;
				}
			}
		}
      
		public function selectPreviousTarget():void
		{
			var checkedCount:int = 0;
			var index:int = Math.abs(selectedTarget) - 1;

			if(selectedTarget > 0) { //selecting an enemey
				while (checkedCount < badEntities.length) {
					if (--index < 0) { index = badEntities.length - 1; }
					if (badEntities[index].getState() != EncounterEntity.STATE_DEAD) {
						selectTarget('enemy', index+1);
						return;
					}
					checkedCount++;
				}
			} else {					//selecting an ally
				while (checkedCount < goodEntities.length) {
					if (--index < 0) { index = goodEntities.length - 1; }
					if (goodEntities[index].getState() != EncounterEntity.STATE_DEAD) {
						selectTarget('ally', index+1);
						return;
					}
					checkedCount++;
				}
			}
		}
      
		public function selectNextMember():void
		{
			menus.changeItem(1);
		}

		/************************** TURN STUFF *********************************/
		
      
		private function endCombat():void
		{
			var dialog:XML = new XML(
				<dialog>
				<prompt type="initial" id="1" action="prompt" promptId="2">You've done it!</prompt>
				<prompt type="normal" id="2" action="end">You got stuff!</prompt>
				</dialog>
			);
			var d:DialogBox = new DialogBox(dialog, null, null, destroy);
			addChild(d);
		}
      
		public function destroy():void
		{
			trace('removing encounter from stage');
			Global.game.endEncounter(this);
		}
      

		public function partyChanged(index:int):void
		{
			partySelector.x = goodEntities[index].getSprite().x;
			partySelector.y = goodEntities[index].getSprite().y+7;
			partySelector.visible = true;

			if(!partySelectorTimer.running) { partySelectorTimer.start(); }
		}
      
		/***************** GRAPHICS STUFF ********************/
		private function partySelectorTimerFired(e:Event):void
		{
			//figure out what frame the selector animation is on & set that frame visible, set all others hidden
			var frame:int = -1;
			for (var i:int = 0; i < partySelector.numChildren; i++) {
				if (partySelector.getChildAt(i).visible) {
					partySelector.getChildAt(i).visible = false;
					if (partySelector.numChildren > i + 1) {
						frame = i + 1;
					} else {
						frame = 0;
					}
				}
			}
			if (frame == -1) { frame = 0; };
			partySelector.getChildAt(frame).visible = true;

			//figure out if this frame should be in front of or behind the character
			if (frame > 5) {
				goodClip.setChildIndex(partySelector, menus.getSelectedIndex("party"));
			} else {
				goodClip.setChildIndex(partySelector, menus.getSelectedIndex("party")+1);
			}
		}
      
		private function enemySelectorTimerFired(e:Event):void
		{
			if (++enemySelectorFrame > Global.game.pointer.length - 1) { enemySelectorFrame = 0; }
			enemySelector.bitmapData.copyPixels(
				Global.game.pointer[enemySelectorFrame].bitmapData, 
				new Rectangle(0, 0, Global.game.pointer[enemySelectorFrame].width, Global.game.pointer[enemySelectorFrame].height),
				new Point(0, 0)
			);
		}
      
		public static function debugOut(value:String):void
		{
			Global.debugOut(value);
		}
   }
}