package org.osflash.async.mocks {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.osflash.async.Deferred;
	/**
	 * @author jonny
	 */
	public class SimpleDeferred extends Deferred
	{
		private var _timer : Timer;
		private var _success : Boolean;
		
		public function SimpleDeferred(success : Boolean = true, delay : uint = 10) 
		{
			_timer = new Timer(delay, 1);
			_success = success;
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_timer.start();
		}

		private function onTimerComplete(event : TimerEvent) : void 
		{
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_timer = null;
			
			if (_success) {
				resolve(this);
			}
			else {
				reject(new Error("Deferred rejected"));
			}
		}
	}
}
