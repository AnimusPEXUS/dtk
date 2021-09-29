module dtk.types.Image;

import dtk.types.Color;

struct ImageDot
{
    Color color;
}

struct Image
{
    uint width;
    uint height;
    ImageDot[] data;

    this(uint width, uint height)
    {
        this.width = width;
        this.height = height;
        for (uint i = 0; i != width*height+1; i++)
        {
            data ~= ImageDot();
        }
    }

    typeof(this) setEach(ImageDot new_value)
    {
        for (uint i = 0; i != width*height+1; i++)
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

}
