package com.lasko.ui 
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.globalization.Collator;
	import flash.text.TextField;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.ui.Keyboard;
   
	import com.lasko.util.Utils;

	public class Screen extends TopLevel
	{
		public static const WIDTH:int = 640;
		public static const HEIGHT:int = 480;
		public static const DEFAULT_BOX_COLOR:uint = 0x5fa7cd;

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

			pointerTimer = new Timer(160, 0);
			pointerTimer.addEventListener(TimerEvent.TIMER, updatePointer);
			pointerTimer.start();

			this.mouseEnabled = false;
		}

		public function addBox(options:Object):void
		{
			var defaults:Object = { x:0, y:0, width:50, height:50, label:null, layout:"vertical", columns:0, color:DEFAULT_BOX_COLOR, defaultCallback:null, defaultExitCallback:null };
			options = Utils.mergeObjects(defaults, options);
			
			//border/box
			var box:Shape = new Shape();
			var clip:MovieClip = new MovieClip();  
			box.graphics.beginFill(options.color);
			box.graphics.drawRoundRect(0, 0, options.width, options.height, 20, 20)
			box.graphics.endFill();
			clip.x = options.x;
			clip.y = options.y;
			clip.addChild(box);

			//container for actual content - scrollable
			var scrollPane:MovieClip = new MovieClip();
			scrollPane.x = 10;
			scrollPane.y = 10;
			scrollPane.graphics.beginFill(options.color);
			scrollPane.graphics.drawRect(0, 0, options.width-20, options.height-20);
			scrollPane.graphics.endFill();
			scrollPane.scrollRect = new Rectangle(0, 0, options.width-20, options.height-20);
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
			
			//corners
			var corners:Bitmap = new Bitmap(new BitmapData(options.width, options.height, true, 0x00000000));
			var ct:ColorTransform = new ColorTransform();
			ct.color = options.color;
			corners.bitmapData.copyPixels(Global.game.corner.bitmapData, new Rectangle(0, 0, 8, 8), new Point(0, 0));
			corners.bitmapData.copyPixels(Global.game.corner.bitmapData, new Rectangle(16, 0, 8, 8), new Point(options.width - 8, 0));
			corners.bitmapData.copyPixels(Global.game.corner.bitmapData, new Rectangle(0, 16, 8, 8), new Point(0, options.height - 8));
			corners.bitmapData.copyPixels(Global.game.corner.bitmapData, new Rectangle(16, 16, 8, 8), new Point(options.width - 8, options.height - 8));
			corners.bitmapData.colorTransform(corners.getRect(corners), ct);
			clip.addChild(corners);

			//construct object Silvia Navarro,
			boxes[options.label] = {
				"menuItems": [],
				"textItems": [],
				"pointer": pointer,
				"pointerFrame": 0,
				"selectedIndex": 0,
				"clip": clip,
				"scrollPane": scrollPane,
				"layout": options.layout,
				"columns": options.columns,
				"defaultCallback": options.defaultCallback,
				"defaultExitCallback": options.defaultExitCallback,
				"index": boxes.length,
				"label": options.label,
				"itemPadding": 10,
				"x": options.x,
				"y": options.y,
				"width": options.width,
				"height": options.height
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
		public function addMenuItem(destination:String, clip:MovieClip, options:Object=null):void
		{
			var defaults:Object = { callback:null, callbackParams: null, exitCallback:null, exitCallbackParams: null, x: null, y: null, enabled: true };
			options = Utils.mergeObjects(defaults, options);
			
			var box:Object = boxes[destination];
			var item:Object = {"element":clip, "callback":options.callback, "exitCallback":options.exitCallback, "callbackParams": options.callbackParams, "exitCallbackParams": options.exitCallbackParams, "enabled":options.enabled};

			var previousElement:MovieClip = box.menuItems.length ? box.menuItems[box.menuItems.length - 1].element : null;

			switch(box.layout) {
				case "vertical":
				clip.x = 0;
				if(!previousElement) {
					clip.y = 0;
				} else {
					clip.y = previousElement.y + previousElement.height + box.itemPadding;
				}
				break;
				case "columns":
					var destColumn:int = box.menuItems.length % box.columns;
					clip.x = destColumn * box.scrollPane.width / box.columns;
					clip.y = Math.floor(box.menuItems.length / box.columns) * clip.height;
				break;
				case "free":
					clip.x = options.x;
					clip.y = options.y;
				break;
				default: break;
			}

			item.index = box.menuItems.length;
			box.menuItems.push(item);
			box.scrollPane.addChild(clip);
		}
      
		//add a menu item that's text
		public function addMenuText(destination:String, options:Object):void 
		{
			var defaults:Object = { label:null, callback:null, callbackParams:null, exitCallback:null, exitCallbackParams:null, changeCallback:null, enabled:true };
			options = Utils.mergeObjects(defaults, options);

			var tf:TextField = Global.makeText(options.label);
			var item:Object = { "element":tf, "callback":options.callback, "exitCallback":options.exitCallback, "callbackParams": options.callbackParams, "exitCallbackParams": options.exitCallbackParams, "changeCallback":options.changeCallback, "enabled":options.enabled };
			var box:Object = boxes[destination];
			var previousElement:TextField = box.menuItems.length ? box.menuItems[box.menuItems.length-1].element : null;

			if(!item.enabled) {
				Global.disableText(tf);
			}

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
						tf.y = previousElement.y + previousElement.height + 0;//box.itemPadding;
					}
				break;
				case "horizontal":
					if(!previousElement) {
						tf.x = 0;
					} else {
						tf.x = previousElement.x + previousElement.width + box.itemPadding;
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

			item.index = box.menuItems.length;
			box.menuItems.push(item);
			box.scrollPane.addChild(tf);
		}

		public function enableMenuTextIndex(index:int):void {
			var box:Object = boxes[index];
			Global.enableText(box.element);
		}

		public function disableMenuTextIndex(index:int):void {
			var box:Object = boxes[index];
			Global.disableText(box.element);
		}

		public function addKeyListener(e:Event=null):void
		{
			if (!hasEventListener(KeyboardEvent.KEY_UP)) {
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
						trace('down');
					}
					break;
				case "horizontal":
					if(e.keyCode == Keyboard.LEFT) {
						changeItem(-1);
					} else if(e.keyCode == Keyboard.RIGHT) {
						changeItem(1);
					}
					break;
				case "free":
					if(e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP) {
						changeItem(-1);
					} else if(e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.DOWN) {
						changeItem(1);
					}
					break;
				default: break;
			}

			var selectedIndex:Object = boxes[currentBox].menuItems[boxes[currentBox].selectedIndex];
			if (e.keyCode == 88) { //X
				if (selectedIndex) { 
					selectedIndex.callback(selectedIndex.callbackParams);
				} else {
					boxes[currentBox].defaultCallback();
				}
			} else if(e.keyCode == 90) { //Z
				if(selectedIndex && selectedIndex.exitCallback) {
					selectedIndex.exitCallback(selectedIndex.exitCallbackParams);
				} else {
					boxes[currentBox].defaultExitCallback();
				}
			}
		 
			e.stopPropagation();
		}
      
		public function changeItem(offset:int, destination:String=null):Boolean
		{
			if (!destination) { destination = currentBox; }
			var box:Object = boxes[destination];
			if (!box.menuItems.length) { return false; }

			//set new selected index
			var newIndex:int = box.selectedIndex + offset;
			if (newIndex > box.menuItems.length - 1 ) {
				box.selectedIndex = -1;
				return changeItem(offset, destination);
			}
			if (newIndex < 0) {
				box.selectedIndex = box.menuItems.length;
				return changeItem(offset, destination);
			}
			if (!box.menuItems[newIndex].enabled) {
				box.selectedIndex = newIndex;
				return changeItem(offset + Utils.sign(offset));
			}
			
			return selectItem(newIndex, destination);
		}
		
		public function selectItem(index:int, destination:String=null):Boolean 
		{
			if (!destination) { destination = currentBox; }
			var box:Object = boxes[destination];
			var item:Object = box.menuItems[index];
			box.selectedIndex = index;

			//move pointer to new item and scroll if necessary
			var selectedElement:Object = box.menuItems[index].element;

			var scrollPane:MovieClip = box.scrollPane;
			if(box.layout != "free") {
				if(selectedElement.y+selectedElement.height > scrollPane.scrollRect.y+scrollPane.height) {
					scrollPane.scrollRect = new Rectangle(0, scrollPane.scrollRect.y+selectedElement.height+box.itemPadding, scrollPane.scrollRect.width, scrollPane.scrollRect.height);
				} else if(selectedElement.y+selectedElement.height < scrollPane.scrollRect.y) {
					scrollPane.scrollRect = new Rectangle(0, scrollPane.scrollRect.y-selectedElement.height-box.itemPadding, scrollPane.scrollRect.width, scrollPane.scrollRect.height);
				}
			}

			box.clip.removeChild(box.pointer);
			box.pointer.y = selectedElement.y - scrollPane.scrollRect.y - box.pointer.height*.125;
			box.pointer.x = selectedElement.x - box.pointer.width/1.25;
			box.clip.addChild(box.pointer);

			if (box.changeCallback) { box.changeCallback(index); }
			return true;
		}
      
		public function clearSelection(destination:String):void
		{
			boxes[destination].selectedIndex = 0;
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
				//boxes[currentBox].pointer.alpha = .5; 
				//boxes[currentBox].clip.alpha = .5;
			}

			if(destination != null) {
				if(boxes[destination].menuItems.length) {  //only show pointer if there are options
					boxes[destination].pointer.alpha = 1;
					boxes[destination].pointer.visible = true;
					boxes[destination].clip.alpha = 1;
				}
				currentBox = destination;
				
				//select first enabled item
				var selectedIndex:int = 0;
				for each(var menuItem:Object in boxes[destination].menuItems) {
					if (menuItem.enabled) { selectedIndex = menuItem.index; break;  }
				}
				changeItem(selectedIndex);
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

		public function getBox(destination:String):Object {
			return(boxes[destination]);
		}

		public function getSelectedItem(destination:String):Object
		{
			return(boxes[destination].menuItems[boxes[destination].selectedIndex]);
		}

		public function getSelectedIndex(destination:String):int
		{
			return(boxes[destination].selectedIndex);
		}

		public function updateselectedIndex(destination:String, item:Object):void
		{
			boxes[destination].selectedIndex = item;
		}
	}
}