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

	/**
	 * The <code>Scaler</code> class tweens both width and height of an object, using either the <code>width</code>
	 * and <code>height</code> properties of <code>DisplayObject</code> or a <code>setSize()</code> method, if it
	 * is defined on the target object. Scaling can either be done by pixels or percent, depending on the 
	 * <code>_scaleType</code> passed to the constructor.
	 * 
	 * The start and end values can either be defined as objects with <code>x</code> and <code>y</code> properties,
	 * or a scalar numeric value that will be used for scaling on both the x and y axes.
	 * 
	 * @example
	 * <pre>
	 * // the following scales a sprite to twice its size over 2 seconds
	 * 
	 * var scaler:Scaler = new Scaler(
	 *   sprite,
	 *   1,
	 *   2,
	 *   2000,
	 *   Scaler.PERCENT
	 * );
	 * scaler.start();
	 * </pre>
	 */
	public class Scaler extends Animation {
	
		public static const PIXEL:String = "pixel";
		public static const PERCENT:String = "percent";
	
		private var _tween:Tweener;
		private var _scaleType:String;
		private var _target:Object;
		private var _startValue:Object;
		private var _endValue:Object;
		private var _time:Number;
		private var _easeFunction:Function;
	
		/**
		 * Constructor.
		 *
		 * @param target The target object for the tweened values.
		 * @param startValue The value of the x and y properties at the start of the tween or a scalar numeric value
		 *                   to be used for both x and y axes.
		 * @param endValue The value of the x and y properties at the end of the tween or a scaler numeric value
		 *                 to be used for both x and y axes.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param scaleType Whether the scaling should be done by pixel value or by percent. Use Scaler.PIXEL or Scaler.PERCENT.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 */
		public function Scaler(
			target:Object,
			startValue:Object,
			endValue:Object,
			time:Number,
			scaleType:String=PIXEL,
			easeFunction:Function=null
		) {
			_target = target;
			if (startValue is Number) {
				startValue = {x:startValue, y:startValue};
				endValue = {x:endValue, y:endValue};
			}
			_startValue = startValue;
			_endValue = endValue;
			_scaleType = scaleType;
			_time = time;
			if (easeFunction == null) easeFunction = Linear.easeNone;
			_easeFunction = easeFunction;
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
			if (_scaleType == PIXEL) {
				if (_target.hasOwnProperty("setSize")) {
					_target.setSize(changedValues.x, changedValues.y);
				} else {
					_target.width = changedValues.x;
					_target.height = changedValues.y;
				}
			} else {
				_target.scaleX = changedValues.x;
				_target.scaleY = changedValues.y;
			}
			dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE));
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
			_tween.start();
			super.start();
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
			_tween.removeEventListener(AnimationEvent.END, onEndTween);
			_tween.stop();
		}
	
	}
	
}