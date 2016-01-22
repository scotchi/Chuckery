#include (MidiHandler)

class Control
{
    -1 => int cc;
    -1 => int channel;

    ControlDispatcher.register(this);

    fun void set(int value)
    {
        <<< "Control Changed: ", cc, ", ", value >>>;
    }
}

class ControlEvent extends Event
{
    int control;
    int value;
}

class EventControl extends Control
{
    ControlEvent changed;

    fun void set(int value)
    {
        cc => changed.control;
        value => changed.value;
        changed.broadcast();
    }
}

class ControlNode
{
    ControlNode @ next;
    Control @ item;
}

class ControlList
{
    static ControlNode @ first;
    static ControlNode @ last;

    fun void append(Control control)
    {
        if(first == null)
        {
            new ControlNode @=> first;
            first @=> last;
            control @=> first.item;
        }
        else
        {
            new ControlNode @=> last.next;
            last.next @=> last;
            control @=> last.item;
        }
    }
}

class ControlDispatcher extends MidiHandler
{
    static ControlList @ controls;

    fun void controlChange(int channel, int control, int value)
    {
        if(controls == null)
        {
            return;
        }

        controls.first @=> ControlNode @ node;

        while(node != null)
        {
            if(node.item.cc == control &&
               (node.item.channel == channel || node.item.channel == -1))
            {
                node.item.set(value);
            }
            node.next @=> node;
        }
    }

    fun static void register(Control control)
    {
        if(controls == null)
        {
            new ControlList @=> controls;
        }

        controls.append(control);
    }
}
