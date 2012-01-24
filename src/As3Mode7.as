// Actionscript 3 Mode7 Engine
// Robert Kabwe
// http://protopop.com
//
// Code adapted to Actionscript 3 from Fred Heintz's Actionscript 2 Mode7 Engine
// Frederic Heintz
// www.fredheintz.com

package {
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.events.*;

	public class As3Mode7 extends Sprite {

		var colZ:Number;
		var colX:Number;
		var cfX:Number;
		var angleX:Number;
		var leCos;
		var dx:Number;
		var dy:Number;
		var x2b:Number;
		var x2:Number;
		var dspd:Number=.2;

		///////////////
		var sinus = Math.sin;
		var cosinus = Math.cos;
		var _resoDx:Number = Stage.width;
		var _resoDy:Number = Stage.height;
		var _angleX:Number = 0;
		var _angleY:Number = 45;
		var _ycam:Number = 500;
		var _xcam:Number = 0;
		var _zcam:Number = 0;
		var _scanSteps:Number = 1;
		var _nbMs:Number = 60;
		var _bmpd:BitmapData = new sol1(0,0);
		var i:Number=0;
		var hx:Number = _resoDx*0.5;
		var hy:Number = _resoDy*0.5;
		var dist:Number;
		var _nbScans:Number = 400;
		var bMouseIsDown:Boolean;

		public function As3Mode7() {
			var mcCode:MovieClip = new MovieClip();
			addChild(mcCode);//added
			mcCode.x = hx;
			mcCode.y = hy;
			for (i=0; i<_nbScans; i++) {
				var mcCo:Sprite = new Sprite();
				mcCo.y = -mcCo.y+(i*_scanSteps);
				mcCo.x=320;
				mcCo.name="mclip"+i;
				addChild(mcCo);
			}
			rayX = sinus(_angleY*Math.PI/180);
			rayZ = cosinus(_angleY*Math.PI/180);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler );
			addEventListener(Event.ENTER_FRAME,enterFrameHandler);
		}
		function onMouseDownHandler( e:Event ):void {
			bMouseIsDown = true;
		}
		function onMouseUpHandler( e:Event ):void {
			bMouseIsDown = false;
		}
		function enterFrameHandler(event:Event):void {

			dx = (mouseX-(320))*0.0003;// pan amount
			dy = (mouseY-(200))*0.0002;// tilt amount
			if (bMouseIsDown) {
				_angleX += dy*_nbMs;// tilt angle -360 to 360
				_angleY += dx*_nbMs;// pan angle -360 to 360

				_angleX = _angleX%360;// loop tilt angle
				_angleY = _angleY%360;// loop pan angle
				rayX = sinus(_angleY*Math.PI/180);
				rayZ = cosinus(_angleY*Math.PI/180);
				_xcam -= (rayX*_nbMs*dspd);
				_zcam -= (rayZ*_nbMs*dspd);
				_ycam -= sinus(_angleX*Math.PI/180)*_nbMs*dspd;
			}
			_xcam = _xcam%1024;
			_zcam = _zcam%1024;
			_ycam<40 ? _ycam=40 : null;
			_ycam>=2000 ? _ycam=2000 : null;
			x2 = (300)/500;
			cfX = (40/_nbScans)*Math.PI/180;
			angleX = (_angleX*Math.PI/180.0)-(cfX*_nbScans*0.5);
			matrix = new Matrix();
			matrix.identity();
			matrix.rotate(_angleY*Math.PI/180.0);
			while (++i<_nbScans) {
				var mcCo=getChildByName("mclip"+i);
				mcCo.graphics.clear();
				angleX += cfX;
				rayY = sinus(angleX);
				if (rayY<0) {
					continue;
				}
				dist = (_ycam/rayY);
				leCos = cosinus(angleX)*dist;
				colX = _xcam-(rayX*leCos);
				colZ = _zcam-(rayZ*leCos);
				matrix.tx = (colX*matrix.a)+(colZ*matrix.c);
				matrix.ty = (colX*matrix.b)+(colZ*matrix.d);
				var x2b = x2*dist;
				mcCo.scaleX = (50000/dist)*.01;
				mcCo.graphics.beginBitmapFill(_bmpd,matrix,true,false);
				mcCo.graphics.drawRect(-x2b, 0, x2b*2, 2);
				mcCo.graphics.endFill();
			}
			i = 0;
		}
	}
}