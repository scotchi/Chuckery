#include (MidiHandler)

class Synth extends MidiHandler
{
    // Initialize oscilators and set the partials relative to the fundamental
    
    SinOsc @ oscilators[6];

    [ 1.0, 0.1, 0.2, 0.4, 0.1, 0.2 ] @=> float partials[];

    0 => int lastPitch;
    
    for(0 => int i; i < oscilators.cap(); i++)
    {
        SinOsc oscilator => dac;
        0 => oscilator.gain;
        oscilator @=> oscilators[i];
    }

    // Handle note on events
    
    fun void noteOn(int channel, int pitch, int velocity)
    {
        Std.mtof(pitch) => float frequency;

        velocity / 127.0 => float gain;

        for(0 => int i; i < oscilators.cap(); i++)
        {
            frequency * (i + 1) => oscilators[i].freq;
            gain * partials[i] => oscilators[i].gain;
        }

        pitch => lastPitch;
    }

    // Handle note off events

    fun void noteOff(int channel, int pitch, int velocity)
    {
        if(pitch == lastPitch)
        {
            for(0 => int i; i < oscilators.cap(); i++)
            {
                0 => oscilators[i].gain;
            }
        }
    }
}

Synth mono;
mono.run();
