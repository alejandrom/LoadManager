/**
 * com.exileetiquette.loader.examples.ExternalListExample
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 19/09/2009 6:08 PM
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
	 * The ExternalListExample class is an example of how to use the LoadManager to load resources from an external list
	 */
	public class ExternalListExample extends Sprite
	{
		private var _loader:LoadManager;
		
		/**
		 * Creates a new instance of the ExternalListExample class
		 */
		public function ExternalListExample ()
		{
			_loader = LoadManager.getInstance();
			_loader.addEventListener(LoadManagerEvent.FILE_COMPLETE, onFileComplete, false, 0, true);
			_loader.addEventListener(LoadManagerEvent.QUEUE_COMPLETE, onQueueComplete, false, 0, true);
			_loader.addEventListener(LoadManagerEvent.LIST_COMPLETE, onListComplete, false, 0, true);
			_loader.addEventListener(LoadManagerEvent.LIST_ADDED_TO_QUEUE, onListAddedToQueue, false, 0, true);
			
			// Load resources listed in myFileList.xml
			_loader.loadQueueFromXML("myFileList.xml");
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
		 * Executed when the XML list has completed loading
		 * @param	e	The LoadManagerEvent
		 */
		private function onListComplete (e:LoadManagerEvent) : void
		{
			trace("XML list complete");
			trace(e.data);	// This will output the XML
		}
		
		/**
		 * Executed when the files listed in the XML list have been added to the queue
		 * @param	e	The LoadManagerEvent
		 */
		private function onListAddedToQueue (e:LoadManagerEvent) : void
		{
			trace("Files added to queue from XML");
			trace("\t", _loader.getQueueList());
		}
		
		/**
		 * Executed when the queue has completed loading
		 * @param	e	The LoadManagerEvent
		 */
		private function onQueueComplete (e:LoadManagerEvent) : void
		{
			trace("Queue complete");
			trace(_loader.getFileList());
			
			var mysWF:Sprite = Sprite(_loader.getFile("mysWF"));
			trace(mysWF);
		}
	}
}