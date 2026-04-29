SECTIONS
{
  . = 0x7c00;

  .text :
  {
    __start = .;
    *(.text*)
    *(.rodata*)
    *(.data*)
    . = __start + 0x1FE;
    SHORT(0xAA55)
  }
}