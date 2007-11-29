class Row
{
    int m_pitches[12];
    0 => int m_current;
    
    generate();

    fun int randomPitch()
    {
        return Std.rand() % 12 + 1;
    }

    fun int contains(int value)
    {
        for(0 => int i; i < 12; i++)
        {
            if(m_pitches[i] == value)
            {
                return true;
            }
        }
        
        return false;
    }
    
    fun void generate()
    {
        // This is a crappy way of generating the set, but ChucK doesn't have a
        // nice list class to make this easier.

        for(0 => int i; i < 12; i++)
        {
            randomPitch() => int pitch;

            while(contains(pitch))
            {
                randomPitch() => pitch;
            }

            pitch => m_pitches[i];
        }
    }

    fun void print()
    {
        <<< "Row:", "" >>>;
        
        for(0 => int i; i < 12; i++)
        {
            <<< m_pitches[i], "" >>>;
        }

        <<< "", "" >>>;
    }

    fun void invert()
    {
        for(0 => int i; i < 12; i++)
        {
            13 - m_pitches[i] => m_pitches[i];
        }
    }

    fun void retrograde()
    {
        int reversed[12];
        
        for(0 => int i; i < 12; i++)
        {
            m_pitches[11 - i] => reversed[i];
        }

        reversed @=> m_pitches;
    }

    fun int nextPitch()
    {
        m_pitches[m_current] => int pitch;
        (m_current + 1) % 12 => m_current;
        return pitch;
    }
}

class RowPlayer
{
    int m_used[128];

    fun void noteOnHandler()
    {
        
    }

    fun void noteOffHandler()
    {

    }
}

class RowAutoPlayer
{
    Row m_row;

    [ 1/4, 1/8, 1/16, 1/2, 1, 2, 3/4, 6/4, 5/4, 7/4 ] @=> float m_denominations[];

    false => int m_ignoreNoteEnd;
    false => int m_ignoreMidiInput;

    0.8 => float m_chanceOfNote;
    4 => int m_maxConcurrentNotes;

    0.05 => float m_inversionChance;
    0.05 => float m_chanceOfRetrograde;

    0 => int m_currentNotes;

    fun void note(dur length)
    {
        <<< "note" >>>;
    }
    
    fun void pulse()
    {
        //
    }
    
    fun dur length()
    {
        //
    }
}


