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
import flash.text.TextField;
import flash.utils.getDefinitionByName;

import jp.raohmaru.controls.Control;

/**
 * The ComboBox control contains a drop-down list from which the user can select one value.
 *
 * @author raohmaru
 * @version 1.0
 */
public class ComboBox extends Control 
{
	private var _label :TextField,
				_mask :Sprite,				_mask_content :Sprite,
				_sb :ScrollBar,
				_bot :MovieClip,
				_back :MovieClip,
				_content :Sprite,
				_dropdown :Sprite,
				
				// Accesors
				_row_count :uint,
				_selected_index :int = -1,
				_prompt :String = "",
				
				// Props
				_item_h :Number,
				_mask_w :Number,
				_data :Array = [],
				_opened :Boolean,
				_item_clicked :Boolean,
				_item_class :Class;

	public function get rowCount() :uint
	{
		return _row_count;
	}	
	public function set rowCount(value :uint) :void
	{
		if(value < 3) value = 3;
		_row_count = value;
		
		_sb.height = _item_h * _row_count;
		
		// TODO Máscara ajustable al número de items
		var masks :Array = [_mask, _mask_content],
			m :Sprite;
		
		for(var i:int=0; i<masks.length; i++) 
		{
			m = masks[i];
			m.graphics.clear();
			m.graphics.beginFill(0);
			m.graphics.drawRect(0, 0, _mask_w - (i==1 ? 1 : 0), _item_h*_row_count);
			m.graphics.endFill();
		}
	}

	public function get scrollBar() :ScrollBar
	{
		return _sb;
	}
	
	public function get label() :TextField
	{
		return _label;
	}
	
	public function get length() :uint
	{
		return _data.length;
	}
	
	public function get selectedIndex() :int
	{
		return _selected_index;
	}	
	public function set selectedIndex(value :int) :void
	{
		if(value < -1 || value > length-1) return;
		
		if(_selected_index > -1)
		{
			var item :MovieClip = _content.getChildAt(_selected_index) as MovieClip;
			item.back_mc.gotoAndStop(1);
		}
			
		_selected_index = value;
		
		if(_selected_index > -1)
		{
			var it :MovieClip = MovieClip(_content.getChildAt(_selected_index));
				it.back_mc.gotoAndStop("mouseDown");
			if(!_item_clicked && _sb.visible)		
				_sb.position = _content.getChildAt(_selected_index).y;
		}
		
		_label.text = (_selected_index > -1) ? _data[_selected_index].label : _prompt;
		
		dispatchEvent(new Event(Event.CHANGE));
	}

	public function get selectedItem() :Object
	{
		return (_selected_index > -1) ? _data[_selected_index] : null;;
	}	
	public function set selectedItem(value :Object) :void
	{
		var item :Object = checkItemData(value),
			founded :Boolean;
				
		for(var i:int=0; i<_data.length; i++) 
		{
			if(_data[i].label == item.label && _data[i].data == item.data)
			{
				founded = true;
				break;
			}
		}
		
		if(founded)	selectedIndex = i;
	}

	public function get prompt() :String
	{
		return _prompt;
	}	
	public function set prompt(value :String) :void
	{
		_prompt = value;
		if(_selected_index == -1)
			_label.text = _prompt;
	}

	public function get text() :String
	{
		return _label.text;
	}	
	public function set text(value :String) :void
	{
		_label.text = value;
	}
	
	public function get value() :*
	{
		return (_selected_index > -1) ? _data[_selected_index].data : null;
	}
	public function set value(value :Object) :void
	{
		var founded :Boolean;
				
		for(var i:int=0; i<_data.length; i++) 
		{
			if(_data[i].data == value)
			{
				founded = true;
				break;
			}
		}
		
		if(founded)	selectedIndex = i;
	}
	
	/**
	 * @private
	 */
	override public function get width() : Number
	{
		return _back.width;
	}
	/**
	 * @private
	 */
	override public function set width(value : Number) : void
	{
		_back.width = value;
		_bot.x = _back.width - _bot.width;		_label.width = _bot.x - _label.x;
		
		_mask_w = value;
		rowCount = rowCount;
		_sb.width = value;
		
		value -= 1;
		var it :MovieClip;
		for(var i:int=0; i<_content.numChildren; i++) 
		{
			it = _content.getChildAt(i) as MovieClip;
			it.back_mc.width = value;
			it.label_tf.width = value - it.label_tf.x - _sb.width;
		}
	}
	
