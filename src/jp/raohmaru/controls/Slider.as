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
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;

import jp.raohmaru.controls.events.DragEvent;

/**
 * Se distribuye mientras el usuario va arrastrando el deslizador y la propiedad <code>position</code> cambia.
 * @eventType jp.raohmaru.events.DragEvent.DRAG
 */
[Event(name="dragDrag", type="jp.raohmaru.events.DragEvent") ]

/**
 * Se distribuye cuando el usuario pulsa el botón del ratón y empiza a arrastrar el deslizador.
 * @eventType jp.raohmaru.events.DragEvent.DRAG_START
 */
[Event(name="dragStart", type="jp.raohmaru.events.DragEvent") ]

/**
 * Se distribuye cuando el usuario suelta el botón del ratón y cancela el arrastre.
 * @eventType jp.raohmaru.events.DragEvent.DRAG_STOP
 */
[Event(name="dragStop", type="jp.raohmaru.events.DragEvent") ]

/**
 * Se distribuye cuando el usuario ha finalizado de arrastrar el deslizador o cuando cambia la propiedad <code>position</code> sin que el deslizador sea arrastrado.
 * @eventType jp.raohmaru.events.DragEvent.DRAG_CHANGE
 */
[Event(name="dragChange", type="jp.raohmaru.events.DragEvent") ]

/**
 * El control Slider permite al usuario seleccionar un valor moviendo el deslizador entre los extremos de la guía de desplazamiento.
 * @example
<listing version="3.0">
import jp.raohmaru.controls.Slider;
import jp.raohmaru.events.DragEvent;

var slider = new Slider(slider_mc);
	slider.trackEnabled = true;
	slider.addEventListener(DragEvent.DRAG_START, sliderHandler);
	slider.addEventListener(DragEvent.DRAG, sliderHandler);
	slider.addEventListener(DragEvent.DRAG_STOP, sliderHandler);
	slider.addEventListener(DragEvent.DRAG_CHANGE, sliderHandler);
	
function sliderHandler(e : DragEvent) : void
{
	trace(e.type, e.position);
}
</listing>
 * @author raohmaru
 * @version 1.1
 */
public class Slider extends Control 
{
	private var slider : MovieClip,
				track : MovieClip,
				bar :MovieClip,
				
				_trackEnabled :Boolean = false,
				_minimun :Number = 0,
				_maximum :Number = 1,
				_snapInterval : Number = 0,
				_tickInterval :Number = 0,
				_tick :Class,
				
				_bounds :Rectangle,
				_dragging :Boolean = false,
				_old_position :Number,
				_snap :Number = 0,
				_fraction_digits :uint = 3,
				_tick_container :DisplayObjectContainer;

	/**
	 * Obtiene o define el valor actual del control Slider. Este valor viene determinado por la posición del control deslizante entre los valores mínimo y máximo.
	 * <br>El valor devuelto es un valor de coma flotante definido por <code>precision</code>, o si se ha definido <code>snapInterval</code> un valor afín.
	 * @see #precision
	 */
	public function get position() : Number
	{
		var _x :Number = (slider.x-_bounds.x) / _bounds.width;
		_x = _x*(_maximum-_minimun) + _minimun;
		
		return Number( _x.toFixed(_fraction_digits) );
	}
	public function set position(value :Number) : void
	{
		if(value < _minimun)		value = _minimun;
		else if(value > _maximum)	value = _maximum;
		
		value = (_bounds.width*(value-_minimun)) / (_maximum-_minimun) + _bounds.x;
		
		updatePosition(value);
	}

	/**
	 * Obtiene o define si la guía puede pulsarse para situar el deslizador en el punto señalado por el cursor.
	 * @default false
	 */
	public function get trackEnabled() : Boolean
	{
		return _trackEnabled;
	}	
	public function set trackEnabled(value : Boolean) : void
	{
		if(_trackEnabled == value) return;
		
		_trackEnabled = value;		

		track.buttonMode = value;
		track.mouseChildren = !value;
		
		track[value ? 'addEventListener' : 'removeEventListener'](MouseEvent.MOUSE_UP, trackHandler);
	}
	
