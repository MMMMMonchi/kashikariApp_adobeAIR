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
	 * The <code>AnimationComposite</code> class allows for running of multiple animations simultaneously through a single call
	 * to the <code>start()</code> method of this class. When all animations complete, this class will dispatch a single
	 * <code>AnimationEvent.END</code> event.
	 * 
	 * This class does not dispatch <code>AnimationEvent.CHANGE</code> events. To be notified when an animation managed by
	 * this class is being run, you must subscribe to the <code>AnimationEvent.CHANGE</code> events dispatched by the managed animation.
	 * 
	 * @example
	 * <pre>
	 * // the following code fades two sprites out simultaneously
	 * // over the course of one second
	 * 
	 * var fadeOut0:Tweener = new Tweener(sprite0, {alpha:1}, {alpha:0}, 1000);
	 * var fadeOut1:Tweener = new Tweener(sprite1, {alpha:1}, {alpha:0}, 1000);
	 * 
	 * var composite:AnimationComposite([fadeOut0, fadeOut1]);
	 * composite.start();
	 * </pre>
	 * 
	 * @see AnimationSequence
	 */
	public class AnimationComposite extends Animation {
	
		private var _animationIndex:uint;
		private var _animations:Array;
	
		/**
		 * Constructor.
		 * 
		 * @param animations An array of <code>Animation</code> instances that will be managed by this instance.
		 */
		public function AnimationComposite(animations:Array) {
			_animations = animations;
		}
	
		/**
		 * Handler for when a single managed animation completes. When all animations have completed,
		 * this dispatches the <code>AnimationEvent.END</code> event.	
		 * 
		 * @param event Event dispatched by Animation.
		 */
		private function onEndAnimation(event:AnimationEvent):void {
			if (++_animationIndex >= _animations.length) {
				stop();
				dispatchEvent(new AnimationEvent(AnimationEvent.END));
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
			for each (var animation:Animation in _animations) {
				animation.removeEventListener(AnimationEvent.END, onEndAnimation);
				if (animation.running) {
					animation.stop();
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
			_animationIndex = 0;
			for each (var animation:Animation in _animations) {
				animation.addEventListener(AnimationEvent.END, onEndAnimation);
				animation.start();
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