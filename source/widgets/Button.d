// Button Widget. used both freely on form or as ToolBar button
// there should not be separate radiobutton or checkbutton: this Button class
// should be visually transformed to such using it's properties.

class Button
{
    private
    {
        RadioGroup _radio_group;

        // this is used when button consissts in RadioGroup,
        // so you could use RadioGroup's getValue() function and get selected
        // value easily
        string _value;

        bool _switchable;
        ButtonTypeE _button_type;
    }
}
