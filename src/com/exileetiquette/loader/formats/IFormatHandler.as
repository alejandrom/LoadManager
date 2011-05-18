/**
 * com.exileetiquette.loader.formats.IFormatHandler
 * 
 * Copyright (c) 2009 Stephen Woolcock
 * 20/06/2009 1:01 PM
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
	
	/**
	 * The IFormatHandler interface must be implemented by all registered file formats for the LoadManager. All format handlers should
	 * also either extends <code>flash.events.EventDispatcher</code> or implement the <code>flash.events.IEventDispatcher</code> interface.
	 */
	public interface IFormatHandler
	{
		/**
		 * A clean up routine that destroys all external references to prepare the class for garbage collection.
		 */
		function destroy () : void;
		
		/**
		 * Retrieves the contents of the loaded file.
		 * @return	The contents of the loaded file
		 */
		function getContent () : * ;
		
		/**
		 * Begins loading a file from a specific URL.
		 * @param	url		The URL of the file to load
		 * @param	context	An optional load context object
		 */
		function load (url:String, context:* = null) : void;
		
		/**
		 * Pauses the loading of the file.
		 */
		function pauseLoad () : void;
	}
}