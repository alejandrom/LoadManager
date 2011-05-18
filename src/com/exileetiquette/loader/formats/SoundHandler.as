﻿/**
 * com.exileetiquette.loader.formats.SoundHandler
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 21/06/2009 2:05 PM
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

package com.exileetiquette.loader.formats
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	/**
	 * The SoundHandler class handles the loading of sound files. The data loaded by SoundHandler is returned as a
	 * <code>Sound</code> object.
	 */
	public class SoundHandler extends EventDispatcher implements IFormatHandler
	{
		private var _loaded:Boolean;
		private var _sound:Sound;
		
		/**
		 * Creates a new instance of the SoundHandler class
		 */
		public function SoundHandler () : void
		{
			_sound = new Sound();
			_sound.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_sound.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
		}
		
		
		// STATIC PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		
		
		// STATIC PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		
		
		// PUBLIC FUNCTIONS
		// ------------------------------------------------------------------------------------------
		/**
		 * @inheritDoc
		 */
		public function destroy () : void
		{
			try { _sound.close(); } catch (e:Error) { }
			_sound = null;
			_loaded = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getContent () : *
		{
			if (!_loaded) return null;
			return _sound;
		}
		
		/**
		 * @inheritDoc
		 */
		public function load (url:String, context:* = null) : void
		{
			_loaded = false;
			_sound.load(new URLRequest(url), SoundLoaderContext(context));
		}
		
		/**
		 * @inheritDoc
		 */
		public function pauseLoad () : void
		{
			try { _sound.close(); } catch (e:Error) { }
		}
		
		
		// PRIVATE FUNCTIONS
		// ------------------------------------------------------------------------------------------
		
		
		// EVENT HANDLERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Executed when the file has completed loading.
		 * @param	e	The Event object
		 */
		private function onLoadComplete (e:Event) : void
		{
			_loaded = true;
			dispatchEvent(e.clone());
		}
		
		/**
		 * Executed when the file could not be loaded.
		 * @param	e	The IOErrorEvent object
		 */
		private function onLoadIOError (e:IOErrorEvent) : void
		{
			dispatchEvent(e.clone());
		}
		
		/**
		 * Executed when the file's load progress changes.
		 * @param	e	The ProgressEvent object
		 */
		private function onLoadProgress (e:ProgressEvent) : void
		{
			dispatchEvent(e.clone());
		}
		
		
		// GETTERS & SETTERS
		// ------------------------------------------------------------------------------------------
		/**
		 * Indicates if the file has been loaded.
		 */
		public function get loaded () : Boolean { return _loaded; }
	}
}