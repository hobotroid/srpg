package {
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.geom.Point;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import com.greensock.*;
   import com.greensock.easing.*;
   import flash.utils.Timer;
   import flash.events.*;
   import mx.accessibility.UIComponentAccProps;
   
   import ui.DialogBox;
   import ui.UIBar;
   import ui.Screen;
   import util.Utils;
   
   public class Encounter extends TopLevel {
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
      [Embed(source="../gfx/plane-fight-background.png")]
      private static var BackgroundClass:Class;
      
      private var background:Bitmap;
      private var party:Array = new Array();
      private var enemies:Array = new Array();
      private var goodParty:Party, badParty:Party;
      private var goodClip:MovieClip = new MovieClip();
      private var badClip:MovieClip = new MovieClip();
      private var selectedEnemy:int = -1;
      private var selectedMember:int = -1;
      private var state:String = "";
      
      private var menus:Screen = new Screen(false);
      private var debugField:TextField = new TextField();
      
      private var partySelector:Sprite = new Sprite();
      private var partySelectorTimer:Timer = new Timer(PARTY_SELECTOR_SPEED, 0);
      private var enemySelector:Bitmap;
      private var enemySelectorTimer:Timer = new Timer(ENEMY_SELECTOR_SPEED, 0);
      private var enemySelectorFrame:int = 0;
      
      public function Encounter(goodies:Party, baddies:Party) 
      {
         var count:int = 0;
         addEventListener(Event.ADDED_TO_STAGE, init);
         goodParty = goodies;
         badParty = baddies;
         
         //set up party array
         for each(var good:Character in goodies.characters) {
            good.setAnimState(Global.STATE_COMBAT);
			good.setState(Global.STATE_COMBAT);0
            var object:Object = {};
            object.character = good;
            object.bitmap = new Bitmap(new BitmapData(good.width, good.height));
            object.sprite = new Sprite();
            object.index = count;
            object.state = "waiting";
            this.party.push(object);
            updateCharacter(object);
            
            count++;
         }
         
         //set up enemies array
         count = 0;
         for each(var bad:Character in baddies.characters) {
            bad.setAnimState(Global.STATE_COMBAT);
            object = {};
            object.character = bad;
            object.bitmap = new Bitmap(new BitmapData(bad.width, bad.height));
            object.sprite = new Sprite();
            object.index = count;
            object.state = "waiting";
            this.enemies.push(object);
            updateCharacter(object);
            
            count++;
         }
         
         //Set up frames for party selector animation
         var frameIndexes:Array = [350, 351, 352, 353, 354, 355, 337,336, 335, 334, 333];
         for (var i:int = 0; i < frameIndexes.length; i++) {
            var bitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
            bitmap.bitmapData.copyPixels(
               Global.tileset48, 
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
         for each(var member:Object in party) {
            member.sprite.scaleX = member.sprite.scaleY = CHARACTER_SCALE;
            member.sprite.y = member.sprite.height * member.index;
            member.original_x = 0;
            member.original_y = member.sprite.y;
            goodClip.addChild(member.sprite);
debugOut('added bitmap for ' + member.character.name + ' (y='+member.sprite.y+')');
         }
         goodClip.x = width - PADDING_RIGHT - goodClip.width;
         goodClip.y = height / 2 - goodClip.height / 2;
         addChild(goodClip);
         goodClip.addChild(partySelector);
         
         for each(var enemy:Object in enemies) {
            enemy.sprite.scaleX = enemy.sprite.scaleY = CHARACTER_SCALE;
            enemy.sprite.y = enemy.sprite.height * enemy.index;
            enemy.original_x = 0;
            enemy.original_y = member.sprite.y;
debugOut('added bitmap for ' + enemy.character.name + ' (y='+enemy.sprite.y+')');
            badClip.addChild(enemy.sprite);
         }
         badClip.x = PADDING_LEFT;
         badClip.y = height / 2 - badClip.height / 2;
         addChild(badClip);
         badClip.addChild(enemySelector);
         
         //place debug output
         debugField.width = width - 100;
         debugField.height = 100;
         debugField.x = width / 2 - debugField.width / 2;
         debugField.y = 10;
         debugField.border = true;
         debugField.borderColor = 0xff0000;
         debugField.background = true;
         debugField.backgroundColor = 0xffffff;
		 debugField.visible = false;
         addChild(debugField);
         
         //menus
         menus.addBox(10,            height - 110, width / 2 - 20, 100, "party");
         menus.addBox(width / 2 + 5, height - 110, width / 2 - 20, 100, "enemies");
		 
         menus.addMenuChangeCallback("party", partyChanged);
         var clip:MovieClip;
         for each(member in party) {
            clip = new MovieClip();
            member.healthBar = new UIBar(0xFF0000, enemy.character.getMaxHP(), 'hp');
            member.healthBar.y = 10;
            clip.addChild(member.healthBar);
            clip.addChild(Global.makeText(member.character.name));
            menus.addMenuItem("party", clip, {callback: partySelected, callbackParams: member});
         }
         for each(enemy in enemies) {
            clip = new MovieClip();
            enemy.healthBar = new UIBar(0xFF0000, enemy.character.getMaxHP(), 'hp');
            enemy.healthBar.y = 10;
            clip.addChild(enemy.healthBar);
            clip.addChild(Global.makeText(enemy.character.name));
            
            menus.addMenuItem("enemies", clip, null);
         }
		 
		 //new bottom menu
		 var heads:MovieClip = new MovieClip();
		 var count:int = 0, HEAD_WIDTH:int = 90, HEAD_HEIGHT:int = 90, BOTTOM_BAR_WIDTH:int = width - 20, BARS_HEIGHT:int = 25, HEAD_PADDING:int = 15;
		 menus.addBox(10, height - 300, BOTTOM_BAR_WIDTH, 128, "bottom", "free", 0, 0xffffff);
		 for each(good in goodies.characters) {
			 trace(good.getState().type);
			 
			//faces
            var headBmp:Bitmap = new Bitmap(new BitmapData(good.width, good.height));
			var currentFrame:int = good.getCurrentFrame();
			headBmp.bitmapData.copyPixels(
				Global.tileset48, new Rectangle((currentFrame % 17) * 48, (int(currentFrame / 17)) * 48, good.width, good.height), new Point(0, 0)
			);
			headBmp.bitmapData = Utils.autoCrop(headBmp.bitmapData);
			headBmp.bitmapData = Utils.crop(headBmp.bitmapData, new Rectangle(0, 0, headBmp.bitmapData.width, good.head_cutoff_y));			
			Utils.resizeMe(headBmp, HEAD_WIDTH, HEAD_HEIGHT);
			headBmp.x = HEAD_PADDING * count + HEAD_WIDTH * count + HEAD_WIDTH / 2 - headBmp.width / 2 + 5;
			headBmp.y = HEAD_HEIGHT / 2 - headBmp.height / 2;
			heads.addChild(headBmp);
			
			//mp+sp bars
			var hpBar:UIBar = new UIBar(Global.BAR_COLOR_HP, good.getMaxHP(), '');
			var spBar:UIBar = new UIBar(Global.BAR_COLOR_SP, good.getMaxMP(), '');
			hpBar.y = 90;
			hpBar.x = HEAD_PADDING * count + count * HEAD_WIDTH + 9;
			spBar.y = 100;
			spBar.x = HEAD_PADDING * count + count * HEAD_WIDTH;
			heads.addChild(hpBar);
			heads.addChild(spBar);
			
			//debug boxes
			/*var debugBox:Bitmap = new Bitmap(new BitmapData(HEAD_WIDTH, HEAD_HEIGHT, true, 0xFF0000FF));
			debugBox.x = headBmp.x;
			debugBox.y = headBmp.y;
			trace(debugBox.x + ' x ' + debugBox.y + ' - ' + debugBox.width + ' x ' + debugBox.height);
			heads.addChild(debugBox);*/
			
			count++;
 		 }
		 menus.addMenuItem("bottom", heads, {x: BOTTOM_BAR_WIDTH - heads.width - 10, y: 0});
		 //Utils.addBorder(heads);
         addChild(menus);
      }
      
      private function init(e:Event):void
      {
         newTurn();
      }
      
      private function partySelected(object:Object):void
      {
debugOut(object.character.name + " selected, giving action choices...");
         selectedMember = object.index;
         menus.addBox(30, height - 150, 110,  100, "actions");
         menus.addMenuText("actions", "Attack", attackSelected, object, function():void { menus.removeBox("actions"); menus.switchBox("party"); } );
         menus.addMenuText("actions", "Science", scienceSelected, object, function():void { menus.removeBox("actions"); menus.switchBox("party"); } );
         menus.addMenuText("actions", "Things", thingsSelected, object, function():void { menus.removeBox("actions"); menus.switchBox("party"); } );
         state = "choosing_actions";
         menus.switchBox("actions");
         partySelectorTimer.stop();
      }
      
      
      
      
      
      
      
      
      /************ MENU OPTIONS WHEN SELECTING A PARTY MEMBER ************/
      private function attackSelected(object:Object):void 
      {
debugOut("attack selected, choosing enemy...");
         party[selectedMember].action = "combat";
         menus.switchBox(null);
         selectFirstEnemy();
         
         menus.removeKeyListener();
         state = "choosing_target";
         addKeyListener();
      }
      
      private function scienceSelected(object:Object):void 
      {
debugOut("science selected, choosing spell...");
         state = "choosing_science";
         
         menus.addBox(60, height - 200, 400,  100, "science");
         var char:Character = party[selectedMember].character;
         var spells:Array = char.getSpells();
         
         for each(var spell:Spell in spells) {
            menus.addMenuText("science", spell.name, spellSelected, spell, function():void { menus.removeBox("science"); menus.switchBox("actions"); } );
         }
         
         menus.switchBox("science");
      }
      
      private function thingsSelected(object:Object):void 
      {
debugOut("things selected, choosing inventory item...");
         var char:Character = party[selectedMember].character;
         state = "choosing_thing";
         if (goodParty.inventory.hasCombatItem()) {
            menus.addBox(60, height - 200, 500,  100, "things");
            var inventory:Object = goodParty.inventory.getCombatItems();
            
            for each(var item:Item in inventory) {
               menus.addMenuText("things", item.name, itemSelected, item, function():void { menus.removeBox("things"); menus.switchBox("actions"); } );
            }
            
            menus.switchBox("things");
         } else {
debugOut("no combat items");
         }
      }
      
      private function spellSelected(spell:Spell):void
      {
debugOut("spell " + spell.name + " selected, choosing target...");
         party[selectedMember].action = "spell";
         party[selectedMember].spell = spell;
         menus.switchBox(null);
         selectFirstEnemy();
         
         menus.removeKeyListener();
         state = "choosing_target";
         addKeyListener();
      }
      
      private function itemSelected(item:Item):void
      {
debugOut("item " + item.name + " selected, choosing target...");
         party[selectedMember].action = "item";
         party[selectedMember].item = item;
         menus.switchBox(null);
         selectFirstEnemy();
         
         menus.removeKeyListener();
         state = "choosing_target";
         addKeyListener();
      }
      
      
      
      
      /********************** FUNCTIONS FOR CHOOSING AN ENEMY / PARTY MEMBER ***************************/
      private function selectEnemy(index:int=-1):void
      {
         if (selectedEnemy > -1) {
            enemySelector.visible = false;
            enemySelectorTimer.stop();
         }
         
         if (index > -1) {
            enemySelector.x = enemies[index].sprite.x + enemies[index].sprite.width + enemySelector.width/2;
            enemySelector.y = enemies[index].sprite.y;
            enemySelector.visible = true;
            if (!enemySelectorTimer.running) { enemySelectorTimer.start(); }
         }
         
         selectedEnemy = index;
      }
      
      private function selectFirstEnemy():void
      {
         for (var i:int = 0; i < enemies.length; i++) {
            if (enemies[i].character.getStateName() != "dead") {
               selectEnemy(i);
               return;
            }
         }
      }
      
      private function selectNextEnemy():void
      {
         var checkedCount:int = 0;
         var index:int = selectedEnemy;
         
         while (checkedCount < enemies.length) {
            if (++index > enemies.length - 1) { index = 0; }
            if (enemies[index].character.getStateName() != "dead") {
               selectEnemy(index);
               return;
            }
            checkedCount++;
         }
      }
      
      private function selectPreviousEnemy():void
      {
         var checkedCount:int = 0;
         var index:int = selectedEnemy;
         
         while (checkedCount < enemies.length) {
            if (--index < 0) { index = enemies.length-1; }
            if (enemies[index].character.getStateName() != "dead") {
               selectEnemy(index);
               return;
            }
            checkedCount++;
         }
      }
      
      private function selectNextMember():void
      {
         menus.changeItem(1);
      }
      
      
      
      /************************** TURN STUFF *********************************/
      private function newTurn():void
      {
debugOut("-------------- new turn --------------");
         for (var i:int = 0; i < party.length; i++) {
            party[i].target = null;
         }
         menus.switchBox("party");
         selectNextMember();
         state = "choosing_member";
         menus.addKeyListener();
      }
      
      private function startTurn():void
      {
debugOut('startTurn() - actions chosen for all party members, initiating turn');
         state = "turn";

         doMemberAction(0);
      }
      
      private function endTurn():void
      {
debugOut('endTurn()');
         var deadCount:int = 0;
         for (var i:int = 0; i < enemies.length; i++) {
            var char:Character = enemies[i].character;
            
            if(char.conditions[0] && char.conditions[0].isActive()) {
               char.conditions[0].applyActions();
            }
            updateCharacter(enemies[i]);
            
            trace(char.name+'\'s STATE: '+char.getStateName());
            if (char.getStateName() == "dead") {
               if (enemies[i].state != "dead") { 
                  doEnemyDeathAnimation(i);
                  enemies[i].state = "dead"
               }
               deadCount++;
            }
         }
         
         if (deadCount >= enemies.length) {
debugOut('ALL ENEMIES KILLED - ending combat');
            endCombat();
         } else {
            newTurn();
         }
      }
      
      private function endCombat():void
      {
         var dialog:XML = new XML(
          <dialog>
            <prompt type="initial" id="1" action="prompt" promptId="2">You've done it!</prompt>
            <prompt type="normal" id="2" action="end">You got stuff!</prompt>
         </dialog>
         );
         var d:DialogBox = new DialogBox(dialog, null, null, destroy);
         removeKeyListener();
         addChild(d);
      }
      
      public function destroy():void
      {
trace('removing encounter from stage');
         Global.game.endEncounter(this);
      }
      
      private function doMemberAction(index:int):void
      {
         //all actions done, start new turn
         if (index > party.length - 1) { 
            endTurn();
            return;
         }
         
         var results:Object;
         if (party[index].target != null && party[index].action != null) {
debugOut(party[index].character.name + "'s action is: " + party[index].action);
            switch(party[index].action) {
               case 'combat':
                  results = party[index].character.sendAttack(enemies[party[index].target].character);
                  showCombatAnimation(party[index], function(e:Event):void {
                     enemies[party[index].target].healthBar.setValue(enemies[party[index].target].character.getHP());
                     doMemberAction(index + 1);
                  });
debugOut(results.message);
                  break;
               case 'spell':
                  results = party[index].character.sendSpell(party[index].spell, enemies[party[index].target].character);
                  showSpellAnimation(party[index], function():void {
                     enemies[party[index].target].healthBar.setValue(enemies[party[index].target].character.getHP());
                     doMemberAction(index + 1);
                  });
debugOut(results.message);
                  break;
               case 'item':
                  results = party[index].item.useItem( { target: enemies[party[index].target] } );
debugOut(results.message);
                  break;
               default: break;
            }
         }
         
         updateCharacter(party[index]);

      }     
      
      /************************** KEY LISTENER STUFF ****************************/
      public function addKeyListener(e:Event=null):void
      {
         if(!hasEventListener(KeyboardEvent.KEY_UP)) { 
            addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true); 
         }
         stage.focus = this;
      }
      
      public function removeKeyListener():void
      {
         if(hasEventListener(KeyboardEvent.KEY_UP)) { 
            removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
         }
      }
      
      private function keyUpHandler(e:KeyboardEvent):void
      {
         switch(state) {
            case "choosing_target":
               if (e.keyCode == Keyboard.UP) {
                  selectPreviousEnemy();
               } else if (e.keyCode == Keyboard.DOWN) {
                  selectNextEnemy();
               } else if(e.keyCode == Keyboard.RIGHT) {
               } else if(e.keyCode == Keyboard.LEFT) {
               }
                     
               if (e.keyCode == 88) { //X
                  party[selectedMember].target = selectedEnemy;
debugOut(party[selectedMember].character.name + ' (' + selectedMember + ') targets: ' + enemies[selectedEnemy].character.name + ' (' + selectedEnemy + ')');
                  removeKeyListener();
                  menus.removeBox("actions");
                  menus.removeBox("science");
                  menus.switchBox("party");
                  selectEnemy( -1);
                  
                  //if all party members have chosen an action + target, do turn
                  var actionCount:int = 0;
                  for (var i:int = 0; i < party.length; i++) {
                     if (party[i].target != null) { 
                        actionCount++; 
                     } else {
                        selectNextMember();
                        break;
                     }
                  }
                  if (actionCount == party.length) {
                     startTurn();
                     return;
                  }
                  
                  menus.addKeyListener();
               } else if(e.keyCode == 90) { //Z
                  selectEnemy( -1);
                  if (party[selectedMember].action == "spell") {
                     menus.switchBox("science");
                  } else { 
                     menus.switchBox("actions");
                  }
                  removeKeyListener();
                  menus.addKeyListener();
               }
               break;
            case "choosing_member":
               trace('CHOOSIN\'');
               break;
            default: break;
         }
         
         e.stopPropagation();
      }
      
      public function partyChanged(index:int):void
      {
         partySelector.x = party[index].sprite.x;
         partySelector.y = party[index].sprite.y+7;
         partySelector.visible = true;
         if(!partySelectorTimer.running) { partySelectorTimer.start(); }
      }
      
      /***************** GRAPHICS STUFF ********************/
      private function updateCharacter(object:Object):void
      {
         if (object.state == "dead") { return; }
         
         var currentFrame:int = object.character.getCurrentFrame();
         object.bitmap.bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((currentFrame % 17) * 48, (int(currentFrame/17)) * 48, object.bitmap.width, object.bitmap.height),
            new Point(0, 0)
         );
         if (!object.sprite.contains(object.bitmap)) { object.sprite.addChild(object.bitmap); }
      }
      
      private function showCombatAnimation(character:Object, callback:Function):void
      {
         showCombatAttack(character, function(e:Event):void { 
            showCombatHit(enemies[e.target.params.character.target], function(e:Event):void { 
               TweenMax.to(character.sprite, .5, { x:character.original_x, ease:Expo.easeInOut }); //move char back to original pos
               callback(e);
            });
         });
      }
      
      private function showSpellAnimation(character:Object, callback:Function):void
      {
         showSpellCast(character, function():void { 
            TweenMax.to(character.sprite, .5, { x:character.original_x, ease:Expo.easeInOut }); //move char back to original pos
            callback();
         });
      }
      
      //shows "pow" graphic on character that got hit by melee
      private function showCombatHit(character:Object, callback:Function):void
      {
         TweenMax.to(character.bitmap,0.1,{repeat:2, y:1+Math.random()*4, x:1+Math.random()*4, delay:0.1, ease:Expo.easeInOut});
         TweenMax.to(character.bitmap, 0.1, { y:Math.random() * 4, x:Math.random() * 4, delay:0.3,/* onComplete:onFinishTween,*/ ease:Expo.easeInOut } );

         var hitBitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
         hitBitmap.bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((340 % 17) * 48, (int(340/17)) * 48, character.bitmap.width, character.bitmap.height),
            new Point(0, 0)
         );
         hitBitmap.x = character.sprite.width / 2 - 48 / 2;
         hitBitmap.y = character.sprite.height / 2 - 48 / 2;
         character.sprite.addChild(hitBitmap);
         hitBitmap.name = "hitBitmap";
         
         var hitTimer:Timer = new MyTimer(300, 1);
         hitTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
            character.sprite.removeChild(character.sprite.getChildByName("hitBitmap"));
         });
         hitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, callback);
         hitTimer.start();
      }
      
      //swings a weapon behind a character (or do whatever frames the weapon specifies)
      private function showCombatAttack(character:Object, callback:Function):void
      {
         var weapon:Item = character.character.getEquippedWeapon();
         character.animation = {
            item: weapon,
            frames: weapon.getAttackFrames()
         }
         character.state = "attacking";

         TweenMax.to(character.sprite, .5, { 
               x:x - 50, ease:Expo.easeInOut, onComplete: function():void {
                  var attackAnimTimer:MyTimer = new MyTimer(100, character.animation.frames.length+1, {character:character});
                  attackAnimTimer.addEventListener(TimerEvent.TIMER, attackTimerFired);
                  attackAnimTimer.addEventListener(TimerEvent.TIMER_COMPLETE, callback);
                  attackAnimTimer.start();
               }
            } 
         );
      }
      
      //character casts a spell
      private function showSpellCast(character:Object, callback:Function):void
      {
         character.state = "casting";

         TweenMax.to(character.sprite, .5, { 
               x:x - 50, ease:Expo.easeInOut, onComplete: function():void {
                  callback();
               }
            } 
         );
      }
      
      //called when weapon swing animation is updated
      private function attackTimerFired(e:Event):void
      {
         var char:Object = e.target.params.character;
         var frame:Object = char.animation.frames[e.target.currentCount - 1];
         
         if(frame) {
            var hitBitmap:Bitmap = char.sprite.getChildByName("hitBitmap") ? char.sprite.getChildByName("hitBitmap") : new Bitmap(new BitmapData(frame.width, frame.height));
            hitBitmap.name = "hitBitmap";
            hitBitmap.bitmapData.copyPixels(
               Global.tileset48, 
               new Rectangle((frame.index % 17) * 48, (int(frame.index/17)) * 48, frame.width, frame.height),
               new Point(0, 0)
            );
            hitBitmap.x = -frame.origin_x + frame.offset_x;
            hitBitmap.y = -frame.origin_y + frame.offset_y;
            if (!char.sprite.contains(hitBitmap)) { char.sprite.addChildAt(hitBitmap, 0); }
            if (frame.hide) { char.sprite.getChildAt(1).visible = false; }
         } else { //animation done
            char.sprite.getChildAt(1).visible = true;
            char.sprite.removeChild(char.sprite.getChildByName("hitBitmap"));
         }
      }
      
      private function doEnemyDeathAnimation(index:int):void
      {
debugOut('doing enemy death for enemy ' + index);
         var sprite:Sprite = enemies[index].sprite;
         var bitmap:Bitmap = enemies[index].bitmap;
         var bmd:BitmapData = bitmap.bitmapData;
         
         var pass1:Bitmap = new Bitmap(new BitmapData(bmd.width, bmd.height, true, 0x00000000));
         var pass2:Bitmap = new Bitmap(new BitmapData(bmd.width, bmd.height, true, 0x00000000));
         
         var mask:Sprite = new Sprite();
         
         //clear sprite
         sprite.removeChild(bitmap);
         
         //mask for clipping
         mask.graphics.beginFill(0, 1);  
         mask.graphics.drawRect(0, 0, bitmap.width, bitmap.height);  
         mask.graphics.endFill();  
         
         for (var i:int = 0; i < bmd.height; i++) {
            if (i % 2) {
               pass1.bitmapData.copyPixels(bmd, new Rectangle(0, i, bmd.width, 1), new Point(0, i));
            } else {
               pass2.bitmapData.copyPixels(bmd, new Rectangle(0, i, bmd.width, 1), new Point(0, i), null, null, true);
            }
         }
         
         sprite.addChild(mask);
         sprite.addChild(pass1);
         sprite.addChild(pass2);
         pass1.mask = mask;
         pass2.mask = mask;
         
         TweenMax.to(pass1, 8, { x: -bitmap.width });
         TweenMax.to(pass2, 8, { x: bitmap.width });
         TweenMax.to(pass1, 1, { alpha: 0 } );
         TweenMax.to(pass2, 1, { alpha: 0 } );
         
         //Ghost!
         var ghostTimer:MyTimer;
         var ghost:Sprite = new Sprite();
         var ghostFrames:Array = [];
         var ghostFrame:int = 0;
         ghostFrames[0] = new Bitmap(new BitmapData(48, 48 * 2, true));
         ghostFrames[1] = new Bitmap(new BitmapData(48, 48 * 2, true));
         ghostFrames[2] = new Bitmap(new BitmapData(48, 48*2, true));
         ghostFrames[0].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((330 % 17) * 48, (int(330/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[1].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((331 % 17) * 48, (int(331/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[2].bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((332 % 17) * 48, (int(332/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         ghostFrames[0].visible = true;
         ghostFrames[1].visible = false;
         ghostFrames[2].visible = false;
         ghost.addChild(ghostFrames[0]);
         ghost.addChild(ghostFrames[1]);
         ghost.addChild(ghostFrames[2]);
         ghost.x = badClip.x + sprite.x + sprite.width / 2 - ghost.width / 2;
         ghost.y = badClip.y + sprite.y + sprite.height / 2 - ghost.height / 2;
         //ghost.alpha = 0;
         addChild(ghost);
         
         //ease:Back.easeOut, 
         //TweenMax.to(ghost, .3, { alpha: 1, onComplete:function():void {
         ghostTimer = new MyTimer(100, 20, {'ghostFrames':ghostFrames, 'frame':ghostFrame} );
         ghostTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
            e.target.params.ghostFrames[e.target.params.frame].visible = false;
            if (++e.target.params.frame > ghostFrames.length - 1) { e.target.params.frame = 0; }
            e.target.params.ghostFrames[e.target.params.frame].visible = true;
         });
         ghostTimer.start();
         //TweenMax.to(ghost, 1, { alpha: 1 } );
         TweenMax.to(ghost, 4, { y: -ghost.height } );
         TweenMax.to(ghost, 1, { delay: .5, alpha: 0 } );
         //}});
      }
      
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
      
      
      
      
      
      
      private function debugOut(value:String):void
      {
         if (debugField.text.length) { debugField.appendText("\n"); }
         debugField.appendText(value);
         debugField.scrollV = debugField.textHeight;
      }
   }
}