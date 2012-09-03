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
import flash.events.*;
import flash.text.*;

/**
 * La clase LabelButton se utiliza como una clase de botón sencillo con una etiqueta de texto.
 * @author raohmaru
 * @version 1.1
 * @example
<listing version="3.0">
import jp.raohmaru.controls.LabelButton;
var bot = new LabelButton(check_bot, "Comprobar");
bot.addEventListener(MouseEvent.MOUSE_UP, botHandler);

function botHandler(e : Event) : void
{
	trace(e.target.label);
}
</listing>
 */
public class LabelButton extends Control 
{					
	private var _offset_top : Number,
				_offset_y : Number,
				_offset_left : Number,
				 // Indica si el usuario ha establecido el ancho o el alto del control, y por tanto están bloqueados
				_width_locked : Boolean = false,
				_height_locked : Boolean = false,
				_default_textColor : uint,
				_over_textColor : uint,
				_down_textColor : uint,
				_change_color :Boolean = true,				_html :Boolean;
				
	/**
	 * @private
	 */
	protected var _value : Object;

	/**
	 * Obtiene o define la etiqueta de texto del control. Las dimensiones del control se ajustan automáticamente a las de la caja de texto interna.
	 * @default "Label"
	 * @see #textField
	 */
	public function get label() : String
	{
		return _movie.label_tf.text;
	}
	public function set label(value : String) : void
	{
		if(!_width_locked || textWordWrap) _movie.label_tf.autoSize = TextFieldAutoSize.LEFT;
		
		if(!_html)
			_movie.label_tf.text = value;
		else			_movie.label_tf.htmlText = value;
		
		if(!_width_locked) adjustWidth();
		
		if(!_height_locked) adjustHeight();
			
		vcenterTextField();
	}
	
	/**
	 * Obtiene o define el objeto de datos asignado al control.
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.LabelButton;
	var bot1 = new LabelButton(case1_bot, "Math.PI", Math.PI);
		bot1.addEventListener(MouseEvent.MOUSE_UP, botHandler);
	var bot2 = new LabelButton(case2_bot, "Math.LN10", Math.LN10);
		bot2.addEventListener(MouseEvent.MOUSE_UP, botHandler);
		
	function botHandler(e : Event) : void
	{
		trace(e.target.value);
	}</listing>
	 */
	public function get value() : Object
	{
		return _value;
	}
	public function set value(v : Object) : void
	{
		_value = v;
	}
	
	/**
	 * Valor booleano que indica si el campo de texto interno tiene ajuste de texto. Si se define como verdadero, el texto se dividirá en líneas si este
	 * excede el ancho de la caja de texto.
	 * @default false
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.LabelButton;	
	var bot = new LabelButton(cancel_bot);
	bot.textWordWrap = true;
	bot.width = 50;
	bot.label = "Cancelar todas las operaciones";</listing>
	 */
	public function get textWordWrap() : Boolean
	{
		return _movie.label_tf.wordWrap;
	}
	public function set textWordWrap(value : Boolean) : void
	{
		if(_width_locked)
			_movie.label_tf.autoSize = TextFieldAutoSize.NONE;
		if(value)
			_movie.label_tf.autoSize = TextFieldAutoSize.LEFT;
			
		_movie.label_tf.wordWrap = value;
		
		if(!value)
		{
			adjustTextFieldHeight(); 
			if(!_width_locked) adjustWidth();
		}
			
		if(!_height_locked) adjustHeight();
	}
	
	/**
	 * Obtiene o define el ancho del control, centrando horizontalmente el campo de texto interno. Esta propiedad se actualiza al cambiar el texto de
	 * la etiqueta, adaptándose al ancho de la misma.
	 * Para que el texto se ajuste al ancho del campo, definir <code>textWordWrap</code> como verdadero.
	 * @see #textWordWrap
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.LabelButton;
	var bot = new LabelButton(car_bot, "Coche de segunda mano");
	bot.width = 50;</listing>
	 */
	override public function set width(value : Number) : void
	{
		_movie.label_tf.autoSize = TextFieldAutoSize.NONE;
		
		_movie.icon_mc.width = value;
		_movie.label_tf.width = value - _offset_left*2;
		
		if(textWordWrap)
		{
			adjustTextFieldHeight(); 
			adjustHeight();
		}
		
		_width_locked = true;
	}	
	
	/**
	 * Obtiene o define la altura del control, centrando verticalmente el campo de texto interno. Esta propiedad se actualiza al cambiar el texto de
	 * la etiqueta, adaptándose al alto de la misma.
	 * @see #width
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.LabelButton;
	var bot = new LabelButton(send_bot, "Enviar");
	bot.height = 50;</listing>
	 */
	override public function set height(value : Number) : void
	{
		_movie.icon_mc.height = value;
		vcenterTextField();
		
		_height_locked = true;
	}
	
