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
	import flash.geom.ColorTransform;

	/**
	 * The <code>ColorTransformer</code> class simply tweens the color transform of a display object. The start
	 * and end values of the animation are defined as <code>ColorTransform</code> instances.
	 * 
	 * @example
	 * <pre>
	 * // the following tweens a sprite's colors from white at no alpha to no transform over half a second
	 * 
	 * var startTransform:ColorTransform = new ColorTransform(0, 0, 0, 0, 255, 255, 255);
	 * var endTransform:ColorTransform = new ColorTransform();
	 * var colorTransformer:ColorTransformer = new ColorTransformer(
	 *   sprite,
	 *   startTransform,
	 *   endTransform,
	 *   500
	 * );
	 * colorTransformer.start();
	 * </pre>
	 */
	public class ColorTransformer extends Animation {

		private var _tween:Tweener;
		private var _target:DisplayObject;
		private var _startTransform:ColorTransform;
		private var _endTransform:ColorTransform;
		private var _time:Number;
		private var _easeFunction:Function;

		/**
		 * Constructor.
		 *
		 * @param target The target object for the tweened values.
		 * @param startValue The starting <code>ColorTransform</code> for the display object.
		 * @param endValue The ending <code>ColorTransform</code> for the display object.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 */
		public function ColorTransformer(
			target:DisplayObject,
			startTransform:ColorTransform=null,
			endTransform:ColorTransform=null,
			time:Number=1000,
			easeFunction:Function=null
		) {
			_target = target;
			_time = time;
			if (easeFunction == null) easeFunction = Linear.easeNone;
			_easeFunction = easeFunction;
			_startTransform = startTransform || new ColorTransform(0, 0, 0, 1, 255, 255, 255, 0);
			_endTransform = endTransform || new ColorTransform();
		}
	
		/**
		 * Turns a <code>ColorTransform</code> instance into an object that can be iterated over.
		 */
		private function makeTransform(transform:ColorTransform):Object {
			var object:Object = {
				ra:transform.redMultiplier,
				rb:transform.redOffset,
				ga:transform.greenMultiplier,
				gb:transform.greenOffset,
				ba:transform.blueMultiplier,
				bb:transform.blueOffset,
				aa:transform.alphaMultiplier,
				ab:transform.alphaOffset
			};
			return object;
		}

		/**
		 * Handler for when the internal Tweener animation completes.
		 * This dispatches the <code>AnimationEvent.END</code> event.
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndTween(event:AnimationEvent):void {
			_target.transform.colorTransform = _endTransform;
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
			var value:Object = _tween.currentValue;
			_target.transform.colorTransform = new ColorTransform(
				value.ra,
				value.ga,
				value.ba,
				value.aa,
				value.rb|0,
				value.gb|0,
				value.bb|0,
				value.ab
			);
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
			_target.transform.colorTransform = _startTransform;
			_tween = new Tweener(null, makeTransform(_startTransform), makeTransform(_endTransform), _time, _easeFunction);
			_tween.addEventListener(AnimationEvent.CHANGE, onChangeTween);
			_tween.addEventListener(AnimationEvent.END, onEndTween);
			_tween.start();
			super.start();
		}

	}

}