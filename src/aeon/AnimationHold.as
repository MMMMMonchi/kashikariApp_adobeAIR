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

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * The <code>AnimationHold</code> class allows you to insert a delay within a larger animation. This class is really intended
	 * for use within an <code>AnimationSequence</code> when a delay between different animations within a sequence is required.
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
	 * @see AnimationSequence
	 */
	public class AnimationHold extends Animation {
	
		private var _timer:Timer;

		/**
		 * Constructor.
		 * 
		 * @param time The amount of time in milliseconds that this animation (or lack of animation) should run.
		 */		
		public function AnimationHold(time:Number) {
			_timer = new Timer(time, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onEndAnimation, false, 0, true);
		}

		/**
		 * Handler for when the delay timer completes. This dispatches the <code>AnimationEvent.END</code> event.	
		 * 
		 * @param event Event dispatched by <code>Timer</code>.
		 */
		private function onEndAnimation(event:TimerEvent):void {
			stop();
			dispatchEvent(new AnimationEvent(AnimationEvent.END));
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
			if (_timer && _timer.running) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onEndAnimation);
				_timer.stop();
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
			_timer.start();
			super.start();
		}
	
	}
	
}