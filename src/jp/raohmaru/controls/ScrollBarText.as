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
import flash.display.*;
import flash.events.*;
import flash.geom.Rectangle;
import flash.text.*;
import flash.ui.Keyboard;
import flash.utils.Timer;

import jp.raohmaru.controls.enums.ButtonBehavior;
import jp.raohmaru.controls.enums.ScrollBarMove;

/**
 * Se distribuye cuando cambia la propiedad <code>position</code> de la instancia de ScrollBarText.
 * @eventType flash.events.Event.CHANGE
 * @see #position
 */
[Event(name="change", type="flash.events.Event") ]

/**
 * El control ScrollBarText genera una barra deslizable para controlar el texto que desborda en un objeto TextField multilínea.
 * @example El siguiente ejemplo crea un campo de texto y un control ScrollBarText a partir de un MovieClip en el escenario:
<listing version="3.0">
import jp.raohmaru.controls.ScrollBarText;

var text_tf :TextField = new TextField();
	text_tf.x = 10;
	text_tf.y = 10;
	text_tf.width = 180;
	text_tf.height = 70;
	text_tf.multiline = true;
	text_tf.wordWrap = true;
	text_tf.text = "En un agujero en el suelo, vivía un hobbit. No un agujero húmedo, sucio, repugnante, con restos de gusanos y olor a fango, ni tampoco un agujero seco, desnudo y arenoso, sin nada en que sentarse o que comer: era un agujero-hobbit, y eso significa comodidad. Tenía una puerta redonda, perfecta como un ojo de buey, pintada de verde, con una manilla de bronce dorada y brillante, justo en el medio. La puerta se abría a un vestíbulo cilíndrico, como un túnel: un túnel muy cómodo, sin humos, con paredes revestidas de madera y suelos enlosados y alfombrados, provisto de sillas barnizadas, y montones y montones de perchas para sombreros y abrigos; el hobbit era aficionado a las visitas.";

addChild(text_tf);
	
var sb : ScrollBarText = new ScrollBarText(sb_mc);
	sb.target = text_tf;
</listing>
 * @author raohmaru
 * @version 1.0.1
 */
public class ScrollBarText extends Control
{
	// UI
	private var _slider : MovieClip,
				_track : MovieClip,
				_up_bot : MovieClip,
				_down_bot : MovieClip,
				_textField : TextField;
	// Props	
	private var _scrollbar_bounds : Rectangle,
				_timer : Timer,
				_track_timer : Timer,
				_arrow_timer : Timer,
				_scroll_height : Number,				_numPages : Number,				_pageNumLines : Number,
				_pageScrollSize : Number,
				_lineScrollSize : Number;

	// Accesors
	private var _linked : Boolean = false,
				_scrollLines : Number = 1,
				_sliderResize : Boolean = true,
				_buttonBehavior : String = ButtonBehavior.PRESS,
				_mouseWheelEnabled : Boolean,
				_trackEnabled : Boolean,
				_repeatDelay : uint = 250,
				_trackDelay : uint = 100,
				_arrowDelay : uint = 50;

	/**
	 * Establece el objeto TextField cuyo contenido de texto se desplazará. La barra de scroll se ajustará automáticamente a la altura del objeto TextField.
	 * Si el objeto TextField es del tipo de introducción de datos (<code>TextFieldType.INPUT</code>), cada vez que el usuario escriba la instancia de
	 * ScrollBarText se actualizará.
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.ScrollBarText;
	
	var sb : ScrollBarText = new ScrollBarText(sb_mc);
	sb.target = text_tf;
	</listing>
	 */
	public function set target(value :TextField) :void
	{
		_textField = value;
		_textField[ (_textField.type==TextFieldType.INPUT) ? 'addEventListener' : 'removeEventListener'](Event.CHANGE, update);
		_textField[ (_textField.selectable) ? 'addEventListener' : 'removeEventListener'](KeyboardEvent.KEY_DOWN, keyHanlder);		_textField[ (_textField.selectable) ? 'addEventListener' : 'removeEventListener'](KeyboardEvent.KEY_UP, keyHanlder);
		
		mouseWheelEnabled = true;
		
		height = _textField.height;
		
		update();
	}
	
