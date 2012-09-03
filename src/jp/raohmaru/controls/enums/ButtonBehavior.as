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

package jp.raohmaru.controls.enums 
{

/**
 * La clase ButtonBehavior define el tipo de comportamiento para los botones de los controles.
 * @author raohmaru
 * @version 1.0
 */
public class ButtonBehavior 
{
	/**
	 * Define que los botones reaccionarán a los eventos del tipo <code>MouseEvent.MOUSE_UP</code> y <code>MouseEvent.MOUSE_DOWN</code>.
	 */
	public static const PRESS : String = "button_press";
	
	/**
	 * Define que los botones reaccionarán a los eventos del tipo <code>MouseEvent.MOUSE_OVER</code> y <code>MouseEvent.MOUSE_OUT</code>.
	 */
	public static const ROLL : String = "button_roll";
}
}