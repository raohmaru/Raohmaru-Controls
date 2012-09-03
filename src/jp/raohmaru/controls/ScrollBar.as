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
import flash.events.*;
import flash.display.*;
import flash.utils.Timer;
import flash.geom.Rectangle;
import jp.raohmaru.controls.enums.ButtonBehavior;
import jp.raohmaru.controls.enums.ScrollBarMove;

/**
 * Se distribuye cuando cambia la propiedad <code>position</code> de la instancia de ScrollBar.
 * @eventType flash.events.Event.CHANGE
 * @see #position
 */
[Event(name="change", type="flash.events.Event") ]

/**
 * El control ScrollBar genera una barra deslizable para controlar la parte de datos que se muestra cuando hay demasiada información para ajustar
 * en el área de visualización.
 * @example
<listing version="3.0">
import jp.raohmaru.controls.ScrollBar;

var sb : ScrollBar = new ScrollBar(sb_mc);
sb.target = scrollcontent_mc;
</listing>
 * @author raohmaru
 * @version 1.0.8
 */
public class ScrollBar extends Control
{
	// UI
	private var slider : MovieClip,
				track : MovieClip,
				up_bot : MovieClip,
				down_bot : MovieClip,
				container : MovieClip,
				mask : DisplayObject,
				content_mc : MovieClip,
				area : DisplayObject;
	// Props	
	private var _scrollbar_bounds : Rectangle,
				_track_timer : Timer,
				_arrow_timer : Timer,
				_scroll_height : Number,
				_numPages : uint,
				_pageScrollSize : Number,
				_content_no_mc :Boolean,				_dragY :Number = -1;

	// Accesors
	private var _linked : Boolean = false,
				_antialiasing : Boolean = false,
				_lineScrollSize : Number = 5,
				_sliderResize : Boolean = false,
				_buttonBehavior : String = ButtonBehavior.PRESS,
				_mouseWheelEnabled : Boolean,
				_trackEnabled : Boolean,
				_repeatDelay : uint = 250,
				_trackDelay : uint = 100,
				_arrowDelay : uint = 50,
				_easing :Boolean;

	/**
	 * Establece el contenedor o el contenido a desplazar. En caso que sea un contenedor, éste ha de incluir un clip de película de nombre "mask_mc" y otro
	 * de nombre "content_mc". Si es un contenido a desplazar, se generará un contenedor con la máscara y dicho contenido en el mismo lugar y profundidad
	 * que el contenido; la máscara tendrá el ancho del contenido y el alto de la barra de scroll.
	 * Si el contenido a desplazar no es un MovieClip, la propiedad <code>linked</code> se establecerá a <code>true</code>;
	 * @see linked
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.ScrollBar;
	
	var sb : ScrollBar = new ScrollBar(sb_mc);
	sb.target = content_mc;
	</listing>
	 */
	public function set target(value :DisplayObject) :void
	{
		_content_no_mc = false;
		
		// Si el target ya contiene una máscara y un contenido...
		if(value is MovieClip && MovieClip(value).mask_mc && MovieClip(value).content_mc)
		{
			container = MovieClip(value);
			mask = MovieClip(value).mask_mc;
			content_mc = MovieClip(value).content_mc;
		}
		else
		{		
			// Añade un contenedor en el lugar donde está el target
			container = MovieClip( value.parent.addChildAt(new MovieClip(), value.parent.getChildIndex(value)) );
			container.x = value.x;
			container.y = value.y;
			
			// Sitúa el target dentro del contenedor
			if(!(value is MovieClip))
			{
				value.x = 0;				value.y = 0;
				var mc :MovieClip = new MovieClip();
					mc.addChild( value.parent.removeChild(value));
				content_mc = MovieClip( container.addChild( mc ) );
				_linked = true;
				_content_no_mc = true;
			}
			else
				content_mc = MovieClip( container.addChild( value.parent.removeChild(value) ) );
			
			content_mc.x = 0;
			content_mc.y = 0;
			
			// Crea la máscara
			var w :Number = getContentRect().width;
			if(w == 0) w = _movie.x - container.x + track.width;
			var h :Number = getContentRect().height;
			if(h == 0) h = track.height;
			
			var mask_rect : Shape = new Shape();
		        mask_rect.graphics.beginFill(0xFFCC00);
		        mask_rect.graphics.drawRect(0, 0, w, h);
		        mask_rect.graphics.endFill();
				
			mask = container.addChild(mask_rect);
			
			container.mask = mask;
		}
		
		// Crea un área en el contenedor para que permita ejecutar eventos de ráton sobre él
		var area_rect : Shape = new Shape();
	        area_rect.graphics.beginFill(0, 0);
	        area_rect.graphics.drawRect(mask.x, mask.y, mask.width, mask.height);
	        area_rect.graphics.endFill();
		area = container.addChildAt(area_rect, 0);
		
		mouseWheelEnabled = true;
		
		update();
	}
	
