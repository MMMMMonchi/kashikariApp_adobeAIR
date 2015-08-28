/**

Copyright (c) 2009 Todd M. Yard

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

*/
package aeon.animators {

	import aeon.Animation;
	import aeon.easing.Linear;
	import aeon.events.AnimationEvent;
	
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	/**
	 * The <code>Mover</code> class tweens both the position of a display object. The start and end values moust be <code>Point</code>
	 * instances defining the start and end positions. In addition, objects animated with the <code>Mover</code> class can have
	 * blurs applied during the animation to simulate motion blur if the <code>useBlur</code> parameter is passed as <code>true</code>
	 * to the constructor.
	 * 
	 * @example
	 * <pre>
	 * // the following tweens the position of a sprite from (0, 0) to (200, 200)
	 * and applies a motion blur all over the course of 2 seconds using a Quadratic
	 * easing out
	 * 
	 * var mover:Mover = new Mover(
	 *   sprite,
	 *   new Point(0, 0),
	 *   new Point(200, 200),
	 *   2000,
	 *   Quad.easeOut,
	 *   true
	 * );
	 * mover.start();
	 * </pre>
	 */
	public class Mover extends Animation {
	
		private var _tween:Tweener;
		private var _target:DisplayObject;
		private var _useBlur:Boolean;
		private var _blurAmount:Number;
		private var _blurQuality:int;
		private var _blurFilter:BlurFilter;
		private var _startValue:Object;
		private var _endValue:Object;
		private var _time:Number;
		private var _easeFunction:Function;
		private var _lastPosition:Point;
	
		/**
		 * Constructor.
		 *
		 * @param target The target object for the tweened values.
		 * @param startValue The starting position of the object in the animation.
		 * @param endValue The ending position of the object in the animation.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 * @param useBlur Whether a blur filter should be applied to the object while it animates in order to 
		 *                simulate motion blur.
		 * @param blurAmount The amount of blur to apply. The higher the number the more visible the blur will appear.
		 * @param blurQuality The number of times to perform a blur. This corresponds with the <code>quality</code> setting
		 *                    of the <code>BlurFilter</code>.
		 */
		public function Mover(
			target:DisplayObject,
			startValue:Point,
			endValue:Point,
			time:Number,
			easeFunction:Function=null,
			useBlur:Boolean=false,
			blurAmount:Number=1,
			blurQuality:int=1
		) {
			_target = target;
			// turn them into simple objects so that they may be iterated over
			_startValue = {x:startValue.x, y:startValue.y};
			_endValue = {x:endValue.x, y:endValue.y};
			_time = time;
			if (easeFunction == null) easeFunction = Linear.easeNone;
			_easeFunction = easeFunction;
			_useBlur = useBlur;
			_blurAmount = blurAmount;
			_blurQuality = blurQuality;
		}
	
		/**
		 * Handler for when the internal Tweener animation completes.
		 * This dispatches the <code>AnimationEvent.END</code> event.
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndTween(event:AnimationEvent):void {
			stop();
			dispatchEvent(new AnimationEvent(AnimationEvent.END));
		}
	
		/**
		 * Handler for when the internal Tweener animation updates.
		 * This dispatches the <code>AnimationEvent.CHANGE</code> event.
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onChangeTween(event:AnimationEvent):void {
			var changedValues:Object = _tween.currentValue;
			_target.x = changedValues.x;
			_target.y = changedValues.y;
			if (_useBlur) {
				var factor:Number = _blurAmount/10;
				_blurFilter.blurX = Math.abs((changedValues.x - _lastPosition.x)*factor);
				_blurFilter.blurY = Math.abs((changedValues.y - _lastPosition.y)*factor);
				var filters:Array = _target.filters.slice(0, -1);
				_target.filters = filters.concat(_blurFilter);
				_lastPosition = new Point(changedValues.x, changedValues.y);
			}
			dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE));
		}
		
		/**
		 * @inheritDoc
		 * 
		 * @example
		 * <pre>
		 * if (animator.running) {
		 *   animator.stop();
		 * }
		 * </pre>
		 */
		override public function stop():void {
			super.stop();
			if (_useBlur) {
				_target.filters = _target.filters.slice(0, -1);
			}
			_tween.removeEventListener(AnimationEvent.CHANGE, onChangeTween);
			_tween.removeEventListener(AnimationEvent.END, onEndTween);
			_tween.stop();
		}
	
		/**
		 * @inheritDoc
		 * 
		 * @example
		 * <pre>
		 * if (!animator.running) {
		 *   animator.start();
		 * }
		 * </pre>
		 */
		override public function start():void {
			_tween = new Tweener(null, _startValue, _endValue, _time, _easeFunction);
			_tween.addEventListener(AnimationEvent.CHANGE, onChangeTween);
			_tween.addEventListener(AnimationEvent.END, onEndTween);
			if (_useBlur) {
				_lastPosition = new Point(_target.x, _target.y);
				var filters:Array = _target.filters || [];
				_blurFilter = new BlurFilter(0, 0, _blurQuality);
				filters.push(_blurFilter);
				_target.filters = filters;
			}
			_tween.start();
			super.start();
		}
	
	}
	
}