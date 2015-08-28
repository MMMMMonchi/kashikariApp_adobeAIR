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
	
	import flash.utils.getTimer;

	/**
	 * The <code>Tweener</code> class handles calculating intermediate values between start and end numeric values over the course
	 * of a specified time using linear interpolation or an optional "easing" function that can be passed to the
	 * constructor. A target object may also be passed to the constructor so that interpolated values may be set 
	 * directly on the target object as the tween is calculated over time.
	 * 
	 * Alternatively, if no target object is set, a <code>Tweener</code> instance may be used to simply interpolate values over time
	 * with directly setting anything on an external object instance. In this scenario, an external object instance would
	 * set up a listener for a tweener's <code>AnimationEvent.CHANGE</code> event and would take care of updating its
	 * own properties by accessing the <code>currentValue</code> of the tweener.
	 * 
	 * The other classes in the <code>aeon.animators</code> package, including <code>Mover</code>, <code>Scaler</code>
	 * and <code>Tranformer3D</code> all use a <code>Tweener</code> instance to handle their animations.
	 * 
	 * @example
	 * <pre>
	 * // the following code tweens the alpha of a sprite from 0 to 1 over 800 milliseconds using a Quad wasing function
	 * 
	 * var tweener:Tweener = new Tweener(
	 *   sprite,
	 *   {alpha:0},
	 *   {alpha:1},
	 *   800,
	 *   Quad.easeOut
	 * );
	 * tweener.start();
	 * </pre>
	 * 
	 * <pre>
	 * // the following code demonstrates how a Tweener instance may be set up to tween values, but not assign
	 * // values to a specific instance; instead, that is handled by the external instance in a custom event handler
	 * 
	 * var tweener:Tweener = new Tweener(
	 *   null,
	 *   {r:0, g:255, b:0},
	 *   {r:255, g:127, b:127},
	 *   2000
	 * );
	 * tweener.addEventListener(AnimationEvent.CHANGE, onAnimationChange);
	 * tweener.start();
	 * </pre>
	 * 
	 * @see Mover
	 * @see Scaler
	 * @see Transformer3D
	 * @see aeon.events.AnimationEvent
	 */
	public class Tweener extends Animation {

		/**
		 * This constant holds the value that can be passed to a <code>Tweener</code> instance to inform it
		 * that the value that should be used in the interpolation at the start point should be the value of the object
		 * at the start of the animation.
		 */
		public static var CURRENT_VALUE:String = "*";
	
		private var _target:Object;
		private var _prop:String;
		private var _startValue:Object;
		private var _endValue:Object;
		private var _changeValue:Object;
		private var _currentValue:Object;
		private var _lastValue:Object;
		private var _time:Number;
		private var _easeFunction:Function;
		private var _startTime:Number;

		/**
		 * Constructor.
		 * 
		 * @param target The target object for the tweened values. This may be null if no object should be directly altered by the tweener.
		 * @param startValue The initial values of an animation. This should be an object of one or more properties.
		 * @param endValue The final values of an animation. This should be an object of one or more properties that matches the
		 *                 <code>startValue</code> object.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 */
		public function Tweener(
			target:Object,
			startValue:Object,
			endValue:Object,
			time:Number,
			easeFunction:Function=null
		) {
			_receiveEnterFrame = true;
			_target = target;
			// @todo It would be nice if single numeric values could be passed in and handled, as opposed to objects
			_startValue = startValue;
			_endValue = endValue;
			_time = time;
			if (easeFunction == null) easeFunction = Linear.easeNone;
			_easeFunction = easeFunction;
			_changeValue = {};
		}

		/**
		 * Assigns the current values of the interpolated properties to the target object.
		 */
		private function setClipValues():void {
			if (_target == null) return;
			for (var property:String in _currentValue) {
				if (_target.hasOwnProperty(property)) {
					_target[property] = _currentValue[property];
				}
			}
		}
	
		/**
		 * Calculates the values of the interpolated properties based on the current time of the animation.
		 * If the time is complete, the <code>AnimationEvent.END</code> event is dispatched. In all cases,
		 * the <code>AnimationEvent.CHANGE</code> event is dispatched.
		 * 
		 * If a target exists for this instance, then current values are assigned directly to it.
		 */
		override protected function updateAnimation():void {
			_lastValue = _currentValue;
			var currentTime:Number = getTimer()-_startTime;
			if (currentTime >= _time || percentComplete >= 1) {
				// if animation is complete, current values should be end values
				_currentValue = _endValue;
				setClipValues();
				stop();
				dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE));
				dispatchEvent(new AnimationEvent(AnimationEvent.END));
			} else {
				_currentValue = {};
				// calculate current values here
				for (var property:String in _changeValue) {
					if (isNaN(_changeValue[property])) {
						_currentValue[property] = _startValue[property];
					} else {
						_currentValue[property] = _easeFunction(currentTime, _startValue[property], _changeValue[property], _time);
					}
				}
				setClipValues();
				dispatchEvent(new AnimationEvent(AnimationEvent.CHANGE));
			}
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
			_startTime = getTimer();
			_currentValue = _startValue;
			for (var property:String in _startValue) {
				// if CURRENT_VALUE is used, assign current value to _startValue object
				if (_startValue[property] == CURRENT_VALUE) {
					if (_target && _target.hasOwnProperty(property)) {
						_startValue[property] = _target[property];
					}
				}
				// skip non-numbers
				if (isNaN(_startValue[property])) {
					_changeValue[property] = _startValue[property];
				} else {
					// if the end value begins with + or -, calculate end value
					if (_endValue[property] is String) {
						var sign:String = _endValue[property].charAt(0);
						if (sign == "+") {
							_endValue[property] = _startValue[property] + Number(_endValue[property].substr(1));
						} else if (sign == "-") {
							_endValue[property] = _startValue[property] - Number(_endValue[property].substr(1));
						}
					}
					_changeValue[property] = _endValue[property] - _startValue[property];
				}
			}
			super.start();
		}
	
		/**
		 * @inheritDoc
		 * 
		 * @example
		 * <pre>
		 * if (animator != null) {
		 *   animator.die();
		 * }
		 * </pre>
		 */
		override public function die():void {
			super.die();
			_target = null;
			_startValue = null;
			_endValue = null;
			_easeFunction = null;
			_changeValue = null;
			_currentValue = null;
			_lastValue = null;
		}

		/**
		 * The percent of the animation that has completed, between 0 and 1.
		 */		
		public function get percentComplete():Number {
			return ((getTimer()-_startTime)/_time);
		}
		
		/**
		 * The current interpolated values of the animation based on the percent complete.
		 */
		public function get currentValue():Object {
			return _currentValue;
		}

		/**
		 * The values of the animation at the last update.
		 */
		public function get lastValue():Object {
			return _lastValue;
		}

	}

}