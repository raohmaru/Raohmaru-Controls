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
 * La clase ScrollBarMove es una enumeración de valores constantes que indican una cantidad y dirección de movimiento para un control ScrollBar.
 * @see ScrollBar
 * @author raohmaru
 * @version 1.0
 */
public class ScrollBarMove 
{
	/**
	 * Indica un desplazamiento hacia arriba de una página.
	 */
	public static const PAGE_UP : String = "scroll_page_up";
	/**
	 * Indica un desplazamiento hacia abajo de una página.
	 */
	public static const PAGE_DOWN : String = "scroll_page_down";
	/**
	 * Indica un desplazamiento hacia arriba de una línea.
	 */
	public static const LINE_UP : String = "scroll_line_up";
	/**
	 * Indica un desplazamiento hacia abajo de una línea.
	 */
	public static const LINE_DOWN : String = "scroll_line_down";
	/**
	 * El limite superior de desplazamiento de la barra de scroll.
	 */
	public static const TOP : String = "scroll_top";
	/**
	 * El limite inferior de desplazamiento de la barra de scroll.
	 */
	public static const BOTTOM : String = "scroll_bottom";
}
}