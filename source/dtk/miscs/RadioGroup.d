// for radio button switch automatization

module dtk.miscs.RadioGroup;

import std.typecons;

import dtk.widgets;

class RadioGroup
{
    public {
        ButtonRadio[] buttons;
    }

    void add(ButtonRadio b)
    {
        foreach (v;buttons)
            if (v == b)
                return;
        buttons ~= b;
    }

    void remove(ButtonRadio b)
    {
        for (int i = cast(int)buttons.length-1; i != -1; i += -1)
            if (buttons[i] == b)
                buttons = buttons[0 .. i] ~ buttons[i+1 .. $];
    }

    void selectButton(ButtonRadio b)
    {
        foreach (v;buttons)
            v.setChecked(v == b);
    }

    ButtonRadio getSelectedButton()
    {
        foreach (v;buttons)
            if (v.getChecked())
                return v;
        return cast(ButtonRadio)null;
    }

}
