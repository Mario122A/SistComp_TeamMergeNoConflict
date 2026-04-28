SECTIONS
{
    . = 0x7C00;
    .text : 
    {
        __start = .;
        *(.text)
        . = 0x1FE;
        SHORT(0xAA55)
    }
}