package org.osflash.async 
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.osflash.async.mocks.PromiseEvent;
	import org.osflash.async.mocks.SimpleDeferred;

	import flash.events.EventDispatcher;
	
	/**
	 * @author Jonny Reeves
	 */
	public class TestWhen 
	{
		private var _eventDispatcher : EventDispatcher;
		
		[Before]
		public function setup() : void
		{
			_eventDispatcher = new EventDispatcher();
		}
		
		[Test (async)]
		public function twoPromisesSupplied_onCompleteCalledOnSuccess() : void
		{
			const promiseA : Promise = new SimpleDeferred(true, 10);
			const promiseB : Promise = new SimpleDeferred(true, 15);
			
			assertPromiseResolves();
			
			when(promiseA, promiseB)
				.completes(notifyResolved)
				.fails(notifyRejected);
		}
		
		[Test (async)]
		public function failedPromise_whenPromiseRejected() : void
		{
			const promiseA : Promise = new SimpleDeferred(true, 10);
			const promiseB : Promise = new SimpleDeferred(false, 15);
			
			assertPromiseRejects();
			
			when(promiseA, promiseB)
				.completes(notifyResolved)
				.fails(notifyRejected);
		}
		
		[Test (async)]
		public function promiseOutcomesReturnedInSuppliedOrder() : void
		{
			const promiseA : Promise = new SimpleDeferred(true, 80);
			const promiseB : Promise = new SimpleDeferred(true, 10);
			
			assertPromiseResolves(function(outcome : Array) : void {
				assertTrue(outcome[0] === promiseA);
				assertTrue(outcome[1] === promiseB);
			});
			
			when(promiseA, promiseB)
				.completes(notifyResolved)
				.fails(notifyRejected);
		}
		
		[Test (async)]
		public function nonPromiseObjectsPassthru() : void
		{
			const promiseA : Promise = new SimpleDeferred(true);
			const promiseB : Promise = new SimpleDeferred(true);
			const mrCat : Object = { fuzzy: true, cutie: true, woofy: false };
			
			assertPromiseResolves(function(outcome : Array) : void {
				assertEquals(4, outcome.length);
				assertEquals(mrCat, outcome[1]);
			});
			
			when(promiseA, mrCat, "some string", promiseB)
				.completes(notifyResolved)
				.fails(notifyRejected);
		}
		
		[Test (async)]
		public function singleNonPromisePassesThru() : void
		{
			const mrDog : Object = { fuzzy: true, cutie: true, woofy: true };
			
			assertPromiseResolves();
			
			when(mrDog)
				.completes(notifyResolved)
				.fails(notifyRejected);
		}
		

		private function assertPromiseResolves(callback : Function = null) : void {
			if (callback == null) {
				Async.proceedOnEvent(this, _eventDispatcher, PromiseEvent.RESOLVED);
			}
			else {
				Async.handleEvent(this, _eventDispatcher, PromiseEvent.RESOLVED, function(event : PromiseEvent, passThru : Object) : void {
					callback(event.outcome);
				});
			}
			Async.failOnEvent(this, _eventDispatcher, PromiseEvent.REJECTED);
		}
		
		private function assertPromiseRejects(callback : Function = null) : void {
			if (callback == null) {
				Async.proceedOnEvent(this, _eventDispatcher, PromiseEvent.REJECTED);
			}
			else {
				Async.handleEvent(this, _eventDispatcher, PromiseEvent.REJECTED, function(event : PromiseEvent, passThru : Object) : void {
					callback(event.error);
				});
			}
			Async.failOnEvent(this, _eventDispatcher, PromiseEvent.RESOLVED);			
		}
		
		private function notifyResolved(outcome : *) : void {
			_eventDispatcher.dispatchEvent(new PromiseEvent(PromiseEvent.RESOLVED, outcome));			
		}
		
		private function notifyRejected(error : Error) : void {
			_eventDispatcher.dispatchEvent(new PromiseEvent(PromiseEvent.REJECTED, error));
		}
	}
}