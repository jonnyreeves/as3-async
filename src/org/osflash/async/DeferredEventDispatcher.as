package org.osflash.async
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	/**
	 * Wraps an EventDispatcher with a Deferred and returns a Promise object.
	 * 
	 * @author Jonny Reeves.
	 */
	public class DeferredEventDispatcher
	{
		private static const ERR_ON_REJECT_EVENT : String = "Reject Event dispatched: ";
		
		private const _resolveHandlerMap : Object = {};
		private const _rejectHandlerMap : Object = {};
		private var _outcome : Deferred;
		private var _eventDispatcher : IEventDispatcher;
		
		public function DeferredEventDispatcher(eventDispatcher : IEventDispatcher) 
		{
			_eventDispatcher = eventDispatcher;
			_outcome = new Deferred();
		}
		
		/**
		 * Returns the Promise assosiated with this Deferred which can be supplied to the client.
		 */
		public function promise() : Promise
		{
			return _outcome;
		}
		
		/**
		 * The Deferred operation will complete when the host EventDispatcher dispatches an event of the supplied
		 * type.  If the event is recieved, and no outcomeProcessor method is supplied then dispatched Event will be 
		 * supplied to the Promises' complete handlers.  
		 * 
		 * An optional outcomeProcessor function can be supplied which will be invoked if this event is dispatched.
		 * The outcomeProcessor should expect a single argument (the dispatched Event) and return the outcome value
		 * which will be supplied to the Promises' complete handlers. 
		 */
		public function resolveOn(eventType : String, outcomeProcessor : Function = null) : DeferredEventDispatcher
		{
			_eventDispatcher.addEventListener(eventType, onResolveEvent);
			_resolveHandlerMap[eventType] = outcomeProcessor;
			
			return this;
		}
		
		/**
		 * The Deferred operation will fail (reject) when the host EventDispatcher dispatches an event of the supplied
		 * type.  If the event is recieved, and no outcomeProcessor method is supplied then an Error will be generated
		 * automatically from the supplied Event.
		 * 
		 * An optional outcomeProcessor function can be supplied which will be invoked if this event is dispatched.
		 * The outcomeProcessor should expect a single argument (the dispatched Event) and return the Error object
		 * which will be supplied to the Promises' fail handlers. 
		 */		
		public function rejectOn(eventType : String, outcomeProcessor : Function = null) : DeferredEventDispatcher
		{
			_eventDispatcher.addEventListener(eventType, onRejectEvent);
			_rejectHandlerMap[eventType] = outcomeProcessor;
			
			return this;
		}

		private function onResolveEvent(event : Event) : void
		{
			if (_resolveHandlerMap[event.type] is Function) {
				_outcome.resolve(_resolveHandlerMap[event.type](event));
			}
			else {
				_outcome.resolve(event);
			}
			
			clear();
		}

		private function onRejectEvent(event : Event) : void
		{
			if (_rejectHandlerMap[event.type] is Function) {
				_outcome.reject(_rejectHandlerMap[event.type](event));
			}
			else if ("text" in event) {
				_outcome.reject(new Error(event["text"]));
			}
			else {
				_outcome.reject(new Error(ERR_ON_REJECT_EVENT + event.type));
			}
			
			clear();
		}
		
		private function clear() : void
		{
			var eventType : String;
			for (eventType in _rejectHandlerMap) {
				_eventDispatcher.removeEventListener(eventType, onRejectEvent);
				delete _rejectHandlerMap[eventType];
			}
			for (eventType in _resolveHandlerMap) {
				_eventDispatcher.removeEventListener(eventType, onResolveEvent);
				delete _resolveHandlerMap[eventType];
			}
			
			_outcome = null;
		}
	}
}