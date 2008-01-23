fun float durationInSeconds(float bpmStart, float bpmEnd, float beats)
{
    10000 => int resolution;

    0 => float sum;

    for(0 => int n; n < resolution; n++)
    {
        (n $ float) / (resolution $ float) => float position;

        bpmStart * position + bpmEnd * (1.0 - position) => float bpmCurrent;

        (beats * 60.0) / (bpmCurrent * (resolution $ float)) +=> sum;
    }

    return sum;
}

fun float findStartBpm(float bpmConstant, float adjustedBeats, float constantBeats)
{
    0.001 => float delta;

    durationInSeconds(bpmConstant, bpmConstant, constantBeats) => float target;

    bpmConstant => float adjustment;

    bpmConstant => float bpmStart;

    while(Math.fabs(target - durationInSeconds(bpmStart, bpmConstant, adjustedBeats)) > delta)
    {
        adjustment / 2 => adjustment;

        if(durationInSeconds(bpmStart, bpmConstant, adjustedBeats) < target)
        {
            adjustment -=> bpmStart;
        }
        else
        {
            adjustment +=> bpmStart;
        }
    }

    return bpmStart;
}

fun float[] scaleBeatsInSeconds(float bpmConstant, int adjustedBeats, int constantBeats)
{
    findStartBpm(bpmConstant, adjustedBeats, constantBeats) => float bpmStart;

    float durations[adjustedBeats];

    for(0 => int i; i < adjustedBeats; i++)
    {
        (i $ float) / (adjustedBeats $ float) => float position;

        position * bpmConstant + (1.0 - position) * bpmStart => float currentBpm;

        60.0 / currentBpm => float beatLength;

        beatLength => durations[i];
    }

    return durations;
}

scaleBeatsInSeconds(120, 3 * 4, 4 * 4) @=> float durations[];

<<< "Durations computed." >>>;

for(0 => int i; i < durations.cap(); i++)
{
    <<< durations[i] >>>;
    durations[i]::second => now;
}