	/**
	 * Valor mínimo permitido.
	 * @default 0
	 */
	public function get minimun() : Number
	{
		return _minimun;
	}	
	public function set minimun(value : Number) : void
	{
		_minimun = value;
	}	
	
	/**
	 * Valor máximo permitido.
	 * @default 1
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.Slider;
	import jp.raohmaru.events.DragEvent;
	
	var slider = new Slider(slider_mc);
		slider.minimun = 5;		slider.maximum = 25;		slider.addEventListener(DragEvent.DRAG_CHANGE, sliderHandler);
	
	function sliderHandler(e : DragEvent) : void
	{
		trace(e.position);  // Devolverá un valor entre 5 y 25
	}
	</listing>
	 */
	public function get maximum() : Number
	{
		return _maximum;
	}	
	public function set maximum(value : Number) : void
	{
		_maximum = value;
	}

	/**
	 * Obtiene o define el incremento que el valor aumenta o disminuye cuando el usuario mueve el deslizador.
	 * @default 0
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.Slider;
	import jp.raohmaru.events.DragEvent;
	
	var slider = new Slider(slider_mc);
		slider.maximum = 10;		slider.snapInterval = 2;
		slider.addEventListener(DragEvent.DRAG_CHANGE, sliderHandler);
	
	function sliderHandler(e : DragEvent) : void
	{
		trace(e.position);  // Devolverá un valor entre 0 y 10 en incrementos de 2 (0, 2, 4...)
	}
	</listing>
	 */
	public function get snapInterval() : Number
	{
		return _snapInterval;
	}	
	public function set snapInterval(n : Number) : void
	{
		_snapInterval = n;
		_fraction_digits = (n-Math.floor(n) != 0) ? n.toString().split(".")[1].length : 0;
		setSnap();
	}
	
	/**
	 * Name of the class to use as the skin for the ticks.
	 * @default SliderTick
	 */
	public function get tickSkin() : Class
	{
		return _tick;
	}	
	public function set tickSkin(c : Class) : void
	{
		_tick = c;
	}

	/**
	 * Espaciado de las marcas de verificación. Se muestran cuando el valor es distinto de <code>0</code>.
	 * @default 0
	 */
	public function get tickInterval() : Number
	{
		return _tickInterval;
	}	
	public function set tickInterval(value : Number) : void
	{
		_tickInterval = value;
		
		if(_tick_container)
		{
			_movie.removeChild(_tick_container);
			_tick_container = null;
		}
		
		if(value != 0)
		{
			_tick_container = DisplayObjectContainer( _movie.addChild(new Sprite) );
			
			var dteX :Number = Math.abs( _bounds.width / ((maximum-minimun)/_snapInterval) ),
				_x :Number = dteX,
				tick :Sprite;
			
			while(_x < _bounds.width)
			{
				if(_tick != null)
					tick = new _tick();
				else
				{
					if(ApplicationDomain.currentDomain.hasDefinition('SliderTick'))
					{
						tick = new (Class(getDefinitionByName('SliderTick')))
					}
					else
					{
						tick = new Sprite();
						tick.graphics.lineStyle(1);
						tick.graphics.lineTo(0, track.height);
					}
				}
				tick.x = Math.round( _bounds.x + _x );
				tick.y = track.y;
				
				_x += dteX;
				
				_tick_container.addChild(tick);
			}
		}
	}
	
	/**
	 * @private
	 */
	override public function get width() : Number
	{
		return track.width;
	}
	override public function set width(value : Number) : void
	{
		track.width = value;
		setBounds();
		setSnap();
		tickInterval = tickInterval;
	}	
	
	/**
	 * @private
	 */
	override public function get height() : Number
	{
		return track.height;
	}
	override public function set height(value : Number) : void
	{
		var offsetY :Number = value - track.height;
		track.height = value;
		bar.height = value;
		slider.y += offsetY;
	}
	