	/**
	 * Define o obtiene si la barra de scroll y el contenido están vinculados; en ese caso, cambiar las dimensiones con <code>height</code> o <code>width</code>
	 * afectará a ambos, en lugar de sólo a la barra de scroll.
	 * @default = false
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.ScrollBarText;
	
	var sb : ScrollBarText = new ScrollBarText(sb_mc);
	sb.target = text_tf;
	sb.linked = true;
	sb.height = 180;
	sb.width = 80;
	
	// Ahora sólo cambiará el ancho de la barra de scroll
	sb.linked = false;
	sb.width = 6;
	</listing>
	 */
	public function get linked() : Boolean
	{
		return _linked;
	}	
	public function set linked(value : Boolean) : void
	{
		_linked = value;
	}

	/**
	 * Obtiene o define un valor que representa el número de líneas que el contenido se desplaza al presionar en un botón de flecha.
	 * @default 1
	 */
	public function get lineScrollSize() : Number
	{
		return _scrollLines;
	}	
	public function set lineScrollSize(value : Number) : void
	{
		_scrollLines = value;
	}	
	
	/**
	 * Indica si el deslizador debe redimensionarse respecto a la cantidad de desplazamiento disponible, esto es, cuanto más datos a desplazar más pequeño será
	 * el deslizador.
	 * @default true
	 */
	public function get sliderResize() : Boolean
	{
		return _sliderResize;
	}	
	public function set sliderResize(value : Boolean) : void
	{
		_sliderResize = value;
		update();
	}	
	
	/**
	 * Obtiene o define el comportamiento de los botones de desplazamiento al interactuar con el ratón.
	 * @default ButtonBehavior.PRESS
	 */
	public function get buttonBehavior() : String
	{
		return _buttonBehavior;
	}	
	public function set buttonBehavior(value : String) : void
	{
		_buttonBehavior = value;
	}
	
	/**
	 * Indica si el contenido puede desplazarse con la rueda del ratón. Si el campo de texto es de introducción de texto, entonces <code>mouseWheelEnabled</code>
	 * es siempre igual a <code>true</code> y no puede cambiarse.
	 * @default true
	 */
	public function get mouseWheelEnabled() : Boolean
	{
		return _mouseWheelEnabled;
	}	
	public function set mouseWheelEnabled(value : Boolean) : void
	{
		if(!_textField || (textField.type == TextFieldType.INPUT && !value)) return;
		
		_textField[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_WHEEL, wheelHandler);
		
		_mouseWheelEnabled = value;		
		_textField.mouseEnabled = value;
	}
		
