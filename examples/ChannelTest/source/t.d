import std.stdio;
import std.format;
import std.concurrency;

import core.thread.threadgroup;

import dtk.miscs.Channel;

// more documentation
// https://tour.dlang.org/tour/en/multithreading/synchronization-sharing

const THREADS_NUMBER_TO_TEST = 1000;

void prt(string s)
{
    synchronized
    {
        writeln(s);
    }
}

void sf1(shared (Channel!int) c, Tid parentId)
{
    prt("sf1 entered");

    for (int i = 0; i != THREADS_NUMBER_TO_TEST; i++)
    {
        prt("pull: going to pull %drd value".format(i));
        int r = c.pull();
    }

    prt("sf1 loop ended");

    parentId.send(0);
}

void sf2(shared (Channel!int) c, int x)
{
    prt("push: %s".format(x));
    c.push(x);
}

void main()
{
    shared (Channel!int)  c = new shared (Channel!int)();

    shared int ret_sf1;

    spawn(&sf1, c, thisTid);

    for (int i = 0; i != THREADS_NUMBER_TO_TEST; i++)
    {
        spawn(&sf2, c, i);
        prt("spawned push #%d thread".format(i));
    }
    prt("   spawn push break");

    prt("waiting for pulling thread");

    receive(
        (int x) { ret_sf1 = x;}
    );

    prt("main exit (ret_sf1 %d)".format(ret_sf1));
}

// void prt(string s)
// {
//     synchronized
//     {
//         writeln(s);
//     }
// }

// void sf1(Channel!int c)
// {
//     while(true)
//     {
//         int r = c.pull();
//         prt("pull: %s".format(r));
//     }
// }

// void sf2(Channel!int c, int x)
// {
//     prt("push: %s".format(x));
//     c.push(x);
// }

// void main()
// {
//     __gshared Channel!int c = new Channel!int();

//     spawn(&sf1, c);

//     int i;
//     while(true)
//     {
//         spawn(&sf2, c, i);
//         i++;
//     }
// }