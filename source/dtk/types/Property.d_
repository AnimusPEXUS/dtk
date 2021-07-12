module dtk.types.Property;

import observable.signal;

class Property(T)
{
    private
    {
        T value;
        Signal!(Property!T) sig;
        bool single_entry_enabled;
    }

    /* @disable this(this); */
    this(T init_value)
    {
        value = init_value;
        // sig =
    }

    @property T opCall()
    {
        return value;
    }

    @property opCall(T new_value)
    {
        if (single_entry_enabled)
            return;
        single_entry_enabled = true;
        scope (exit)
            single_entry_enabled = false;
        value = new_value;
        sig.emit(this);
    }

    @property Signal!(Property!T) signal()
    {
        return sig;
    }

}
