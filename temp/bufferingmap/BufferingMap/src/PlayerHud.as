package  {
	
	import com.UIBase;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class PlayerHud extends com.UIBase {

		// ==================================================================================================================
		// STATIC MEMBERS                                                                                      STATIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PUBLIC MEMBERS                                                                                      PUBLIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PRIVATE MEMBERS                                                                                    PRIVATE MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// CONSTRUCTOR / DESTRUCTOR                                                                  CONSTRUCTOR / DESTRUCTOR
		// ==================================================================================================================

		public function PlayerHud( ) {
			init();
		}

		// ==================================================================================================================
		// PUBLIC FUNCTIONS                                                                                  PUBLIC FUNCTIONS
		// ==================================================================================================================

		override public function setSize( newWidth:Number, newHeight:Number ):void {
			super.setSize( newWidth, newHeight );
		}

		// ==================================================================================================================
		// PRIVATE FUNCTIONS                                                                                PRIVATE FUNCTIONS
		// ==================================================================================================================

		protected function init():void {
			// override the package and class names for the toString method
			__packagename = "";
			__classname = "PlayerHud";
			
			createChildren();
		}
		
		protected function createChildren():void {
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter(0x333333, 1, 2, 2, 3, 2, false, false);
			
			var lvl:TextField;
			var level:TextField;
			var name:TextField;
			
			myformat.color = 0xcccccc;
			lvl = new TextField();
			lvl.autoSize = TextFieldAutoSize.LEFT;
			lvl.defaultTextFormat = myformat;
			lvl.selectable = false;
			lvl.text = "lvl";
			addChild( lvl );
			
			myformat.color = 0xffffff;
			myformat.size = 24;
			level = new TextField();
			level.autoSize = TextFieldAutoSize.LEFT;
			level.defaultTextFormat = myformat;
			level.selectable = false;
			level.text = "32";
			level.filters = [ myglow ];
			level.x = level.y = 5;
			addChild( level );
			
			myformat.size = 14;
			myformat.bold = true;
			name = new TextField();
			name.autoSize = TextFieldAutoSize.LEFT;
			name.defaultTextFormat = myformat;
			name.selectable = false;
			name.text = "Exorcyze";
			name.filters = [ myglow ];
			name.x = 35;
			name.y = 6;
			addChild( name );
			
			var currenthp:TextField;
			currenthp = new TextField();
			currenthp.autoSize = TextFieldAutoSize.LEFT;
			currenthp.defaultTextFormat = myformat;
			currenthp.selectable = false;
			currenthp.text = "320";
			currenthp.filters = [ myglow ];
			currenthp.x = 138;
			currenthp.y = 6;
			addChild( currenthp );
			
			var currentmp:TextField;
			currentmp = new TextField();
			currentmp.autoSize = TextFieldAutoSize.LEFT;
			currentmp.defaultTextFormat = myformat;
			currentmp.selectable = false;
			currentmp.text = "42";
			currentmp.filters = [ myglow ];
			currentmp.x = 198;
			currentmp.y = 6;
			addChild( currentmp );
			
			var hplabel:TextField;
			myformat.size = 11;
			myformat.bold = false;
			myformat.color = 0xff9900;
			hplabel = new TextField();
			hplabel.autoSize = TextFieldAutoSize.LEFT;
			hplabel.defaultTextFormat = myformat;
			hplabel.selectable = false;
			hplabel.text = "HP";
			hplabel.filters = [ myglow ];
			hplabel.x = 120;
			hplabel.y = 8;
			addChild( hplabel );
			
			var mplabel:TextField;
			mplabel = new TextField();
			mplabel.autoSize = TextFieldAutoSize.LEFT;
			mplabel.defaultTextFormat = myformat;
			mplabel.selectable = false;
			mplabel.text = "MP";
			mplabel.filters = [ myglow ];
			mplabel.x = 180;
			mplabel.y = 8;
			addChild( mplabel );
			
			/** bar backgrounds **/
			var barback:Sprite = new Sprite();
			addChild( barback );
			
			barback.graphics.beginFill( 0x333333, .5 );
			barback.graphics.drawRect( 37, 26, 75, 3 );
			barback.graphics.endFill();
			
			barback.graphics.beginFill( 0x333333, .5 );
			barback.graphics.drawRect( 122, 26, 50, 3 );
			barback.graphics.endFill();
			
			barback.graphics.beginFill( 0x333333, .5 );
			barback.graphics.drawRect( 182, 26, 50, 3 );
			barback.graphics.endFill();
			
			/** bars **/
			var bars:Sprite = new Sprite();
			addChild( bars );
			
			bars.graphics.beginFill( 0xcccc00, 1 );
			bars.graphics.drawRect( 37, 26, 25, 3 );
			bars.graphics.endFill();
			
			bars.graphics.beginFill( 0x009900, 1 );
			bars.graphics.drawRect( 122, 26, 35, 3 );
			bars.graphics.endFill();
			
			bars.graphics.beginFill( 0x000099, 1 );
			bars.graphics.drawRect( 182, 26, 45, 3 );
			bars.graphics.endFill();
			
		}
		
		override protected function render( ):void {
			// this is where you would place your specific code for rendering
			// the state at the current size.
		}

		// ==================================================================================================================
		// PROPERTIES                                                                                              PROPERTIES
		// ==================================================================================================================


		// ==================================================================================================================
		// EVENTS AND CALLBACKS                                                                          EVENTS AND CALLBACKS
		// ==================================================================================================================

	}
}
