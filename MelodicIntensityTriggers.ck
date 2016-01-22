#include (Control)

4 => int inputController;
0 => int outputController;

9 => int intensityControl;
1 => int intensityControlChannel;

10 => int firstTriggerChannel;

[ 3, 4, 2 ] @=> int tracks[];

ControlDispatcher controller;
controller.open(inputController, outputController);

fun ControlChangeMessage triggerMessage(int track, int clip)
{
    ControlChangeMessage m;
    track + firstTriggerChannel => m.channel;
    clip => m.control;
    return m;
}

fun void setup()
{
    <<< "Starting" >>>;

    5::second => now;

    firstTriggerChannel => int first;

    for(0 => int track; track < tracks.cap(); track++)
    {
        for(1 => int clip; clip <= tracks[track]; clip++)
        {
            triggerMessage(track, clip) @=> ControlChangeMessage m;
            controller.send(m);
            <<< m.channel, m.control >>>;
            1::second => now;
        }
    }
}

class GlobalIntensityControl extends Control
{
    intensityControl => cc;
    intensityControlChannel => channel;

    int currentClip[tracks.cap()];

    fun static int clipForIntensity(int track, float intensity)
    {
        Math.ceil(intensity * tracks[track]) $ int => int clip;
        return (clip == 0) ? 1 : clip;
    }

    fun void set(int value)
    {
        (value $ float) / 127.0 => float intensity;

        <<< "Intensity:", intensity >>>;

        for(0 => int track; track < tracks.cap(); track++)
        {
            clipForIntensity(track, intensity) => int clip;

            if(currentClip[track] != clip)
            {
                clip => currentClip[track];
                controller.send(triggerMessage(track, clip));
                <<< "Track:", track, "clip:", clip >>>;
            }
        }
    }
}

fun void run()
{
    GlobalIntensityControl control;
    controller.run();
}

if(Std.getenv("MIDI_SETUP").length() > 0)
{
    setup();
}
else
{
    run();
}
