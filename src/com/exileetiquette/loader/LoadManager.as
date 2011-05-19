/**
 * com.exileetiquette.loader.LoadManager
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 20/06/2009 12:47 PM
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

package com.exileetiquette.loader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import com.exileetiquette.loader.events.LoadManagerEvent;
	import com.exileetiquette.loader.events.LoadManagerProgressEvent;
	import com.exileetiquette.loader.formats.*;
	
	/**
	 * Dispatched when a file has completed loading
	 * @eventType com.exileetiquette.loader.events.LoadManagerEvent.FILE_COMPLETE
	 */
	[Event(name = "loadManagerFileComplete", type = "com.exileetiquette.loader.events.LoadManagerEvent")]
	
	/**
	 * Dispatched when an XML resource list has completed loading, but before the files have been added to the queue (when using loadQueueFromXML())
	 * @eventType com.exileetiquette.loader.events.LoadManagerEvent.LIST_COMPLETE
	 */
	[Event(name = "loadManagerListComplete", type = "com.exileetiquette.loader.events.LoadManagerEvent")]
	
	/**
	 * Dispatched when files from an XML resource list have been added to the queue
	 * @eventType com.exileetiquette.loader.events.LoadManagerEvent.LIST_ADDED_TO_QUEUE
	 */
	[Event(name = "loadManagerListAddedToQueue", type = "com.exileetiquette.loader.events.LoadManagerEvent")]
	
	/**
	 * Dispatched when all files in the queue have completed loading
	 * @eventType com.exileetiquette.loader.events.LoadManagerEvent.QUEUE_COMPLETE
	 */
	[Event(name = "loadManagerQueueComplete", type = "com.exileetiquette.loader.events.LoadManagerEvent")]
	
	/**
	 * Dispatched when a the load progress of a file changes
	 * @eventType com.exileetiquette.loader.events.LoadManagerProgressEvent.PROGRESS
	 */
	[Event(name = "loadManagerProgress", type = "com.exileetiquette.loader.events.LoadManagerProgressEvent")]
	
	/**
	 * [Multiton] The LoadManager class is a Multiton object that handles the sequential loading of multiple files.
	 */
	public class LoadManager extends EventDispatcher
	{
		static private var _global:LoadManager;
		static private var _local:Dictionary = new Dictionary();
		static private var _formats:Dictionary = new Dictionary();
		static private var _formatExtensions:Dictionary = new Dictionary();
		
		// Static constructor
		// Register default file types
		{
			registerFileFormat("binary",	BinaryHandler);
			registerFileFormat("image",		ImageHandler,		["jpg", "jpeg", "png", "gif"]);
			registerFileFormat("sound",		SoundHandler,		["mp3"]);
			registerFileFormat("swf",		SWFHandler,			["swf"]);
			registerFileFormat("text",		GenericHandler,		["txt"]);
			registerFileFormat("xml",		XMLHandler,			["xml", "htm", "html"]);
		}
		
		private var _baseURL:String = "";
		private var _dispatchProgressEvents:Boolean;
		private var _files:Array;
		private var _filesById:Dictionary;
		private var _nextFileId:int = 0;
		private var _id:String;
		private var _loading:Boolean = true;
		private var _loadingXML:Boolean;
		private var _queue:Array;
		
		/**
		 * [Multiton] LoadManager is a Multiton and cannot be directly instantiated. Use <code>LoadManager.getInstance()</code> to retrieve an instance
		 * of the LoadManager class.
		 */
		public function LoadManager (enforcer:LoadManagerSingletonEnforcer, id:String)
		{
			if (!enforcer) throw new Error("LoadManager is a Multiton and cannot be directly instantiated. Use LoadManager.getInstance().");
			
			_id = id;
			_queue = [];
			_files = [];
			_filesById = new Dictionary();
		}
		
		
		// STATIC PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Retrieves the single instance of LoadManager class.
		 * @return	The single instance of the LoadManager class
		 */
		static public function getInstance (id:String = null) : LoadManager
		{
			var instance:LoadManager;
			
			if (!_global) _global = new LoadManager(new LoadManagerSingletonEnforcer(), "$_global");
			
			if (!id || id == "$_global") return _global;
			else {
				instance = _local[id];
				if (!_local[id]) _local[id] = instance = new LoadManager(new LoadManagerSingletonEnforcer(), id);
			}
			
			return instance;
		}
		
		/**
		 * Registers a new file format handler.
		 * @param	id			The id of the file format
		 * @param	handler		The handler Class of the format
		 * @param	extensions	[Optional] An Array of file extensions that should be handled by this format handler
		 */
		static public function registerFileFormat (id:String, handler:Class, extensions:Array = null) : void
		{
			_formats[id] = handler;
			
			if (extensions) {
				var numExts:int = extensions.length;
				for (var i:int = 0; i < numExts; i ++)
					_formatExtensions[extensions[i]] = id;
			}
		}
		
		/**
		 * Traces the list of registered file formats to the output window.
		 */
		static public function listRegisteredFileFormats () : void
		{
			var output:String = "LoadManager registered file formats: ";
			for (var i:String in _formats) {
				output += "\r	" + i + " (handler: " + _formats[i] + ")";
			}
			
			trace(output);
		}
		
		
		// STATIC PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		
		
		// PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Adds a resource URL to the queue for loading.
		 * @param	url			The url of the resource
		 * @param	priority	[optional] The priority of the resource. Higher prorities will be added to the front of the queue.
		 * @param	id			[optional] A unique identifier for the resource (defaults to '_file<i>N</i>', where <i>N</i> is an incrementing number beginning at 0)
		 * @param	type		[optional] The type of resource
		 * @param	context		[optional] A load context object to use when loading the file
		 * @param	data		[optional] Any custom data you want to store along with the file. This can be retrieved later using <code>getFileData()</code>
		 * @return	The id of the file that was added to the queue
		 */
		public function addToQueue (url:String, priority:uint = 0, id:String = null, type:String = null, context:* = null, data:* = null) : String
		{
			if (!type) type = getHandlerIdFromURL(url);
			
			var HandlerClass:Class = _formats[type];
			if (!HandlerClass) throw new Error("No format handler with the type '" + type + "' has been registered. Use LoadManager.registerFileFormat() to register new file formats.");
			
			var file:LoadManagerFile = new LoadManagerFile();
			file.handler = new HandlerClass();
			file.id = id ? id : getNextFileId();
			file.priority = priority;
			file.url = url;
			file.context = context;
			file.data = data;
			
			if (_queue.length > 0 && priority > 0) {
				var f:LoadManagerFile = LoadManagerFile(_queue[0]);
				
				// If the priority of this file is greater than the priority of the first file in the queue, we just have to unshift
				// the new file into the queue
				if (priority > f.priority) {
					f.handler.pauseLoad();	// Stop loading the file
					_queue.unshift(file);
					
					// -- Exit
					// Begin loading the queue and return the file id
					if (_loading) loadQueue();
					return file.id;
					
				} else {
					
					// Work down the queue until we find a priority lower than the priority of the file we're adding
					var index:int;
					while (f.priority >= priority) {
						index ++;
						
						if (index == _queue.length) break; // Reached the end of the queue
						f = LoadManagerFile(_queue[index]);
					}
					
					// Insert the file into the queue at the correct point
					if (index == _queue.length) _queue.push(file);
					else _queue.splice(index, 0, file);
				}
				
			} else {
				_queue.push(file);
			}
			
			// -- Exit
			// Begin loading the queue (if needed) and return the file id
			if (_loading && _queue.length == 1) loadQueue();
			return file.id;
		}
		
		/**
		 * Adds files to the queue from an XML resource list. Each file node within the XML document should be formatted as follows:<br/>
		 * 		<code>&lt;file id="fileId" type="typeId"&gt;&lt;![CDATA[urlToFile]]&gt;&lt;/file&gt;</code><br/>
		 * Once the file has loaded, you can use <code>getFileData()</code> to retrieve the XML node for the file.
		 * @param	xml	The XML document containing a list of resources to load
		 */
		public function addToQueueFromXML (xml:XML) : void
		{
			var numItems:uint = xml.file.length();
			for (var i:int = 0; i < numItems; i ++) {
				var node:XML = xml.file[i];
				addToQueue(node.toString(), node.hasOwnProperty("@priority") ? int(node.@priority.toString()) : 0, node.@id.toString(), node.@type.toString(), null, node);
			}
			
			dispatchEvent(new LoadManagerEvent(LoadManagerEvent.LIST_ADDED_TO_QUEUE, false, false, null, xml));
		}
		
		/**
		 * Purges all content from the LoadManager instance and prepares the instance for garbage collection. The LoadManager instance
		 * will no longer be accessible once this method is called.
		 */
		public function destroy () : void
		{
			purge();
			_local[_id] = null;
			
			if (_id != "$_global") _global.loadQueue();	// Continue loading the global queue
		}
		
		/**
		 * Retrieves a loaded resource. Then type of the resource depends on the handler that was used to load it.
		 * @param	id	The id of the resource
		 * @return	The resources with the id supplied
		 */
		public function getFile (id:String) : *
		{
			if (!_filesById[id]) return null;
			return LoadManagerFile(_filesById[id]).handler.getContent();
		}
		
		/**
		 * Retrives the custom data stored along with the file (as specified when using <code>addToQueue(...)</code>). If the file was
		 * added to the queue using <code>addToQueueFromXML</code> or <code>loadQueueFromXML</code>, the returned value will be the file's
		 * XML node from the XML list.
		 * @param	id	The id of the file to retrieve the data for
		 * @return	The custom data stored for the specified file
		 */
		public function getFileData (id:String) : *
		{
			if (!_filesById[id]) return null;
			return LoadManagerFile(_filesById[id]).data;
		}
		
		/**
		 * Retrieves the list of file ids that have been loaded.
		 * @return	An Array containing the list of files ids currently loaded
		 */
		public function getFileList () : Array
		{
			var output:Array = [];
			var numFiles:int = _files.length;
			
			for (var i:int = 0; i < numFiles; i ++) 
				output.push(LoadManagerFile(_files[i]).id);
			
			return output;
		}
		
		/**
		 * Retrieves the type of a loaded resource. This is the same as the registered file format handler ids. Use
		 * <code>LoadManager.listRegisteredFileFormats()</code> to retrieve a list of all registered file format handlers.
		 * @param	id	The id of the resource
		 * @return	The type of the 
		 */
		public function getFileType (id:String) : String
		{
			if (!_filesById[id]) return null;
			return getHandlerIdFromURL(LoadManagerFile(_filesById[id]).url);
		}
		
		/**
		 * Retrieves the URL of a loaded resource .
		 * @param	id	The id of the resource
		 * @return	The URL of the resource with the id supplied
		 */
		public function getFileURL (id:String) : String
		{
			if (!_filesById[id]) return null;
			return LoadManagerFile(_filesById[id]).url;
		}
		
		/**
		 * Retrieves the list of file ids that are currently in the queue.
		 * @return	An Array containing the list of files ids currently in the queue
		 */
		public function getQueueList () : Array
		{
			var output:Array = [];
			var numFiles:int = _queue.length;
			
			for (var i:int = 0; i < numFiles; i ++) 
				output.push(LoadManagerFile(_queue[i]).id);
			
			return output;
		}
		
		/**
		 * Begins loading the file at the head of the queue. If the queue is empty, calls to this method will do nothing.
		 */
		public function loadQueue () : void
		{
			if (_loadingXML || _queue.length == 0) return;
			
			var file:LoadManagerFile = _queue[0];
			//trace("Loading " + _id + ":", file.id, "(" + file.url + ") with", file.handler);
			
			// Add listeners to the loader
			var loaderAsDispatcher:IEventDispatcher = IEventDispatcher(file.handler);
			loaderAsDispatcher.addEventListener(Event.COMPLETE, onFileLoadComplete, false, 0, true);
			loaderAsDispatcher.addEventListener(IOErrorEvent.IO_ERROR, onFileIOError, false, 0, true);
			
			if (_dispatchProgressEvents) 
				loaderAsDispatcher.addEventListener(ProgressEvent.PROGRESS, onFileProgress, false, 0, true);
			
			if (_id != "$_global") _global.pauseQueue();
			
			_loading = true;
			file.handler.load(_baseURL + file.url, file.context);
		}
		
		/**
		 * Loads a resource list from a location and adds each file item to the queue.
		 * @param	xmlURL	The URL to the XML document containing the queue
		 */
		public function loadQueueFromXML (xmlURL:String) : void
		{
			if (_loading) pauseQueue();
			_loadingXML = true;
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onXMLComplete, false, 0, true);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLError, false, 0, true);
			xmlLoader.load(new URLRequest(_baseURL + xmlURL));
		}
		
		/**
		 * Pauses the loading of files in the queue. User <code>loadQueue()</code> to resume loading.
		 */
		public function pauseQueue () : void
		{
			_loading = false;
			
			var file:LoadManagerFile = _queue[0];
			if (!file) return;
			file.handler.pauseLoad();
		}
		
		/**
		 * Releases all data from the LoadManager instance to prepare the contents for garbage collection. The LoadManager instance
		 * is still accessible after this method is called, although all files loaded and in the queue will be destroyed.
		 */
		public function purge () : void
		{
			var allFiles:Array = _files.concat(_queue), numFiles:int = allFiles.length;
			var file:LoadManagerFile;
			
			for (var i:int = 0; i < numFiles; i ++) {
				file = allFiles[i];
				file.destroy();
			}
			
			_queue = [];
			_files = [];
			_filesById = new Dictionary();
		}
		
		/**
		 * Releases a specific file from the LoadManager instance. After this method is called, the specified file will not longer be
		 * accessible through the LoadManager instance. This method will also remove any items in the load queue with the supplied id.
		 * @param	id	The id of the file to purge
		 */
		public function purgeFile (id:String) : void
		{
			removeFromQueue(id);
			
			var file:LoadManagerFile = _filesById[id];
			if (!file) return;
			
			var i:int = _files.indexOf(file);
			if (i > -1) _files.splice(i, 1);
			
			file.destroy();
			delete _filesById[id];
		}
		
		/**
		 * Removes a file from the queue.
		 * @param	id	The id of the file to remove from the queue
		 */
		public function removeFromQueue (id:String) : void
		{
			var numFiles:uint = _queue.length;
			var file:LoadManagerFile;
			
			for (var i:int = 0; i < numFiles; i ++) {
				file = _queue[i];
				
				if (file.id == id) {
					_queue.splice(i, 1);
					break;
				}
			}
			
			if (file) file.destroy();
			if (i == 0 && _loading) loadQueue();	// If the file was currently being loaded, begin loading the next item in the queue
		}
		
		/**
		 * Sets the loader context for a file in the queue. This is useful when loading resources from an XML list that require a
		 * different loader context than the default.
		 * @param	id			The id of the file to set the loader context for
		 * @param	context		The context object
		 */
		public function setLoaderContext (id:String, context:*) : void
		{
			var file:LoadManagerFile = getFileInQueue(id);
			if (!file) return;
			file.context = context;
		}
		
		
		// PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * Retrieves the file in the queue with the id supplied.
		 * @param	id	The id of the file
		 * @return	The LoadManagerFile with the id supplied
		 */
		private function getFileInQueue (id:String) : LoadManagerFile
		{
			var numFiles:uint = _queue.length, file:LoadManagerFile;
			for (var i:int = 0; i < numFiles; i ++) {
				file = _queue[i];
				if (file.id == id) return file;
			}
			
			return null;
		}
		
		/**
		 * Retrieves the next 'new file' id for items in which no file name was supplied.
		 * @return	The unique next 'new file' id
		 */
		private function getNextFileId () : String
		{
			return "_file" + (_nextFileId ++);
		}
		
		/**
		 * Retrieves a format handler for a file based on the file's extension in the URL. If no handler could be found
		 * for the file's extension, the binary handler will be used.
		 * @param	url	The URL of the file
		 * @return	The id of the format handler to use for the URL
		 */
		private function getHandlerIdFromURL (url:String) : String
		{
			var ext:String = url.substr(url.lastIndexOf(".") + 1);
			var handlerId:String = _formatExtensions[ext];
			return handlerId ? handlerId : "binary";
		}
		
		/**
		 * Sets the base URL to load all files from.
		 * @param	value	The base URL to load files from
		 */
		private function setBaseURL (value:String) : void
		{
			_baseURL = value;
			if (_baseURL.substr(_baseURL.length - 1) != "/") _baseURL += "/";
		}
		
		/**
		 * Set the dispatch progress events flag.
		 * @param	value	The dispatch progress events flag
		 */
		private function setDispatchProgressEvents (value:Boolean) : void
		{
			_dispatchProgressEvents = value;
			
			var file:LoadManagerFile = LoadManagerFile(_queue[0]);
			var loaderAsDispatcher:IEventDispatcher = IEventDispatcher(file.handler);
			loaderAsDispatcher.removeEventListener(ProgressEvent.PROGRESS, onFileProgress);
			
			if (_dispatchProgressEvents) loaderAsDispatcher.addEventListener(ProgressEvent.PROGRESS, onFileProgress);
		}
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when a file has completed loading.
		 * @param	e	The Event object
		 */
		private function onFileLoadComplete (e:Event) : void
		{
			var file:LoadManagerFile = LoadManagerFile(_queue.shift());
			var content:* = file.handler.getContent();
			
			_files.push(file);
			_filesById[file.id] = file;
			
			dispatchEvent(new LoadManagerEvent(LoadManagerEvent.FILE_COMPLETE, false, false, file.id));
			
			if (_queue.length == 0) {
				dispatchEvent(new LoadManagerEvent(LoadManagerEvent.QUEUE_COMPLETE));
				if (_id != "$_global") _global.loadQueue();
			
			} else {
				loadQueue();
			}
		}
		
		/**
		 * Executed when a file could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onFileIOError (e:IOErrorEvent) : void
		{
			_loading = false;
			trace("LoadManager: Error: File could not be found");
			removeFromQueue(LoadManagerFile(_queue[0]).id);
			dispatchEvent(e.clone());
		}	
		
		/**
		 * Executed when a file's load progress changes.
		 * @param	e	The ProgressEvent object
		 */
		private function onFileProgress (e:ProgressEvent) : void
		{
			var file:LoadManagerFile = LoadManagerFile(_queue[0]);
			dispatchEvent(new LoadManagerProgressEvent(LoadManagerProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal, file.id));
		}
		
		/**
		 * Executed when an XML cue has completed loading.
		 * @param	e	The Event object
		 */
		private function onXMLComplete (e:Event) : void
		{
			var xml:XML = XML(e.currentTarget.data);
			_loadingXML = false;
			
			dispatchEvent(new LoadManagerEvent(LoadManagerEvent.LIST_COMPLETE, false, false, null, xml));
			addToQueueFromXML(xml);
			
			loadQueue();
		}
		
		/**
		 * Executed when an XML cue file could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onXMLError (e:IOErrorEvent) : void
		{
			_loadingXML = false;
			trace("LoadManager: Error: XML file could not be found.");
			dispatchEvent(e.clone());
		}
		
		
		// GETTERS & SETTERS
		// ------------------------------------------------------------------------------------------
		/**
		 * The base URL to load all files from. For example, if <code>baseURL</code> was set to "myApp/data/", all files added to the
		 * queue (and XML file lists loaded using <code>loadQueueFromXML()</code>) would have "myApp/data/" prepended to their URLs, making
		 * the final URL "myApp/data/myXMLFile.xml".
		 */
		public function get baseURL () : String { return _baseURL; }
		public function set baseURL (value:String) : void { setBaseURL(value); }
		
		/**
		 * Determines if progress events are dispatched when files are loading. Set this value to <code>true</code> if you want to monitor
		 * the load progress of individual files. Progress events are dispatched as <code>com.exileetiquette.loader.events.LoadManagerProgressEvent</code> events.
		 */
		public function get dispatchProgressEvents () : Boolean { return _dispatchProgressEvents; }
		public function set dispatchProgressEvents (value:Boolean) : void { setDispatchProgressEvents(value) }
		
		/**
		 * The id of the LoadManager instance.
		 */
		public function get id () : String { return _id; }
		
		/**
		 * Determines if the LoadManager instance is currently set to load files in the queue. This value is <code>true</code> by default,
		 * meaning files added to the queue will begin loading immediately. It will also be set to <code>true</code> when
		 * <code>loadQueue()</code> or <code>loadQueueFromXML()</code> is called, and set to false <i>only</i> when
		 * <code>pauseQueue()</code> is called.
		 */
		public function get loading () : Boolean { return _loading; }
		
		/**
		 * The total number of files being handled by the LoadManager. This is the sum of both loaded files and files in the queue.
		 */
		public function get filesTotal () : uint { return _queue.length + _files.length; }
		
		/**
		 * The number of files loaded.
		 */
		public function get filesLoaded () : uint { return _files.length; }
		
		/**
		 * The number of files currently in the queue.
		 */
		public function get filesQueued () : uint { return _queue.length; }
	}
}


/**
 * An internal class used to store temporary information about files being loaded
 */

import com.exileetiquette.loader.formats.IFormatHandler;

class LoadManagerFile
{
	public var context:*;
	public var data:*;
	public var id:String;
	public var handler:IFormatHandler;
	public var priority:uint = 0;
	public var url:String;
	
	public function destroy () : void
	{
		if (handler) handler.destroy();
		data = null;
		handler = null;
		context = null;
		url = id = null;
		priority = 0;
	}
}

/**
 *An internal class used to enforce the LoadManager class as a Singleton
 */
class LoadManagerSingletonEnforcer { }