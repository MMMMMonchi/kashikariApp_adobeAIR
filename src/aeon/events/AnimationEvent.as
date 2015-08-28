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
package aeon.events {
	
	import flash.events.Event;

	/**
	 * The <code>AnimationEvent</code> class defines the types of events that an aeon <code>Animation</code>
	 * class will dispatch, including when an animation starts, stops, or is in the process of running.
	 */
	public class AnimationEvent extends Event {
		
		/**
		 * The <code>AnimationEvent.START</code> constant defines the values of the <code>type</code>
		 * property of the event object for a <code>animationStart</code> event.
		 * 
		 * @eventType animationStart
		 */
		public static const START:String = "animationStart";

		/**
		 * The <code>AnimationEvent.END</code> constant defines the values of the <code>type</code>
		 * property of the event object for a <code>animationEnd</code> event.
		 * 
		 * @eventType animationEnd
		 */
		public static const END:String = "animationEnd";

		/**
		 * The <code>AnimationEvent.CHANGE</code> constant defines the values of the <code>type</code>
		 * property of the event object for a <code>animationChange</code> event.
		 * 
		 * @eventType animationChange
		 */
		public static const CHANGE:String = "animationChange";

		/**
		 * Constructor.
		 * 
		 * @param type The type of event to be dispatched. This should be one of the constants of this class.
		 * 
		 * @example
		 * <pre>
		 * var event:AnimationEvent = new AnimationEvent(AnimationEvent.START);
		 * dispatchEvent(event);
		 * </pre>
		 */
		public function AnimationEvent(type:String) {
			super(type);
		}

		/**
		 * Duplicates the event when bubbling up an event. This should never need to be invoked directly.
		 * 
		 * @return The cloned event.
		 */
		override public function clone():Event {
			return new AnimationEvent(type);
		}

	}
	
}