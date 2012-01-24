package ui {
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.LineScaleMode;
   import flash.display.CapsStyle;
   import flash.display.JointStyle;
   import flash.text.TextField;
   import flash.geom.Rectangle;
   import flash.geom.Point;
   import flash.events.*;
   import flash.utils.Timer;
   import flash.ui.Keyboard;

   public class Screen extends TopLevel
   {
      public static const WIDTH:int = 640;
      public static const HEIGHT:int = 480;
	  public static const DEFAULT_BOX_COLOR:uint = 0x5fa7cd;
      private static const ITEM_PADDING:int = 10;
   
      private var boxes:Array = new Array();
      private var currentBox:String = "";
      
      private var pointerTimer:Timer;
   
      public function Screen(useBackground:Boolean=false)
      {
         var bg:Shape = new Shape();
         bg.graphics.beginFill(0x000000, useBackground ? .75 : 0);
         bg.graphics.lineStyle();
         bg.graphics.drawRect(0, 0, WIDTH, HEIGHT);
         bg.graphics.endFill();
         addChild(bg);
         0
         pointerTimer = new Timer(160, 0);
         pointerTimer.addEventListener(TimerEvent.TIMER, updatePointer);
         pointerTimer.start();
         
         this.mouseEnabled = false;
      }
      
      public function addBox(x:int, y:int, w:int, h:int, label:String, layout:String = "vertical", columns:int = 0, color:uint=DEFAULT_BOX_COLOR, defaultCallback:Function=null):void
      {
         //border/box
         var box:Shape = new Shape();
         var clip:MovieClip = new MovieClip();  
         box.graphics.beginFill(color);
         //box.graphics.lineStyle(10, /*0x5fa7cd*/0xff0000, 1.0, true, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND);
         //box.graphics.drawRect(0, 0, w, h);
		 box.graphics.drawRoundRect(0, 0, w, h, 30, 30)
         box.graphics.endFill();
         clip.x = x;
         clip.y = y;
         clip.addChild(box);
         
         //container for actual content - scrollable
         var scrollPane:MovieClip = new MovieClip();
         scrollPane.x = 10;
         scrollPane.y = 10;
         scrollPane.graphics.beginFill(color);
         scrollPane.graphics.drawRect(0, 0, w-20, h-20);
         scrollPane.graphics.endFill();
         scrollPane.scrollRect = new Rectangle(0, 0, w-20, h-20);
         clip.addChild(scrollPane);
         
         //pointer/cursor
         var pointer:Bitmap = new Bitmap(new BitmapData(Global.game.pointer[0].width, Global.game.pointer[0].height, true));
         pointer.bitmapData.copyPixels(
            Global.game.pointer[0].bitmapData, 
            new Rectangle(0, 0, Global.game.pointer[0].width, Global.game.pointer[0].height),
            new Point(0, 0)
         );
         pointer.visible = false;
         clip.addChild(pointer);
         
         //construct object
         boxes[label] = {
            "menuItems": [],
            "textItems": [],
            "pointer": pointer,
            "pointerFrame": 0,
            "selectedItem": 0,
            "clip": clip,
            "scrollPane": scrollPane,
            "layout": layout,
            "columns": columns,
            "defaultCallback": defaultCallback,
            "index": boxes.length
         }

         //add box to screen
         addChild(clip);
      }
      
      private function updatePointer(e:Event):void
      {
         if (currentBox && currentBox.length) {
            if (++boxes[currentBox].pointerFrame > Global.game.pointer.length - 1) { boxes[currentBox].pointerFrame = 0; }
            boxes[currentBox].pointer.bitmapData.copyPixels(
               Global.game.pointer[boxes[currentBox].pointerFrame].bitmapData, 
               new Rectangle(0, 0, Global.game.pointer[boxes[currentBox].pointerFrame].width, Global.game.pointer[boxes[currentBox].pointerFrame].height),
               new Point(0, 0)
            );
         }
      }
      
      //adds static box text
      public function addBoxText(destination:String, label:String):void
      {
         var tf:TextField = Global.makeText(label);
         var item:Object = {"element":tf};
         tf.x = 0;
         tf.y = 0;
         
         boxes[destination].textItems.push(item);
         boxes[destination].scrollPane.addChild(tf);
      }
      
      //add a menu item that's not text
      public function addMenuItem(destination:String, clip:MovieClip, callback:Function, callbackParams:Object=null, exitCallback:Function=null, exitCallbackParams:Object=null):void
      {
         var item:Object = {"element":clip, "callback":callback, "exitCallback":exitCallback, "callbackParams": callbackParams, "exitCallbackParams": exitCallbackParams};
         var box:Object = boxes[destination];
         var previousElement:MovieClip = box.menuItems.length ? box.menuItems[box.menuItems.length - 1].element : null;
         
         switch(box.layout) {
            case "vertical":
               clip.x = 0;
               if(!previousElement) {
                  clip.y = 0;
               } else {
                  clip.y = previousElement.y + previousElement.height + ITEM_PADDING;
               }
               break;
            case "columns":
               var destColumn:int = box.menuItems.length % box.columns;
               clip.x = destColumn * box.scrollPane.width / box.columns;
               clip.y = Math.floor(box.menuItems.length / box.columns) * clip.height;
               break;
			case "free":
				break;
            default: break;
         }
      
         box.menuItems.push(item);
         box.scrollPane.addChild(clip);
      }
      
      //add a menu item that's text
      public function addMenuText(destination:String, label:String, callback:Function=null, callbackParams:Object=null, exitCallback:Function=null, exitCallbackParams:Object=null):void
      {
         var tf:TextField = Global.makeText(label);
         var item:Object = { "element":tf, "callback":callback, "exitCallback":exitCallback, "callbackParams": callbackParams, "exitCallbackParams": exitCallbackParams };
         var box:Object = boxes[destination];
         var previousElement:TextField = box.menuItems.length ? box.menuItems[box.menuItems.length-1].element : null;
         
         switch(box.layout) {
            case "vertical":
               tf.x = 0;
               if(box.textItems.length) { tf.x += 20; }
               if(!previousElement) {
                  tf.y = 0;
                  for each(var itm:Object in box.textItems) {
                     tf.y += itm.element.textHeight + 20;
                  }
               } else {
                  tf.y = previousElement.y + previousElement.height + ITEM_PADDING;
               }
               break;
            case "horizontal":
               if(!previousElement) {
                  tf.x = 0;
               } else {
                  tf.x = previousElement.x + previousElement.width + ITEM_PADDING;
               }
               tf.y = 0;
               break;
            case "columns":
               var destColumn:int = box.menuItems.length % box.columns;
               tf.x = destColumn * box.scrollPane.width / box.columns;
               tf.y = Math.floor(box.menuItems.length / box.columns) * tf.height;
               break;
            default: break;
         }
         
         box.menuItems.push(item);
         box.scrollPane.addChild(tf);
      }
      
      public function addKeyListener(e:Event=null):void
      {
         if(!hasEventListener(KeyboardEvent.KEY_UP)) { 
            addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true); 
         }
         stage.focus = this;
      }
      
      public function addMenuChangeCallback(destination:String, callback:Function):void
      {
         boxes[destination].changeCallback = callback;
      }
      
      public function removeKeyListener():void
      {
         removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
      }

      private function keyUpHandler(e:KeyboardEvent):void
      {
         switch(boxes[currentBox].layout) {
            case "columns":
               if(e.keyCode == Keyboard.UP) {
                  changeItem(-boxes[currentBox].columns);
               } else if(e.keyCode == Keyboard.DOWN) {
                  changeItem(boxes[currentBox].columns);
               } else if(e.keyCode == Keyboard.RIGHT) {
                  changeItem(1);
               } else if(e.keyCode == Keyboard.LEFT) {
                  changeItem(-1);
               }
               break;
            case "vertical":
               if(e.keyCode == Keyboard.UP) {
                  changeItem(-1);
               } else if(e.keyCode == Keyboard.DOWN) {
                  changeItem(1);
               }
               break;
            case "horizontal":
               if(e.keyCode == Keyboard.LEFT) {
                  changeItem(-1);
               } else if(e.keyCode == Keyboard.RIGHT) {
                  changeItem(1);
               }
               break;
            default: break;
         }

         var selectedItem:Object = boxes[currentBox].menuItems[boxes[currentBox].selectedItem];
         if (e.keyCode == 88) { //X
            if (selectedItem) { 
               selectedItem.callback(selectedItem.callbackParams);
            } else {
               boxes[currentBox].defaultCallback();
            }
         } else if(e.keyCode == 90) { //Z
            if(selectedItem) {
               selectedItem.exitCallback(selectedItem.exitCallbackParams);
            } else {
               boxes[currentBox].defaultCallback();
            }
         }
         
         e.stopPropagation();
      }
      
      public function changeItem(offset:int):void
      {
         //set new selected index
         var newIndex:int = boxes[currentBox].selectedItem+offset;
         if(newIndex < 0) { newIndex = boxes[currentBox].menuItems.length-1; }
         if(newIndex > boxes[currentBox].menuItems.length-1) { newIndex = 0; }
         boxes[currentBox].selectedItem = newIndex;
         if(!boxes[currentBox].menuItems.length) { return; }
         
         //move pointer to new item and scroll if necessary
         var selectedElement:Object = boxes[currentBox].menuItems[newIndex].element;
         var scrollPane:MovieClip = boxes[currentBox].scrollPane;
         if(selectedElement.y+selectedElement.height > scrollPane.scrollRect.y+scrollPane.height) {
            scrollPane.scrollRect = new Rectangle(0, scrollPane.scrollRect.y+selectedElement.height+ITEM_PADDING, scrollPane.scrollRect.width, scrollPane.scrollRect.height);
         } else if(selectedElement.y+selectedElement.height < scrollPane.scrollRect.y) {
            scrollPane.scrollRect = new Rectangle(0, scrollPane.scrollRect.y-selectedElement.height-ITEM_PADDING, scrollPane.scrollRect.width, scrollPane.scrollRect.height);
         }
         boxes[currentBox].clip.removeChild(boxes[currentBox].pointer);
         boxes[currentBox].pointer.y = selectedElement.y - scrollPane.scrollRect.y - boxes[currentBox].pointer.height*.125;
         boxes[currentBox].pointer.x = selectedElement.x - boxes[currentBox].pointer.width/1.25;
         boxes[currentBox].clip.addChild(boxes[currentBox].pointer);
         
         if (boxes[currentBox].changeCallback) { boxes[currentBox].changeCallback(newIndex); }
      }
      
      public function clearSelection(destination:String):void
      {
         boxes[destination].selectedItem = 0;
         boxes[destination].pointer.visible = false;
      }
      
      public function clear(destination:String):void
      {
         var box:Object = boxes[destination];
         var item:Object;
         
         clearSelection(destination);
         
         for each(item in box.menuItems) {
            item.element.parent.removeChild(item.element);
         }
         for each(item in box.textItems) {
            item.element.parent.removeChild(item.element);
         }
         box.menuItems = [];
         box.textItems = [];
      }
      
      public function switchBox(destination:String):void
      {
         if (currentBox) {
            boxes[currentBox].pointer.alpha = .5; 
            boxes[currentBox].clip.alpha = .5;
         }

         if(destination != null) {
            if(boxes[destination].menuItems.length) {  //only show pointer if there are options
               boxes[destination].pointer.alpha = 1;
               boxes[destination].pointer.visible = true;
               boxes[destination].clip.alpha = 1;
            }
            currentBox = destination;
            changeItem(0);
         } else {
            currentBox = null;
         }
      }
      
      public function removeBox(destination:String):void
      {
         var box:Object = boxes[destination];
         
         if(box) {
            clearSelection(destination);
            if(box.clip && contains(box.clip)) { removeChild(box.clip); }
            boxes.splice(box.index, 1);
         }
      }
      
      public function getSelectedItem(destination:String):Object
      {
         return(boxes[destination].menuItems[boxes[destination].selectedItem]);

      }
      
      public function getSelectedIndex(destination:String):int
      {
         return(boxes[destination].selectedItem);
      }
      
      public function updateSelectedItem(destination:String, item:Object):void
      {
         boxes[destination].selectedItem = item;
      }
   }
}