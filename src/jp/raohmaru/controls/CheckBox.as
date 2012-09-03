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
import flash.text.TextFieldAutoSize;
import flash.display.MovieClip;
import flash.events.*;
import jp.raohmaru.controls.enums.LabelPosition;

/**
 * Se distribuye cuando la propiedad <code>selected</code> pasa a ser verdadera.
 * @eventType flash.events.Event.SELECT
 * @see #selected
 */
[Event(name="select", type="flash.events.Event") ]
/**
 * Se distribuye cuando cambia la propiedad <code>selected</code> de la instancia del control.
 * @eventType flash.events.Event.CHANGE
 * @see #selected
 */
[Event(name="change", type="flash.events.Event") ]

/**
 * El control CheckBox muestra un pequeño cuadro que puede incluir una marca de verificación, una etiqueta de texto y contener un valor.
 * <br>Cuando un control CheckBox es seleccionado por el usuario, dispara un evento <code>Event.SELECT</code> si la propiedad selected pasa a verdadera,
 * alternativamente con un evento <code>Event.CHANGE</code>.
 * @example
<listing version="3.0">
import jp.raohmaru.controls.CheckBox;

var cbx1 = new CheckBox(test1_chx, "Con sal y pimienta", 1);
cbx1.addEventListener(Event.SELECT, cbxHandler);
	
var cbx2 = new CheckBox(test2_chx, "Con sal y pimienta", 2);
cbx2.textWordWrap = true;
cbx2.textWidth = 100;
cbx2.addEventListener(Event.CHANGE, cbxHandler);	

function cbxHandler(e : Event) : void
{
	trace(e.target.name, e.target.selected, e.target.value);
}
</listing>
 * @author raohmaru
 * @version 1.1
 */
public class CheckBox extends LabelButton
{
	/**
	 * @private
	 */
	protected var	_selected : Boolean = false,
					_label_pos :String,
					_icon_x :Number,
					_sel_x :Number,
					_label_x :Number;
	
	/**
	 * Indica si el control está seleccionado o no.
	 */
	public function get selected() : Boolean
	{
		return _selected;
	}
	public function set selected(value : Boolean) : void
	{
		_selected = value;
		
		_movie.selected_mc.visible = _selected;
		if(_selected)
			_movie.selected_mc.gotoAndPlay(1);
		
		onMouseUp();
	}
	
	/**
	 * Establece la posición del campo de texto respecto al control.
	 * Existen dos posibles valores: LabelPosition.LEFT (a la izquerda del control) o LabelPosition.RIGHT (a la derecha del control, posición por defecto).
	 * @default LabelPosition.RIGHT
	 */
	public function get labelPosition() : String
	{
		return _label_pos;
	}
	public function set labelPosition(value : String) : void
	{
		_label_pos = value;
		
		if(value == LabelPosition.LEFT)
		{
			_movie.label_tf.x = 0;			
			_movie.icon_mc.x = _icon_x + _movie.label_tf.textWidth + 5;
			_movie.selected_mc.x = _sel_x + _movie.label_tf.textWidth + 5;
		}		
		else
		{
			_movie.label_tf.x = _label_x;			
			_movie.icon_mc.x = _icon_x;
			_movie.selected_mc.x = _sel_x;
		}
	}
	
	/**
	 * @private
	 */
	override public function set label(value : String) : void
	{
		if(!html)
			_movie.label_tf.text = value;
		else
			_movie.label_tf.htmlText = value;
			
		labelPosition = _label_pos;
	}
	
	/**
	 * @private
	 */
	override public function set textWordWrap(value : Boolean) : void
	{
		_movie.label_tf.wordWrap = value;
		
		labelPosition = _label_pos;
	}
	
	/**
	 * Obtiene o define el el ancho del campo de texto interno. Por defecto el campo de texto crecerá a la derecha cuando se produzca un cambio de texto,
	 * manteniéndolo en una línea. Para que el texto se ajuste al ancho del campo, definir <code>textWordWrap</code> como verdadero.
	 * @see LabelButton#textWordWrap
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.CheckBox;
	var cbx = new CheckBox(test2_chx, "Coche de segunda mano", true);
	cbx.textWordWrap = true;
	cbx.width = 100;</listing>
	 */
	override public function set width(value : Number) : void
	{
		_movie.label_tf.width = value;
		
		labelPosition = _label_pos;
	}
	
	/**
	 * @private
	 */
	override public function get height() : Number
	{
		return _movie.height;
	}	
	/**
	 * @private
	 */
	override public function set height(value : Number) : void
	{
		
	}
	
	/**
	 * Crea una nueva instancia de la clase CheckBox.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 * @param label Etiqueta de texto del control
	 * @param value El valor asignado al control
	 */
	public function CheckBox(movie : MovieClip, label : String = null, value : Object = null)
	{
		_icon_x = movie.icon_mc.x;
		_sel_x = movie.selected_mc.x;
		_label_x = movie.label_tf.x;
		
		super(movie, label, value);
		
		_movie.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
		_movie.label_tf.autoSize = TextFieldAutoSize.LEFT;
		
		_movie.selected_mc.visible = _selected;
	}
	
	/**
	 * @private
	 */
	protected function onMouseUp(e :Event = null) : void
	{
		if(e)
		{
			_selected = !_selected;
			
			_movie.selected_mc.visible = _selected;
			if(_selected)
				_movie.selected_mc.gotoAndPlay(1);
		}
		
		if(_selected) dispatchEvent(new Event(Event.SELECT));
		dispatchEvent(new Event(Event.CHANGE));
	}
}
}