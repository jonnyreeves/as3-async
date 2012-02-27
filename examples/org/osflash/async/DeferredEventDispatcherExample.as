package org.osflash.async 
{
	import org.osflash.async.impl.TweetVO;
	import org.osflash.async.impl.XMLTweetParser;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Jonny
	 */
	public class DeferredEventDispatcherExample
	{
		public function DeferredEventDispatcherExample() 
		{
			when(fetchTweetsFor("catburton"), fetchTweetsFor("jonnyreeves"))
				.completes(function() : void {
					trace("Got Tweets yo!"); 
				})
				.completes(onTweetsFetched)
				.fails(onFailed);
		}

		private function fetchTweetsFor(username : String) : Promise
		{
			const urlLoader : URLLoader = new URLLoader();
			const deferred : DeferredEventDispatcher = new DeferredEventDispatcher(urlLoader)
				.resolveOn(Event.COMPLETE, function(event : Event) : Vector.<TweetVO> {
					return new XMLTweetParser().parse(urlLoader.data);	 
				})
				.rejectOn(IOErrorEvent.IO_ERROR);
				
			urlLoader.load(new URLRequest("https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=" + username + "&count=3"));
			return deferred.promise();
		}

		private function onFailed(error : Error) : void
		{
			trace("Failed to fetch tweets: " + error);
		}

		private function onTweetsFetched(outcomes : Array) : void
		{
			trace("Fetched " + outcomes.length + " sets of Tweets");
			
			for each (var tweets : Vector.<TweetVO> in outcomes) {
				trace(tweets.join("\n"));
			}
		}
	}
}