	/**
	 * Define o obtiene si la barra de scroll y el contenido están vinculados; en ese caso, cambiar las dimensiones con <code>height</code> o <code>width</code>
	 * afectará a ambos, en lugar de sólo a la barra de scroll.
	 * @default = false
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.ScrollBar;
	
	var sb : ScrollBar = new ScrollBar(sb_mc);
	sb.target = content_mc;
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
	 * Indica si el contenido debe situarse únicamente en coordenadas enteras para evitar el aliasing en los campos de texto. Esto sobretodo afecta a fuentes
	 * con el suvizado desactivado, cuando el campo de texto se situa en un valor decimal (como 0.6).
	 * @default false
	 */
	public function get antialiasing() : Boolean
	{
		return _antialiasing;
	}	
	public function set antialiasing(value : Boolean) : void
	{
		_antialiasing = value;
	}	
	
	/**
	 * Obtiene o define un valor que representa el incremento que el contenido se desplaza al presionar en un botón de flecha.
	 * @default 5
	 */
	public function get lineScrollSize() : Number
	{
		return _lineScrollSize;
	}	
	public function set lineScrollSize(value : Number) : void
	{
		_lineScrollSize = value;
	}	
	
	/**
	 * Obtiene o define un valor que representa el incremento que el contenido se desplaza al presionar sobre la guía.
	 * Este valor se genera automáticamente según la altura del contenido. 
	 */
	public function get pageScrollSize() : Number
	{
		return _pageScrollSize;
	}	
	public function set pageScrollSize(value : Number) : void
	{
		_pageScrollSize = value;
	}
	
