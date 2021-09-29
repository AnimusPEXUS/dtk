module dtk.types.Image;

import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Color;

struct ImageDot
{
    Color color;
}

class Image // : DrawingSurfaceI // TODO: enable DrawingSurfaceI
{
    uint width;
    uint height;
    ImageDot[] data;

    this(uint width, uint height)
    {
        this.width = width;
        this.height = height;
        this.data = new ImageDot[](width*height);
    }

    typeof(this) setEach(ImageDot new_value)
    {
        for (uint i = 0; i != data.length; i++)
        {
            data[i] = new_value;
        }
        return this;
    }

    typeof(this) setDot(uint x, uint y, ImageDot new_value)
    {
        this.data[y*width+x] = new_value;
        return this;
    }

    ImageDot getDot(uint x, uint y)
    {
        return this.data[y*width+x];
    }

    ref ImageDot getDotRef(uint x, uint y)
    {
        return this.data[y*width+x];
    }

}
