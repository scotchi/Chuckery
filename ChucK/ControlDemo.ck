#include (Control)

ControlDispatcher controller;

// Two demos here:  one with subclassing, one with events:

class FooControl extends Control
{
    1 => cc;

    fun void set(int value)
    {
        <<< "Foo: ", value >>>;
    }
}

FooControl foo;

// And now with events.

EventControl bar;
2 => bar.cc;

fun void listener()
{
    while(true)
    {
        bar.changed => now;
        <<< "Bar: ", bar.changed.value >>>;
    }
}

spork ~ listener();

// And now let's create some fake hardware controls to test things.

fun void fakeKnob()
{
    ControlChangeMessage message;

    1 => message.control;

    for(0 => int i; i < 10; i++)
    {
        i => message.value;
        controller.send(message);
        10::ms => now;
    }
}

fun void fakeButton()
{
    ControlChangeMessage message;

    2 => message.control;
    127 => message.value;

    controller.send(message);
}

spork ~ fakeKnob();
spork ~ fakeButton();

controller.run();