	/**
	 * @private
	 */
	override public function get height() : Number
	{
		return _back.height;
	}
	/**
	 * @private
	 */
	override public function set height(value : Number) : void
	{
		_back.height = value;		_bot.height = value;
		_label.y = int( value/2 - _label.height/2 );
		
		_mask.y = _mask_content.y = _sb.y = value;
	}
	
	public function get rowHeight() : Number
	{
		return _item_h;
	}	
	public function set rowHeight(value : Number) : void
	{
		_item_h = value;
		rowCount = rowCount;
		
		var it :MovieClip;
		for(var i:int=0; i<_content.numChildren; i++) 
		{
			it = _content.getChildAt(i) as MovieClip;
			it.y = i * _item_h;
			it.back_mc.height = value;
			it.label_tf.y = int( value/2 - it.label_tf.height/2 );
		}
	}
	
	public function get dropdown() :Sprite
	{
		return _dropdown;
	}
		
	/**
	 * Name of the class to use as the skin for the items of the combobox.
	 * @default ComboBoxItem
	 */
	public function get itemSkin() : Class
	{
		return _item_class;
	}	
	public function set itemSkin(c : Class) : void
	{
		_item_class = c;
	}
	
	
	public function ComboBox(movie :MovieClip)
	{
		super(movie);
	}
	
	/**
	 * @private
	 */
	override protected function init() : void
	{
		super.init();
		
		_movie.buttonMode = true;
		
		_label = _movie.label_tf;
		_label.mouseEnabled = false;
		
		_bot = _movie.bot_mc;
		_bot.mouseEnabled = false;
		
		_back = _movie.back_mc;
		_back.mouseEnabled = false;
		
		var item :MovieClip = _item_class != null ? new _item_class() : new (Class(getDefinitionByName('ComboBoxItem')));
		_item_h = item.back_mc.height;
		
		_mask = new Sprite();
		_mask_w = _movie.mask_mc.width;
		_mask.x = _movie.mask_mc.x;
		_mask.y = _movie.mask_mc.y;
		_mask.scaleY = 0;
		_movie.removeChild(_movie.mask_mc);
		
		_mask_content = new Sprite();
		_mask_content.x = _mask.x;		_mask_content.y = _mask.y;		_mask_content.scaleY = 0;
		_movie.addChild(_mask_content);
		
		_content = new Sprite();
		_content.y = _mask.y;
		_content.mask = _mask_content;
		_movie.addChildAt(_content, 0);
		
		_sb = new ScrollBar(_movie.sb);
		_sb.target = _content;
		_sb.sliderResize = true;
		_sb.linked = true;
		_sb.useMouseArea = false;
		
		// Añade los elementos de la lista a un contenedor 
		_dropdown = new Sprite();
		_dropdown.addChild(Sprite(_sb.content).parent.parent);		_dropdown.addChild(_mask_content);		_dropdown.addChild(_sb.movie);		_dropdown.addChild(_mask);
		_dropdown.filters = _movie.filters;
		
		_sb.movie.mask = _mask;
		
		rowCount = 5;
		
		if(_movie.scaleX != 1)
		{
			var w :Number = _movie.width;
			_movie.scaleX = 1;
			width = w;
		}
		if(_movie.scaleY != 1)
		{
			var h :Number = _movie.height;
			_movie.scaleY = 1;
			height = h;
		}
	}



	public function addItem(item :Object) :uint
	{
		var it :MovieClip = createItem( _data.push( checkItemData(item) )-1 );
		_content.addChild(it);
		_sb.update();
		_sb.lineScrollSize = 40/_data.length;		
		return _data.length;
	}
	
	public function getItemAt(index :uint) :Object
	{
		return _data[index];
	}
	
