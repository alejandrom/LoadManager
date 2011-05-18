/**
 * com.exileetiquette.loader.events.LoadManagerEvent
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 20/06/2009 2:18 PM
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author Stephen Woolcock
 * @version 1.0.0
 * @link blog.exileetiquette.com
*/

package com.exileetiquette.loader.events
{
	import flash.events.Event;
	
	/**
	 * LoadManagerEvent instances are dispatched by LoadManager instances, and relate to the state of the LoadManager or one if its files.
	 */
	public class LoadManagerEvent extends Event
	{
		/**
		 * The LoadManagerEvent.FILE_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>loadManagerFileComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class=innertable>
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the LoadManagerEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The LoadManager instance that has completed loading the file.</td></tr>
		 * <tr><td>fileId</td><td>The id of the file that has completed loading.</td></tr>
		 * <tr><td>data</td><td>Any custom data that was specified when the file was added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType loadManagerFileComplete
		 */
		static public const FILE_COMPLETE:String = "loadManagerFileComplete";
		
		/**
		 * The LoadManagerEvent.LIST_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>loadManagerListComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class=innertable>
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the LoadManagerEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The LoadManager instance that has completed loading the XML file list.</td></tr>
		 * <tr><td>data</td><td>The XML file list containing the file definitions that will be added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType loadManagerListComplete
		 */
		static public const LIST_COMPLETE:String = "loadManagerListComplete";
		
		/**
		 * The LoadManagerEvent.LIST_ADDED_TO_QUEUE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>loadManagerListAddedToQueue</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class=innertable>
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the LoadManagerEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The LoadManager instance that has added the XML file list to the queue.</td></tr>
		 * <tr><td>data</td><td>The XML file list containing the file definitions that were added to the queue.</td></tr>
		 * </table>
		 *
		 * @eventType loadManagerListAddedToQueue
		 */
		static public const LIST_ADDED_TO_QUEUE:String = "loadManagerListAddedToQueue";
		
		/**
		 * The LoadManagerEvent.QUEUE_COMPLETE constant defines the value of the <code>type</code> property of the event object 
		 * for a <code>loadManagerQueueComplete</code> event.
		 *
		 * <p>The properties of the event object have the following values:</p>
		 * <table class=innertable>
		 * <tr><th>Property</th><th>Value</th></tr>
		 * <tr><td>bubbles</td><td><code>true</code></td></tr>
		 * <tr><td>cancelable</td><td><code>false</code>; there is no default behavior to cancel.</td></tr>
		 * <tr><td>currentTarget</td><td>The object that is actively processing the LoadManagerEvent object with an event listener.</td></tr>
		 * <tr><td>target</td><td>The LoadManager instance that has completed loading its queue.</td></tr>
		 * </table>
		 *
		 * @eventType loadManagerQueueComplete
		 */
		static public const QUEUE_COMPLETE:String = "loadManagerQueueComplete";
		
		private var _fileId:String;
		private var _data:Object;
		
		/**
		 * Creates a new instance of the LoadManagerEvent class
		 * @param	type		The type of event to create
		 * @param	bubbles		Specifies if bubbling is enabled for this event
		 * @param	cancelable	Specifies if this event can be canceled
		 */
		public function LoadManagerEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, fileId:String = null, data:Object = null)
		{
			super(type, bubbles, cancelable);
			_fileId = fileId;
			_data = data;
		}
		
		/**
		 * The id of the file the event relates to.
		 */
		public function get fileId () : String { return _fileId; }
		
		/**
		 * An object passed to the event via the dispatching object. This is usually custom data that was specified for the file the event relates to.
		 */
		public function get data () : Object { return _data; }
	}
}