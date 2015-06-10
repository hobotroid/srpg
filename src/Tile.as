package {
   import flash.display.MovieClip;	
   import flash.display.Bitmap;	

   import com.lasko.map.Map;
   
   public class Tile  {
      public var type:String;
      private var parentMap:Map;
      
      public var x:int;
      public var y:int;
      public var width:int;
      public var height:int;
      public var spriteNum:int;
      public var collisionType:int;
      public var collideIndex:int;
      public var layerIndex:int;
      public var object:Object;
      
      public function Tile(parentMap:Map, spriteNum:int, collisionType:int=0) {
         this.parentMap = parentMap;
         this.spriteNum = spriteNum;
         type = "tile";
      }
      
      public function setSize(w:int, h:int):void {
         width = w;
         height = h;
      }
      
      public function setLayerIndex(index:int):void {
         layerIndex = index;
      }
   }
}
