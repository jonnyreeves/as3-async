package org.osflash.async {
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * @author jonny
	 */
	public class TestWhen 
	{
		private var _dispatcher : EventDispatcher;
		
		[Before]
		public function setup() : void
		{
			_dispatcher = new EventDispatcher();
		}
		
		[Test]
		public function eventRoutedToListenerFunction() : void
		{
			var listenerInvoked : Boolean = false;
			
			when(_dispatcher, Event.COMPLETE, function() : void {
				listenerInvoked = true; 
			});
			
			_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			
			assertTrue(listenerInvoked);
		}
		
		[Test]
		public function oneShotUnmappedAfterInitialDispatch() : void
		{
			var timesInvoked : uint = 0;
			
			when(_dispatcher, Event.COMPLETE, function() : void {
				timesInvoked += 1;
			});
			
			_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			
			assertEquals(1, timesInvoked);
			assertFalse(_dispatcher.hasEventListener(Event.COMPLETE));
		}
		
		[Test]
		public function notOneShotIsNotUnmapped() : void {
			var timesInvoked : uint = 0;
			
			when(_dispatcher, Event.COMPLETE, function() : void {
				timesInvoked += 1;
			}, false);
			
			_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			
			assertEquals(2, timesInvoked);
			assertTrue(_dispatcher.hasEventListener(Event.COMPLETE));
		}
	}
}
