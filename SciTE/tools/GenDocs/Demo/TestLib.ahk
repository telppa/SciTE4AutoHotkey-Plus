/*!
	Library: Test library
		This library does something
		
		or maybe not!  
		In-paragraph line breaks work
	Author: fincs
	License: WTFPL
	Version: 1.0
*/

/*!
	Page: Test Page
	Filename: TestPage
	Contents: @file:TestPage.md
*/

/*!
	Function: something(a, b [, c])
		something() does something :)

	Parameters:
		a - Something
		    > MsgBox Yay, this works?! ; comment!
		b - Something else
		c - (Optional) Even more stuff

	Remarks:
		Meow.

	Returns:
		Dinner, really :)

	Extra:
		### It looks like everybody's been taken to Tykogi Tower!
		Oh, my!

	Throws:
		Stuff if stuff
*/

something(a, b, c="")
{
}

/*!
	Class: MyClass
		Provides an interface to *dinner*
	Inherits: OtherClass
	Example: @file:TestExample.ahk
*/

class MyClass extends OtherClass
{
	/*!
		Constructor: (a)
			Creates a MyClass object.
		Parameters:
			a - Something
	*/
	__New(a)
	{
	}
	
	/*!
		Method: Hello()
			Displays hello world message.
	*/
	Hello()
	{
	}
	
	__Get(m, p*)
	{
		return this["get_" m](p*)
	}

	__Set(m, ByRef v, p*)
	{
		return this["set_" m](v, p*)
	}
	
	/*!
		Property: Something [get/set]
			It's the something of a something
		Value:
			The something to set
		Remarks:
			Automagically dinner
	*/
	
	get_Something()
	{
	}
	
	set_Something(ByRef v)
	{
	}
	
	/*!
		Class: Meow
			What do you want me to do?!?!
		@UseShortForm
		Example:
			> MsgBox Meow example ; Testing
	*/
	class Meow
	{
		/*!
			Method: Hello([msg])
				Displays a greeting message.
			Parameters:
				msg - (Optional) The message to display. Defaults to "Hello, world!".
			Returns: Absolutely nothing :)
			Throws: Again, nothing :)
		*/
		Hello(msg="Hello, world!")
		{
			MsgBox, % msg
		}
		
		/*!
			Class: MoreNesting
				Nesting is so much fun!
			Example:
				> MsgBox MoreNesting example ; Testing
		*/
		
		class MoreNesting
		{
			/*!
				Property: HasDinner [get]
					Does this object have dinner?
			*/
			__Get(m)
			{
				if m = HasDinner
					return true
			}
		}
		
		/*!
			End of class
		*/
	}
	/*!
		End of class
	*/

	/*!
		Class: InnerCls
			This time it's dinnerish!
		@UseShortForm
	*/
	class InnerCls
	{
		/*!
			Constructor: (params...)
			Parameters:
				params - The parameters to use to create the object.
			Throws: I have no clue!
		*/
		__New(prm*)
		{
		}
	}
	/*!
		End of class
	*/
}

/*!
	End of class
*/
