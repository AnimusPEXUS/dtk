module dtk.types.Color;

import std.format;

struct Color
{
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;

    this(ubyte[3] rgb)
    {
        this([rgb[0], rgb[1], rgb[2], 0], true);
    }

    this(ubyte[4] rgba, bool is_rgba = true)
    {
        if (is_rgba)
        {
            r = rgba[0];
            g = rgba[1];
            b = rgba[2];
            a = rgba[3];
        }
        else
        {
            a = rgba[0];
            r = rgba[1];
            g = rgba[2];
            b = rgba[3];
        }
    }

    this(uint rgba, bool is_rgba = true)
    {
        if (rgba > 0xffffff)
        {
            if (is_rgba)
            {
                r = (rgba & 0xff000000) / 0x1000000;
                g = (rgba & 0x00ff0000) / 0x10000;
                b = (rgba & 0x0000ff00) / 0x100;
                a = rgba & 0x000000ff;
            }
            else
            {
                a = (rgba & 0xff000000) / 0x1000000;
                r = (rgba & 0x00ff0000) / 0x10000;
                g = (rgba & 0x0000ff00) / 0x100;
                b = rgba & 0x000000ff;
            }
        }
        else
        {
            r = (rgba & 0xff0000) / 0x10000;
            g = (rgba & 0x00ff00) / 0x100;
            b = rgba & 0x0000ff;
            a = 0;
        }
    }

    string String()
    {
        return format("r: %x g: %x b: %x a: %x\n", r, g, b, a,);
    }

    ubyte[3] rgb_ubyte_3()
    {
        return [r, g, b];
    }

    uint rgb_uint()
    {
        uint ret;
        *(cast(ubyte[4]*)(&ret)) = cast(ubyte[4])[cast(ubyte) 0, r, g, b];
        return ret;
    }

    ubyte[4] rgba_ubyte4()
    {
        return [r, g, b, a];
    }

    ubyte[4] argb_ubyte4()
    {
        return [a, r, g, b];
    }

    uint rgba_uint()
    {
        uint ret;
        *(cast(ubyte[4]*)(&ret)) = cast(ubyte[4])[r, g, b, a];
        return ret;
    }

    uint argb_uint()
    {
        uint ret;
        *(cast(ubyte[4]*)(&ret)) = cast(ubyte[4])[a, r, g, b];
        return ret;
    }

    Color add(Color other)
    {
        Color ret;
        ret.r = cast(ubyte)(this.r + other.r);
        ret.g = cast(ubyte)(this.g + other.g);
        ret.b = cast(ubyte)(this.b + other.b);
        return ret;
    }

    Color sub(Color other)
    {
        Color ret;
        ret.r = cast(ubyte)(this.r - other.r);
        ret.g = cast(ubyte)(this.g - other.g);
        ret.b = cast(ubyte)(this.b - other.b);
        return ret;
    }

    Color mul(Color other)
    {
        Color ret;
        ret.r = cast(ubyte)(this.r * other.r);
        ret.g = cast(ubyte)(this.g * other.g);
        ret.b = cast(ubyte)(this.b * other.b);
        return ret;
    }

    Color div(Color other)
    {
        Color ret;
        ret.r = cast(ubyte)(this.r / other.r);
        ret.g = cast(ubyte)(this.g / other.g);
        ret.b = cast(ubyte)(this.b / other.b);
        return ret;
    }

}