	public function open() :void
	{
		_mask.scaleY = 1;
		_mask_content.scaleY = 1;
		
		_bot.gotoAndStop("mouseDown");
		_back.gotoAndStop("mouseDown");
			
		_opened = true;
		_movie.mouseChildren = true;
		
		var rect :Rectangle = _movie.getRect(_movie.stage);		
		_dropdown.x = Math.round(rect.x);		_dropdown.y = Math.round(rect.y);
		_movie.stage.addChild(_dropdown);
		
		dispatchEvent(new Event(Event.OPEN));
	}
	public function close() :void
	{
		_mask.scaleY = 0;
		_mask_content.scaleY = 0;
		if(_dropdown.parent)
			_movie.stage.removeChild(_dropdown);
		
		_bot.gotoAndStop(1);
		_back.gotoAndStop(1);
		
		_opened = false;
		_movie.mouseChildren = false;
		_movie.stage.removeEventListener(MouseEvent.MOUSE_UP, pressHandler);
		dispatchEvent(new Event(Event.CLOSE));
	}
	
	public function reset() :void
	{
		if(_selected_index > -1)
		{
			var item :MovieClip = _content.getChildAt(_selected_index) as MovieClip;
			item.back_mc.gotoAndStop(1);
		}
		
		_selected_index = -1;		
		_label.text = _prompt;		
		_sb.reset();
	}
	
	
	
	private function createItem(index :int) :MovieClip
	{
		var item :MovieClip = _item_class != null ? new _item_class() : new (Class(getDefinitionByName('ComboBoxItem')));		
			item.y = index * _item_h;
			item.index = index;
			item.label_tf.text = _data[index].label;
			item.back_mc.stop();
			item.back_mc.width = _back.width;
			item.back_mc.height = _item_h;
			item.label_tf.width = _back.width - item.label_tf.x - _sb.width;
			item.label_tf.y = int( _item_h/2 - item.label_tf.height/2 );
		
		item.buttonMode = true;
		item.mouseChildren = false;
		item.addEventListener(MouseEvent.MOUSE_DOWN, itemHandler);
		item.addEventListener(MouseEvent.MOUSE_UP, itemHandler);
		item.addEventListener(MouseEvent.MOUSE_OVER, itemHandler);
		item.addEventListener(MouseEvent.MOUSE_OUT, itemHandler);
			
		return item;
	}
	
	private function checkItemData(item :Object) :Object
	{
		if(item != null)
		{
			if(item.hasOwnProperty("label"))
			{
				if(item.hasOwnProperty("data")) return item;
				return { label:String(item.label), data:item.label };
			}
			else if(item.hasOwnProperty("data"))
			{
				return { label:String(item.data), data:item.data };
			}
			
			return { label:String(item), data:item };
		}
		return {label:"", data:null};
	}
	
	

	/**
	 * @private
	 */
	override protected function pressHandler(e :MouseEvent) :void
	{
		if(e.target == _movie)
		{
			if(e.type == MouseEvent.MOUSE_DOWN)
			{				
				_movie.stage.addEventListener(MouseEvent.MOUSE_UP, pressHandler);
			}
			else if(e.type == MouseEvent.MOUSE_UP)
			{
				if(e.currentTarget != _movie.stage)
				{
					if(!_opened)
						open();
					else
						close();
				}
				
				//_movie.stage.addEventListener(MouseEvent.MOUSE_UP, pressHandler);
			}
		}
		else if( !_movie.contains(DisplayObject(e.target)) && !_dropdown.contains(DisplayObject(e.target)) )
		{
			close();
		}
		
		super.pressHandler(e);
	}
	
	/**
	 * @private
	 */
	override protected function overHandler(e : MouseEvent) : void
	{
		if(!_opened)
		{		
			_bot.gotoAndStop(e.type);
			_back.gotoAndStop(e.type);
		}
	}

	private function itemHandler(e :MouseEvent) : void
	{		
		if(e.type == MouseEvent.MOUSE_UP)
		{
			_item_clicked = true;
			selectedIndex = e.target.index;
			_item_clicked = false;
			close();
		}
		else
		{
			if(e.target.index == _selected_index && (e.type == MouseEvent.MOUSE_OVER || e.type == MouseEvent.MOUSE_OUT))
				return;
			e.target.back_mc.gotoAndStop(e.type);
		}
	}
}
}