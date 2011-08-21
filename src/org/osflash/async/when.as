package org.osflash.async 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * Provides a convenience method for mapping annoymous functions to an EventDispatcher instance.
	 * 
	 * @param dispatcher		The instance that dispatches the event you want to listen to.
	 * @param type				The eventType that you want to listen for.
	 * @param listener			A function which will be invoked when the target eventType is dispatched by the
	 * 							eventDispatcher.  This function must expect a single argument (the dispatched Event).
	 * @param oneShot			Determines whether the supplied listener will be automatically removed (unregistered)
	 * 							from the supplied eventDispatcher after it has been invoked.  Defaults to true.
	 * @param useCapture		@see IEventDispatcher.useCapture
	 * @param priority			@see IEventDispatcher.priorty
	 * @param useWeakReference	@see IeventDispatcher.useWeakReference.
	 * @return					A reference to the inner closure that is added (registered) to the supplied 
	 * 							eventDispatcher which can be used to remove it at a later date, if required.
	 * 							
	 * @example The following example demonstrates how an annoymous function can be mapped to a URLLoader.
	 * <listing version="3.0">
	 * 		const loader : URLLoader = new URLLoader();
	 * 		
	 * 		// Create an event mapping so that when the loader dispatches Event.COMPLETE, the supplied function
	 * 		// is invoked and then automatically removed so that the loader is eligable for garbage collection.
	 * 		when(loader, Event.COMPLETE, function() : void {
	 * 			// This function is a closure so we still have access to the scope of the parent function and can
	 * 			// therefore access the loader instance.
	 * 			trace("Load complete: " + loader.data); 
	 * 		});
	 * 		
	 * 		// Invoke the loader.
	 * 		loader.load(new URLRequest("data.xml"));
	 * </listing>
	 */
	public function when(dispatcher : IEventDispatcher, type : String, listener : Function,  oneShot : Boolean = true, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : Function 
	{
		const closure : Function = function(event : Event) : void {
			listener(event);
			if (oneShot) {
				dispatcher.removeEventListener(type, closure);
			}
		};
		
		dispatcher.addEventListener(type, closure, useCapture, priority, useWeakReference);

		// A reference to the closure is provided so that, if required, it can be removed by the the client.
		return closure;
	}
}