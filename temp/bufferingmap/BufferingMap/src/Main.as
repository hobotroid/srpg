package {
	
	import com.UIBase;
	import com.utils.FpsDisplay;
	import com.utils.Key;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class Main extends UIBase {

		// ==================================================================================================================
		// STATIC MEMBERS                                                                                      STATIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PUBLIC MEMBERS                                                                                      PUBLIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PRIVATE MEMBERS                                                                                    PRIVATE MEMBERS
		// ==================================================================================================================
		
		protected var display:Sprite;
		protected var map:MapData;
		protected var tileSize:Number;
		protected var viewSize:Point;
		protected var playerTile:Point;
		protected var zeroTile:Point;
		protected var displayOffset:Point;
		protected var mytimer:Timer;
		protected var mapIndex:int;
		
		// bitmap objects
		protected var mapDisplay:BitmapData;
		protected var bufferBase:BitmapData;
		protected var bufferSprite:BitmapData;
		protected var bufferOver:BitmapData;
		protected var chipSource:BitmapData;
		protected var spriteSource:BitmapData;
		protected var viewRect:Rectangle;
		protected var bufferRect:Rectangle;
		
		// ==================================================================================================================
		// CONSTRUCTOR / DESTRUCTOR                                                                  CONSTRUCTOR / DESTRUCTOR
		// ==================================================================================================================

		public function Main():void {
			super();
			init();
		}
		
		// ==================================================================================================================
		// PUBLIC FUNCTIONS                                                                                  PUBLIC FUNCTIONS
		// ==================================================================================================================

		public override function setSize( newWidth:Number, newHeight:Number ):void {
			super.setSize( newWidth, newHeight );
			// update the size of the other controls
		}
		
		// ==================================================================================================================
		// PRIVATE FUNCTIONS                                                                                PRIVATE FUNCTIONS
		// ==================================================================================================================

		protected function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			__classname = "Main";
			__packagename = "";
			
			// initialize our keyboard handler
			Key.initialize( stage );
			
			setInitialValues();
			createChildren();
			mapIndex = -1;
			loadNextMap();
			
			// setup our interval for key checking
			mytimer = new Timer( 5, 0 );
			mytimer.addEventListener( TimerEvent.TIMER, onKeyCheck, false, 0, true );
			mytimer.start();
			
			// take care of resizing
			stage.addEventListener( Event.RESIZE, onStageResize );
			onStageResize( null );
		}
		
		protected function setInitialValues():void {
			// default values
			tileSize = 16;
			viewRect = new Rectangle( 0, 0, 544, 480 );
			bufferRect = new Rectangle( 0, 0, viewRect.width + tileSize, viewRect.height + tileSize );
			viewSize = new Point( viewRect.width / tileSize, viewRect.height / tileSize );
			trace( "VIEW SIZE : " + viewSize );
			zeroTile = new Point( 0, 0 );
			displayOffset = new Point( 0, 0 );
		}
		
		protected function createChildren():void {
			
			// create our bitmap objects
			mapDisplay = new BitmapData( viewRect.width, viewRect.height, false, 0x00eeeeee );
			bufferBase = new BitmapData( bufferRect.width, bufferRect.height, false, 0x00eeeeee );
			bufferSprite = new BitmapData( bufferRect.width, bufferRect.height, true, 0x00ff00ff );
			bufferOver = new BitmapData( bufferRect.width, bufferRect.height, true, 0x00ff00ff );
			
			// create our display + attach
			display = new Sprite();
			addChild( display );
			display.addChild( new Bitmap( mapDisplay ) );
			display.addEventListener( MouseEvent.CLICK, onMapClick, false, 0, true );
			
			map = new MapData();
			map.addEventListener( Event.COMPLETE, mapLoaded, false, 0, true );
			
			var hud:PlayerHud = new PlayerHud();
			hud.x = viewRect.width - hud.width - 10;
			hud.y = viewRect.height - hud.height - 10;
			addChild( hud );
			
			var fps:FpsDisplay = new FpsDisplay();
			fps.x = 10;
			fps.y = viewRect.height - fps.height - 10;
			addChild( fps );
		}
		
		protected function loadMapData( mapName:String ):void {
			map.loadMap( mapName );
		}
		
		protected function setChipset( chipsetName:String ):void {
			var chipsetHash:Dictionary = new Dictionary( true );
			chipsetHash[ "chips.world" ] = AssetManager.WORLD_CHIPS;
			chipsetHash[ "chips.cave" ] = AssetManager.CAVE_CHIPS;
			chipsetHash[ "chips.cave.blue" ] = AssetManager.BLUECAVE_CHIPS;
			
			var myclass:Class = chipsetHash[ chipsetName ];
			var mychips:Bitmap = new myclass();
			chipSource = new BitmapData( mychips.width, mychips.height, false );
			chipSource.draw( mychips );
		}
		
		protected function renderFullMap():void {
			
			// clear our render layers
			bufferBase.fillRect( bufferRect, 0x00ffffff );
			bufferSprite.fillRect( bufferRect, 0x00ffffff );
			bufferOver.fillRect( bufferRect, 0x00ffffff );
			
			// up-front calcs
			var xtiles:Number = viewSize.x;
			var ytiles:Number = viewSize.y;
			var chipsAcross:Number = 160 / tileSize;
			var xend:Number = Math.min( zeroTile.x + xtiles, map.dataBase[0].length );
			var yend:Number = Math.min( zeroTile.y + ytiles, map.dataBase.length );

			// start copying tiles
			for ( var cx:Number = zeroTile.x; cx <= xend; cx++ ) {
				for ( var cy:Number = zeroTile.y; cy <= yend; cy++ ) {
					var destPoint:Point = new Point( (cx - zeroTile.x) * tileSize, (cy - zeroTile.y) * tileSize );
					var tilenum:Number;
					var sourceRect:Rectangle;
					
					// base data
					tilenum = map.dataBase[cy][cx];
					if ( tilenum != -1 ) {
						sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
						bufferBase.copyPixels( chipSource, sourceRect, destPoint );
					}
					
					// overlay data
					tilenum = map.dataOver[cy][cx];
					if ( tilenum != -1 ) {
						sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
						bufferOver.copyPixels( chipSource, sourceRect, destPoint );
					}
					
				}
			}
			// set magenta to transparent for overlay
			bufferOver.threshold(bufferOver, bufferOver.rect, new Point(0, 0), "==", 0xFFFF00FF, 0);
			
			// copy our render layers to our display
			mapDisplay.copyPixels( bufferBase, bufferBase.rect, new Point(0, 0) );
			mapDisplay.copyPixels( bufferOver, bufferOver.rect, new Point(0, 0) );
			
		}
		
		protected function addHorizontalStrip( addToTop:Boolean ):void {
			
			// scroll our render maps
			var yscroll:Number = ( addToTop ) ? tileSize : -tileSize;
			bufferBase.scroll(0, yscroll);
			bufferOver.scroll(0, yscroll);
			
			// clear the new strip
			var newy:Number = ( addToTop ) ? 0 : bufferOver.rect.height - tileSize;
			var newStrip:Rectangle = new Rectangle(0, newy, bufferOver.rect.width, tileSize);
			bufferBase.fillRect( newStrip, 0x00ffffff );
			bufferOver.fillRect( newStrip, 0x00ffffff );
			
			// up-front calcs
			var xtiles:Number = viewSize.x;
			var ytiles:Number = viewSize.y;
			var chipsAcross:Number = 160 / tileSize;
			var xend:Number = Math.min( zeroTile.x + xtiles, map.dataBase[0].length );
			var yend:Number = Math.min( zeroTile.y + ytiles, map.dataBase.length );
			var cy:Number = ( addToTop ) ? zeroTile.y : yend;
			for ( var cx:Number = zeroTile.x; cx <= xend; cx++ ) {
				var destPoint:Point = new Point( (cx - zeroTile.x) * tileSize, (cy - zeroTile.y) * tileSize );
				var tilenum:Number;
				var sourceRect:Rectangle;
				
				// base data
				tilenum = ( cy < map.dataBase.length ) ? map.dataBase[cy][cx] : -1;
				if ( tilenum != -1 ) {
					sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
					bufferBase.copyPixels( chipSource, sourceRect, destPoint );
				}
				
				// overlay data
				tilenum = ( cy < map.dataBase.length ) ? map.dataOver[cy][cx] : -1;
				if ( tilenum != -1 ) {
					sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
					bufferOver.copyPixels( chipSource, sourceRect, destPoint );
				}
				
			}
			// set magenta to transparent for overlay
			bufferOver.threshold(bufferOver, bufferOver.rect, new Point(0, 0), "==", 0xFFFF00FF, 0);
			
			// copy our render layers to our display
			mapDisplay.copyPixels( bufferBase, bufferBase.rect, new Point(0, 0) );
			mapDisplay.copyPixels( bufferOver, bufferOver.rect, new Point(0, 0) );
			
		}
		
		protected function addVerticalStrip( addToLeft:Boolean ):void {
			
			// scroll our render maps
			var xscroll:Number = ( addToLeft ) ? tileSize : -tileSize;
			bufferBase.scroll(xscroll, 0);
			bufferOver.scroll(xscroll, 0);
			
			// clear the new strip in the overlay
			var newx:Number = ( addToLeft ) ? 0 : bufferOver.rect.width - tileSize;
			var newStrip:Rectangle = new Rectangle(newx, 0, tileSize, bufferOver.rect.height);
			bufferOver.fillRect( newStrip, 0x00ffffff );
			
			// up-front calcs
			var xtiles:Number = viewSize.x;
			var ytiles:Number = viewSize.y;
			var chipsAcross:Number = 160 / tileSize;
			var xend:Number = Math.min( zeroTile.x + xtiles, map.dataBase[0].length );
			var yend:Number = Math.min( zeroTile.y + ytiles, map.dataBase.length );
			var cx:Number = ( addToLeft ) ? zeroTile.x : xend;
			for ( var cy:Number = zeroTile.y; cy <= yend; cy++ ) {
				var destPoint:Point = new Point( (cx - zeroTile.x) * tileSize, (cy - zeroTile.y) * tileSize );
				var tilenum:Number;
				var sourceRect:Rectangle;
				
				// base data
				tilenum = ( cy < map.dataBase.length ) ? map.dataBase[cy][cx] : -1;
				if ( tilenum != -1 ) {
					sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
					bufferBase.copyPixels( chipSource, sourceRect, destPoint );
				}
				
				// overlay data
				tilenum = ( cy < map.dataBase.length ) ? map.dataOver[cy][cx] : -1;
				if ( tilenum != -1 ) {
					sourceRect = new Rectangle( (tilenum % chipsAcross) * tileSize, Math.floor(tilenum / chipsAcross) * tileSize, tileSize, tileSize );
					bufferOver.copyPixels( chipSource, sourceRect, destPoint );
				}
				
			}
			// set magenta to transparent for overlay
			bufferOver.threshold(bufferOver, bufferOver.rect, new Point(0, 0), "==", 0xFFFF00FF, 0);
			
			// copy our render layers to our display
			mapDisplay.copyPixels( bufferBase, bufferBase.rect, new Point(0, 0) );
			mapDisplay.copyPixels( bufferOver, bufferOver.rect, new Point(0, 0) );
			
		}
		
		protected function loadNextMap():void {
			var maps:Array = [ "world-test", "mist01", "mist02", "mist03", "test" ];
			mapIndex = ( mapIndex + 1 ) % maps.length;
			zeroTile = new Point( 0, 0 );
			loadMapData( maps[ mapIndex ] );
		}
		
		// ==================================================================================================================
		// PROPERTIES                                                                                              PROPERTIES
		// ==================================================================================================================


		// ==================================================================================================================
		// EVENTS AND CALLBACKS                                                                          EVENTS AND CALLBACKS
		// ==================================================================================================================

		/**
		* Fired when the stage is resized.
		* @param	e
		* @return
		*/
		protected function onStageResize( e:Event ):void {
			trace( "Stage Resized : " + [ stage.stageWidth, stage.stageHeight ] );
			setSize( stage.stageWidth, stage.stageHeight );
		}
		
		protected function mapLoaded( e:Event ):void {
			// map loaded
			trace( "MAP DATA LOADED : " + [ map.chipset, map.width, map.height ] );
			setChipset( map.chipset );
			renderFullMap();
		}
		
		protected function onMapClick( e:MouseEvent ):void {
			loadNextMap();
		}
		
		protected function onKeyCheck( e:TimerEvent ):void {
			if ( Key.isDown( Keyboard.LEFT ) && ( zeroTile.x > 0 ) ) {
				zeroTile.x -= 1;
				addVerticalStrip( true );
			}
			if ( Key.isDown( Keyboard.RIGHT ) && ( zeroTile.x + viewSize.x < map.dataBase[0].length ) ) {
				zeroTile.x += 1;
				addVerticalStrip( false );
			}
			if ( Key.isDown( Keyboard.UP ) && ( zeroTile.y > 0 ) ) {
				zeroTile.y -= 1;
				addHorizontalStrip( true );
			}
			if ( Key.isDown( Keyboard.DOWN ) && ( zeroTile.y + viewSize.y < map.dataBase.length ) ) {
				zeroTile.y += 1;
				addHorizontalStrip( false );
			}
		}
	}
}
