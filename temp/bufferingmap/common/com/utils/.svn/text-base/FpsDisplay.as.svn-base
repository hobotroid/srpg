package com.utils {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class FpsDisplay extends Sprite {

		// ==================================================================================================================
		// STATIC MEMBERS                                                                                      STATIC MEMBERS
		// ==================================================================================================================

		protected static var BACKGROUND_COLOR:uint = 0xff666666;
		protected static var LINE_COLOR:uint = 0x33999999;
		protected static var GRAPH_COLOR:uint = 0xff93D27C;

		// ==================================================================================================================
		// PUBLIC MEMBERS                                                                                      PUBLIC MEMBERS
		// ==================================================================================================================


		// ==================================================================================================================
		// PRIVATE MEMBERS                                                                                    PRIVATE MEMBERS
		// ==================================================================================================================

		private var mytext:TextField;
		private var fps:uint;
		private var timer:Timer;
		private var graph:BitmapData;

		// ==================================================================================================================
		// CONSTRUCTOR / DESTRUCTOR                                                                  CONSTRUCTOR / DESTRUCTOR
		// ==================================================================================================================


		/**
		* Class Constructor.
		*/
		public function FpsDisplay( ) {
			init();
		}

		// ==================================================================================================================
		// PUBLIC FUNCTIONS                                                                                  PUBLIC FUNCTIONS
		// ==================================================================================================================


		// ==================================================================================================================
		// PRIVATE FUNCTIONS                                                                                PRIVATE FUNCTIONS
		// ==================================================================================================================

		private function init():void {
			var myformat:TextFormat = new TextFormat( "_sans", 11, 0xffffff, false );
			var myglow:GlowFilter = new GlowFilter( 0x333333, 1, 2, 2, 3, 2, false, false );

			// fps graph
			var graphHolder:Sprite = new Sprite();
			graphHolder.x = 35;
			addChild( graphHolder );
			graph = new BitmapData( 40, 20, false, BACKGROUND_COLOR );
			graphHolder.addChild( new Bitmap( graph ) );
			drawGraphLines();

			// display label
			mytext = new TextField();
			mytext.autoSize = TextFieldAutoSize.LEFT;
			mytext.defaultTextFormat = myformat;
			mytext.selectable = false;
			mytext.text = "00 fps";
			mytext.filters = [ myglow ];
			addChild( mytext );

			// setup our timers
			fps = 0;
			timer = new Timer( 1000 );
			timer.addEventListener( TimerEvent.TIMER, onTimerEvent );
			timer.start();
			addEventListener( Event.ENTER_FRAME, onEnterFrame );

		}

		private function drawGraphLines():void {
			for ( var i:Number = 5; i < graph.height; i += 5 ) {
				var lineRect:Rectangle = new Rectangle( 0, i, graph.width, 1 );
				graph.fillRect( lineRect, LINE_COLOR );
			}
		}

		public function setPosition( newx:Number, newy:Number ):void {
			x = newx;
			y = newy;
		}
		
		// ==================================================================================================================
		// PROPERTIES                                                                                              PROPERTIES
		// ==================================================================================================================


		// ==================================================================================================================
		// EVENTS AND CALLBACKS                                                                          EVENTS AND CALLBACKS
		// ==================================================================================================================

		private function onEnterFrame( e:Event ):void {
			fps ++;
		}

		private function onTimerEvent( e:Event ):void {
			// update our graph for the current tick
			graph.fillRect( new Rectangle( graph.width - 1, 0, 1, graph.height ), BACKGROUND_COLOR );
			var val:Number = ( fps / 2 );
			graph.fillRect( new Rectangle( graph.width - 1, graph.height - val, 1, val ), GRAPH_COLOR );
			graph.scroll( -2, 0 );
			drawGraphLines();
			// update our label + reset the counter
			mytext.text = fps.toString() + " fps";
			fps = 0;
		}
	}
}