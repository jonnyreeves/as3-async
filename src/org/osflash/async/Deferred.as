package org.osflash.async
{
	/**
	 * A Deferred object provides the means to fulfil a Promise by the means of calling 'resolve', 'reject' and
	 * 'progress'.  Typlically a Deferred object is instantiated and retained by a client so that when the operation
	 * completes, rejects, or progresses, the appropriate methods can be invoked.  The client can invoke 'abort' if
	 * the Deferred operation needs to be terminated (in which case none of the callback will be invoked.)
	 * 
	 * A Deferred object uses a finite state machine to ensure that it can only transition from PENDING to one of 
	 * either RESOLVED or REJECTED to ensure that the Promise gets resolved in a predicable fashion.
	 * 
	 * @author Jonny Reeves.
	 */
	public class Deferred implements Promise
	{
		private static const PENDING : uint = 0;
		private static const RESOLVED : uint = 1;
		private static const REJECTED : uint = 2;
		private static const ABORTED : uint = 3;
		
		private const _completeListeners : Vector.<Function> = new Vector.<Function>();
		private const _failListeners : Vector.<Function> = new Vector.<Function>();
		private const _progressListeners : Vector.<Function> = new Vector.<Function>();
		
		private var _finalCallback : Function;
		private var _state : uint = PENDING;
		private var _outcome : *;
		
		/**
		 * Notifies all 'completes' handlers that the deferred operation was succesful.  An optional outcome object
		 * can be supplied which will provided to all the complete handlers.
		 * 
		 * @parm outcome	The optional result of the Deferred operation.
		 */
		public function resolve(outcome : * = null) : void
		{
			if (_state != PENDING) {
				return;
			}
			
			_outcome = outcome;
			_state = RESOLVED;
			
			const len : uint = _completeListeners.length;
			for (var i : uint = 0; i < len; i++) {
				_completeListeners[i](_outcome);
			}
			
			clearListeners();
			invokeFinalCallback();
		}
		
		/**
		 * Notifies all 'fails' handlers that this deferred operation has been unsuccesful.  The supplied Error object
		 * will be supplied to all of the handlers.
		 * 
		 * @param error		Error object which explains how or why the operation was unsuccesful.
		 */
		public function reject(error : Error) : void
		{
			if (_state != PENDING) {
				return;
			}
			
			// By contact, we will always supply an Error object to the fail handlers.
			_outcome = error || new Error("Promise Rejected");
			_state = REJECTED;
			
			const len : uint = _failListeners.length;
			for (var i : uint = 0; i < len; i++) {
				_failListeners[i](_outcome);
			}
			
			clearListeners();
			invokeFinalCallback();			
		}

		/**
		 * Notifies all of the 'progresses' handlers of the current progress of the deferred operation.  The supplied
		 * value should be a Number between 0 and 1 (although there is no fixed validation).  Once the deferred 
		 * operation has resolved further progress updates will be ignored.
		 * 
		 * @param ratioComplete		A number between 0 and 1 which represents the progress of the deferred oepration.
		 */
		public function progress(ratioComplete : Number) : void
		{
			const len : uint = _progressListeners.length;
			for (var i : uint = 0; i < len; i++) {
				_progressListeners[i](ratioComplete);
			}
		}
		
		/**
		 * Aborts the deferred operation; none of the handlers bound to the Promise will be invoked; typically this
		 * is used when the Deferred's host needs to cancel the operation.
		 */
		public function abort() : void
		{
			_state = ABORTED;
			_outcome = null;
			_finalCallback = null;
			
			clearListeners();
		}

		public function completes(callback : Function) : Promise
		{
			if (_state == PENDING) {
				_completeListeners.push(callback);
			}
			else if (_state == RESOLVED) {
				callback(_outcome);
			}
			
			return this;
		}
		
		public function fails(callback : Function) : Promise
		{
			if (_state == PENDING) {
				_failListeners.push(callback);
			}
			else if (_state == REJECTED) {
				callback(_outcome);
			}
			
			return this;
		}
		
		public function progresses(callback : Function) : Promise
		{
			if (_state == PENDING) {
				_progressListeners.push(callback);
			}
			
			return this;
		}
		
		public function thenFinally(callback : Function) : void
		{
            if (_state == PENDING) {
			    _finalCallback = callback;
            }
            else {
                callback();
            }
		}

		private function clearListeners() : void
		{
			_completeListeners.length = 0;
			_failListeners.length = 0;
			_progressListeners.length = 0;
		}

		private function invokeFinalCallback() : void
		{
			if (_finalCallback !== null) {
				_finalCallback();
				_finalCallback = null;
			}
		}
	}
}