	/**
	 * Obtiene o define si la guía puede pulsarse para desplazar el contenido.
	 * @default true
	 */
	public function get trackEnabled() : Boolean
	{
		return _trackEnabled;
	}	
	public function set trackEnabled(value : Boolean) : void
	{
		if(_trackEnabled == value) return;
		
		_trackEnabled = value;		

		_track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_DOWN, trackHandler);
		_track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_UP, trackHandler);
		_track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_OUT, trackHandler);
	}
	
	/**
	 * Obtiene una referencia al campo de texto vinculado al objeto ScrollBarText.
	 */
	public function get textField() :TextField
	{
		return _textField;
	}
	
	/**
	 * Define o obtiene la altura de la barra de scroll. Si <code>linked</code> es verdadero, entonces también define la altura del campo de texto.
	 * @see #linked
	 */
	override public function set height(value : Number) : void
	{
		_track.height = value;
		if(_up_bot) _track.height -= _up_bot.height;
		if(_down_bot)
		{
			_track.height -= _down_bot.height;
			_down_bot.y = Math.round( _track.y + _track.height );
		}
		setScrollBarBounds();		
		
		if(_linked)
		{
			_textField.height = value;
		}
		
		update();
	}
	
	/**
	 * Define o obtiene la anchura de la barra de scroll. Si <code>linked</code> es verdadero, entonces define la anchura del campo de texto.
	 * @see #linked
	 */
	override public function set width(value : Number) : void
	{
		if(!_linked)
		{
			_slider.width = value;
			_track.width = value;
			if(_up_bot) _up_bot.width = value;
			if(_down_bot) _down_bot.width = value;
		}
		else
		{
			var dteX : Number = _movie.x - (_textField.x + _textField.width);
			_textField.width = value;
			_movie.x = _textField.x + _textField.width + dteX;
		}
		
		update();
	}
	
	/**
	 * El número de milisegundos de espera después de que el evento <code>buttonDown</code> se distribuyera por primera vez antes de enviar un segundo
	 * evento <code>buttonDown</code>, al pulsar en la gúia o en un botón de flecha.
	 * @default 250
	 */
	public function get repeatDelay() : int
	{
		return _repeatDelay;
	}
	public function set repeatDelay(value : int) : void
	{
		_repeatDelay = value;
	}
	
	/**
	 * La frecuencia en milisegundos en la que se desplazará el contenido al pulsar sobre la guía.
	 * @default 100
	 */
	public function get trackDelay() : int
	{
		return _trackDelay;
	}
	public function set trackDelay(value : int) : void
	{
		_trackDelay = value;
	}
	
	/**
	 * La frecuencia en milisegundos en la que se desplazará el contenido al interactuar con un botón de desplazamiento.
	 * @default 50
	 */
	public function get arrowDelay() : int
	{
		return _arrowDelay;
	}
	public function set arrowDelay(value : int) : void
	{
		_arrowDelay = value;
	}	
	
	/**
	 * Obtiene o define la línea de texto de desplazamiento actual y actualiza la posición del deslizador.
	 */
	public function get position() : int
	{
		return _textField.scrollV;
	}	
	public function set position(value : int) : void
	{
		var _scrollV :int = _textField.scrollV;
		_textField.scrollV = value;
		
		_slider.y += _lineScrollSize * (value-_scrollV);
		checkSliderPosition();
	}
	
	/**
	 * @private
	 */
	override public function set enabled(value : Boolean) : void
	{
		super.enabled = value;
		
		_textField.mouseEnabled = value;
		_textField.alpha = value ? 1 : .5;
	}
	
	/**
	 * @private
	 */
	override public function get x() : Number
	{
		return (linked) ? Math.min(_movie.x, _textField.x) : _movie.x;
	}
	/**
	 * @private
	 */
	override public function set x(value : Number) : void
	{
		if(linked)
		{
			if(_textField.x < _movie.x)
			{
				_movie.x += value - _textField.x;
				_textField.x = value;
			}
			else
			{
				_textField.x += value - _movie.x;
				_movie.x = value;
			}
		}
		else
		{
			_movie.x = value;
		} 
	}

	/**
	 * @private
	 */
	override public function get y() : Number
	{
		return (linked) ? Math.min(_movie.y, _textField.y) : _movie.y;
	}
	/**
	 * @private
	 */
	override public function set y(value : Number) : void
	{
		if(linked)
		{
			if(_textField.y < _movie.y)
			{
				_movie.y += value - _textField.y;
				_textField.y = value;
			}
			else
			{
				_textField.y += value - _movie.y;
				_movie.y = value;
			}
		}
		else
		{
			_movie.y = value;
		} 
	}

	

	
	/**
	 * Crea una nueva instancia de ScrollBarText. Por defecto se puede clicar en la guía, está activado el evento de rueda de ratón, la altura de la
	 * barra de scroll se iguala a la del objeto TextField asociado y la altura del deslizador se ajusta a la cantidad de texto desbordante.
	 * Si el objeto MovieClip contiene además dos instancias de nombre "up_mc" y "down_mc", se activarán los botones de desplazamiento de flecha.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 */
	public function ScrollBarText(movie : MovieClip)
	{
		super(movie);
	}
	
	override protected function init() : void
	{
		_slider = _movie.slider_mc;
		_track = _movie.track_mc;
		
		_slider.defHeight = _slider.height;
		_slider.buttonMode = true;
		_slider.mouseChildren = false;
		_slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderHandler);
		_slider.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
		_slider.addEventListener(MouseEvent.MOUSE_OVER, sliderHandler);
		_slider.addEventListener(MouseEvent.MOUSE_OUT, sliderHandler);
		
		trackEnabled = true;
		
		// Si scrollbar_mc tiene un botón de desplazamiento hacia arriba o hacia abajo...
		if(_movie.up_mc)
		{
			_up_bot = _movie.up_mc;
			_up_bot.buttonMode = true;
			_up_bot.mouseChildren = false;
			_up_bot.addEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);
			_up_bot.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);
			_up_bot.addEventListener(MouseEvent.MOUSE_OVER, arrowHandler);
			_up_bot.addEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		if(_movie.down_mc)
		{
			_down_bot = _movie.down_mc;
			_down_bot.buttonMode = true;
			_down_bot.mouseChildren = false;
			_down_bot.addEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);
			_down_bot.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);
			_down_bot.addEventListener(MouseEvent.MOUSE_OVER, arrowHandler);
			_down_bot.addEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		
		
		_timer = new Timer(40);
		setScrollBarBounds();
	}
	
	/**
	 * Actualiza la barra de scroll y verifica que sea necesario mostrarlo (si hay contenido suficiente que desplazar). Se llama automáticamente
	 * al cambiar la altura o la anchura del scroll, al establecer un <code>target</code> o cada vez que el usuario
	 * escribe uno o varios caracteres en el campo de texto (el campo de texto debe ser de entrada de datos, o con la propiedad <code>TextField.type</code>
	 * igual a <code>TextFieldType.INPUT</code>).<br>
	 * Debe invocarse cada vez que se cambie el contenido del scroll.
	 */
	public function update(e :Event = null) :void
	{
		if(_sliderResize)
		{
			_slider.height = Math.round( (_textField.height * _track.height) / _textField.textHeight );
			if(_slider.height < 10) _slider.height = 10;
		}
		else
			_slider.height = _slider.defHeight;
		setScrollBarBounds();		
		
		_pageNumLines = Math.floor( (_textField.height * _textField.numLines) / _textField.textHeight );
		_numPages = Math.ceil( _textField.numLines / _pageNumLines ) - 1;
		_scroll_height = _textField.height - _textField.textHeight;
		_lineScrollSize = _scrollbar_bounds.height / (_textField.numLines-_pageNumLines);
		_pageScrollSize = Math.round(_scrollbar_bounds.height/_numPages);
		
		// ¿Es necesario el scroll?
		var is_scrollable : Boolean = (_scroll_height < 0);
		_timer[is_scrollable ? 'addEventListener' : 'removeEventListener'](TimerEvent.TIMER, updateContentPosition);		
		_movie.visible = is_scrollable;
		
		// Actualiza la posición de la barra si se invoca cuando el usuario introduce texto
		if(e) checkSliderPosition(true);
	}
	
	private function updateContentPosition(e : TimerEvent = null) : void
	{
		var newY : Number = ( (_textField.numLines-_pageNumLines)*(_slider.y-_scrollbar_bounds.y)) / _scrollbar_bounds.height + 1;
		_textField.scrollV = Math.ceil(newY);
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	private function moveSlider(newY : Number) : void
	{
		_slider.y = newY;
		
		if(_slider.y < _scrollbar_bounds.y) _slider.y = _scrollbar_bounds.y;
		if(_slider.y > _scrollbar_bounds.y+_scrollbar_bounds.height) _slider.y = _scrollbar_bounds.y+_scrollbar_bounds.height;
		
		updateContentPosition();
	}

	/**
	 * Desplaza el scroll al destino indicado. El destino puede ser:
	 * <ul>
	 * <li>un objeto <b>String</b> que corresponde a un valor de la clase ScrollBarMove.</li>
	 * </ul>
	 * @param target Objeto que señala el destino
	 * @see ScrollBarMove
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.ScrollBarText;
	import jp.raohmaru.controls.ScrollBarMove;
	
	var sb : ScrollBarText = new ScrollBarText(sb_mc);
	sb.target = scrollcontent_mc;
	sb.goto(ScrollBarMove.BOTTOM); // Desplaza el scroll al límite inferior
	sb.goto(ScrollBarMove.LINE_UP); // Desplaza el scroll una línea hacia arriba (es igual que la llamada ScrollBarText.lineUp())
	</listing>
	 */
	public function goto(target : Object) : void
	{
		if(target is String)
		{
			switch(target) 
			{
				case ScrollBarMove.PAGE_UP :
					moveSlider( _slider.y - _pageScrollSize );
					break;
					
				case ScrollBarMove.PAGE_DOWN :
					moveSlider( _slider.y + _pageScrollSize );
					break;
					
				case ScrollBarMove.LINE_UP :
					moveSlider( _slider.y - _lineScrollSize * _scrollLines );
					break;
					
				case ScrollBarMove.LINE_DOWN :
					moveSlider( _slider.y + _lineScrollSize * _scrollLines );
					break;
					
				case ScrollBarMove.TOP :
					moveSlider( _scrollbar_bounds.y );
					break;
					
				case ScrollBarMove.BOTTOM :
					moveSlider( _scrollbar_bounds.y+_scrollbar_bounds.height );
					break;
			}
		}
	}
	
	/**
	 * Desplaza el contenido del campo de texto una página hacia arriba.
	 */
	public function pageUp() : void
	{
		goto(ScrollBarMove.PAGE_UP);
	}
	
	/**
	 * Desplaza el contenido del campo de texto una página hacia abajo.
	 */
	public function pageDown() : void
	{
		goto(ScrollBarMove.PAGE_DOWN);
	}
	
	/**
	 * Desplaza el contenido del campo de texto una línea hacia arriba.
	 */
	public function lineUp() : void
	{
		goto(ScrollBarMove.LINE_UP);
	}
	
	/**
	 * Desplaza el contenido del campo de texto una línea hacia abajo.
	 */
	public function lineDown() : void
	{
		goto(ScrollBarMove.LINE_DOWN);
	}

	/**
	 * Resetea el control, situando en la parte superior el deslizador y en la primera línea el texto del objeto TextField.
	 */
	public function reset() : void
	{
		_slider.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		_slider.y = _scrollbar_bounds.y;
		_textField.scrollV = 1;
	}
	
	
	
	private function sliderHandler(e : MouseEvent) : void
	{
		if(e.type == MouseEvent.MOUSE_DOWN)
		{
			_slider.startDrag(false, _scrollbar_bounds);
			_timer.start();
			// onReleaseOutside trick
			_slider.stage.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			_slider.gotoAndStop(e.type);
		}
		else if(e.type == MouseEvent.MOUSE_UP)
		{
			_slider.stopDrag();
			_timer.stop();
			updateContentPosition();
			// onReleaseOutside trick
			_slider.stage.removeEventListener(MouseEvent.MOUSE_UP, sliderHandler);
		}
		
		if(!_timer.running) _slider.gotoAndStop( _slider.contains(DisplayObject(e.target)) ? e.type : 0 );
	}
	
	private function trackHandler(e : MouseEvent) : void
	{
		if(e.type == MouseEvent.MOUSE_DOWN)
		{
			var pageMove : Function = (e.localY < _slider.y) ?  pageUp : pageDown;
			// Primero un delay suficientemente largo por si el usuario solo quiere desplazarse una página
			_track_timer = new Timer(_repeatDelay);
			_track_timer.addEventListener(TimerEvent.TIMER, function():void
			{
				pageMove();
				// Se reduce el tiempo si el usuario ha dejado presionado el botón del mouse
				_track_timer.delay = _trackDelay;
			});
			_track_timer.start();
			
			pageMove();
		}
		else
		{
			if(_track_timer) _track_timer.reset();
		}
	}
	
	private function arrowHandler(e : MouseEvent) : void
	{
		if( (e.type == MouseEvent.MOUSE_DOWN && _buttonBehavior == ButtonBehavior.PRESS) ||
			(e.type == MouseEvent.MOUSE_OVER && _buttonBehavior == ButtonBehavior.ROLL) )
		{
			var lineMove : Function = (e.target.name.indexOf("up") != -1) ? lineUp : lineDown;
			// Primero un delay suficientemente largo por si el usuario solo quiere desplazarse una página
			_arrow_timer = new Timer( _buttonBehavior == ButtonBehavior.PRESS ? _repeatDelay : _arrowDelay );
			_arrow_timer.addEventListener(TimerEvent.TIMER, function():void
			{
				lineMove();
				// Se reduce el tiempo si el usuario ha dejado presionado el botón del mouse
				_arrow_timer.delay = _arrowDelay;
			});
			_arrow_timer.start();
			
			lineMove();
		}
		else if((e.type == MouseEvent.MOUSE_UP && _buttonBehavior == ButtonBehavior.PRESS) ||
				(e.type == MouseEvent.MOUSE_OUT && _buttonBehavior == ButtonBehavior.ROLL) )
		{
			if(_arrow_timer) _arrow_timer.reset();
		}
		
		// onReleaseOutside trick
		if( e.type == MouseEvent.MOUSE_DOWN) _slider.stage.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);
		if( e.type == MouseEvent.MOUSE_UP) _slider.stage.removeEventListener(MouseEvent.MOUSE_UP, arrowHandler);
		
		// Coloca el fotograma del botón en el estado actual
		if( (_movie.up_mc && e.target == _movie.up_mc) || (_movie.down_mc && e.target == _movie.down_mc) )
		{
			if(e.target.currentLabel == "mouseDown")
			{
				if(e.type == MouseEvent.MOUSE_UP) e.target.gotoAndStop( e.type );
			}
			else
			{
				e.target.gotoAndStop( e.type );
			}
		}
		else
		{
			// El evento se ha disparado fuera de los botones
			if(_movie.up_mc) _movie.up_mc.gotoAndStop( 0 );
			if(_movie.down_mc) _movie.down_mc.gotoAndStop( 0 );
		}
	}
	
	private function wheelHandler(e : MouseEvent) : void
	{
		if(!_enabled) return;
		
		_slider.y -= _lineScrollSize * e.delta;
		checkSliderPosition();
	}

	private function keyHanlder(e :KeyboardEvent) : void
	{
	    if(	e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN ||
	    	e.keyCode == Keyboard.PAGE_UP || e.keyCode == Keyboard.PAGE_DOWN ||
	    	e.keyCode == Keyboard.HOME || e.keyCode == Keyboard.END)
			{
				checkSliderPosition(true);
			}
	}
	
	
	/**
	 * Establece el área de desplazamiento del deslizador
	 */
	private function setScrollBarBounds() : void
	{
		_scrollbar_bounds = new Rectangle(0, _track.y, 0, _track.height-_slider.height);
	}

	/**
	 * Comprueba que el deslizador no se salga de los límites de la guía, y si se indica lo resitúa según la posición del texto.
	 */
	private function checkSliderPosition(calculateSliderY :Boolean = false) : void
	{
		if(calculateSliderY)
		{
			_slider.y = _lineScrollSize * (_textField.scrollV+1);
			if(_textField.scrollV == 1) _slider.y = 0;
		}
		
		if(_slider.y < _scrollbar_bounds.y) _slider.y = _scrollbar_bounds.y;
		if(_slider.y > _scrollbar_bounds.y+_scrollbar_bounds.height) _slider.y = _scrollbar_bounds.y+_scrollbar_bounds.height;
		
		dispatchEvent(new Event(Event.CHANGE));
	}
}
}