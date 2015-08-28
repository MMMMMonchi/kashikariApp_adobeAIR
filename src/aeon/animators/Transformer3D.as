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
	import aeon.events.AnimationEvent;
	
	import flash.display.DisplayObject;
	import flash.geom.Matrix3D;
	
	/**
	 * The <code>Transformer3D</code> class simplifies 3D transformation of a display object from one
	 * transform matrix to another. The constructor takes the object to transform, the start matrix,
	 * the end matrix, the time of the animation and any particular easing function to apply.
	 * 
	 * Note that interpolating scale between two matrices is not currently supported using <code>Matrix3D</code>'s
	 * <code>interpolate()</code> method, which is what <code>Transformer3D</code> currently uses to tween matrix values.
	 *
	 * @example
	 * <pre>
	 * // the following code tweens a sprite on two axes of rotation
	 * 
	 * var startMatrix:Matrix3D = sprite.transform.matrix3D;
	 * var endMatrix:Matrix3D = startMatrix.clone();
	 * endMatrix.appendRotation(45, Vector3D.Y_AXIS);
	 * endMatrix.appendRotation(30, Vector3D.Z_AXIS);
	 * 
	 * var transformer3D:Transformer3D = new Transformer3D(
	 *   sprite,
	 *   startMatrix,
	 *   endMatrix,
	 *   800,
	 *   Quad.easeOut
	 * );
	 * transformer3D.start();
	 * </pre>
	 */
	public class Transformer3D extends Animation {
	
		private var _tween:Tweener;
		private var _target:DisplayObject;
		private var _startValue:Matrix3D;
		private var _endValue:Matrix3D;
		private var _time:Number;
		private var _easeFunction:Function;
	
		/**
		 * Constructor.
		 * 
		 * @param target The target object for the tweened values.
		 * @param startValue The initial 3D transform matrix of the animation.
		 * @param endValue The final 3D transform matrix of the animation.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 */
		public function Transformer3D(
			target:DisplayObject,
			startValue:Matrix3D,
			endValue:Matrix3D,
			time:Number,
			easeFunction:Function=null
		) {
			_target = target;
			_startValue = startValue;
			_endValue = endValue;
			_time = time;
			_easeFunction = easeFunction;
		}

		/**
		 * Handler for when the internal Tweener animation completes.
		 * This dispatches the <code>AnimationEvent.END</code> event.
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndTween(event:AnimationEvent):void {
			_target.transform.matrix3D = _endValue;
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
			var percent:Number = _tween.currentValue.percent as Number;
			var matrix:Matrix3D = Matrix3D.interpolate(_startValue, _endValue, percent);
			_target.transform.matrix3D = matrix;
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
			_target.transform.matrix3D = _startValue;
			_tween = new Tweener(null, {percent:0}, {percent:1}, _time, _easeFunction);
			_tween.addEventListener(AnimationEvent.CHANGE, onChangeTween);
			_tween.addEventListener(AnimationEvent.END, onEndTween);
			_tween.start();
			super.start();
		}
	
	}
	
}