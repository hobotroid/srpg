package com.lasko
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import spark.primitives.Rect;
	
	import mx.controls.TextArea;
	
	import com.greensock.*;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import com.greensock.motionPaths.RectanglePath2D;
	
	import com.lasko.ui.*;
    import com.lasko.util.*;
	import com.lasko.entity.Character;
	import com.lasko.entity.Party;
	import com.lasko.encounter.Encounter;
	import com.lasko.input.GameInputMapScreen;
	import com.lasko.input.GameInput;
	import com.lasko.Global;
	import com.lasko.GameGraphics;
	import com.lasko.map.Map;
	
	public class Game extends Engine
	{
		public static const GAME_STATE_LOADING:int = 0;
		public static const GAME_STATE_PLAYING:int = 1;
		public static const GAME_STATE_DIALOG:int = 2;
		public static const GAME_STATE_START_ENCOUNTER:int = 3;
		public static const GAME_STATE_ENCOUNTER:int = 4;
		public static const GAME_STATE_CHARACTER_SCREEN:int = 5;
		public static const GAME_STATE_MODE7:int = 7;
		
		public var maps:Array = new Array();
		public var activeMap:int;
		public var pointer:Array = new Array();
		public var corner:Bitmap = new Bitmap();
		
		private var input:GameInputMapScreen;

		private var party:Party = new Party("party");
		private var leader:int;
		
		//dialog box for conversations
		private var dialogBox:DialogBox;
		
		//for mode 7 airship flying - awesome
		private var mode7:Awesome;
		
		//random encounter stuff
		//private var randomEncounterIndex:int = 100 + Math.random() * 100;
		private var randomEncounterIndex:int = 999999 + Math.random() * 100;
		private var randomEncounterCounter:int = 0;
		
		public function Game()
		{
			super(800, 600, 30, true);
			activeMap = 0;
			maps.push(new Map("plane"));
			initParty();
			FP.world = maps[activeMap];
		}
		
		override public function init():void
		{
			Global.setGame(this);
			//this.mouseEnabled = false;
			TweenPlugin.activate([TransformAroundCenterPlugin, TransformAroundPointPlugin, ShortRotationPlugin]);		
			
			//pointer
			pointer[0] = new Bitmap(new BitmapData(48,48, true));
			pointer[0].bitmapData.copyPixels(GameGraphics.tileset48, new Rectangle((323 % 17) * 48, (int(323 / 17)) * 48, 48, 48), new Point(0, 0));
			pointer[1] = new Bitmap(new BitmapData(48, 48, true));
			pointer[1].bitmapData.copyPixels(GameGraphics.tileset48, new Rectangle((324 % 17) * 48, (int(324 / 17)) * 48, 48, 48), new Point(0, 0));
			pointer[2] = new Bitmap(new BitmapData(48, 48, true));
			pointer[2].bitmapData.copyPixels(GameGraphics.tileset48, new Rectangle((325 % 17) * 48, (int(325 / 17)) * 48, 48, 48), new Point(0, 0));
			pointer[3] = pointer[1];
			
			//corner
			corner = new Bitmap(new BitmapData(24, 24, true));
			corner.bitmapData.copyPixels(GameGraphics.tileset24, new Rectangle((6 % 34) * 24, (int(6 / 34)) * 24, 24, 24), new Point(0, 0));
			
			this.input = new GameInputMapScreen();
			FP.world.add(input);
						
			//temporary - start encounter immediately
			//checkRandomEncounter(true);
        }
		
		private function initParty():void
		{
			var carlXML:XMLList = (Global.charactersXML.character.(@id == "carl"));
			var carl:Character = new Character(carlXML);
			var philXML:XMLList = (Global.charactersXML.character.(@id == "phillip lasko"));
			//var phil:Character = new Character(philXML);
			
			var townsmanXML:XMLList = (Global.charactersXML.character.(@id == "townsman"));
			//var townsman:Character = new Character(townsmanXML);
			
			//phil.setState(Global.STATE_FOLLOWING, {"target": carl});
			//townsman.setState(Global.STATE_FOLLOWING, {"target": phil});
			
			party.inventory.addItem(new Item("Bomb"));
			party.inventory.addItem(new Item("Nunchucks"));
			carl.setSlot("L. Hand", new Item("Nunchucks"));
			//phil.setSlot("L. Hand", new Item("Pistol"));
			
			party.addCharacter(carl);
			//party.addCharacter(phil);
			//party.addCharacter(townsman);
			
			maps[activeMap].addParty(party);
			carl.moveTo(maps[activeMap].getPlayerStart().x, maps[activeMap].getPlayerStart().y);
			maps[activeMap].cam.adjustToCharacter(maps[activeMap].pixelWidth, maps[activeMap].pixelHeight, carl);
		}
		
		override public function update():void
		{
			maps[activeMap].cam.followCharacter(maps[activeMap].pixelWidth, maps[activeMap].pixelHeight, party.getLeader());
			super.update();
		}
		
		public function changeMap(mapName:String):void
		{
			var map:Map = new Map(mapName);
			maps.push(map); 

		}
		
		private function loadMap(mapName:String):void
		{
			maps.push(new Map(mapName));
		}
		        
		public function startEncounter(party:Party, npc:Party):void
		{
			
			GameInput.stop();
			//gameState = Main.GAME_STATE_ENCOUNTER;
			/*var encounter:Encounter = new Encounter(party, npc);
			
			var src:Bitmap = new Bitmap(canvasBitmap.bitmapData);
			var dest = new Bitmap(new BitmapData(canvasBitmap.width, canvasBitmap.height, false, 0xffffff));
			var pixelator:Pixelator = new Pixelator(src, encounter, 200);
			addChild(pixelator);
			pixelator.startTransition(Pixelator.PIXELATION_MEDIUM);
			pixelator.addEventListener(Pixelator.PIXEL_TRANSITION_COMPLETE, function(e:Event):void {*/
				//gameState = Main.GAME_STATE_ENCOUNTER;
				trace('new encounter!');
				var encounter:Encounter = new Encounter(party, npc);
				//addChild(encounter);
			//});
		}
		
		public function startDialog(sourceChar:Character, dialogXML:XML, npc:Party = null, actionCallback:Function = null):void
		{
			/*stopGameTimer();
			//gameState = Main.GAME_STATE_DIALOG;
			if (dialogBox && contains(dialogBox))
			{
				removeChild(dialogBox);
			}
			
			if (npc && npc.name == "joshua")
			{
				var shopScreen:ShopScreen = new ShopScreen(sourceChar.getShopItems());
				addChild(shopScreen);
			}
			else
			{
				dialogBox = new DialogBox(dialogXML, npc, actionCallback);
				addChild(dialogBox);
			}*/
		}
		
		public function endDialog():void
		{
			/*if (dialogBox && contains(dialogBox))
			{
				removeChild(dialogBox);
			}
			gameState = Main.GAME_STATE_PLAYING;
			startGameTimer();*/
		}
		
		public function endEncounter(encounter:Encounter):void
		{
			/*removeChild(encounter);
			gameState = Main.GAME_STATE_PLAYING;
			startGameTimer();
			stage.focus = parent;*/
		}
		
		public function resumeGame():void
		{
			//gameState = Main.GAME_STATE_PLAYING;
			//stage.focus = this;
			//startGameTimer();
		}
				
		public function getActiveMap():Map
		{
			return (maps[activeMap]);
		}
		
		public function checkRandomEncounter(force:Boolean=false):void
		{
			if (/*++randomEncounterCounter >= randomEncounterIndex || */force)
			{
				trace('starting random encounter');
				
				randomEncounterCounter = 0;
				randomEncounterIndex = 100 + Math.random() * 100;
				
				//get random mob
				var mobArray:Array = [];
				for (var i:int = 0; i < Utils.randRange(3, 3); i++)
				{
					var guys:Array = ["file ghost", "file ghost", "file ghost"];
					//var guys:Array = ["dogs", "dogs", "dogs"];
					var mobXML:XMLList = (Global.charactersXML.character.(@id == guys[Utils.randRange(0, 2)]));
					var mob:Character = new Character(mobXML);
					mobArray.push(mob);
				}
				var mobParty:Party = new Party("random", mobArray);
				
				startEncounter(party, mobParty);
			}
		}
		
		public function getCharacterXML(id:String):XMLList
		{
			return (Global.charactersXML.character.(@id == id));
		}
		
		public function getParty():Party {
			return this.party;
		}
	}
}
