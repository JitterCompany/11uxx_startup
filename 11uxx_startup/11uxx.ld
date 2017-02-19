/* TODO: lpc_usb_lib references RAM2, maybe rename to a more descriptive name */

INCLUDE "link.ld"

ENTRY(ResetISR)

SECTIONS
{

    /* MAIN TEXT SECTION */    
    .text : ALIGN(4)
    {
        FILL(0xff)
        __vectors_start__ = ABSOLUTE(.) ;
        KEEP(*(.isr_vector))
        
        /* Global Section Table */
        . = ALIGN(4) ;
        __section_table_start = .;
        __data_section_table = .;
        LONG(LOADADDR(.data));
        LONG(    ADDR(.data));
        LONG(  SIZEOF(.data));
        LONG(LOADADDR(.data_RAM2));
        LONG(    ADDR(.data_RAM2));
        LONG(  SIZEOF(.data_RAM2));
        __data_section_table_end = .;
        __bss_section_table = .;
        LONG(    ADDR(.bss));
        LONG(  SIZEOF(.bss));
        LONG(    ADDR(.bss_RAM2));
        LONG(  SIZEOF(.bss_RAM2));
        __bss_section_table_end = .;
        __section_table_end = . ;
        /* End of Global Section Table */
        

        *(.after_vectors*)
        
    } >Flash
    
    .text : ALIGN(4)    
    {
         *(.text*)
        *(.rodata .rodata.* .constdata .constdata.*)
        . = ALIGN(4);
        
    } > Flash

    /*
     * for exception handling/unwind - some Newlib functions (in common
     * with C++ and STDC++) use this. 
     */
    .ARM.extab : ALIGN(4)
    {
    	*(.ARM.extab* .gnu.linkonce.armextab.*)
    } > Flash
    __exidx_start = .;
    
    .ARM.exidx : ALIGN(4)
    {
    	*(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > Flash
    __exidx_end = .;
    
    _etext = .;
        
    
    /* DATA section for RAM_USB */
    .data_RAM2 : ALIGN(4)
    {
       FILL(0xff)
    	*(.data.$RAM2*)
    	*(.data.$RAM_USB*)
       . = ALIGN(4) ;
    } > RAM_USB AT>Flash
    
    /* MAIN DATA SECTION */
    

    .uninit_RESERVED : ALIGN(4)
    {
        KEEP(*(.bss.$RESERVED*))
        . = ALIGN(4) ;
        _end_uninit_RESERVED = .;
    } > RAM_main

	
	/* Main DATA section (RAM_main) */
	.data : ALIGN(4)
	{
	   FILL(0xff)
	   _data = . ;
	   *(vtable)
	   *(.data*)
	   . = ALIGN(4) ;
	   _edata = . ;
	} > RAM_main AT>Flash

    /* BSS section for RAM_USB */
    .bss_RAM2 : ALIGN(4)
    {
    	*(.bss.$RAM2*)
    	*(.bss.$RAM_USB*)
       . = ALIGN(4) ;
    } > RAM_USB

    /* MAIN BSS SECTION */
    .bss : ALIGN(4)
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4) ;
        _ebss = .;
        PROVIDE(end = .);
    } > RAM_main
        
    /* NOINIT section for RAM_USB */
    .noinit_RAM2 (NOLOAD) : ALIGN(4)
    {
    	*(.noinit.$RAM2*)
    	*(.noinit.$RAM_USB*)
       . = ALIGN(4) ;
    } > RAM_USB 
    
    /* DEFAULT NOINIT SECTION */
    .noinit (NOLOAD): ALIGN(4)
    {
        _noinit = .;
        *(.noinit*) 
         . = ALIGN(4) ;
        _end_noinit = .;
    } > RAM_main
    
    PROVIDE(_pvHeapStart = .);
    PROVIDE(_vStackTop = __top_RAM_main - 0);

    PROVIDE(__valid_user_code_checksum = 0 - 
        (_vStackTop 
        + (ResetISR + 1) 
        + (NMI_Handler + 1) 
        + (HardFault_Handler + 1)
        + (0)
        + (0)
        + (0)
        )
    );
}
