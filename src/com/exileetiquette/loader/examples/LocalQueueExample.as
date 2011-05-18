/**
 * com.exileetiquette.loader.examples.LocalQueueExample
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 19/09/2009 5:55 PM
 * 
 * @author Stephen Woolcock
 * @link blog.exileetiquette.com
*/

package com.exileetiquette.loader.examples
{
	import flash.display.Sprite;
	
	import com.exileetiquette.loader.events.LoadManagerEvent;
	import com.exileetiquette.loader.LoadManager;
	
	/**
	 * The LocalQueueExample class gives a brief overview on how to use LoadManager
	 */
	public class LocalQueueExample extends Sprite
	{
		private var _loader:LoadManager;
		
		/**
		 * Creates a new instance of the LocalQueueExample class
		 */
		public function LocalQueueExample () : void
		{
			_loader = LoadManager.getInstance();
			_loader.addEventListener(LoadManagerEvent.FILE_COMPLETE, onFileComplete, false, 0, true);
			_loader.addEventListener(LoadManagerEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			
			_loader.addToQueue("data/mySWF.swf", 0, "mySWF");
			_loader.addToQueue("data/myXML.xml", 0, "myXML");
		}
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when a file has completed loading
		 * @param	e	The LoadManagerEvent object
		 */
		private function onFileComplete (e:LoadManagerEvent) : void
		{
			trace("File complete:", e.fileId, ":", _loader.filesLoaded, "of", _loader.filesTotal);
		}
		
		/**
		 * Executed when the queue has completed loading
		 * @param	e	The LoadManagerEvent
		 */
		private function onQueueComplete (e:LoadManagerEvent) : void
		{
			trace("Queue complete");
			trace(_loader.getFileList());
			
			var myXML:XML = XML(_loader.getFile("myXML"));
			trace(myXML);
		}
	}
}