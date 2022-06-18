module dtk.types.Size2D;

struct Size2D
{
    int width;
    int height;
    /* int depth; */

    invariant
    {
        assert(width >= 0);
        assert(height >= 0);
    }

    Size2D sub(Size2D size)
    {
        return Size2D(width - size.width, height - size.height);
    }

    Size2D add(Size2D size)
    {
        return Size2D(width + size.width, height + size.height);
    }
}
