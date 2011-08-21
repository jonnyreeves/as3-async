package {
	import org.osflash.async.when;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author jonny
	 */
	public class Main extends Sprite {
		public function Main() {
			when(this, Event.COMPLETE, function() : void {
				trace("Invoked..."); 
			});
			
			dispatchEvent(new Event(Event.COMPLETE));
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
