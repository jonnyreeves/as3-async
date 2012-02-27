package org.osflash.async.mocks {
	import flash.events.Event;
	/**
	 * @author jonny
	 */
	public class PromiseEvent extends Event 
	{
		public static const RESOLVED : String = "PromiseEvent::RESOLVED";
		public static const REJECTED : String = "PromiseEvent::REJECTED";
		
		private var _outcome : *;
		
		public function PromiseEvent(type : String, outcome : *) 
		{
			super(type);
			_outcome = outcome;
		}

		override public function clone() : Event {
			return new PromiseEvent(type, outcome);
		}

		public function get outcome() : * {
			return _outcome;
		}
		
		public function get error() : Error {
			return _outcome as Error;
		}
	}
}
