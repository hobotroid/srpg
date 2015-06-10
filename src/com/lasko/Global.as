package com.lasko {
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.filters.DropShadowFilter;
	
	import mx.core.BitmapAsset;

	import com.lasko.Game;
	import com.lasko.util.Utils;
	import com.lasko.ui.DebugWindow;

	public class Global
	{
		private static const TEXT_HEIGHT:int = 30;

		public static const TILE_TYPE_PORTAL = 1;
		public static const TILE_TYPE_GRAVE = 2;
		public static const TILE_TYPE_AIRSHIP = 3;
		public static const TILE_TYPE_BOX = 4;
		public static const TILE_TYPE_DEAD_BOX = 5;
		public static const TILE_TYPE_WALL = 6;
		public static const TILE_TYPE_NPC = 7;
		public static const TILE_TYPE_MISC = 8;
		public static const TILE_TYPE_TROLLY = 8;

		public static const COLLISION_LEVEL = 0;
		public static const COLLISION_MAP_OBJECT_COLLIDABLE = 1;
		public static const COLLISION_MAP_OBJECT= 2;
		public static const COLLISION_TYPE_CHARACTER = 3;
		public static const COLLISION_TYPE_PLAYER = 4;

		public static const DIRECTION_LEFT = 1;
		public static const DIRECTION_RIGHT = 2;
		public static const DIRECTION_UP = 3;
		public static const DIRECTION_DOWN = 4;

		public static const STATE_UPWALK = 1;
		public static const STATE_DOWNWALK = 2;
		public static const STATE_LEFTWALK = 3;
		public static const STATE_RIGHTWALK = 4;
		public static const STATE_RIGHTSTILL = 5;
		public static const STATE_UPSTILL = 6;
		public static const STATE_DOWNSTILL = 7;
		public static const STATE_LEFTSTILL = 8;
		public static const STATE_COMBAT = 9;
		public static const STATE_DEAD = 10;
		public static const STATE_LEFTBLINK = 11;
		public static const STATE_RIGHTBLINK = 12;
		public static const STATE_DOWNBLINK = 13;
		public static const STATE_STANDARD = 14;
		public static const STATE_INVULNERABLE = 15;
		public static const STATE_WANDERING = 16;
		public static const STATE_FOLLOWING = 17;

		public static const BAR_COLOR_HP = 0xdc6048;
		public static const BAR_COLOR_SP = 0x7daa1b;
		
		public static const WALK_SPEED = 4;
		public static const SCROLL_SPEED = 4;
		
		public static const USE_DISTANCE = 10;

		public static var game:Game;
		public static var main:Main;
		public static var currentBackground:BitmapData;
		public static var gameWidth:int, gameHeight:int;
		
		public static var charactersXML:XML;
		public static var itemsXML:XML;
		private static var mapXMLs = new Object();
		
		public static var debugWindow:DebugWindow;
		public static var showCollisionBoxes:Boolean = false;
		 
		public function Global() { }
      
		public static function setGame(g:Game)
		{
			game = g;
			gameWidth = 800;
			gameHeight = 600;
		}
		
		public static function setMain(m:Main) {
			main = m;
		}
      
		public static function makeText(string:String, bold:Boolean=true):TextField
		{
			var tf = new TextField();

			tf.text = string;
			tf.embedFonts = true;
			tf.setTextFormat(Fonts.textFormatMain);
			tf.defaultTextFormat = Fonts.textFormatMain;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var f:DropShadowFilter = new DropShadowFilter();
			f.blurX = f.blurY = 0;
			f.distance = 1;
			tf.filters = [f];

			return(tf);
		}
	  
		public static function makeSmallText(string:String):TextField
		{
			var tf = new TextField();

			tf.text = string;
			tf.embedFonts = true;
			tf.setTextFormat(Fonts.textFormatMain);
			tf.defaultTextFormat = Fonts.textFormatMain;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			return(tf);
		}
		
		public static function disableText(tf:TextField) {
			tf.alpha = 0.5;
		}
		
		public static function enableText(tf:TextField) {
			tf.alpha = 1.0;
		}

		public static function getRandomMoney():int
		{
			return(Utils.randRange(1, 8));
		}

		public static function makeDialog(string:String):XML
		{
			return(XML("<dialog><prompt type='initial'>" + string + "</prompt></dialog>"));
		}
		
		public static function addMapXML(name:String, xml:XML) {
			mapXMLs[name] = xml;
		}
		
		public static function setCharactersXML(xml:XML) {
			charactersXML = xml;
		}
		
		public static function setItemsXML(xml:XML) {
			itemsXML = xml;
		}
		
		public static function getMapXML(name:String) {
			return mapXMLs[name];
		}
		
		public static function setDebugWindow(window:DebugWindow) {
			debugWindow = window;
		}
		
		public static function debugOut(string:String) {
			debugWindow.out(string);
		}
   }
}