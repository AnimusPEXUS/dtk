/// documentation test 3
module dtk.interfaces.ContainerableI;

/++
 documentation test 2
+/

import dtk.interfaces.WidgetI;
import dtk.interfaces.ContainerI;

/// cool interface
interface ContainerableI // : WidgetI
{
	 typeof(this) setParent(ContainerI container);
	 typeof(this) unsetParent();
	 ContainerI getParent();
	 void propagatePosAndSizeRecalc();
	 
	 static foreach (v; ["X", "Y", "Width", "Height"])
	 {
	 	 import std.format;
	 	 mixin(
	 	 	 q{
	 	 	 	 ulong get%1$s();
	 	 	 	 typeof(this) set%1$s(ulong v);
	 	 	 }.format(v)
	 	 	 );
	 }
}