	/**
	 * Un entero entre 0 y 20, ambos inclusive, que representa el número deseado de cifras decimales al obtener el valor <code>position</code>.
	 * @default 3
	 * @see #position
	 */
	public function get precision() : uint
	{
		return _fraction_digits;
	}	
	public function set precision(value :uint) : void
	{
		_fraction_digits = value;
	}
	

	/**
	 * Crea una instancia del control Slider.
	 * @param movie Objeto MovieClip que es la representación gráfica del control 
	 */
	public function Slider(movie : MovieClip)
	{
		super(movie);
	}
	
	override protected function init() : void
	{
		slider = _movie.slider_mc;
		track = _movie.track_mc;
		
		bar = _movie.bar_mc;
		bar.width = 0;
		bar.mouseChildren = false;
		bar.mouseEnabled = false;
		
		slider.buttonMode = true;
		slider.mouseChildren = false;
		slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_OVER, sliderHandler);
		slider.addEventListener(MouseEvent.MOUSE_OUT, sliderHandler);
		
		setBounds();
	}
	
	
	private function sliderHandler(e : MouseEvent) : void
	{
		if(e.type == MouseEvent.MOUSE_DOWN)
		{
			_movie.stage.addEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			_movie.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			_dragging = true;
			
			dispatchDragEvent(DragEvent.DRAG_START);
		}
		else if(e.type == MouseEvent.MOUSE_UP)
		{	
			_movie.stage.removeEventListener(MouseEvent.MOUSE_UP, sliderHandler);
			_movie.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			_dragging = false;
			
			dispatchDragEvent(DragEvent.DRAG_STOP);
			dispatchDragEvent(DragEvent.DRAG_CHANGE);
		}
		
		// Evitamos que vaya al fotograma mouseOut cuando aun se esta arrastrando el deslizador pero el cursor ha salido del sprite
		if(_dragging && (e.type == MouseEvent.MOUSE_OUT || e.type == MouseEvent.MOUSE_OVER)) return;
		
		slider.gotoAndStop(e.type);
	}

	private function trackHandler(e : MouseEvent) : void
	{
		updatePosition(_movie.mouseX);
	}
	
	private function mouseMoveHandler(e : MouseEvent) : void
	{
		updatePosition(_movie.mouseX, false);
		
		var new_pos :Number = position;
		if(_old_position != new_pos)
		{
			_old_position = new_pos;
			dispatchDragEvent(DragEvent.DRAG);
		}
	}

	
	private function dispatchDragEvent(type :String) :void
	{
		dispatchEvent(new DragEvent(type, position, 0, 0));
	}
	
	private function updatePosition(x :Number, dispatch :Boolean = true) :void
	{
		x -= _bounds.x;
		
		if(_snapInterval != 0)
		{
			// Situa el deslizador en el valor más próximo según el valor de incremento snapInterval
			var approx :Number = 0;
			while(approx < x) approx += _snap;
			x = _bounds.x + ((Math.abs(approx-x) < Math.abs(approx-_snap-x)) ? approx : approx-_snap);
		}
		
		if(x < _bounds.x) x = _bounds.x;
		if(x > _bounds.right) x = _bounds.right;
		
		slider.x = x;
		bar.width = x - _bounds.x;
		
		if(dispatch) dispatchDragEvent(DragEvent.DRAG_CHANGE);
	}
	
	/**
	 * Establece el área de desplazamiento del deslizador
	 */
	private function setBounds() : void
	{
		_bounds = new Rectangle(track.x, slider.y, track.width, 0);
	}
	
	/**
	 * Establece la distancia entre las posiciones del deslizador para cada valor según el incremento <code>snapInterval</code>.
	 */
	private function setSnap() : void
	{
		_snap = Math.abs( _bounds.width / ((maximum-minimun)/_snapInterval) );
	}
}
}