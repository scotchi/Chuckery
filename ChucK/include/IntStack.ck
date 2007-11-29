class IntStack
{
    class Item
    {
        0 => int value;
        Item @ below;
    }

    Item bottom @=> Item top;

    fun void push(int value)
    {
        Item item;
        value => item.value;
        top @=> item.below;
        item @=> top;
    }

    fun int pop()
    {
        top.value => int value;

        if(!isEmpty())
        {
            top.below @=> top;
        }

        return value;
    }

    fun int isEmpty()
    {
        return top == bottom;
    }
}
