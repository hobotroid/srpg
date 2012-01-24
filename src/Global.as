package {
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFieldAutoSize;
   import flash.text.AntiAliasType;
   import flash.filters.DropShadowFilter;
   
   import util.Utils;

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
      
      public static const COLLISION_TYPE_NORMAL = 1;
      public static const COLLISION_TYPE_PORTAL = 2;
      public static const COLLISION_TYPE_MOVABLE = 3;
      public static const COLLISION_TYPE_AIRSHIP = 4;
      public static const COLLISION_TYPE_NPC = 5;
	  
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
	  
      public static var game:Test;
      public static var tileset48:BitmapData;
      public static var tileset24:BitmapData;
      public static var currentBackground:BitmapData;
      public static var gameWidth:int, gameHeight:int;
      
      [Embed(source="../characters.xml",mimeType="application/octet-stream")]
      public static var EmbeddedXML:Class;
      public static var charactersXML:XML = XML(new EmbeddedXML());
      [Embed(source="../items.xml",mimeType="application/octet-stream")]
      public static var EmbeddedXML2:Class;
      public static var itemsXML:XML = XML(new EmbeddedXML2());
         
      public function Global() { }
      
      public static function setGame(g:Test)
      {
         game = g;
         gameWidth = g.stage.stageWidth;
         gameHeight = g.stage.stageHeight;
      }
      
      public static function debugOut(text:String)
      {
         game.debugField.appendText(text + '\n');
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
      
      public static function makeSprite(index:int):Bitmap
      {
         var map:Map = game.getActiveMap();
         var bitmap:Bitmap = new Bitmap(new BitmapData(48, 48));
         bitmap.bitmapData.copyPixels(
            Global.tileset48, 
            new Rectangle((index % 17) * 48, (int(index/17)) * 48, 48, 48*2),
            new Point(0, 0)
         );
         
         return(bitmap);
      }
      
      public static function getRandomMoney():int
      {
         return(Utils.randRange(1, 8));
      }
      
      public static function makeDialog(string:String):XML
      {
         return(XML("<dialog><prompt type='initial'>" + string + "</prompt></dialog>"));
      }
   }
}