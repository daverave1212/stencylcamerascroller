

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;


import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;


class CameraScroller extends SceneScript
{

	public static var cameraScroller : CameraScroller = null;

	var clickX : Float;
	var clickY : Float;
	var clickCameraX : Float;
	var clickCameraY : Float;
	var isDraggingCamera : Bool = false;
	var isVerticalScrollEnabled : Bool = false;
	var isHorizontalScrollEnabled : Bool = false;
	var isCameraSmoothingEnabled : Bool = true;
	
	private var timeSinceClick : Float = 0;
	private var timeSinceSmoothingCamera : Float = 0;
	private var deltaX : Float = 0;
	private var deltaY : Float = 0;
	private var speedX : Float = 0;
	private var speedY : Float = 0;
	private var isSpeedXPositive : Bool = true;
	private var isSpeedYPositive : Bool = true;
	private var isSpeedXFaster : Bool = true;
	private var isSpeedYFaster : Bool = false;
	private var isSmoothingCamera : Bool = false;
	
	
	public static function initialize(?smooth : Bool){
		cameraScroller = new CameraScroller();
		cameraScroller.isVerticalScrollEnabled = true;
		cameraScroller.isHorizontalScrollEnabled = true;
		if(smooth == true){
			cameraScroller.isCameraSmoothingEnabled = true;
		}
	}

	public static function unlock(){
		cameraScroller.isVerticalScrollEnabled = true;
		cameraScroller.isHorizontalScrollEnabled	= true;
	}
	
	public static function lock(){
		cameraScroller.isVerticalScrollEnabled = false;
		cameraScroller.isHorizontalScrollEnabled	= false;
	}
	
	public static function unlockHorizontal(){
		cameraScroller.isHorizontalScrollEnabled	= true;
	}
	
	public static function unlockVertical(){
		cameraScroller.isVerticalScrollEnabled	= true;
	}
	
	public static function lockHorizontal(){
		cameraScroller.isHorizontalScrollEnabled = false;
	}
	
	public static function lockVertical(){
		cameraScroller.isVerticalScrollEnabled = false;
	}
	
	public static function enableSmoothing(){
		cameraScroller.isCameraSmoothingEnabled = true;
	}
	
	public static function disableSmoothing(){
		cameraScroller.isCameraSmoothingEnabled = false;
	}

	public static function lockAny(type : Int){
		switch(type){
			case 1: lock();
			case 2: lockHorizontal();
			case 3: lockVertical();
		}
	}
	
	public static function unlockAny(type : Int){
		switch(type){
			case 1: unlock();
			case 2: unlockHorizontal();
			case 3: unlockVertical();
		}
	}
	
	public static function setSmoothing(type : Int){
		if(type == 1){
			enableSmoothing();
		} else {
			disableSmoothing();
		}
	}
	
	public static function initializeAny(type : Int, ?smooth : Bool){
		initialize(smooth);
		if(type == 2){
			cameraScroller.isVerticalScrollEnabled = false;
		} else if(type == 3){
			cameraScroller.isHorizontalScrollEnabled = false;
		} else if(type == 4){
			cameraScroller.isHorizontalScrollEnabled = false;
			cameraScroller.isVerticalScrollEnabled = false;
		}
	}

	public function new(){
		super();
		enableScroll();
	}
	
	private function enableScroll(){
		trace("enabling scroll. Should work");
		addMousePressedListener(function(list:Array<Dynamic>):Void{
			clickCameraX = getScreenXCenter();
			clickCameraY = getScreenYCenter();
			if(isHorizontalScrollEnabled){
				clickX = getMouseX();
				timeSinceClick = 0;
			}
			if(isVerticalScrollEnabled){
				clickY = getMouseY();
				timeSinceClick = 0;
			}
			isDraggingCamera = true;
			isSmoothingCamera = false;
		});
		addMouseReleasedListener(function(list:Array<Dynamic>):Void{
			isDraggingCamera = false;
			if(isCameraSmoothingEnabled){
				if(timeSinceClick < 300){
					speedX = deltaX / timeSinceClick * 20;
					speedY = deltaY / timeSinceClick * 20;
					if(speedX < 0) isSpeedXPositive = false;
					else isSpeedXPositive = true;
					if(speedY < 0) isSpeedYPositive = false;
					else isSpeedYPositive = true;
					if(Math.abs(speedX) > Math.abs(speedY)){
						isSpeedXFaster = true;
						isSpeedYFaster = false;
					} else {
						isSpeedXFaster = false;
						isSpeedYFaster = true;
					}
					trace("SpeedX: " + speedX + ", SpeedY: " + speedY);
					timeSinceSmoothingCamera = 0;
					isSmoothingCamera = true;
				}
			}
		});
		runPeriodically(20, function(timeTask:TimedTask):Void{
			if(isDraggingCamera){
				timeSinceClick += 20;
				deltaX = 0;
				deltaY = 0;
				if(isHorizontalScrollEnabled) deltaX = clickX - getMouseX();
				if(isVerticalScrollEnabled) deltaY = clickY - getMouseY();
				engine.moveCamera(clickCameraX + deltaX, clickCameraY + deltaY);
			} else if(isSmoothingCamera){
				timeSinceSmoothingCamera += 20;
				engine.moveCamera(getScreenXCenter() + speedX, getScreenYCenter() + speedY);
				if(timeSinceSmoothingCamera > 250){
					if(isSpeedXPositive){
						speedX -= speedX * 0.02;
						if(isSpeedXFaster && speedX < 0.1){
							isSmoothingCamera = false;
						}
					} else {
						speedX -= speedX * 0.02;
						if(isSpeedXFaster && speedX > -0.1){
							isSmoothingCamera = false;
						}
					}
					trace(speedX);
					if(isSpeedYPositive){
						speedY -= speedY * 0.02;
						if(isSpeedYFaster && speedY < 0.1){
							isSmoothingCamera = false;
						}
					} else {
						speedY -= speedY * 0.02;
						if(isSpeedYFaster && speedY > -0.1){
							isSmoothingCamera = false;
						}
					}
				}

			}
		}, null);
	}

}