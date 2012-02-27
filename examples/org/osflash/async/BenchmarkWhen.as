package org.osflash.async {
	import org.osflash.async.Promise;
	import org.osflash.async.mocks.SimpleDeferred;
	import org.osflash.async.when;

	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	/**
	 * @author jonny
	 */
	public class BenchmarkWhen 
	{
		private var REPS : int = 250000;
		private var DEF_DELAY : int = 10000;
		
		private var _startTime : uint;
		private var _promises : Array;
		
		public function BenchmarkWhen()
		{
			
			setTimeout(run, 2000);
		}

		private function run() : void {
			setup();
			
			_startTime = getTimer();
			trace("Deferreds Created: " + _startTime);
			
			const promise : Promise = when.apply(null, _promises);
			promise.completes(function() : void {
				const totalTime : Number = getTimer() - _startTime;
				trace("Benchmark complete in: " + totalTime + ", when execution time: " + (totalTime - DEF_DELAY).toString()); 
			});
		}

		private function setup() : void 
		{
			_promises = [];
			for (var i : uint = 0; i < REPS; i++) {
				_promises.push(new SimpleDeferred(true, DEF_DELAY));
			}
		}
		
		
	}
}
