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

/**
 * El control RadioButton permite obligar al usuario a seleccionar una opción de un conjunto de opciones. Este conjunto de opciones corresponde a un objeto
 * RadioButtonGroup que contienen uno o varios controles RadioButton.<br>
 * Cuando un control RadioButton es seleccionado por el usuario, dispara un evento <code>Event.SELECT</code>. Si se selecciona a través de código, sólo debería
 * ser a través del objeto RadioButtonGroup al que pertenece el control.
 * @example
<listing version="3.0">
import jp.raohmaru.controls.RadioButton;

var rb1 : RadioButton = new RadioButton(test1_rb, "Con sal", 1);
	rb1.addEventListener(Event.SELECT, rbHandler);
	
var rb2 : RadioButton = new RadioButton(test2_rb, "Con azúcar", 2, rb1.group);
	rb2.addEventListener(Event.SELECT, rbHandler);

function rbHandler(e : Event) : void
{
	trace(e.target.name, e.target.label, e.target.value);
}
</listing>
 * @see RadioButtonGroup
 * @author raohmaru
 * @version 1.1
 */
public class RadioButton extends CheckBox
{
	private var _group : RadioButtonGroup;

	/**
	 * Asigna o obtiene el grupo a que pertenece este control.
	 */
	public function get group() : RadioButtonGroup
	{
		return _group;
	}
	public function set group(rbg : RadioButtonGroup) : void
	{
		if(_group) _group.removeEventListener(Event.CHANGE, groupHandler);
		_group = rbg;
		_group.addEventListener(Event.CHANGE, groupHandler);
	}
	
	
	
	/**
	 * Crea una nueva instancia de la clase RadioButton. Si no se especifica un objeto RadioButtonGroup, automáticamente se creará uno para este control,
	 * al que se puede referenciar a través de <code>group</code>.
	 * @param movie Objeto MovieClip que es la representación gráfica del control
	 * @param label Etiqueta de texto del control
	 * @param value El valor asignado al control
	 * @param rbg El objeto RadioButtonGroup al que pertenece este control
	 */
	public function RadioButton(movie : MovieClip, label : String = null, value : Object = null, rbg : RadioButtonGroup = null)
	{
		super(movie, label, value);
		
		group = (rbg) ? rbg : new RadioButtonGroup("rbgroup");
		
		_group.addRadioButton(this);
	}

	/**
	 * @private
	 */
	override protected function onMouseUp(e :Event = null) : void
	{
		if(!selected) dispatchEvent(new Event(Event.SELECT));
		_group.selection = this;
	}
	
	private function groupHandler(e : Event) : void
	{
		_selected = (_group.selection == this);
		
		if(e)
		{
			_movie.selected_mc.visible = _selected;
			if(_selected)
				_movie.selected_mc.gotoAndPlay(1);
		}
		
		dispatchEvent(new Event(Event.CHANGE));
	}
}
}