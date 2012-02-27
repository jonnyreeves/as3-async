package org.osflash.async.impl
{
	/**
	 * @author Jonny
	 */
	public class XMLTweetParser
	{
		public function parse(data : *) : Vector.<TweetVO>
		{
			const xml : XML = new XML(data);
			const result : Vector.<TweetVO> = new Vector.<TweetVO>();
			
			for each (var status : XML in xml..status) {
				const tweet : TweetVO = new TweetVO();
				tweet.id = status.id;
				tweet.message = status["text"];
				
				result.push(tweet);
			}
			
			return result;
		}
	}
}
