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

	import aeon.events.AnimationEvent;

	/**
	 * The <code>AnimationSequence</code> class allows for running of multiple animations in a sequence through a single call to the
	 * <code>start()</code> method of this class. The order of the animations is determined by the order of the array passed to this
	 * class's constructor. When one animation completes, the next animation in the sequence is run. When the final animation in the
	 * sequence completes, this class will dispatch a single <code>AnimationEvent.END</code> event.
	 * 
	 * This class does not dispatch <code>AnimationEvent.CHANGE</code> events. To be notified when an animation managed by
	 * this class is being run, you must subscribe to the <code>AnimationEvent.CHANGE</code> events dispatched by the managed animation.
	 * 
	 * @example
	 * <pre>
	 * // the following code fades a sprite in over one second, holds without animation for one second,
	 * // then fades the sprite out over one second
	 * 
	 * var fadeIn:Tweener = new Tweener(sprite, {alpha:0}, {alpha:1}, 1000);
	 * var hold:AnimationHold = new AnimationHold(1000);
	 * var fadeOut:Tweener = new Tweener(sprite, {alpha:1}, {alpha:0}, 1000);
	 * 
	 * var sequence:AnimationSequence([fadeIn, hold, fadeOut]);
	 * sequence.start();
	 * </pre>
	 * 
	 * @see AnimationComposite, AnimationHold
	 */
	public class AnimationSequence extends Animation {
	
		private var _animation:Animation;
		private var _animations:Array;
		private var _runningAnimations:Array;
	
		/**
		 * Constructor.
		 * 
		 * @param animations An array of <code>Animation</code> instances that will be managed by this instance.
		 */
		public function AnimationSequence(animations:Array) {
			_animations = animations;
		}
	
		/**
		 * Handler for when a single managed animation completes. This calls the <code>runAnimation()</code>
		 * method, which will advance to the next animation or determine that all animations in the sequence
		 * have been run.	
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndAnimation(event:AnimationEvent):void {
			_animation.removeEventListener(AnimationEvent.END, onEndAnimation);
			runAnimation();
		}
	
		private function runAnimation():void {
			_animation = _runningAnimations.shift() as Animation;
			if (_animation == null) {
				stop();
				dispatchEvent(new AnimationEvent(AnimationEvent.END));
			} else {
				_animation.addEventListener(AnimationEvent.END, onEndAnimation);
				_animation.start();
			}
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
				if (_animation.running) {
					_animation.stop();
				}
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
			_runningAnimations = _animations.slice();
			runAnimation();
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
			_animations = null;
		}
		
		/**
		 * The array of animations managed by this instance.
		 */
		public function get animations():Array {
			return _animations;
		}

	}
	
}