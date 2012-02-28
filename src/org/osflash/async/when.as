package org.osflash.async 
{
	/**
	 * Returns a new Promise which will resolve once all the supplied promises Objects have themselves resolved.  The
	 * returned promise will supply an Array of outcomes in the same order as the supplied promise Objects.  
	 * 
	 * If any of the supplied promises reject then the returned Promise will also reject.
	 * 
	 * @author Jonny Reeves.
	 */
	public function when(promise : *, ...promises) : Promise
	{
		if (promises.length == 0) {
			if (promise is Promise) {
				return promise;
			}
			else {
				const result : Deferred = new Deferred();
				result.resolve(promise);
				return result;
			}
		}
		else
		{
			promises.unshift(promise);
			
			// A Promise composed of all the supplied promises is returned; this Promise will only resolve once
			// all of the child promises have completed.
			const combinedPromise : Deferred = new Deferred();

			const totalPromises : uint = promises.length;
			const promiseOutcomes : Array = new Array(totalPromises);
			var completedPromises : uint = 0;

			var onChildPromiseResolved : Function = function(outcome : *) : void {
				promiseOutcomes[completedPromises] = outcome;
				completedPromises += 1;
				
				if (completedPromises == totalPromises) {
					combinedPromise.resolve(promiseOutcomes);
				}
				else {
					resolveNextPromise();
				}
			};
			
			var resolveNextPromise : Function = function() : void {
				// Allow non Promises to pass thru.
				if (!(promises[completedPromises] is Promise)) {
					onChildPromiseResolved(promises[completedPromises]);
				}
				else {
					(promises[completedPromises] as Promise)
						.completes(onChildPromiseResolved)
						.fails(combinedPromise.reject);
				}
			};
			
			resolveNextPromise();
			
			return combinedPromise;
		}
	}
}