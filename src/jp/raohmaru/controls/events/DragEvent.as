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

package jp.raohmaru.controls.events 
{
import flash.events.Event;

/**
 * La clase DragEvent define eventos asociados al arrastramiento de Sprites.
 * Incluyen lo siguiente:
<ul>
	<li><code>DragEvent.DRAG</code>: se distribuye cuando un usuario arrastra un sprite.</li>
	<li><code>DragEvent.DRAG_START_</code>: se distribuye cuando un usuario comienza la acción de arrastar.</li>
	<li><code>DragEvent.DRAG_STOP</code>: se distribuye cuando un usuario detiene la acción de arrastar.</li>	<li><code>DragEvent.DRAG_CHANGE</code>: se distribuye cuando se produce un cambio en la posición de un control deslizador o este ha dejado de arrastrarse.</li>
</ul>  
 * @see jp.raohmaru.controls.Slider 
 * @see flash.display.Sprite#startDrag()
 * @author raohmaru
 * @version 1.0
 */
public class DragEvent extends Event 
{
	/**
	 * Define el valor de la propiedad <code>type</code> para un objeto de evento <code>dragDrag</code>. 
	 */
	public static const DRAG :String = "dragDrag";
	/**
	 * Define el valor de la propiedad <code>type</code> para un objeto de evento <code>dragStart</code>. 
	 */
	public static const DRAG_START :String = "dragStart";
	/**
	 * Define el valor de la propiedad <code>type</code> para un objeto de evento <code>dragStop</code>. 
	 */
	public static const DRAG_STOP :String = "dragStop";
	/**
	 * Define el valor de la propiedad <code>type</code> para un objeto de evento <code>dragChange</code>. 
	 */
	public static const DRAG_CHANGE :String = "dragChange";
	
	private var _position :Number,
				_localX :Number,
				_localY :Number;
	
	/**
	 * Obtiene el nuevo valor de un control Slider basado en su posición.
	 */
	public function get position() :Number
	{
		return _position;
	}
	
	/**
	 * La coordenada horizontal en la que se produce el evento en relación con la clase Sprite contenida.
	 */
	public function get localX() :Number
	{
		return _localX;
	}
	
	/**
	 * La coordenada vertical en la que se produce el evento en relación con la clase Sprite contenida.
	 */
	public function get localY() :Number
	{
		return _localY;
	}


	
	/**
	 * Crea un nuevo objeto DragEvent con los parámetros especificados.
	 * @param type Tipo de evento; este valor identifica la acción que ha activado el evento.
	 * @param position Nuevo valor del deslizador.
	 * @param localX La coordenada horizontal en la que se produce el evento en relación con la clase Sprite contenida.
	 * @param localY La coordenada vertical en la que se produce el evento en relación con la clase Sprite contenida.
	 */
	public function DragEvent(type :String, position :Number, localX :Number, localY :Number)
	{
		_position = position;		_localX = localX;		_localY = localY;
		
		super(type);
	}
	
	
	/**
	 * Devuelve una cadena con todas las propiedades del objeto DragEvent.
	 * La cadena tiene el siguiente formato:
	 * 
	 * <p>[<code>DragEvent type=<em>value</em> position=<em>position</em>
	 * bubbles=<em>value</em> cancelable=<em>value</em> 
     * localX=<em>value</em> localY=<em>value</em></code>]</p>
	 *
     * @return Una representación de cadena del objeto DragEvent
	 */
	override public function toString() :String 
	{
		return formatToString("SliderEvent", "type", "position", "bubbles", "cancelable", "clickTarget");
	}

	/**
	 * Crea una copia del objeto DragEvent y define el valor de cada parámetro para que coincida con el original.
     * @return Copia de la instancia de DragEvent actual.
	 */
	override public function clone() :Event
	{
		return new DragEvent(type, _position, localX, localY);
	}
}
}
