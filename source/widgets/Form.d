// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import dtk.interfaces.FormI;

import dtk.types.Size;

class Form : FormI
{
    private
    {
        /* bool _visible; */
        Size _size;
    }

    void Resize(uint width, uint height)
    {

    }

    /* @property void visible(bool value)
    {
        _visible = value;
    }

    @property bool visible()
    {
        return _visible;
    } */
}
