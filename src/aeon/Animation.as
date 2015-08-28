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
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * Dispatched once when an animation begins.
	 * 
	 * @eventType aeon.events.AnimationEvent.START
	 */
	[Event(name="animationStart", type="aeon.events.AnimationEvent")]

	/**
	 * Dispatched once when an animation completes.
	 * 
	 * @eventType aeon.events.AnimationEvent.END
	 */
	[Event(name="animationEnd", type="aeon.events.AnimationEvent")]

	/**
	 * Dispatched each frame while an animation runs.
	 * 
	 * @eventType aeon.events.AnimationEvent.CHANGE
	 */
	[Event(name="animationChange", type="aeon.events.AnimationEvent")]

	/**
	 * The <code>Animation</code> class serves as an abstract base class for all animations built with aeon.
	 * This class should not be instantiated directly, but instead extended by concrete child classes that may be instantiated.
	 * 
	 * @see AnimationSequence
	 * @see AnimationComposite
	 * @see aeon.animators.Tweener
	 */
	public class Animation extends EventDispatcher {
	
		private static var sTimerSprite:Sprite = new Sprite();

		private var _running:Boolean;
		
		/**
		 * When set to <code>true</code> by a child class, this property is informs this super class that 
		 * the protected method <code>updateAnimation()</code> should be called each frame than an animation is run.
		 * The child class must then override this method.
		 */
		protected var _receiveEnterFrame:Boolean;

		/**
		 * Add a listener to a static sprite's <code>ENTER_FRAME</code> event so that animation updates can be handled
		 * each rendered frame in the Flash Player.
		 * 
		 * @param add True to add listener for ENTER_FRAME.
		 */
		private function addEnterFrameListener(add:Boolean=true):void {
			if (_receiveEnterFrame) {
				sTimerSprite.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				if (add) {
					sTimerSprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
				}
			}
		}
		
		/**
		 * <code>ENTER_FRAME</code> handler calls <code>updateAnimation()</code> if animation is currently being run and
		 * <code>_receiveEnterFrame</code> was set to <code>true</code>.
		 * 
		 * @param event Event dispatched by <code>Sprite</code>.
		 */
		private function onEnterFrame(event:Event):void {
			if (_running) {
				updateAnimation();
			}
		}
		
		/**
		 * Abstract method that wil be called each frame an animation is run if <code>_receiveEnterFrame</code>
		 * was set to <code>true</code> in the child class. For that child class, this method must
		 * be overridden or an exception will be thrown.
		 * 
		 * @throws Error Standard exception when this method not overridden by child class.
		 */
		protected function updateAnimation():void {
			throw new Error("updateAnimation must be overridden by child class is _receiveEnterFrame is set to true.");
		}

		/**
		 * Starts the animation.
		 * 
		 * @example
		 * <pre>
		 * if (!animator.running) {
		 *   animator.start();
		 * }
		 * </pre>
		 */
		public function start():void {
			_running = true;
			addEnterFrameListener();
			dispatchEvent(new AnimationEvent(AnimationEvent.START));
		}

		/**
		 * Stops the animation.
		 * 
		 * @example
		 * <pre>
		 * if (animator.running) {
		 *   animator.stop();
		 * }
		 * </pre>
		 */
		public function stop():void {
			_running = false;
			addEnterFrameListener(false);
		}
		
		/**
		 * Destructor method for an animation. This should stop all animation being run and clean up any timers and listeners.
		 * After this method is called, an animation cannot be started again.
		 * 
		 * @example
		 * <pre>
		 * if (animator != null) {
		 *   animator.die();
		 * }
		 * </pre>
		 */
		public function die():void {
			stop();
		}
	
		/**
		 * True when an animation is currently in the process of being run.
		 * 
		 * @example
		 * <pre>
		 * if (animator.running) {
		 *   animator.stop();
		 * }
		 * </pre>
		 */
		public function get running():Boolean {
			return _running;
		}

	}
	
}