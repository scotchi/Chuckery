#include (MidiHandler)

class Bank
{
    // Initialize oscilators and set the partials relative to the fundamental
    
    SinOsc @ oscilators[6];

    [ 1.0, 0.1, 0.2, 0.4, 0.1, 0.2 ] @=> float partials[];

    for(0 => int i; i < oscilators.cap(); i++)
    {
        SinOsc oscilator => dac;
        0 => oscilator.gain;
        oscilator @=> oscilators[i];
    }

    0 => int m_pitch;

    // Handle note on events
    
    fun void noteOn(int pitch, int velocity)
    {
        Std.mtof(pitch) => float frequency;

        velocity / 127.0 => float gain;

        for(0 => int i; i < oscilators.cap(); i++)
        {
            frequency * (i + 1) => oscilators[i].freq;
            gain * partials[i] => oscilators[i].gain;
        }

        pitch => m_pitch;
    }

    fun void noteOff()
    {
        for(0 => int i; i < oscilators.cap(); i++)
        {
            0 => oscilators[i].gain;
        }

	0 => m_pitch;
    }

    fun int getPitch()
    {
	return m_pitch;
    }
}

class Synth extends MidiHandler
{
    Bank @ banks[6];

    for(0 => int i; i < banks.cap(); i++)
    {
	new Bank @=> banks[i];
    }

    fun void noteOn(int channel, int pitch, int velocity)
    {
	for(0 => int i; i < banks.cap(); i++)
	{
	    if(banks[i].getPitch() == 0)
	    {
		banks[i].noteOn(pitch, velocity);
		return;
	    }
	}
    }

    fun void noteOff(int channel, int pitch, int velocity)
    {
	for(0 => int i; i < banks.cap(); i++)
	{
	    if(banks[i].getPitch() == pitch)
	    {
		banks[i].noteOff();
		return;
	    }
	}	
    }
    
}

Synth poly;
poly.run();
