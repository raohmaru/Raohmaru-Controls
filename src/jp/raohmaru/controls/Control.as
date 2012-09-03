/*
Copyright (c) 2012 Raohmaru

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
*/

package jp.raohmaru.controls 
{
import flash.display.MovieClip;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

/**
 * Se distribuye cuando el usuario pulsa sobre una instancia de Control.
 * @eventType flash.events.MouseEvent.MOUSE_DOWN
 */
[Event(name="mouseDown", type="flash.events.MouseEvent") ]

/**
 * Se distribuye cuando el usuario suelta el botón sobre una instancia de Control.
 * @eventType flash.events.MouseEvent.MOUSE_UP
 */
[Event(name="mouseUp", type="flash.events.MouseEvent") ]

/**
 * Se distribuye cuando el usuario pasa el cursor por encima de una instancia de Control.
 * @eventType flash.events.MouseEvent.MOUSE_OVER
 */
[Event(name="mouseOver", type="flash.events.MouseEvent") ]

/**
 * Se distribuye cuando el usuario mueve el cursor hacia el exterior de una instancia de Control.
 * @eventType flash.events.MouseEvent.MOUSE_OUT 
 */
[Event(name="mouseOut", type="flash.events.MouseEvent") ]


/**
 * La clase Control es la clase base para todos los controles.
 * @author raohmaru
 * @version 1.0.2
 */
public class Control extends EventDispatcher 
{
	/**
	 * @private
	 */
	protected var	_movie : MovieClip,
					_enabled : Boolean = true;

	/**
	* Un valor booleano que especifica si está activado un control. Cuando un control está desactivado, el control está visible pero no responde a los
	* eventos de ratón.
	* @default true
	*/
	public function get enabled() : Boolean
	{
		return _enabled;
	}	
	public function set enabled(value : Boolean) : void
	{
		_enabled = value;
		_movie.enabled = _enabled;
		_movie.mouseEnabled = _enabled;
		_movie.mouseChildren = _enabled;
		_movie.alpha = _enabled ? 1 : .5;
	}
	
	/**
	* Indica si el control es visible.
	*/
	public function get visible() : Boolean
	{
		return _movie.visible;
	}	
	public function set visible(value : Boolean) : void
	{
		_movie.visible = value;
	}
	
	/**
	 * Define o obtiene la altura del control.
	 */
	public function get height() : Number
	{
		return _movie.height;
	}
	public function set height(value : Number) : void
	{
		_movie.height = value;
	}
	
	/**
	 * Define o obtiene la anchura de la barra del control.
	 */
	public function get width() : Number
	{
		return _movie.width;
	}
	public function set width(value : Number) : void
	{
		_movie.width = value;
	}
	
	/**
	 * Define el nombre del control. Por defecto, este es el nombre del MovieClip que representa en el escenario.
	 */
	public function get name() : String
	{
		return _movie.name;
	}
	public function set name(value : String) : void
	{
		_movie.name = value;
	}

	/**
	 * Indica la coordenada <i>x</i> de la instancia de Control en relación a las coordenadas locales del DisplayObjectContainer principal.
	 * @see flash.display.DisplayObject#x
	 */
	public function get x() : Number
	{
		return _movie.x;
	}	
	public function set x(value : Number) : void
	{
		_movie.x = value;
	}
	
	/**
	 * Indica la coordenada <i>y</i> de la instancia de Control en relación a las coordenadas locales del DisplayObjectContainer principal.
	 * @see flash.display.DisplayObject#y
	 */
	public function get y() : Number
	{
		return _movie.y;
	}	
	public function set y(value : Number) : void
	{
		_movie.y = value;
	}

	/**
	 * Indica el valor de transparencia alfa del control.
	 */
	public function get alpha() : Number
	{
		return _movie.alpha;
	}
	public function set alpha(value : Number) : void
	{
		_movie.alpha = value;
	}
	
	/**
	 * Obtiene el clip de película asociado al control.
	 */
	public function get movie() :MovieClip
	{
		return _movie;
	}
	
	
	/**
	 * Crea una nueva instancia del objeto Control.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 */
	public function Control(movie : MovieClip)
	{
		_movie = movie;
		
		init();
	}
	
	/**
	 * @private
	 */
	protected function init() : void
	{
		_movie.buttonMode = true;
		_movie.mouseChildren = false;
		
		_movie.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
		_movie.addEventListener(MouseEvent.MOUSE_UP, pressHandler);
		_movie.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
		_movie.addEventListener(MouseEvent.MOUSE_OUT, overHandler);
	}
	
	/**
	 * @private
	 */
	protected function pressHandler(e : MouseEvent) : void
	{		
		dispatchEvent(e);
	}
	
	/**
	 * @private
	 */
	protected function overHandler(e : MouseEvent) : void
	{		
		dispatchEvent(e);
	}
}
}
