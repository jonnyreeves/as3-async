package org.osflash.async
{
	/**
	 * A Promise represents the outcome of a process, or action which will be yeilded at an undetermined point. Promises
	 * make dealing with asyncronous operations simple by exposing a simple API and hiding away all the event handling
	 * and garbage collection boiler plate code.
	 *   
	 * Promises will either resolve, at which point the callback registered to 'completes' will be invoked, or 
	 * rejects, in which case the callbacks registered to 'fails' will be invoked.  Promises will only ever transition 
	 * from PENDING to one of their RESOLVED or REJECTED.  Once a promise has RESOLVED or has been REJECTED, it will  
	 * not transition to any other state.  Handlers added via 'completes' or 'fails' after the Promise has RESOLVED or 
	 * REJECTED will be executed immediatley.
	 * 
	 * The Promise interface makes use the Builder Pattern to allow method chaining; note that callbacks will be invoked
	 * in the order they are added.
	 * 
	 * Promises can also, optionally provide information about their progress whilst they are still in a PENDING state 
	 * by registering callbacks via the `progresses` method.
	 *   
	 * @author Jonny Reeves.
	 */
	public interface Promise
	{
		/**
		 * Register a callback function which will be invoked when this Promise is in a RESOLVED state (ie: completed).
		 * The supplied function should expect zero, or one argument (the outcome yeilded by the Deferred process).  
		 * Note that callbacks registered after the Promise resolves will be executed immediately.  Callbacks will be
		 * exectured in the order they are supplied.
		 */
		function completes(callback : Function) : Promise;
		
		/**
		 * Register a callback function which will be invoked should this Promise be rejected (ie: fail to resolve).
		 * The supplied function should expect zero or one argument (an Error object yeilded by the Deferred process).
		 * Note that callbacks registered after the Promise is rejected will be executed immediately.  Callbacks will be
		 * exectured in the order they are supplied.
		 */
		function fails(callback : Function) : Promise;

		/**
		 * Register a callback function which will be invoked as the Deferred process progresses during its PENDING
		 * state.  The supplied function should expect zero or one argument (a Number between 0 and 1 which represents
		 * the progress of the operation).  Note that callbacks registered after the Promise resolves, or rejects will
		 * be executed immediatley with a value of 1 (representing complete).  Callbacks will be executed in the order 
		 * they are supplied.
		 */
		function progresses(callback : Function) : Promise;
		
		/**
		 * Register a callback which will be executed after all other callbacks have been invoked.  Typically this 
		 * is used to destroy or free the client.
		 */
		function thenFinally(callback : Function) : void;
	}
}
