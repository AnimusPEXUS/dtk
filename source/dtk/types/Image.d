module dtk.types.Image;

import std.stdio;

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
        if (x > width)
            throw new Exception("invalid x");
        if (y > height)
            throw new Exception("invalid y");
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

    void resize(uint width, uint height)
    {
        auto new_data = new ImageDot[](width*height);

        auto this_width = this.width;
        auto this_height = this.height;

        uint copy_width = (this_width > width ? width : this_width);
        uint copy_height = (this_height > height ? height : this_height);

        for (uint y = 0 ; y != copy_height; y++)
        {
            for (uint x = 0 ; x != copy_width; x++)
            {
                new_data[y*width+x] = this.data[y*this_width+x];
            }
        }

        this.data = new_data;
        this.width = width;
        this.height = height;
    }

    void putImage(uint x, uint y, Image new_image)
    {
        if (x > width)
            return;
        if (y > height)
            return;

        uint horizontal_copy_count = new_image.width;
        uint vertical_copy_count = new_image.height;

        if ((x+horizontal_copy_count) > width)
            horizontal_copy_count -= width - x;

        if ((y+vertical_copy_count) > height)
            vertical_copy_count -= height - y;

        for (uint y2 = 0; y2 != vertical_copy_count; y2++)
        {
            for (uint x2 = 0; x2 != horizontal_copy_count; x2++)
            {
                auto dot = new_image.getDot(x2,y2);
                setDot(x+x2,y+y2,dot);
            }
        }
    }

    void printImage()
    {
        for (uint y = 0; y != height; y++)
        {
            for (uint x = 0; x != width; x++)
            {
                if (getDot(x,y).color.r == 0)
                {
                    write(" ");
                }
                else
                {
                    write("*");
                }
            }
            writeln();
        }
        writeln();
    }

}
