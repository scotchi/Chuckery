#include (MidiHandler)

class Controller extends MidiHandler
{
    130 => float beatsPerMinute;
    4 => int beatsPerMeasure;
    
    (60.0 * 1000.0) / beatsPerMinute => float msPerBeat;

    (msPerBeat * beatsPerMeasure)::ms => dur measure;

    int notes[0];

    0 => notes["Tempo"];
    
    int controls[0];

    29 => controls["Tempo"];

    fun void noteOn(int channel, int pitch, int velocity)
    {
        if(velocity > 0)
        {
            <<< "Control Note On: ", pitch >>>;
        
            if(pitch == notes["Tempo"])
            {
                fadeIn(controls["Tempo"], 4 * beatsPerMeasure);
            }
        }
    }

    fun void controlChange(int channel, int control, int value)
    {
        // We don't care
    }

    fun void fade(int control, int begin, int end, int beats)
    {
        100 => int steps;
        
        (beats * msPerBeat) / steps => float msPerStep;

        -1 => int lastControlValue;
        
        for(0 => int i; i <= steps; i++)
        {
            (((end $ float - begin $ float) / steps $ float)
            * i $ float + begin $ float) $ int => int controlValue;

            if(controlValue != lastControlValue)
            {
                ControlChangeMessage message;
                control => message.control;
                controlValue => message.value;
                controlValue => lastControlValue;

                send(message);

                // <<< "Fading Control: ", control, " Value: ", controlValue >>>;
            }

            msPerStep::ms => now;
        }
    }

    fun void fadeIn(int control, int beats)
    {
        fade(control, 0, 127, beats);
    }

    fun void fadeOut(int control, int beats)
    {
        fade(control, 127, 0, beats);
    }

    fun void controlOn(int control)
    {
        <<< "Control On: ", control >>>;
        
        ControlChangeMessage message;
        control => message.control;
        127 => message.value;
        send(message);
    }

    fun void controlOff(int control)
    {
        <<< "Control Off: ", control >>>;
        
        ControlChangeMessage message;
        control => message.control;
        0 => message.value;
        send(message);
    }
    
    fun void startTrack()
    {
        // First control.
        
        8 => int control;
        
        ControlChangeMessage start;
        ControlChangeMessage stop;
        ControlChangeMessage restart;

        control++ => start.control;
        control++ => stop.control;
        control++ => restart.control;

        12 => int measures;
        measures * beatsPerMeasure => int beats;

        msPerBeat * (beats $ float) => float playInMs;
        msPerBeat * beatsPerMeasure => float pauseInMs;
        
        <<< "Starting..." >>>;

        2::second => now;
        
        send(start);

        spork ~ fade(controls["BassFader"], 20, 127, 6 * beatsPerMeasure);
        
        playInMs::ms => now;

        send(stop);

        pauseInMs::ms => now;

        send(restart);
    }
}

Controller controller;

spork ~ controller.startTrack();

controller.run();