	/**
	 * Indica si el deslizador debe redimensionarse respecto a la cantidad de desplazamiento disponible, esto es, cuanto más datos a desplazar más pequeño será
	 * el deslizador.
	 * @default false
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
	 * Indica si el contenido puede desplazarse con la rueda del ratón.
	 * @default true
	 */
	public function get mouseWheelEnabled() : Boolean
	{
		return _mouseWheelEnabled;
	}	
	public function set mouseWheelEnabled(value : Boolean) : void
	{
		if(!container) return;
		if(value && container.hasEventListener(MouseEvent.ROLL_OVER)) return;
		
		_mouseWheelEnabled = value;		
		
		container[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.ROLL_OVER, containerHandler);
		container[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.ROLL_OUT, containerHandler);
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

		track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_DOWN, trackHandler);
		track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_UP, trackHandler);
		track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_OUT, trackHandler);
	}
	
	/**
	 * Obtiene una referencia al contenido desplazable.
	 */
	public function get content() :DisplayObject
	{
		return (!_content_no_mc) ? content_mc : content_mc.getChildAt(0);
	}
	
	/**
	 * Define o obtiene la altura de la barra de scroll. Si <code>linked</code> es verdadero, entonces también define la altura del contenido
	 * (<code>content_height</code>).
	 * @see #linked
	 */
	override public function set height(value : Number) : void
	{
		track.height = value;
		if(up_bot) track.height -= up_bot.height;		if(down_bot)
		{
			track.height -= down_bot.height;
			down_bot.y = Math.round( track.y + track.height );
		}
		setScrollBarBounds();
		
		
		if(_linked)
		{
			content_height = value;
		}
		else
		{
			update();
		}
	}
	
	/**
	 * Define o obtiene la anchura de la barra de scroll. Si <code>linked</code> es verdadero, entonces define la anchura del conjunto <code>content</code> 
	 * más barra de scroll.
	 * @see #linked
	 */
	override public function set width(value : Number) : void
	{
		if(!_linked)
		{
			slider.width = value;
			track.width = value;
			if(up_bot) up_bot.width = value;
			if(down_bot) down_bot.width = value;
		}
		else
		{
			var dteX : Number = _movie.x - (container.x + content_width);
			content_width = value;
			_movie.x = container.x + content_width + dteX;
		}
	}
	
	/**
	 * Define o obtiene la altura de contenido desplazable.
	 */
	public function get content_height() : Number
	{
		return mask.height;
	}
	public function set content_height(value : Number) : void
	{
		if(!mask) return;
		
		mask.height = area.height = value;
		update();
	}
	
	/**
	 * Define o obtiene la anchura de contenido desplazable.
	 */
	public function get content_width() : Number
	{
		return mask.width;
	}
	public function set content_width(value : Number) : void
	{
		mask.width = area.width = value;
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
	* Obtiene o define la posición de desplazamiento actual y actualiza la posición del deslizador.
	*/
	public function get position() : Number
	{
		return Math.abs(content_mc.y);
	}	
	public function set position(value : Number) : void
	{
		moveSlider( _scrollbar_bounds.y + (value * _scrollbar_bounds.height) / Math.abs(_scroll_height) );
	}
	
	/**
	 * @private
	 */
	override public function set enabled(value : Boolean) : void
	{
		super.enabled = value;
		_movie.alpha = value ? 1 : .5;
	}
	
	/**
	 * @private
	 */
	override public function get x() : Number
	{
		return (linked) ? Math.min(_movie.x, container.x) : _movie.x;
	}
	/**
	 * @private
	 */
	override public function set x(value : Number) : void
	{
		if(linked)
		{
			if(container.x < _movie.x)
			{
				_movie.x += value - container.x;
				container.x = value;
			}
			else
			{
				container.x += value - _movie.x;
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
		return (linked) ? Math.min(_movie.y, container.y) : _movie.y;
	}
	/**
	 * @private
	 */
	override public function set y(value : Number) : void
	{
		if(linked)
		{
			if(container.y < _movie.y)
			{
				_movie.y += value - container.y;
				container.y = value;
			}
			else
			{
				container.y += value - _movie.y;
				_movie.y = value;
			}
		}
		else
		{
			_movie.y = value;
		} 
	}

	/**
	 * Define si el control usará una área de refuerzo para detectar el evento de ratón MouseEvent.MOUSE_WHEEL.
	 * Cuando el usuario sitúe el cursor encima del contenido desplazable ésta área, un objeto Shape invisible con las dimensiones del contenido,
	 * servirá para detectar el evento de una manera más eficiente. 
	 * @default true
	 */
	public function get useMouseArea() :Boolean
	{
		return container.contains(area);
	}	
	public function set useMouseArea(value :Boolean) :void
	{
		if(value)
		{
			if(!container.contains(area))
				container.addChildAt(area, 0);
		}
		else
		{
			if(container.contains(area))
				container.removeChild(area);
		}
	}
	
	/**
	 * Define si debe utilizarse una ecuación de movimiento para representar el desplazamiento del contenido.
	 * La ecuación por defecto es <code>Quad.easeOut</code>.
	 * @default false
	 */
	public function get easing() :Boolean
	{
		return _easing;
	}	
	public function set easing(value :Boolean) :void
	{
		_easing = value;
	}
	

	
	/**
	 * Crea una nueva instancia de ScrollBar. Por defecto se puede clicar en la guía y está activado el evento de rueda de ratón. Si el objeto MovieClip
	 * contiene además dos instancias de nombre "up_mc" y "down_mc", se activarán los botones de desplazamiento de flecha.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 */
	public function ScrollBar(movie : MovieClip)
	{
		super(movie);
	}
	
	override protected function init() : void
	{
		slider = _movie.slider_mc;
		track = _movie.track_mc;
		
		slider.buttonMode = true;
		slider.mouseChildren = false;
		slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_OVER, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_OUT, sliderHandler);
		
		trackEnabled = true;
		
		// Si scrollbar_mc tiene un botón de desplazamiento hacia arriba o hacia abajo
		if(_movie.up_mc)
		{
			up_bot = _movie.up_mc;
			up_bot.buttonMode = true;
			up_bot.mouseChildren = false;
			up_bot.addEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);			up_bot.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);			up_bot.addEventListener(MouseEvent.MOUSE_OVER, arrowHandler);			up_bot.addEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		if(_movie.down_mc)
		{
			down_bot = _movie.down_mc;
			down_bot.buttonMode = true;
			down_bot.mouseChildren = false;
			down_bot.addEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);
			down_bot.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);
			down_bot.addEventListener(MouseEvent.MOUSE_OVER, arrowHandler);
			down_bot.addEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		
		
		setScrollBarBounds();
	}
	
	/**
	 * Actualiza la barra de scroll y verifica que sea necesario mostrarlo (si hay contenido suficiente que desplazar). Se llama automáticamente
	 * al cambiar la altura del contenido o al establecer un <code>target</code>.<br>
	 * Debe invocarse cada vez que se cambie el contenido del scroll.
	 */
	public function update() : void
	{
		if(!mask) return;
		
		if(_sliderResize)
		{
			slider.height = Math.round( (mask.height * track.height) / getContentRect().height );
			if(slider.height < 10) slider.height = 10;
			setScrollBarBounds();
		}
		
		_scroll_height = mask.height - getContentRect().height;	
		_numPages = Math.ceil(Math.abs(_scroll_height) / mask.height);
		_pageScrollSize = Math.round(_scrollbar_bounds.height/_numPages);
		
		// ¿Es necesario el scroll?
		var is_scrollable : Boolean = (_scroll_height < 0);
		//_movie[is_scrollable ? 'addEventListener' : 'removeEventListener'](Event.ENTER_FRAME, updateContentPosition);
		_movie.visible = is_scrollable;
		
		if(is_scrollable)
			updateContentPosition();
		else
			reset();
		
		if(_mouseWheelEnabled)
		{
			if(is_scrollable)
			{
				if(!container.hasEventListener(MouseEvent.ROLL_OVER))
					mouseWheelEnabled = true;
			}
			else
			{
				mouseWheelEnabled = false;
				_mouseWheelEnabled = true;
			}
		}
	}
	
	private function updateContentPosition(e :Event = null) : void
	{
		if(_dragY != -1)
		{
			slider.y = _movie.mouseY - _dragY;
			if(slider.y < _scrollbar_bounds.y) slider.y = _scrollbar_bounds.y;			else if(slider.y > _scrollbar_bounds.bottom) slider.y = _scrollbar_bounds.bottom;
		}
		
		var newY : Number = (_scroll_height*(slider.y-_scrollbar_bounds.y)) / _scrollbar_bounds.height;
		if(_antialiasing) newY = Math.round(newY);
		
		if(_easing)
		{
//			if(content_mc.y != newY)
//				Paprika.add(content_mc, .3, {y:newY}, Quad.easeOut);
			content_mc.y = newY;
		}
		else
			content_mc.y = newY;		
		
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	private function moveSlider(newY : Number) : void
	{
		if(newY < _scrollbar_bounds.y) newY = _scrollbar_bounds.y;
		if(newY > _scrollbar_bounds.y+_scrollbar_bounds.height) newY = _scrollbar_bounds.y+_scrollbar_bounds.height;
		
		slider.y = newY;
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
	import jp.raohmaru.controls.ScrollBar;
	import jp.raohmaru.controls.ScrollBarMove;
	
	var sb : ScrollBar = new ScrollBar(sb_mc);
	sb.target = scrollcontent_mc;
	sb.goto(ScrollBarMove.BOTTOM); // Desplaza el scroll al límite inferior
	sb.goto(ScrollBarMove.LINE_UP); // Desplaza el scroll una línea hacia arriba (es igual que la llamada ScrollBar.lineUp())
	</listing>
	 */
	public function goto(target : Object) : void
	{
		if(target is String)
		{
			switch(target) 
			{
				case ScrollBarMove.PAGE_UP :
					moveSlider( slider.y - _pageScrollSize );
					break;
					
				case ScrollBarMove.PAGE_DOWN :
					moveSlider( slider.y + _pageScrollSize );
					break;
					
				case ScrollBarMove.LINE_UP :
					moveSlider( slider.y - _lineScrollSize );
					break;
					
				case ScrollBarMove.LINE_DOWN :
					moveSlider( slider.y + _lineScrollSize );
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
	 * Desplaza el scroll una página hacia arriba.
	 */
	public function pageUp() : void
	{
		goto(ScrollBarMove.PAGE_UP);
	}
	
	/**
	 * Desplaza el scroll una página hacia abajo.
	 */
	public function pageDown() : void
	{
		goto(ScrollBarMove.PAGE_DOWN);
	}
	
	/**
	 * Desplaza el scroll una línea hacia arriba.
	 */
	public function lineUp() : void
	{
		goto(ScrollBarMove.LINE_UP);
	}
	
	/**
	 * Desplaza el scroll una línea hacia abajo.
	 */
	public function lineDown() : void
	{
		goto(ScrollBarMove.LINE_DOWN);
	}

	/**
	 * Resetea el control, situando en la parte superior el deslizador y el contenido desplazable.
	 */
	public function reset() : void
	{
		slider.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
		slider.y = _scrollbar_bounds.y;
		updateContentPosition();
	}
	
	/**
	 * Detiene el control y elimina todo comportamiento. Es aconsejable utlizar <code>ScrollBar.kill</code> antes de eliminar del escenario el control.
	 */
	public function kill() :void
	{
		mouseWheelEnabled = false;		trackEnabled = false;
		
		slider.removeEventListener(MouseEvent.MOUSE_DOWN, sliderHandler);
		slider.removeEventListener(MouseEvent.MOUSE_UP, sliderHandler);
		slider.removeEventListener(MouseEvent.MOUSE_OVER, sliderHandler);
		slider.removeEventListener(MouseEvent.MOUSE_OUT, sliderHandler);
		
		if(_movie.up_mc)
		{
			up_bot.removeEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);
			up_bot.removeEventListener(MouseEvent.MOUSE_UP, arrowHandler);
			up_bot.removeEventListener(MouseEvent.MOUSE_OVER, arrowHandler);
			up_bot.removeEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		if(_movie.down_mc)
		{
			down_bot.removeEventListener(MouseEvent.MOUSE_DOWN, arrowHandler);
			down_bot.removeEventListener(MouseEvent.MOUSE_UP, arrowHandler);
			down_bot.removeEventListener(MouseEvent.MOUSE_OVER, arrowHandler);
			down_bot.removeEventListener(MouseEvent.MOUSE_OUT, arrowHandler);
		}
		
		_movie.removeEventListener(Event.ENTER_FRAME, updateContentPosition);
		if(slider.stage)
		{
			slider.stage.removeEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			slider.stage.removeEventListener(MouseEvent.MOUSE_UP, arrowHandler);
		}
		
		container.removeEventListener(MouseEvent.MOUSE_WHEEL, containerHandler);
		
		container = null;
		mask = null;
		content_mc = null;
		area = null;
	}
	
	
	
	private function sliderHandler(e : MouseEvent) : void
	{
		if(e.type == MouseEvent.MOUSE_DOWN)
		{
			// startDrag() no funciona en objetos rotados con rotationX del API de Flash
			//slider.startDrag(false, _scrollbar_bounds);
			_dragY = _movie.mouseY - slider.y;
			_movie.addEventListener(Event.ENTER_FRAME, updateContentPosition);
			// onReleaseOutside trick
			slider.stage.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			slider.gotoAndStop(e.type);
			
			container.mouseChildren = false;
		}
		else if(e.type == MouseEvent.MOUSE_UP)
		{
			//slider.stopDrag();
			_dragY = -1;
			_movie.removeEventListener(Event.ENTER_FRAME, updateContentPosition);
			updateContentPosition();
			// onReleaseOutside trick
			if(slider.stage)
				slider.stage.removeEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			
			container.mouseChildren = true;
		}
		
		if(!_movie.hasEventListener(Event.ENTER_FRAME)) slider.gotoAndStop( slider.contains(DisplayObject(e.target)) ? e.type : 0 );
	}
	
	private function trackHandler(e : MouseEvent) : void
	{
		if(e.type == MouseEvent.MOUSE_DOWN)
		{
			var pageMove : Function = (_movie.mouseY < slider.y) ?  pageUp : pageDown;
			// Primero un delay suficientemente largo por si el usuario solo quiere desplazarse una página
			_track_timer = new Timer(_repeatDelay);
			_track_timer.addEventListener(TimerEvent.TIMER, function():void
			{
				pageMove();
				// Se reduce el tiempo si el usuario ha dejado presionado el botón del mouse
				_track_timer.delay = _trackDelay;
			}, false, 0, true);
			_track_timer.start();
			
			pageMove();
		}
		else
		{
			if(_track_timer)
			{
				_track_timer.reset();
				_track_timer = null;
			}
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
			}, false, 0, true);
			_arrow_timer.start();
			
			lineMove();
		}
		else if((e.type == MouseEvent.MOUSE_UP && _buttonBehavior == ButtonBehavior.PRESS) ||
				(e.type == MouseEvent.MOUSE_OUT && _buttonBehavior == ButtonBehavior.ROLL) )
		{
			if(_arrow_timer)
			{
				_arrow_timer.reset();
				_arrow_timer = null;
			}
		}
		
		// onReleaseOutside trick
		if( e.type == MouseEvent.MOUSE_DOWN) slider.stage.addEventListener(MouseEvent.MOUSE_UP, arrowHandler);		if( e.type == MouseEvent.MOUSE_UP) slider.stage.removeEventListener(MouseEvent.MOUSE_UP, arrowHandler);
		
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
			if(_movie.up_mc) _movie.up_mc.gotoAndStop( 0 );			if(_movie.down_mc) _movie.down_mc.gotoAndStop( 0 );
		}
	}
	
	private function containerHandler(e : MouseEvent) : void
	{
		if(!_enabled) return;
		
		if(e.type == MouseEvent.MOUSE_WHEEL)
		{
			// Desplaza el deslizador una página arriba o abajo al mover la rueda del ratón.
			if(e.delta > 0)
				pageUp();
			else
				pageDown();
		}
		else
		{		
			container[(e.type==MouseEvent.ROLL_OVER) ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_WHEEL, containerHandler);
		}
	}
	
	
	
	
	/**
	 * Establece el área de desplazamiento del deslizador
	 */
	private function setScrollBarBounds() : void
	{
		_scrollbar_bounds = new Rectangle(0, track.y, 0, track.height-slider.height);
	}
	
	/**
	 * Obtiene las dimensiones máximas del contenido del scroll (es necesario pq cuando hay campos de texto el contenedor da dimensiones altura errónea).
	 * @return Un objeto Rectangle con las dimensiones correctas
	 */
	private function getContentRect() : Rectangle
	{
		var content_h : Number = 0,
			content_w : Number = 0,
			temp_h : Number,
			temp_w : Number,
			bounds : Rectangle;
			
		for(var i:int=0; i<content_mc.numChildren; i++)
		{
			bounds = content_mc.getChildAt(i).getBounds(content_mc);
			temp_h = temp_w = 0;
			
			if(bounds.height > 0)
			{
				temp_h = bounds.y + bounds.height;
				if(temp_h > content_h) content_h = temp_h;
			}
			
			if(bounds.width > 0)
			{
				temp_w = bounds.x + bounds.width;
				if(temp_w > content_w) content_w = temp_w;
			}
		}
		
		return new Rectangle(0, 0, content_w, content_h);
	}
}
}