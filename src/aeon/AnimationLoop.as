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
package aeon {

	import aeon.easing.Linear;
	import aeon.events.AnimationEvent;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * The <code>AnimationLoop</code> class allows you to replay an animation (which can be a composite or sequence as well) a specified
	 * number of times, or indefinitely.
	 * 
	 * This class also allows for functions to be passed to the constructor to be invoked whenever the <code>AnimationEvent.CHANGE</code>
	 * or <code>AnimationEvent.END</code> events are fired by the managed animation. This differs from other <code>Animation</code> child classes,
	 * which do not accept functions in their constructors, merely to make it easier to set up an infinitely looping animation that can completely
	 * manage itself without ties to external handlers (although that can be done as well).
	 * 
	 * @example
	 * <pre>
	 * // this sets up a looping animation for a sprite, tweening its alpha from 0 to 1, then 1 to 0, indefinitely
	 * 
	 * var loop:AnimationLoop = new AnimationLoop(
	 *   new AnimationSequence(
	 *     [
	 *     new Tweener(sprite, {alpha:0}, {alpha:1}, 500),
	 *     new Tweener(sprite, {alpha:1}, {alpha:0}, 500)
	 *     ]
	 *   )
	 * );
	 * loop.start();
	 * </pre>
	 * 
	 * @see AnimationSequence
	 * @see aeon.animators.Tweener
	 */
	public class AnimationLoop extends Animation {
	
		private var _animation:Animation;
		private var _totalLoops:uint;
		private var _currentLoop:uint;

		/**
		 * Constructor.
		 * 
		 * @param animation The animation to run in a loop.
		 * @param numLoops The number of times to run an animation. If this is -1, then the animation will be run indefinitely.
		 * @param changeFunction The function to invoke every time the <code>AnimationEvent.CHANGE</code> is dispatched by the managed animation.
		 * @param endFunction The function to invoke every time the <code>AnimationEvent.END</code> is dispatched by the managed animation.
		 */
		public function AnimationLoop(
			animation:Animation,
			numLoops:Number=-1,
			changeFunction:Function=null,
			endFunction:Function=null
		) {
			_animation = animation;
			_animation.addEventListener(AnimationEvent.END, onEndAnimation);
			_totalLoops = numLoops;
			// yes, this could all be done external to the class, but having it managed here means an external
			// instance doesn't have to set up handlers and can pass anonymous functions that are not needed
			// except for the loop
			if (changeFunction != null) {
				_animation.addEventListener(AnimationEvent.CHANGE, changeFunction);
			}
			if (endFunction != null) {
				_animation.addEventListener(AnimationEvent.END, endFunction);
			}
		}
	
		/**
		 * Handler for when the animation managed in the loop completes. If the total number of
		 * loops have run, then the <code>AnimationEvent.END</code> event is dispatched.
		 * Otherwise, the animation is started once more.	
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndAnimation(event:AnimationEvent):void {
			// if _totalLoops is 0 or less, run indefinitely
			if (_totalLoops > 0 && ++_currentLoop >= _totalLoops) {
				stop();
				dispatchEvent(new AnimationEvent(AnimationEvent.END));
			} else {
				_animation.start();
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
			_currentLoop = 0;
			super.start();
			_animation.start();
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
			if (_animation) {
				_animation.removeEventListener(AnimationEvent.END, onEndAnimation);
				_animation.stop();
			}
		}

		/**
		 * The animation currently being run in the loop.
		 */
		public function get animation():Animation {
			return _animation;
		}

	}

}