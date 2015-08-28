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
	import flash.filters.BitmapFilter;
	
	/**
	 * The <code>FilterAnimator</code> class simplifies the animation of <code>BitmapFilter</code> instance properties
	 * applied to a display object. The constructor for this class takes a filter to animate and two objects defining
	 * the start and end values to be tweened on the filter.
	 * 
	 * The filter may already be applied to a display object, and the index to the filter to animate within a display
	 * object's <code>filters</code> array may be passed to the <code>FilterAnimator</code> constructor as the
	 * <code>filterIndex</code>. If -1 is passed as the <code>filterIndex</code>, then the filter to be animated
	 * is added to the end of the display object's <code>filters</code> array.
	 * 
	 * @example
	 * <pre>
	 * // the following tweens the blurX and blurY properties of a new BlurFilter instance applied to a display object
	 * 
	 * var filterAnimator:FilterAnimator = new FilterAnimator(
	 *   sprite,
	 *   new BlurFilter(),
	 *   {blurX:0, blurY:0},
	 *   {blurX:20, blurY:20},
	 *   -1,
	 *   2000
	 * );
	 * filterAnimator.start();
	 * </pre>
	 * 
	 * <pre>
	 * // the following tweens the blurX and blurY properties of an existing GlowFilter instance applied to a display object
	 * 
	 * var filters:Array = sprite.filters;
	 * var filter:GlowFilter = new GlowFilter();
	 * filters.push(filter);
	 * sprite.filters = filters;
	 * var fitlerIndex:int = filters.indexOf(filter);
	 * 
	 * var filterAnimator:FilterAnimator = new FilterAnimator(
	 *   sprite,
	 *   filter,
	 *   {blurX:0, blurY:0},
	 *   {blurX:20, blurY:20},
	 *   fitlerIndex,
	 *   2000
	 * );
	 * filterAnimator.start();
	 * </pre>
	 */
	public class FilterAnimator extends Animation {

		private var _tween:Tweener;
		private var _target:DisplayObject;
		private var _startTransform:Object;
		private var _endTransform:Object;
		private var _time:Number;
		private var _easeFunction:Function;
		private var _filter:BitmapFilter;
		private var _filterIndex:int;
		private var _removeFilter:Boolean;
	
		/**
		 * Constructor.
		 *
		 * @param target The target object for the tweened values.
		 * @param filter The filter to apply to the interpolated values to during the animation.
		 * @param startValue The starting values on the filter to be tweened during the animation.
		 * @param endValue The final values on the filter to be tweened during the animation. This properties available on this object
		 *                 should match exactly the propertie available in the startValue's object.
		 * @param filterIndex The index within the target object's filters array where the filter to be animated can be found.
		 *                    If the filter is to be added new, then -1 should be passed.
		 * @param time The amount of time in milliseconds that the animation should run.
		 * @param easeFunction The function that will be used to interpolate values between the start and end values. If no function
		 *                     is passed in, the <code>aether.easing.Linear.easeNone</code> is used.
		 */
		public function FilterAnimator(
			target:DisplayObject,
			filter:BitmapFilter,
			startTransform:Object,
			endTransform:Object,
			filterIndex:int=-1,
			time:Number=1000,
			easeFunction:Function=null
		) {
			_target = target;
			_filter = filter;
			_filterIndex = filterIndex;
			_removeFilter = _filterIndex < 0;
			_startTransform = startTransform;
			_endTransform = endTransform;
			_time = time;
			if (easeFunction == null) easeFunction = Linear.easeNone;
			_easeFunction = easeFunction;
		}

		/**
		 * Adds the animated filter to the target's <code>filters</code> array.
		 */
		private function addFilter():void {
			var filters:Array = _target.filters || [];
			_filterIndex = filters.length;
			filters.push(_filter);
			_target.filters = filters;
		}

		/**
		 * Removes the animated filter from the target's <code>filters</code> array.
		 */
		private function removeFilter():void {
			var filters:Array = _target.filters;
			filters.splice(_filterIndex, 1);
			_target.filters = filters;
		}

		/**
		 * Replaces the filter in the target's <code>filters</code> array with the filter
		 * that is being animated and its current values.
		 */
		private function setFilter():void {
			var filters:Array = _target.filters;
			filters.splice(_filterIndex, 1, _filter);
			_target.filters = filters;
		}

		/**
		 * Runs through the interpolated values and assigns them to the animated filter.
		 * 
		 * @param transform The collection of properties being interpolated with their current values.
		 */
		private function setFilterProperties(transform:Object):void {
			for (var property:String in transform) {
				_filter[property] = transform[property];
			}
		}

		/**
		 * Handler for when the internal Tweener animation completes.
		 * This dispatches the <code>AnimationEvent.END</code> event.
		 * 
		 * @param event Event dispatched by <code>Animation</code>.
		 */
		private function onEndTween(event:AnimationEvent):void {
			if (_removeFilter) {
				removeFilter();
			} else {
				setFilterProperties(_endTransform);
				setFilter();
			}
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
			setFilterProperties(_tween.currentValue);
			setFilter();
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
			setFilterProperties(_startTransform);
			if (_removeFilter) {
				addFilter();
			} else {
				setFilter();
			}
			_tween = new Tweener(null, _startTransform, _endTransform, _time, _easeFunction);
			_tween.addEventListener(AnimationEvent.CHANGE, onChangeTween);
			_tween.addEventListener(AnimationEvent.END, onEndTween);
			_tween.start();
			super.start();
		}

	}
	
}