package {
   import flash.display.MovieClip;	
   import flash.display.Bitmap;	
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.events.TimerEvent;
   
   import com.lasko.Global;

   public class MapObject {
      public var type:int;
      private var parentMap:Map;
      public var x:int;
      public var y:int;
      public var width:int;
      public var height:int;
      public var spriteNum:int;
      public var collideIndex:int;
      public var collisionType:int;
      public var params:Object;
      public var layerIndex:int = 0;
      private var moveTimer:Timer;
      private var state:String = "static";
      private var moveParams:Object;
      
      public function MapObject(parentMap:Map, type:int, params:Object=null) {
         this.parentMap = parentMap;
         this.type = type;
         this.params = params;
         
         switch(type) {
            case Global.TILE_TYPE_PORTAL:
               collisionType = Global.COLLISION_TYPE_PORTAL;
               spriteNum = -1;
               break;
            case Global.TILE_TYPE_GRAVE:
               collisionType = Global.COLLISION_TYPE_MOVABLE;
               spriteNum = 55;
               break;
            case Global.TILE_TYPE_TROLLY:
               collisionType = Global.COLLISION_TYPE_MOVABLE;
               spriteNum = params.spriteNum;
               break;
            case Global.TILE_TYPE_AIRSHIP:
               collisionType = Global.COLLISION_TYPE_AIRSHIP;
               spriteNum = 137;
trace("got mapobject airship");
               break;
            case Global.TILE_TYPE_BOX:
               if(!String(params.quantity).length) { params.quantity = 1; }
trace("got mapobject box - " + params.contents + " x"+params.quantity);
               collisionType = Global.COLLISION_TYPE_NORMAL;
               spriteNum = 57;
            case Global.TILE_TYPE_WALL:
               collisionType = Global.COLLISION_TYPE_NORMAL;
               break;
            case Global.TILE_TYPE_NPC:
               this.params = params.character;
               this.spriteNum = 1;
               collisionType = Global.COLLISION_TYPE_NPC;
               break;
            case Global.TILE_TYPE_MISC:
               this.spriteNum = params.spriteNum;
               break;
            default: 
               break;
         }
      }
      
      public function useItem():void
      {
trace('MapObject::useItem(), type='+type);
         switch(type) {
            case Global.TILE_TYPE_AIRSHIP:
               Global.game.stopGameTimer();
               Global.game.startMode7(this);
               return;
            case Global.TILE_TYPE_BOX:
               var dialog:DialogBox = Global.game.startDialog(null, XML(Global.game.getCharacterXML("boxman").dialog), null, 
                  function(actionType:String):void { //this function gets called if player chooses to loot
                     var lootTokens:Array = String(params.contents).split(" ");
                     spriteNum = 58; // change to open box sprite
                     type = Global.TILE_TYPE_DEAD_BOX;
					 Global.game.drawMap();
                     switch(lootTokens[0]) {
                        case "money":
                           var gained:int = lootTokens[1] == "random" ? Global.getRandomMoney() : lootTokens[1];
                           Global.game.getParty().addMoney(gained);
                           //Global.game.startDialog(null, Global.makeDialog("You found " + gained + " gift cards!"));
                           Global.game.startDialog(null, Global.makeDialog("You found " + gained + " gift cards!"));
                           break;
                        case "item":
                           var newItem:Item = new Item(lootTokens[1]);
                           Global.game.getParty().inventory.addItem(newItem);
                           //Global.game.startDialog(null, Global.makeDialog("You found "+newItem.name+"!"));
                           Global.game.startDialog(null, Global.makeDialog("You found "+newItem.name+"!"));
                           break;
                        default: break;
                     }
                  }
               );
               return;
            case Global.TILE_TYPE_NPC:
               if (params.leader.hasDialog()) {
                  Global.game.startDialog(params.leader, params.leader.getDialog(), params as Party);
               }
            default: break;
         }
      }
      
      public function setSize(w:int, h:int):void {
         width = w;
         height = h;
      }
      
      public function startMove(destX:int, destY:int):void {
         if(state == "static") {
            state = "moving";
            moveParams = {to: new Point(destX, destY), from:new Point(x, y)};
            trace('moving to ' + destX + 'x' + destY);
            moveTimer = new Timer(5, 0);
            moveTimer.addEventListener(TimerEvent.TIMER, moveTimerEvent, false, 0, true);
            moveTimer.start();
         }
      }
      
      private function moveTimerEvent(e:TimerEvent):void {
         //move complete
         if(x == moveParams.to.x && y == moveParams.to.y) { 
            parentMap.addTileAt(x, y, this);
            parentMap.removeTileAt(moveParams.from.x, moveParams.from.y, this);
            state = "static";
            moveTimer.stop();
            moveTimer = null;
            moveParams = null;
            return;
         }
      
         //move not complete
         var xo:int=0, yo:int=0;
         if (x != moveParams.to.x) { 
            xo = x > moveParams.to.x ? -1 : 1;
         }
         if (y != moveParams.to.y) {
            yo = y > moveParams.to.y ? -1 : 1;
         }
         x += xo;
         y += yo
         parentMap.collisionMap[collideIndex].x += xo;
         parentMap.collisionMap[collideIndex].y += yo;
      }
      
      public function toString():String {
         return('MapObject - type: ' + type +', collision: '+collisionType+', layer: '+layerIndex+', state: ' + state);
      }
   }
}
