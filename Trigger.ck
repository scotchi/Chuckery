class Trigger
{
    // SndBuf source => dac;
    // "tur.wav" => source.read;
    // true => source.loop;

    UGen link;

    adc => link => dac;

    0 => float total;
    

    spork ~ sum();
    spork ~ checkTrigger();
    
    fun void sum()
    {
	while(true)
	{
	    1::samp => now;
	    Std.fabs(link.last()) +=> total;
	}
    }

    fun void checkTrigger()
    {
	SndBuf trigger => dac;

	0 => float lastTotal;

	false => int rising;
	
	while(true)
	{
	    30::ms => now;

	    if(lastTotal * 1.5 < total && total > 0.8 && !rising)
	    {
		"snare.wav" => trigger.read;
	    }

	    total < lastTotal => rising;
	    total => lastTotal;
	    0 => total;
	}
    }
}

Trigger t;

100::second => now;
