import std.stdio;
import std.format;
import std.concurrency;

import core.thread.threadgroup;

import dtk.miscs.Channel;

// more documentation
// https://tour.dlang.org/tour/en/multithreading/synchronization-sharing

void prt(string s)
{
    synchronized
    {
        writeln(s);
    }
}

void sf1(shared(Channel!int) c)
{
    while(true)
    {
        int r = c.pull();
        prt("pull: %s".format(r));
        if (r == 101)
        {
            prt("pull: exiting");
            break;
        }
    }
}

void sf2(shared(Channel!int) c, int x)
{
    prt("push: %s".format(x));
    c.push(x);
}

void main()
{
    shared (Channel!int) c = new shared (Channel!int)();

    auto t = spawn(&sf1, c);

    Tid[] tids;

    for (int i = 0; i != 100; i++)
    {
        auto tt = spawn(&sf2, c, i);

        tids ~= tt;
    }

    c.push(101);
}