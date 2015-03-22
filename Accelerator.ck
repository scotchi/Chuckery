#include (Sequence)

MidiHandler handler;

class Accelerator extends Sequence
{
    handler @=> output;

    fun void bass()
    {
	note(midi["C#1"], 1::second);
    }

    midi["G1"] => int snareNote;

    fun void snare()
    {
	note(snareNote, 700.1::second);
    }

    fun void hihat()
    {
	note(midi["D#3"], 60, 0.5::second);
    }

    140 => int beatsPerMinute;

    (60 * 1000) / beatsPerMinute => int beatLength;
    beatLength * 4 => int measureLength;

    fun void simple(int beats)
    {
	for(0 => int i; i < beats; i++)
	{
            spork ~ snare();
            // <<< beatLength >>>;
            beatLength::ms => now;
	}
    }

    fun void complex(float beginCycle, float endCycle)
    {
	1 => int measures;
	4 => float unit;
	0 => float elapsed;
	1 => float acceleration;
	
	// 0.5 => float beginCycle;
	// 1 => float endCycle;

	while(elapsed < measureLength * measures)
	{
            measureLength / unit => float unitLength;
            elapsed / (measureLength * measures) => float pos;
	    
            unitLength * (1 - Math.pow(Math.sin(pi * beginCycle + pi * pos * (endCycle - beginCycle)), 1 / acceleration)) => float advance;
        
            if(advance < 10)
            {
		10 => advance;
            }

            <<< elapsed, advance >>>;
            
            advance +=> elapsed;

            spork ~ snare();

            advance::ms => now;
	}

	spork ~ snare();
    }

    fun void complexHandle(float beginCycle, float endCycle)
    {
	spork ~ complex(beginCycle, endCycle);
	1 * measureLength::ms => now;
    }

    fun void play()
    {
	simple(8);
	complexHandle(0, 0.2);
	complexHandle(0.2, 0.43);
	Std.rand() % 128 => snareNote;
	complexHandle(0.43, 0.95);
	simple(8);
    }
}

Accelerator accel;

while(true)
{
    accel.play();
}
