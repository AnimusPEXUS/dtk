/++
Button Widget. used both freely on form or as ToolBar button
there should not be separate radiobutton or checkbutton: this Button class
should be visually transformed to such using it's properties.
+/

module dtk.widgets.Button;

import std.typecons;

import dtk.miscs.RadioGroup;
import dtk.interfaces.ContainerableWidgetI;
import dtk.interfaces.WidgetI;
import dtk.interfaces.FormI;

import dtk.types.ButtonTypeE;
import dtk.types.Size2D;

import dtk.widgets.mixins;
import dtk.widgets.Widget;

/// Button class
class Button : Widget, ContainerableWidgetI
{
    private
    {
        RadioGroup _radio_group;

        // this is used when button participates in RadioGroup,
        // so you could use RadioGroup's getValue() function and get selected
        // value easily
        // TODO: replace this with propery and name it RadioValue
        string _value;

        bool _switchable;
        ButtonTypeE _button_type;
    }


}
