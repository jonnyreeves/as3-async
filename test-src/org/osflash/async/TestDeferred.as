package org.osflash.async 
{
	import org.flexunit.asserts.assertStrictlyEquals;
	import flexunit.framework.Assert;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	/**
	 * @author Jonny Reeves
	 */
	public class TestDeferred 
	{
		private var _deferred : Deferred;
		private var _deferredResolved : Boolean;
		
		[Before]
		public function setup() : void
		{
			_deferred = new Deferred();
			_deferredResolved = false;
		}
		
		[Test]
		public function completeHandlerAddedBeforeResolved_outcomeSuppliedToHandler() : void
		{
			const expectedOutcome : String = "Outcome";
			var actualOutcome : String;
			
			// Register the 'complete' handler for when the Promise resolves.
			_deferred.completes(function(outcome : String) : void {
				_deferredResolved = true;
				actualOutcome = outcome;
			});
			
			// Resolve after handler added.
			_deferred.resolve("Outcome");
			
			// Completes handler must have executed.
			assertTrue(_deferredResolved);
			assertStrictlyEquals(expectedOutcome, actualOutcome);
		}
		
		[Test]
		public function completeHandlerAddedAfterResolved_outcomeSuppliedToHandler() : void
		{
			const expectedOutcome : String = "Outcome";
			var actualOutcome : String;
			
			// Resolve before the handler is added.
			_deferred.resolve(expectedOutcome);
			
			_deferred.completes(function(outcome : String) : void {
				_deferredResolved = true;
				actualOutcome = outcome;
			});
			
			// Completes handler must have executed.
			assertTrue(_deferredResolved);
			assertStrictlyEquals(expectedOutcome, actualOutcome); 
		}
		
		[Test]
		public function completeHandlerCanExpectNoArguments() : void
		{
			// Note this completes handler doesn't expect any arguments.
			_deferred.completes(function() : void {
				_deferredResolved = true; 
			});
			
			_deferred.resolve("Handler doesn't care about this String");
			
			assertTrue(_deferredResolved);
		}
		
		[Test]
		public function promiseNeedNotSupplyAnOutcomeWhenResolved() : void
		{
			_deferred.completes(function() : void {
				_deferredResolved = true; 
			});
			
			_deferred.resolve();
			
			assertTrue(_deferredResolved);
		}

		[Test]
		public function completeHandlerInvokedInOrderSupplied() : void
		{
			const callbacksByOrderInvoked : Array = [];
			
			const callback1 : Function = function() : void {
				callbacksByOrderInvoked.push(callback1); 
			};
			const callback2 : Function = function() : void {
				callbacksByOrderInvoked.push(callback2); 
			};
			
			_deferred.completes(callback1);
			_deferred.completes(callback2);
			
			_deferred.resolve();
		
			assertStrictlyEquals(callback1, callbacksByOrderInvoked[0]);
			assertStrictlyEquals(callback2, callbacksByOrderInvoked[1]);
		}
		
		[Test]
		public function failHanderAddedBeforeRejected_errorSuppliedToHandler() : void
		{
			const expectedError : Error = new Error("Rejected");
			var actualError : Error;
			
			_deferred.fails(function(error : Error) : void {
				_deferredResolved = true;
				actualError = error;
			});
			
			_deferred.reject(expectedError);
			
			assertTrue(_deferredResolved);			
			assertStrictlyEquals(expectedError, actualError); 
		}
		
		[Test]
		public function failHanderAddedAfterRejected_errorSuppliedToHandler() : void
		{
			const expectedError : Error = new Error("Rejected");
			var actualError : Error;
			
			_deferred.reject(expectedError);
			
			_deferred.fails(function(error : Error) : void {
				_deferredResolved = true;
				actualError = error;
			});
			
			assertTrue(_deferredResolved);			
		}

		[Test]
		public function failHandlerCanExpectNoArguments() : void
		{
			// No arguments please; I'm all about the simple life.
			_deferred.fails(function() : void {
				_deferredResolved = true; 
			});
			
			_deferred.reject(new Error());
			
			assertTrue(_deferredResolved);
		}
		
		[Test]
		public function promiseNeedNotSupplyAnErrorOnRejection_errorObjectCreated() : void
		{
			var actualError : Error;
			
			_deferred.fails(function(error : Error) : void {
				_deferredResolved = true;
				actualError = error; 
			});
			
			// Contract expects an Error, but will generate one if it gets a null.
			_deferred.reject(null);
			
			assertNotNull(actualError);
		}

		
		[Test]
		public function failHandlerInvokedInOrderSupplied() : void
		{
			const callbacksByOrderInvoked : Array = [];
			
			const callback1 : Function = function() : void {
				callbacksByOrderInvoked.push(callback1); 
			};
			const callback2 : Function = function() : void {
				callbacksByOrderInvoked.push(callback2); 
			};
			
			_deferred.fails(callback1);
			_deferred.fails(callback2);
			
			_deferred.reject(new Error());
			
			assertStrictlyEquals(callback1, callbacksByOrderInvoked[0]);
			assertStrictlyEquals(callback2, callbacksByOrderInvoked[1]);
		}
		
		[Test]
		public function finalHandlerInvokedLastWhenResolved() : void
		{
			const callbacksByOrderInvoked : Array = [];
			
			const finalCallback : Function = function() : void {
				callbacksByOrderInvoked.push(finalCallback);
			};
			
			const resolvedCallback : Function = function() : void {
				callbacksByOrderInvoked.push(resolvedCallback);
			};
			
			_deferred.thenFinally(finalCallback);
			_deferred.completes(resolvedCallback);
			
			_deferred.resolve();
			
			assertStrictlyEquals(resolvedCallback, callbacksByOrderInvoked[0]);
			assertStrictlyEquals(finalCallback, callbacksByOrderInvoked[1]);
		}
		
		[Test]
		public function finalHandlerInvokedLastWhenRejected() : void
		{
			const callbacksByOrderInvoked : Array = [];
			
			const finalCallback : Function = function() : void {
				callbacksByOrderInvoked.push(finalCallback);
			};
			
			const rejectedCallback : Function = function(error : Error) : void {
				callbacksByOrderInvoked.push(rejectedCallback);
			};
			
			_deferred.thenFinally(finalCallback);
			_deferred.completes(rejectedCallback);
			
			_deferred.resolve();
			
			assertStrictlyEquals(rejectedCallback, callbacksByOrderInvoked[0]);
			assertStrictlyEquals(finalCallback, callbacksByOrderInvoked[1]);
		}
		
        [Test]
        public function finalHandlerInvokedWhenAddedAfterResolve () : void
        {
            var finalHandlerInvoked:Boolean = false;
            const finalCallback : Function = function() : void {
                finalHandlerInvoked = true;
            };
            _deferred.resolve();
            _deferred.thenFinally(finalCallback);
            assertTrue(finalHandlerInvoked);
        }
        
        [Test]
        public function finalHandlerInvokedWhenAddedAfterReject () : void
        {
            var finalHandlerInvoked:Boolean = false;
            const finalCallback : Function = function() : void {
                finalHandlerInvoked = true;
            };
            _deferred.reject(new Error());
            _deferred.thenFinally(finalCallback);
            assertTrue(finalHandlerInvoked);
        }
        
		[Test]
		public function deferredDoesNotTransitionToRejectedOnceResolved() : void
		{
			var rejectedHandlerInvoked : Boolean = false;
			
			_deferred.fails(function(error : Error) : void {
				rejectedHandlerInvoked = true; 
			});
			
			_deferred.resolve();
			_deferred.reject(new Error());
			
			assertFalse(rejectedHandlerInvoked);
		}

		[Test]
		public function deferredDoesNotTransitionToResolvedOnceRejected() : void
		{
			var resolvedHandlerInvoked : Boolean = false;
			
			_deferred.completes(function() : void {
				resolvedHandlerInvoked = true; 
			});
			
			_deferred.reject(new Error());
			_deferred.resolve();
			
			assertFalse(resolvedHandlerInvoked);
		}		
		
		[Test]
		public function progressHandlerInvoked() : void
		{
			const expectedProgressUpdates : Array = [ 0.2, 0.5, 0.8 ];
			const actualProgressUpdates : Array = [];
			
			_deferred.progresses(function(ratioComplete : Number) : void {
				actualProgressUpdates.push(ratioComplete); 
			});
			
			for each (var ratioComplete : Number in expectedProgressUpdates) {
				_deferred.progress(ratioComplete);
			}
			
			assertArraysEqual(expectedProgressUpdates, actualProgressUpdates);
		}
		
		[Test]
		public function progressUpdatedIgnoredAfterDeferredResolves() : void
		{
			var progressHandlerInvoked : Boolean = false;
			
			_deferred.progresses(function(ratioComplete : Number) : void {
				 progressHandlerInvoked = true;
			});
			
			_deferred.resolve();
			_deferred.progress(0.5);
			
			assertFalse(progressHandlerInvoked);
		}
		
		[Test]
		public function deferredWillNotResolveAfterBeingAborted() : void
		{
			_deferred.completes(function() : void {
				_deferredResolved = true; 
			});
			
			_deferred.abort();
			_deferred.resolve();
			
			assertFalse(_deferredResolved);
		}
		
		[Test]
		public function deferredWillNotRejectAfterBeingAborted() : void
		{
			_deferred.fails(function() : void {
				_deferredResolved = true; 
			});
			
			_deferred.abort();
			_deferred.reject(new Error());
			
			assertFalse(_deferredResolved);
		}

		[Test]
		public function deferredWillNotProgressAfterBeingAborted() : void
		{
			_deferred.progresses(function(ratioComplete : Number) : void {
				_deferredResolved = true; 
			});
			
			_deferred.abort();
			_deferred.progress(0.5);
			
			assertFalse(_deferredResolved);
		}



		
		private function assertArraysEqual(expected : Array, actual : Array) : void
		{
			assertEquals(expected.length, actual.length);
			for (var i : uint = 0; i < expected.length; i++) {
				assertEquals(expected[i], actual[i]);
			}
		}
	}
}
