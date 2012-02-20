package
{
    import com.greensock.motionPaths.RectanglePath2D;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.Shape;
	import flash.display.StageDisplayState;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import spark.primitives.Rect;
	
	import mx.controls.TextArea;
	import mx.core.FlexGlobals;
	
	import com.greensock.*;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	
	import ui.*;
    import util.*;
	
	public class Test extends TopLevel
	{
		private var loaderContext:LoaderContext = new LoaderContext();
		
		//map stuff-as3 directory
		private var maps:Array = new Array();
		private var activeMap:int;
		public var canvas:BitmapData;
		public var background:BitmapData;
		public var pointer:Array = new Array();
		private var tempCanvas:BitmapData;
		private var canvasBitmap:Bitmap;
		public var mapScrollX:int = 0;
		public var mapScrollY:int = 0;
		public var mapScrollLocked:Boolean = true;
		
		public var keysPressed:Array = new Array();
		public var keysPressedCount:int = 0;
		private var gameState:String = "loading";
		
		public var party:Party = new Party("party");
		private var leader:int;
		
		//for frame timing
        private var frameTimer:FrameTimer;
        private var gameTimer:Timer;
		public static const FRAME_RATE:int = 30;
        private var _period:Number = 1000 / FRAME_RATE;
        private var _beforeTime:int = 0;
        private var _afterTime:int = 0;
        private var _timeDiff:int = 0;
        private var _sleepTime:int = 0;
        private var _overSleepTime:int = 0;
        private var _excess:int = 0;
		
		//sounds
		private var music:Sound;
		
		//debug
		public var debugField:TextField;
		private var debugShowCollision:Boolean = false;
		private var debugParams:Object = { };
		private var debugHighlightedTiles:Array = [];
		private var drawLayer:int = 0;
		
		//dialog box for conversations
		private var dialogBox:DialogBox;
		
		//for mode 7 airship flying - awesome
		private var mode7:Awesome;
		
		//random encounter stuff
		//private var randomEncounterIndex:int = 100 + Math.random() * 100;
		private var randomEncounterIndex:int = 999999 + Math.random() * 100;
		private var randomEncounterCounter:int = 0;
		
		public function Test()
		{
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			TweenPlugin.activate([TransformAroundCenterPlugin, TransformAroundPointPlugin, ShortRotationPlugin]);
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
			
			this.mouseEnabled = false;
		}
		
		public function init(e:Event = null):void
		{
			loaderContext.checkPolicyFile = true;
			XML.ignoreWhitespace = true;
			XML.prettyIndent = 0;
			
			//canvas to draw on
			canvas = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			canvasBitmap = new Bitmap(canvas);
			addChild(canvasBitmap);
			this.focusRect = false;
            
            //load tilesets
            loadTilesets(function():void {
                //load all character data and then the initial map
                loadMap("plane2", function():void {
                    //pointer
                    pointer[0] = new Bitmap(new BitmapData(48,48, true));
                    pointer[0].bitmapData.copyPixels(Global.tileset48, new Rectangle((323 % 17) * 48, (int(323 / 17)) * 48, 48, 48), new Point(0, 0));
                    pointer[1] = new Bitmap(new BitmapData(48, 48, true));
                    pointer[1].bitmapData.copyPixels(Global.tileset48, new Rectangle((324 % 17) * 48, (int(324 / 17)) * 48, 48, 48), new Point(0, 0));
                    pointer[2] = new Bitmap(new BitmapData(48, 48, true));
                    pointer[2].bitmapData.copyPixels(Global.tileset48, new Rectangle((325 % 17) * 48, (int(325 / 17)) * 48, 48, 48), new Point(0, 0));
                    pointer[3] = pointer[1];
                    
                    initParty();
                    addKeyListeners();
                    //loadMusic();
                    activeMap = 0;
                    gameState = "play";
                    startGameTimer();
					
					//temporary
					//checkRandomEncounter(true);
                });
            });
			
            Global.setGame(this);
            
			//big debug output field
			debugField = new TextField();
            
            //set up timer
            gameTimer = new Timer(1000 / FRAME_RATE, 1);
            gameTimer.addEventListener(TimerEvent.TIMER, mainLoop);
        }
		
		public function changeMap(mapFile:String):void
		{
			gameState = "loading";
			maps.push(new Map(this, "../maps/" + mapFile + ".tmx", 
                function(map:Map):void
				{
					canvas.fillRect(canvas.rect, 0x000000);
					mapScrollX = 0;
					mapScrollY = 0;
					party.leader.x = map.playerStart.x;
					party.leader.y = map.playerStart.y;
					trace('changed: ' + party.leader.x + 'x' + party.leader.y);
					activeMap = maps.length - 1;
					for each (var char:Character in party.characters)
					{
						char.setMap(map);
					}
					gameState = "play";
				}
            ));
		}
		
		private function loadMap(mapFile:String, callback:Function):void
		{
			gameState = "loading";
			maps.push(new Map(this, "../maps/" + mapFile + ".tmx", callback));
		}
		
		private function loadMusic():void
		{
			var request:URLRequest = new URLRequest("../gypsy.mp3");
			music = new Sound();
			music.load(request);
			music.play();
		}
        
        private function loadTilesets(callback:Function):void {
            var loaded:int = 0;
            var tilesLoader48:Loader = new Loader();
            var tilesLoader24:Loader = new Loader();
			tilesLoader48.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
                Global.tileset48 = Bitmap(tilesLoader48.content).bitmapData;
                if (++loaded == 2) { callback(); }
            });
            tilesLoader24.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):void {
                Global.tileset24 = Bitmap(tilesLoader24.content).bitmapData;
                if (++loaded == 2) { callback(); }
            });     
            tilesLoader24.load(new URLRequest('../maps/tileset24.png'));
			tilesLoader48.load(new URLRequest('../maps/tileset.png'));
        }
		
		private function mainLoop(e:TimerEvent):void
		{   
            
			//trace('mainloop start');
			switch (gameState)
			{
				case "dialog": 
					break;
				case "play": 
					stage.focus = this;
					getInput();
					canvas.lock();
					updateScroll();
					drawMap();
					canvas.unlock();
                    
					break;
				case "startencounter": 
					break;
				
				case "encounter": 
					trace('encounter state');
					break;
				case "characterscreen": 
					stopGameTimer();
					var characterScreen:CharacterScreen = new CharacterScreen(party);
					addChild(characterScreen);
					break;
				case "debug": 
					getInput();
				default: 
					break;
			}
		
            gameTimer.reset();
            gameTimer.start();
			//trace('mainLoop over');
		}
		
		private function initParty():void
		{
			var carlXML:XMLList = (Global.charactersXML.character.(@id == "carl"));
			var carl:Character = new Character(maps[activeMap], carlXML, maps[activeMap].playerStart.x, maps[activeMap].playerStart.y);
			
			var philXML:XMLList = (Global.charactersXML.character.(@id == "phillip lasko"));
			var phil:Character = new Character(maps[activeMap], philXML, maps[activeMap].playerStart.x, maps[activeMap].playerStart.y);
			
			var townsmanXML:XMLList = (Global.charactersXML.character.(@id == "townsman"));
			var townsman:Character = new Character(maps[activeMap], townsmanXML, maps[activeMap].playerStart.x, maps[activeMap].playerStart.y);
			
			phil.setState(Global.STATE_FOLLOWING, {"target": carl});
			townsman.setState(Global.STATE_FOLLOWING, {"target": phil});
			
			party.inventory.addItem(new Item("Bomb"));
			party.inventory.addItem(new Item("Nunchucks"));
			carl.setSlot("L. Hand", new Item("Nunchucks"));
			phil.setSlot("L. Hand", new Item("Pistol"));
			
			party.addCharacter(carl);
            
			party.addCharacter(phil);
			party.addCharacter(townsman);
            
            maps[activeMap].npcs.push(party);
		}
		
		public function drawMap():void
		{
			var spriteNum:int;
			var tile:Object;
            var chars:Array;
			var charsDrawn:Object = {};

			//needs to be optimized to not draw every time. maybe?
			if (Global.currentBackground) {
                canvas.copyPixels(Global.currentBackground, Global.currentBackground.rect, new Point(0, 0));
			}
			
            
			for (var l:int = 0; l < maps[activeMap].tiles.length ; l++) {
                //skip this layer if it's debug-invisible at the moment
				if (!maps[activeMap].visibleLayers[l])	{
					continue;
				}

                for (var y:int = mapScrollY / maps[activeMap].tileHeight; y < mapScrollY / maps[activeMap].tileHeight + stage.stageHeight / maps[activeMap].tileHeight; y++) {
                    for (var x:int = mapScrollX / maps[activeMap].tileWidth; x < mapScrollX / maps[activeMap].tileWidth + stage.stageWidth / maps[activeMap].tileWidth; x++) {
                        
                        //are there any characters to draw at this location?
                        /*if(maps[activeMap].playerLayers[l]) {
                            chars = maps[activeMap].getCharactersAt(l, x, y);
                            for each(var char:Character in chars) {
                                spriteNum = char.getCurrentFrame();
                                canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % 17) * 48, (int(spriteNum / 17)) * 48, 48, 48), new Point(char.x - mapScrollX, char.y - mapScrollY));
                                char.updatePosition(); 
                            }
                        }*/
                        
                        
                                                
                        //is there a tile/object to draw at this location?
						if ((tile = maps[activeMap].getTileAt(l, x, y))) { 
						spriteNum = tile.spriteNum - 1;
                        //trace(spriteNum);
                        if (spriteNum >= 3333) {
                            spriteNum -= 3332;
                            canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % maps[activeMap].tileSets[48].tilesPerRow) * 48, (int(spriteNum / maps[activeMap].tileSets[48].tilesPerRow)) * 48, 48, 48), new Point(tile.x - mapScrollX, tile.y - mapScrollY));
                        } else {
                            canvas.copyPixels(Global.tileset24, new Rectangle((spriteNum % maps[activeMap].tileSets[24].tilesPerRow) * maps[activeMap].tileWidth, (int(spriteNum / maps[activeMap].tileSets[24].tilesPerRow)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(tile.x - mapScrollX, tile.y - mapScrollY));
                        }
                        }
                        
                        //are there any characters to draw at this location?
                        if(maps[activeMap].playerLayers[l]) {
                            chars = maps[activeMap].getCharactersAt(l, x, y);
                            for each(var char:Character in chars) {
								if (charsDrawn[char.id]) { continue; }
                                char.tick();
                                spriteNum = char.getCurrentFrame();
                                canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % 17) * 48, (int(spriteNum / 17)) * 48, 48, 48), new Point(char.x - mapScrollX, char.y - mapScrollY)); 
								charsDrawn[char.id] = true;
                            }
                        }
					}
				}
			}
			
			debugDrawCollisionBoxes();
            drawPlayerBox(party.leader.mapX * maps[activeMap].tileWidth - mapScrollX, party.leader.mapY * maps[activeMap].tileHeight - mapScrollY, maps[activeMap].tileWidth, maps[activeMap].tileHeight);      
        }
		
        private function drawPlayerBox(x:int, y:int, w:int, h:int):void
        {
            var rectangle:Shape = new Shape;
            rectangle.graphics.beginFill(0xFF0000, 0.5);
            rectangle.graphics.lineStyle(1, 0x0000FF);
            rectangle.graphics.drawRect(0, 0, w, h);
            rectangle.graphics.endFill();
            canvas.draw(rectangle, new Matrix(1, 0, 0, 1, x, y));
        }
        
		public function startEncounter(party:Party, npc:Party):void
		{
			stopGameTimer();
			gameState = "encounter";
			/*var encounter:Encounter = new Encounter(party, npc);
			
			var src:Bitmap = new Bitmap(canvasBitmap.bitmapData);
			var dest = new Bitmap(new BitmapData(canvasBitmap.width, canvasBitmap.height, false, 0xffffff));
			var pixelator:Pixelator = new Pixelator(src, encounter, 200);
			addChild(pixelator);
			pixelator.startTransition(Pixelator.PIXELATION_MEDIUM);
			pixelator.addEventListener(Pixelator.PIXEL_TRANSITION_COMPLETE, function(e:Event):void {*/
				gameState = "encounter";
				trace('new encounter!');
				var encounter:Encounter = new Encounter(party, npc);
				addChild(encounter);
			//});
		}
		
		public function startDialog(sourceChar:Character, dialogXML:XML, npc:Party = null, actionCallback:Function = null):void
		{
			stopGameTimer();
			gameState = "dialog";
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
			}
		}
		
		public function endDialog():void
		{
			if (dialogBox && contains(dialogBox))
			{
				removeChild(dialogBox);
			}
			gameState = "play";
			startGameTimer();
			addKeyListeners();
		}
		
		public function endEncounter(encounter:Encounter):void
		{
			removeChild(encounter);
			gameState = "play";
			startGameTimer();
			addKeyListeners();
			stage.focus = parent;
		}
		
		public function startMode7(object:MapObject):void
		{
			maps[activeMap].removeTileAt(object.x, object.y, object);
			stopGameTimer();
			canvas.unlock();
			gameState = "mode7";
			
			var bmd:BitmapData = new BitmapData(maps[activeMap].width * maps[activeMap].tileWidth, maps[activeMap].height * maps[activeMap].tileHeight, false, 0x000000);
			for (var l:int = 0; l < maps[activeMap].tiles.length; l++)
			{
				for (var x:int = 0; x < maps[activeMap].width; x++)
				{
					for (var y:int = 0; y < maps[activeMap].height; y++)
					{
						var tile:Object = maps[activeMap].getTileAt(l, x, y);
						if (tile)
						{
							if (tile.spriteNum > -1)
							{
								var typeId:int = tile.spriteNum - 1;
								bmd.copyPixels(Global.tileset48, new Rectangle((typeId % 17) * maps[activeMap].tileWidth, (int(typeId / 17)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(tile.x, tile.y));
							}
						}
					}
				}
			}
			
			var airship:BitmapData = new BitmapData(maps[activeMap].tileWidth, maps[activeMap].tileHeight);
			airship.copyPixels(Global.tileset48, new Rectangle((136 % 17) * maps[activeMap].tileWidth, (int(136 / 17)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(0, 0));
			var shadow:BitmapData = new BitmapData(maps[activeMap].tileWidth, maps[activeMap].tileHeight);
			shadow.copyPixels(Global.tileset48, new Rectangle((153 % 17) * maps[activeMap].tileWidth, (int(153 / 17)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(0, 0));
			
			//mode7 = new Awesome(object, bmd, airship, shadow, party.leader.x, party.leader.y);
			mode7 = new Awesome(bmd);
			addChild(mode7);
			canvasBitmap.visible = false;
			//startGameTimer();
//trace(bmd.width + "x" + bmd.height);
		}
		
		public function endMode7(object:MapObject, x:int, y:int):void
		{
			trace('ending mode7 with character settling at ' + x + 'x' + y);
			maps[activeMap].addTileAt(x, y, object);
			party.leader.x = x;
			party.leader.y = y;
			removeChild(mode7);
			mode7 = null;
			gameState = "play";
			canvasBitmap.visible = true;
			startGameTimer();
		}
		
		public function stopGameTimer():void
		{
			removeKeyListeners();
			gameTimer.stop();
		}
		
		public function startGameTimer():void
		{
            gameTimer.start();
			addKeyListeners();
		}
		
		public function resumeGame():void
		{
			clearKeys();
			gameState = "play";
			stage.focus = this;
			startGameTimer();
		}
		
		private function clearKeys():void
		{
			keysPressed = new Array();
		}
		
		private function keyDownHandler(event:KeyboardEvent):void
		{
			if (!keysPressed[event.keyCode]) { 
				keysPressedCount++;
				keysPressed[event.keyCode] = true;
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void
		{
			keysPressed[event.keyCode] = false;
			keysPressedCount--;
			keyPressed(event);
		}
		
		private function getInput():void
		{
			//if no keys pressed, make character stop 
			if (!keysPressedCount) {
				if (gameState == "play") {
					party.leader.moveStop();
				}
				return;
			}
			
			//directions
			if (keysPressed[Keyboard.UP])
			{
				if (gameState == "play")
				{
					checkRandomEncounter();
					party.leader.moveUp();
				}
			}
			else if (keysPressed[Keyboard.DOWN])
			{
				if (gameState == "play")
				{
					checkRandomEncounter();
					party.leader.moveDown();
				}
			}
			else if (keysPressed[Keyboard.LEFT])
			{
				if (gameState == "play")
				{
					checkRandomEncounter();
					party.leader.moveLeft();
				}
			}
			else if (keysPressed[Keyboard.RIGHT])
			{
				if (gameState == "play")
				{
					checkRandomEncounter();
					party.leader.moveRight();
				}
			}

			//manual scrolling
			if (keysPressed[Keyboard.NUMPAD_4])
			{
				mapScrollLocked = false;
				mapScrollX -= 5;
				if (mapScrollX < 0)
				{
					mapScrollX = 0;
				}
			}
			if (keysPressed[Keyboard.NUMPAD_6])
			{
				mapScrollLocked = false;
				mapScrollX += 5;
			}
			if (keysPressed[Keyboard.NUMPAD_8])
			{
				mapScrollLocked = false;
				mapScrollY -= 5;
				if (mapScrollY < 0)
				{
					mapScrollY = 0;
				}
			}
			if (keysPressed[Keyboard.NUMPAD_5])
			{
				mapScrollLocked = false;
				mapScrollY += 5;
			}
			
			//misc
			if (keysPressed[Keyboard.SPACE])
			{
				if (gameState == "debug")
				{
					drawNextTile();
				}
			}
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 88: //use (X key)
					trace(party.leader.collidingWith);
					if (party.leader.collidingWith)
					{
						party.leader.collidingWith.useItem();
					}
					break;
				case 32: //space
					
					break;
				case 82: //random encounter (capital R)
					checkRandomEncounter(true);
					break;
				case 80: //pause
					gameState = "characterscreen";
					break;
				case 70: //fullscreen - f key
					//if normal size, go to fullscreen, else go to normal size
					if (FlexGlobals.topLevelApplication.stage.displayState == StageDisplayState.NORMAL)
					{
						FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.FULL_SCREEN;
						FlexGlobals.topLevelApplication.stage.scaleMode = StageScaleMode.SHOW_ALL;
						
					}
					else
					{
						FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;
							//stage.displayState = "normal";
					}
					break;
				case 67: //c key - toggle collision view
					debugShowCollision = !debugShowCollision;
					debugHighlightedTiles = [];
					break;
				case 68: //d key - turn on debugging
					if (gameState == "play")
					{
						gameState = "debug";
						canvas.fillRect(canvas.rect, 0x000000);
						debugParams.drawParams = null;
					}
					else
					{
						gameState = "play";
					}
					break;
				case 84: //t key
					break;
				case 48: //0
					for each (var l:int in maps[activeMap].visibleLayers)
					{
						maps[activeMap].visibleLayers[l] = 1;
					}
					break;
				case 49: //1
				case 50: //2
				case 51: //3
				case 52: //4
				case 53: //5
				case 54: //6
				case 55: //7
				case 56: //8
				case 57: //9
					maps[activeMap].visibleLayers[e.keyCode - 49] = !maps[activeMap].visibleLayers[e.keyCode - 49];
					break;
				default: 
					break;
			}
			//trace(e.keyCode);
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		private function updateScroll():void
		{
			if (mapScrollLocked && maps[activeMap].pixelWidth > stage.stageWidth && maps[activeMap].pixelHeight > stage.stageHeight)
			{
				mapScrollY = party.leader.y + party.leader.height / 2 - stage.stageHeight / 2;
				mapScrollX = party.leader.x + party.leader.width / 2 - stage.stageWidth / 2;
				if (mapScrollX < 0)
				{
					mapScrollX = 0;
				}
				if (mapScrollY < 0)
				{
					mapScrollY = 0;
				}
				if (mapScrollX + stage.stageWidth > maps[activeMap].pixelWidth)
				{
					mapScrollX = maps[activeMap].pixelWidth - stage.stageWidth;
				}
				if (mapScrollY + stage.stageHeight > maps[activeMap].pixelHeight)
				{
					mapScrollY = maps[activeMap].pixelHeight - stage.stageHeight;
				}
			}
		}
		
		public function getTileSet():BitmapData
		{
			return (maps[activeMap].tileSet);
		}
		
		public function getActiveMap():Map
		{
			return (maps[activeMap]);
		}
		
		private function checkRandomEncounter(force:Boolean=false):void
		{
			if (++randomEncounterCounter >= randomEncounterIndex || force)
			{
				trace('starting random encounter');
				stopGameTimer();
				randomEncounterCounter = 0;
				randomEncounterIndex = 100 + Math.random() * 100;
				
				//get random mob
				var mobArray:Array = [];
				for (var i:int = 0; i < Utils.randRange(1, 3); i++)
				{
					var guys:Array = ["file ghost", "file ghost", "file ghost"];
					//var guys:Array = ["dogs", "dogs", "dogs"];
					var mobXML:XMLList = (Global.charactersXML.character.(@id == guys[Utils.randRange(0, 2)]));
					var mob:Character = new Character(maps[activeMap], mobXML, 0, 0);
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
		
		public function removeKeyListeners():void
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		public function addKeyListeners():void
		{
			clearKeys();
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/******************** debug functions ***********************/
		private function drawNextTile():void
		{
			if (!debugParams.drawParams)
			{
				debugParams.drawParams = {l: 0, x: mapScrollX / maps[activeMap].tileWidth, y: mapScrollY / maps[activeMap].tileHeight, paintRect: new Shape}
				debugParams.drawParams.paintRect.graphics.beginFill(0xFF0000, 0.5);
				debugParams.drawParams.paintRect.graphics.lineStyle(1, 0x0000FF);
				debugParams.drawParams.paintRect.graphics.drawRect(0, 0, maps[activeMap].tileWidth, maps[activeMap].tileHeight);
				debugParams.drawParams.paintRect.graphics.endFill();
				addChild(debugParams.drawParams.paintRect);
			}
			var drawParams:Object = debugParams.drawParams;
			
			//player party
			/*if (drawParams.l == maps[activeMap].playerLayer && int((party.leader.x + 24) / maps[activeMap].tileWidth) == drawParams.x && int((party.leader.y + 40) / maps[activeMap].tileHeight) == drawParams.y)
			{
				var spriteNum:int = party.leader.getCurrentFrame();
				canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % 17) * maps[activeMap].tileWidth, (int(spriteNum / 17)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(party.leader.x - mapScrollX, party.leader.y - mapScrollY));
				party.leader.updatePosition();
			}*/
            
            //char?
            if(maps[activeMap].playerLayers[drawParams.l]) {
                var chars:Array = maps[activeMap].getCharactersAt(drawParams.l, drawParams.x, drawParams.y);
                for each(var char:Character in chars) {
                    spriteNum = char.getCurrentFrame();
                    canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % 17) * 48, (int(spriteNum / 17)) * 48, 48, 48), new Point(char.x - mapScrollX, char.y - mapScrollY));
                    char.tick();
                }
            }
			
			//tile/object
            //is there a tile/object to draw at this location?
            var tile:Object = maps[activeMap].getTileAt(drawParams.l, drawParams.x, drawParams.y);
            if(tile) {
                var spriteNum:int = tile.spriteNum - 1;
                //trace(spriteNum);
                if (spriteNum >= 3333) {
                    spriteNum -= 3332;
                    canvas.copyPixels(Global.tileset48, new Rectangle((spriteNum % maps[activeMap].tileSets[48].tilesPerRow) * 48, (int(spriteNum / maps[activeMap].tileSets[48].tilesPerRow)) * 48, 48, 48), new Point(tile.x - mapScrollX, tile.y - mapScrollY));
                } else {
                    canvas.copyPixels(Global.tileset24, new Rectangle((spriteNum % maps[activeMap].tileSets[24].tilesPerRow) * maps[activeMap].tileWidth, (int(spriteNum / maps[activeMap].tileSets[24].tilesPerRow)) * maps[activeMap].tileWidth, maps[activeMap].tileWidth, maps[activeMap].tileHeight), new Point(tile.x - mapScrollX, tile.y - mapScrollY));
                }
            }
			
			drawParams.paintRect.x = drawParams.x * maps[activeMap].tileWidth - mapScrollX;
			drawParams.paintRect.y = drawParams.y * maps[activeMap].tileHeight - mapScrollY;
			
			if (drawParams.y < mapScrollY / maps[activeMap].tileHeight + stage.stageHeight / maps[activeMap].tileHeight - 1)
			{
				drawParams.y++;
			}
			else if (drawParams.x < mapScrollX / maps[activeMap].tileWidth + stage.stageWidth / maps[activeMap].tileWidth - 1)
			{
				drawParams.x++;
				drawParams.y = 0;
			}
			else if (drawParams.l < maps[activeMap].tiles.length - 1)
			{
				drawParams.l++;
				drawParams.x = 0;
			}
			else
			{
				removeChild(drawParams.paintRect);
				debugParams.drawParams = null;
				canvas.fillRect(canvas.rect, 0x000000);
			}
		}
		
		private function debugDrawCollisionBoxes():void
		{
			//debug stuff - show collision rectangles
			if (debugShowCollision)
			{
				var rectangle:Shape;
				
				for each (var collisionRect:Rectangle in maps[activeMap].collisionMap)
				{
					if (collisionRect != null && collisionRect.intersects(new Rectangle(mapScrollX, mapScrollY, stage.stageWidth, stage.stageHeight)))
					{
						rectangle = new Shape;
						rectangle.graphics.beginFill(0xFF0000, 0.5);
						rectangle.graphics.lineStyle(1, 0x0000FF);
						rectangle.graphics.drawRect(0, 0, collisionRect.width, collisionRect.height);
						rectangle.graphics.endFill();
						canvas.draw(rectangle, new Matrix(1, 0, 0, 1, collisionRect.x - mapScrollX, collisionRect.y - mapScrollY));
					}
				}
				for each (collisionRect in maps[activeMap].collisionMapColliding)
				{
					if (collisionRect != null && collisionRect.intersects(new Rectangle(mapScrollX, mapScrollY, stage.stageWidth, stage.stageHeight)))
					{
						rectangle = new Shape;
						rectangle.graphics.beginFill(0xFF0000, 0.5);
						rectangle.graphics.lineStyle(1, 0xFFFFFF);
						rectangle.graphics.drawRect(0, 0, collisionRect.width, collisionRect.height);
						rectangle.graphics.endFill();
						canvas.draw(rectangle, new Matrix(1, 0, 0, 1, collisionRect.x - mapScrollX, collisionRect.y - mapScrollY));
					}
				}
				for each (var t:Rectangle in debugHighlightedTiles)
				{
					rectangle = new Shape;
					rectangle.graphics.beginFill(0x00FF00, 0.5);
					rectangle.graphics.lineStyle(1, 0x0000FF);
					rectangle.graphics.drawRect(0, 0, t.width, t.height);
					rectangle.graphics.endFill();
					canvas.draw(rectangle, new Matrix(1, 0, 0, 1, t.x - mapScrollX, t.y - mapScrollY));
				}
			}
		}
		
		public function debugAddHighlightedTile(x:int, y:int):void {
			trace('adding highlight as ' + x + 'x' + y);
			if (!debugShowCollision || debugHighlightedTiles.length > 10) { return; }
			debugHighlightedTiles.push(new Rectangle(x, y, maps[activeMap].tileWidth, maps[activeMap].tileHeight));
		}
	}
}
