// MIDI Event IDs

int codes[0];

144 => codes["NoteOn"];
128 => codes["NoteOff"];
176 => codes["ControlChange"];

class MidiMessage
{
    fun int[] data()
    {
        return [ 0, 0, 0 ];
    }
}

class StatusMessage extends MidiMessage
{
    int id;
    1 => int channel;
}

class NoteMessage extends StatusMessage
{
    int pitch;
    int velocity;

    fun int[] data()
    {
        return [ id + channel - 1, pitch, velocity ];
    }
}

class NoteOnMessage extends NoteMessage
{
    codes["NoteOn"] => id;
    100 => velocity;
}

class NoteOffMessage extends NoteMessage
{
    codes["NoteOff"] => id;
    0 => velocity;
}

class ControlChangeMessage extends StatusMessage
{
    codes["ControlChange"] => id;
    1 => int control;
    127 => int value;

    fun int [] data()
    {
        return [ id + channel - 1, control, value ];
    }
}

class MidiHandler
{
    // Members

    MidiIn midiIn;
    MidiOut midiOut;

    false => int local;
    false => int isOpen;

    fun void open(int inputDevice, int outputDevice)
    {
        if(isOpen)
        {
            return;
        }

        // Constructor

        if(!midiIn.open(inputDevice))
        {
            <<< "Could not open MIDI input device." >>>;
            me.exit();
        }

        if(!midiOut.open(outputDevice))
        {
            <<< "Could not open MIDI output device." >>>;
            me.exit();
        }

        true => isOpen;
    }

    fun void send(MidiMessage message)
    {
        open(0, 0);

        message.data() @=> int data[];

        if(data.cap() == 3)
        {
            MidiMsg out;

            data[0] => out.data1;
            data[1] => out.data2;
            data[2] => out.data3;

            if(local)
            {
                handleMessage(out);
            }
            else
            {
                midiOut.send(out);
            }
        }
        else
        {
            <<< "Invalid data() for MidiMessage." >>>;
        }
    }

    fun void sendNote(int channel, int pitch, int velocity, dur length)
    {
        NoteOnMessage on;
        velocity => on.velocity;
        pitch => on.pitch;
        channel => on.channel;
        
        send(on);
        
        length => now;
        
        NoteOffMessage off;
        
        pitch => off.pitch;
        channel => off.channel;
        
        send(off);
    }


    fun void sendControlChange(int channel, int control, int value)
    {
        new ControlChangeMessage @=> ControlChangeMessage m;
        channel => m.channel;
        control => m.control;
        value => m.value;
        send(m);
    }

    fun void sendControlOn(int channel, int control)
    {
        sendControlChange(channel, control, 127);
    }

    fun void sendControlOff(int channel, int control)
    {
        sendControlChange(channel, control, 0);
    }

    fun void run()
    {
        open(0, 0);

        // Now handle incoming events.

        MidiMsg message;

        while(true)
        {
            midiIn => now;

            while(midiIn.recv(message))
            {
                handleMessage(message);
            }
        }
    }

    fun int isChannel(int code, int base)
    {
        if(code >= base && code < base + 16)
        {
            return code - base + 1;
        }
        return 0;
    }

    fun void handleMessage(MidiMsg message)
    {
        message.data1 => int code;

        if(isChannel(code, codes["NoteOn"]))
        {
            spork ~ noteOn(isChannel(code, codes["NoteOn"]), message.data2, message.data3);
        }
        else if(isChannel(code, codes["NoteOff"]))
        {
            spork ~ noteOff(isChannel(code, codes["NoteOff"]), message.data2, message.data3);
        }
        else if(isChannel(code, codes["ControlChange"]))
        {
            spork ~ controlChange(isChannel(code, codes["ControlChange"]), message.data2, message.data3);
        }
        else
        {
            <<< "Unhandled MIDI Message: ", message.data1, message.data2, message.data3 >>>;
        }
    }

    fun void noteOn(int channel, int pitch, int velocity)
    {
        <<< "Note On: ", channel, pitch, velocity >>>;
    }

    fun void noteOff(int channel, int pitch, int velocity)
    {
        <<< "Note Off: ", channel, pitch, velocity >>>;
    }

    fun void controlChange(int channel, int control, int value)
    {
        <<< "Control Change: ", channel, control, value >>>;
    }
}
