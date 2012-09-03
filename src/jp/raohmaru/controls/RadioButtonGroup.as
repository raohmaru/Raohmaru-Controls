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
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * La clase RadioButtonGroup define un grupo de controles RadioButton para que actúen como un solo control. Sólo se puede seleccionar un botón de
 * opción del mismo grupo.<br>
 * Cuando un control RadioButton es seleccionado por el usuario, dispara un evento <code>Event.CHANGE</code>.
 * @example
<listing version="3.0">
import jp.raohmaru.controls.RadioButton;
import jp.raohmaru.controls.RadioButtonGroup;

var rbg : RadioButtonGroup = new RadioButtonGroup("condimento");
	rbg.addEventListener(Event.CHANGE, groupHandler);

var rb1 : RadioButton = new RadioButton(test1_rb, "Con sal", 1, rbg);
	rb1.addEventListener(Event.SELECT, rbHandler);

var rb2 : RadioButton = new RadioButton(test2_rb, "Con azúcar", 2, rbg);
	rb2.addEventListener(Event.SELECT, rbHandler);

function groupHandler(e : Event) : void
{
	trace(e.target.name, e.target.selectedData);
}

function rbHandler(e : Event) : void
{
	trace(e.target.name, e.target.label, e.target.value);
}
</listing> 
 * @author raohmaru
 * @version 1.0.1
 */
public class RadioButtonGroup extends EventDispatcher 
{
	private var _name : String,
				_selection : RadioButton,
				_list : Array;

	/**
	 * Obtiene o define el nombre del objeto RadioButtonGroup. 
	 */
	public function get name() : String
	{
		return _name;
	}
	public function set name(value : String) : void
	{
		_name = value;
	}
	
	/**
	 * Obtiene o define una referencia al control seleccionado en el grupo de RadioButton. La propiedad <code>selected</code> del control seleccionado pasa a ser
	 * <code>true</code>, y <code>false</code> la del resto de controles del grupo. Es recomendable usar este atributo para seleccionar un RadioButton en lugar
	 * de RadioButton.selected.
	 * @example
	<listing version="3.0">
	import jp.raohmaru.controls.RadioButton;
	import jp.raohmaru.controls.RadioButtonGroup;
	
	var rbg : RadioButtonGroup = new RadioButtonGroup("noticias");
	
	var rb1 : RadioButton = new RadioButton(si_rb, "Sí", true, rbg);	
	var rb2 : RadioButton = new RadioButton(no_rb, "No", false, rbg);
	
	rbg.selection = rb1;
	</listing> 
	 */
	public function get selection() : RadioButton
	{
		return _selection;
	}
	public function set selection(value : RadioButton) : void
	{
		_selection = value;
		dispatchEvent(new Event(Event.CHANGE));
	}	
	
	/**
	 * Obtiene la propiedad <code>value</code> del RadioButton seleccionado. Si no hay seleccionado ningún control, esta propiedad será null. 
	 */
	public function get selectedData() : Object
	{
		return (_selection ? _selection.value : null);
	}
	
	/**
	 * Define la propiedad <code>value</code> y selecciona el RadioButton correspondiente. 
	 */
	public function set selectedData(value :Object) : void
	{
		var founded :RadioButton;
				
		for(var i:int=0; i<_list.length; i++) 
		{
			if(RadioButton(_list[i]).value == value)
			{
				founded = _list[i];
				break;
			}
		}
		
		if(founded)	selection = founded;
	}
	
	/**
	 * Obtiene el número de controles de este grupo. 
	 */
	public function get numRadioButtons() : int
	{
		return _list.length;
	}			
	
	
	
	/**
	 * Crea una nueva instancia de RadioButtonGroup. Esta acción se suele realizar automáticamente al crear una instancia de RadioButton.
	 * @param name El nombre del grupo
	 */
	public function RadioButtonGroup(name : String)
	{
		_name = name;
		_list = new Array();
	}
	
	/**
	 * Añade un botón de opción a la matriz interna de botones de opción. Este método se invoca automáticamente al crear un control RadioButton.
	 * @param radioButton Instancia RadioButton que se añade al grupo
	 */
	public function addRadioButton(radioButton : RadioButton) : void
	{
		_list.push(radioButton);
	}
	
	/**
	 * Recupera el componente RadioButton en la ubicación de índice especificada.
	 * @param index Índice del componente RadioButton
	 */
	public function getRadioButtonAt(index : int) : RadioButton
	{
		return (_list[index]) ? _list[index] : null;
	}
}
}