	/**
	 * Referencia al campo de texto interno del control.
	 */
	public function get textField() : TextField 
	{
		return _movie.label_tf;
	}
	
	/**
	* El color del texto del campo de texto interno, expresado en formato hexadecimal (por ejemplo, el color blanco es 0xFFFFFF).<br>
	* Cuando se define, se define también la propiedad <code>overTextColor</code> con el mismo valor un poco más brillante, y la propiedad
	* <code>downTextColor</code> con el mismo valor que <code>textColor</code>.
	* @default La propiedad TextField.textColor del campo de texto interno.
	* @see flash.text.TextField#textColor
	*/
	public function get textColor() : uint
	{
		return _default_textColor;
	}	
	public function set textColor(value : uint) : void
	{
		_default_textColor = value;
		_over_textColor = value;
		_down_textColor = value;
		
		_movie.label_tf.textColor = value;
	}
	
	/**
	 * El color del texto del campo de texto interno cuando el cursor se situa encima del control, expresado en formato hexadecimal (por ejemplo, el color blanco es 0xFFFFFF).
	 */
	public function get overTextColor() : uint
	{
		return _over_textColor;
	}	
	public function set overTextColor(value : uint) : void
	{
		_over_textColor = value;
	}
	
	/**
	 * El color del texto del campo de texto interno cuando se pulsa en el control, expresado en formato hexadecimal (por ejemplo, el color blanco es 0xFFFFFF).
	 */
	public function get downTextColor() : uint
	{
		return _down_textColor;
	}	
	public function set downTextColor(value : uint) : void
	{
		_down_textColor = value;
	}
	
	/**
	 * Valor que indica si el color del campo de texto debe cambiar como respuesta a los eventos de ratón.
	 * @see #textColor
	 */
	public function get enableTextColor() :Boolean
	{
		return _change_color;
	}	
	public function set enableTextColor(value :Boolean) :void
	{
		_change_color = value;
	}
	
	/**
	 * Valor booleano que especifica si en el campo de texto interno se deben introducir las cadena de texto como código HTML.
	 */
	public function get html() :Boolean
	{
		return _html;
	}	
	public function set html(value :Boolean) :void
	{
		_html = value;
	}


	/**
	 * Crea una nueva instancia de la clase AbstractLabelButton.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 * @param _label Etiqueta de texto del control
	 * @param _value El valor asignado al control
	 */
	public function LabelButton(movie : MovieClip, label : String = null, value : Object = null)
	{
		super(movie);
		
		textWordWrap = false;
		textColor = _movie.label_tf.textColor;
		
		// Calcula el desfase vertical de la caja de texto para que quede visualmente centrado. Esto se debe a que las cajas de texto
		// tienen más relleno superior que inferior, y por eso en el editor las situamos ligeramente más arriba
		_offset_top = _movie.label_tf.y + (_movie.icon_mc.height + movie.icon_mc.y) - (_movie.label_tf.height + _movie.label_tf.y);
		_offset_y = (_movie.label_tf.y+_movie.label_tf.height/2) - (_movie.icon_mc.y+_movie.icon_mc.height/2);
		
		_offset_left = _movie.label_tf.x - _movie.icon_mc.x;
		
		if(label) this.label = label;
		if(value != null) this.value = value;
	}
	
	/**
	 * @private
	 */
	override protected function pressHandler(e : MouseEvent) : void
	{
		_movie.icon_mc.gotoAndStop(e.type);
		
		if(_change_color)
			_movie.label_tf.textColor = (e.type == MouseEvent.MOUSE_DOWN) ? _down_textColor : _over_textColor;
		
		super.pressHandler(e);
	}
	
	/**
	 * @private
	 */
	override protected function overHandler(e : MouseEvent) : void
	{
		_movie.icon_mc.gotoAndStop(e.type);
		
		if(_change_color)
			_movie.label_tf.textColor = (e.type == MouseEvent.MOUSE_OVER) ? _over_textColor : _default_textColor;
		
		super.overHandler(e);
	}

	
	
	
	private function vcenterTextField() : void
	{
		_movie.label_tf.y = Math.round( _movie.icon_mc.height/2 - _movie.label_tf.height/2 + _offset_y );
	}
	
	private function adjustWidth() : void
	{
		_movie.icon_mc.width =  Math.round( _movie.label_tf.x + _movie.label_tf.width + _offset_left );
	}
	
	private function adjustHeight() : void
	{
		_movie.icon_mc.height = Math.round( _movie.label_tf.height + _offset_top );
	}
	
	private function adjustTextFieldHeight() : void
	{
		_movie.label_tf.height = _movie.label_tf.textHeight + 4; // + 4 -> Si no se come la última línea 
	}
}
}