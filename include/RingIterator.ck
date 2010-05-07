class RingIterator 
{
    int list[];

    0 => int index;

    fun int next()
    {
	(index + 1 ) % list.cap() => index;

	return list[index];
    }

    fun int previous()
    {
	(index - 1 + list.cap()) % list.cap() => index;
	return list[index];
    }

    fun int value()
    {
	return list[index];
    }

    fun static RingIterator create(int l[])
    {
	RingIterator it;
	l @=> it.list;
	return it;
    }
}
