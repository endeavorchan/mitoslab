
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		_start
_start:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4 66                	in     $0x66,%al

f010000c <_start>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 20 11 00 	lgdtl  0x112018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Set the stack pointer
	movl	$(bootstacktop),%esp
f0100033:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 a0 00 00 00       	call   f01000dd <i386_init>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>
	...

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f0100046:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100049:	89 44 24 08          	mov    %eax,0x8(%esp)
f010004d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100050:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100054:	c7 04 24 20 20 10 f0 	movl   $0xf0102020,(%esp)
f010005b:	e8 6b 0f 00 00       	call   f0100fcb <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 26 0f 00 00       	call   f0100f98 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 94 20 10 f0 	movl   $0xf0102094,(%esp)
f0100079:	e8 4d 0f 00 00       	call   f0100fcb <cprintf>
	va_end(ap);
}
f010007e:	c9                   	leave  
f010007f:	c3                   	ret    

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100086:	83 3d 60 23 11 f0 00 	cmpl   $0x0,0xf0112360
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 60 23 11 f0       	mov    %eax,0xf0112360

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 3a 20 10 f0 	movl   $0xf010203a,(%esp)
f01000ac:	e8 1a 0f 00 00       	call   f0100fcb <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 d5 0e 00 00       	call   f0100f98 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 94 20 10 f0 	movl   $0xf0102094,(%esp)
f01000ca:	e8 fc 0e 00 00       	call   f0100fcb <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 a1 06 00 00       	call   f010077c <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000e3:	b8 f0 29 11 f0       	mov    $0xf01129f0,%eax
f01000e8:	2d 58 23 11 f0       	sub    $0xf0112358,%eax
f01000ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f8:	00 
f01000f9:	c7 04 24 58 23 11 f0 	movl   $0xf0112358,(%esp)
f0100100:	e8 91 1a 00 00       	call   f0101b96 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 37 02 00 00       	call   f0100341 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 52 20 10 f0 	movl   $0xf0102052,(%esp)
f0100119:	e8 ad 0e 00 00       	call   f0100fcb <cprintf>

	// Lab 2 memory management initialization functions
	i386_detect_memory();
f010011e:	e8 fb 09 00 00       	call   f0100b1e <i386_detect_memory>
	i386_vm_init();
f0100123:	e8 ca 08 00 00       	call   f01009f2 <i386_vm_init>
	page_init();
f0100128:	e8 9b 07 00 00       	call   f01008c8 <page_init>
	page_check();
f010012d:	8d 76 00             	lea    0x0(%esi),%esi
f0100130:	e8 df 08 00 00       	call   f0100a14 <page_check>



	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010013c:	e8 3b 06 00 00       	call   f010077c <monitor>
f0100141:	eb f2                	jmp    f0100135 <i386_init+0x58>
	...

f0100150 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100153:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100158:	ec                   	in     (%dx),%al
f0100159:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100160:	f6 c2 01             	test   $0x1,%dl
f0100163:	74 09                	je     f010016e <serial_proc_data+0x1e>
f0100165:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010016a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010016b:	0f b6 c0             	movzbl %al,%eax
}
f010016e:	5d                   	pop    %ebp
f010016f:	c3                   	ret    

f0100170 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100174:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100179:	b8 00 00 00 00       	mov    $0x0,%eax
f010017e:	89 da                	mov    %ebx,%edx
f0100180:	ee                   	out    %al,(%dx)
f0100181:	b2 fb                	mov    $0xfb,%dl
f0100183:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100188:	ee                   	out    %al,(%dx)
f0100189:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010018e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100193:	89 ca                	mov    %ecx,%edx
f0100195:	ee                   	out    %al,(%dx)
f0100196:	b2 f9                	mov    $0xf9,%dl
f0100198:	b8 00 00 00 00       	mov    $0x0,%eax
f010019d:	ee                   	out    %al,(%dx)
f010019e:	b2 fb                	mov    $0xfb,%dl
f01001a0:	b8 03 00 00 00       	mov    $0x3,%eax
f01001a5:	ee                   	out    %al,(%dx)
f01001a6:	b2 fc                	mov    $0xfc,%dl
f01001a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ad:	ee                   	out    %al,(%dx)
f01001ae:	b2 f9                	mov    $0xf9,%dl
f01001b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01001b5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b6:	b2 fd                	mov    $0xfd,%dl
f01001b8:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01001b9:	3c ff                	cmp    $0xff,%al
f01001bb:	0f 95 c0             	setne  %al
f01001be:	0f b6 c0             	movzbl %al,%eax
f01001c1:	a3 84 23 11 f0       	mov    %eax,0xf0112384
f01001c6:	89 da                	mov    %ebx,%edx
f01001c8:	ec                   	in     (%dx),%al
f01001c9:	89 ca                	mov    %ecx,%edx
f01001cb:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f01001cc:	5b                   	pop    %ebx
f01001cd:	5d                   	pop    %ebp
f01001ce:	c3                   	ret    

f01001cf <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f01001cf:	55                   	push   %ebp
f01001d0:	89 e5                	mov    %esp,%ebp
f01001d2:	83 ec 0c             	sub    $0xc,%esp
f01001d5:	89 1c 24             	mov    %ebx,(%esp)
f01001d8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01001dc:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01001e0:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01001e5:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01001e8:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01001ed:	0f b7 00             	movzwl (%eax),%eax
f01001f0:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01001f4:	74 11                	je     f0100207 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01001f6:	c7 05 88 23 11 f0 b4 	movl   $0x3b4,0xf0112388
f01001fd:	03 00 00 
f0100200:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100205:	eb 16                	jmp    f010021d <cga_init+0x4e>
	} else {
		*cp = was;
f0100207:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010020e:	c7 05 88 23 11 f0 d4 	movl   $0x3d4,0xf0112388
f0100215:	03 00 00 
f0100218:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010021d:	8b 0d 88 23 11 f0    	mov    0xf0112388,%ecx
f0100223:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100225:	b8 0e 00 00 00       	mov    $0xe,%eax
f010022a:	89 ca                	mov    %ecx,%edx
f010022c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010022d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100230:	89 ca                	mov    %ecx,%edx
f0100232:	ec                   	in     (%dx),%al
f0100233:	0f b6 f8             	movzbl %al,%edi
f0100236:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100239:	b8 0f 00 00 00       	mov    $0xf,%eax
f010023e:	89 da                	mov    %ebx,%edx
f0100240:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100241:	89 ca                	mov    %ecx,%edx
f0100243:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100244:	89 35 8c 23 11 f0    	mov    %esi,0xf011238c
	crt_pos = pos;
f010024a:	0f b6 c8             	movzbl %al,%ecx
f010024d:	09 cf                	or     %ecx,%edi
f010024f:	66 89 3d 90 23 11 f0 	mov    %di,0xf0112390
}
f0100256:	8b 1c 24             	mov    (%esp),%ebx
f0100259:	8b 74 24 04          	mov    0x4(%esp),%esi
f010025d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0100261:	89 ec                	mov    %ebp,%esp
f0100263:	5d                   	pop    %ebp
f0100264:	c3                   	ret    

f0100265 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f0100265:	55                   	push   %ebp
f0100266:	89 e5                	mov    %esp,%ebp
}
f0100268:	5d                   	pop    %ebp
f0100269:	c3                   	ret    

f010026a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010026a:	55                   	push   %ebp
f010026b:	89 e5                	mov    %esp,%ebp
f010026d:	57                   	push   %edi
f010026e:	56                   	push   %esi
f010026f:	53                   	push   %ebx
f0100270:	83 ec 0c             	sub    $0xc,%esp
f0100273:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100276:	bb a4 25 11 f0       	mov    $0xf01125a4,%ebx
f010027b:	bf a0 23 11 f0       	mov    $0xf01123a0,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100280:	eb 1e                	jmp    f01002a0 <cons_intr+0x36>
		if (c == 0)
f0100282:	85 c0                	test   %eax,%eax
f0100284:	74 1a                	je     f01002a0 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100286:	8b 13                	mov    (%ebx),%edx
f0100288:	88 04 17             	mov    %al,(%edi,%edx,1)
f010028b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010028e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100293:	0f 94 c2             	sete   %dl
f0100296:	0f b6 d2             	movzbl %dl,%edx
f0100299:	83 ea 01             	sub    $0x1,%edx
f010029c:	21 d0                	and    %edx,%eax
f010029e:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002a0:	ff d6                	call   *%esi
f01002a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a5:	75 db                	jne    f0100282 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002a7:	83 c4 0c             	add    $0xc,%esp
f01002aa:	5b                   	pop    %ebx
f01002ab:	5e                   	pop    %esi
f01002ac:	5f                   	pop    %edi
f01002ad:	5d                   	pop    %ebp
f01002ae:	c3                   	ret    

f01002af <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01002af:	55                   	push   %ebp
f01002b0:	89 e5                	mov    %esp,%ebp
f01002b2:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f01002b5:	c7 04 24 68 03 10 f0 	movl   $0xf0100368,(%esp)
f01002bc:	e8 a9 ff ff ff       	call   f010026a <cons_intr>
}
f01002c1:	c9                   	leave  
f01002c2:	c3                   	ret    

f01002c3 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01002c3:	55                   	push   %ebp
f01002c4:	89 e5                	mov    %esp,%ebp
f01002c6:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f01002c9:	83 3d 84 23 11 f0 00 	cmpl   $0x0,0xf0112384
f01002d0:	74 0c                	je     f01002de <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f01002d2:	c7 04 24 50 01 10 f0 	movl   $0xf0100150,(%esp)
f01002d9:	e8 8c ff ff ff       	call   f010026a <cons_intr>
}
f01002de:	c9                   	leave  
f01002df:	c3                   	ret    

f01002e0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01002e0:	55                   	push   %ebp
f01002e1:	89 e5                	mov    %esp,%ebp
f01002e3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01002e6:	e8 d8 ff ff ff       	call   f01002c3 <serial_intr>
	kbd_intr();
f01002eb:	e8 bf ff ff ff       	call   f01002af <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01002f0:	8b 15 a0 25 11 f0    	mov    0xf01125a0,%edx
f01002f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01002fb:	3b 15 a4 25 11 f0    	cmp    0xf01125a4,%edx
f0100301:	74 21                	je     f0100324 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100303:	0f b6 82 a0 23 11 f0 	movzbl -0xfeedc60(%edx),%eax
f010030a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010030d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100313:	0f 94 c1             	sete   %cl
f0100316:	0f b6 c9             	movzbl %cl,%ecx
f0100319:	83 e9 01             	sub    $0x1,%ecx
f010031c:	21 ca                	and    %ecx,%edx
f010031e:	89 15 a0 25 11 f0    	mov    %edx,0xf01125a0
		return c;
	}
	return 0;
}
f0100324:	c9                   	leave  
f0100325:	c3                   	ret    

f0100326 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100326:	55                   	push   %ebp
f0100327:	89 e5                	mov    %esp,%ebp
f0100329:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010032c:	e8 af ff ff ff       	call   f01002e0 <cons_getc>
f0100331:	85 c0                	test   %eax,%eax
f0100333:	74 f7                	je     f010032c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100335:	c9                   	leave  
f0100336:	c3                   	ret    

f0100337 <iscons>:

int
iscons(int fdnum)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010033a:	b8 01 00 00 00       	mov    $0x1,%eax
f010033f:	5d                   	pop    %ebp
f0100340:	c3                   	ret    

f0100341 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100341:	55                   	push   %ebp
f0100342:	89 e5                	mov    %esp,%ebp
f0100344:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f0100347:	e8 83 fe ff ff       	call   f01001cf <cga_init>
	kbd_init();
	serial_init();
f010034c:	e8 1f fe ff ff       	call   f0100170 <serial_init>

	if (!serial_exists)
f0100351:	83 3d 84 23 11 f0 00 	cmpl   $0x0,0xf0112384
f0100358:	75 0c                	jne    f0100366 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f010035a:	c7 04 24 6d 20 10 f0 	movl   $0xf010206d,(%esp)
f0100361:	e8 65 0c 00 00       	call   f0100fcb <cprintf>
}
f0100366:	c9                   	leave  
f0100367:	c3                   	ret    

f0100368 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100368:	55                   	push   %ebp
f0100369:	89 e5                	mov    %esp,%ebp
f010036b:	53                   	push   %ebx
f010036c:	83 ec 14             	sub    $0x14,%esp
f010036f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100374:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100375:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010037a:	a8 01                	test   $0x1,%al
f010037c:	0f 84 d9 00 00 00    	je     f010045b <kbd_proc_data+0xf3>
f0100382:	b2 60                	mov    $0x60,%dl
f0100384:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100385:	3c e0                	cmp    $0xe0,%al
f0100387:	75 11                	jne    f010039a <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100389:	83 0d 80 23 11 f0 40 	orl    $0x40,0xf0112380
f0100390:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100395:	e9 c1 00 00 00       	jmp    f010045b <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010039a:	84 c0                	test   %al,%al
f010039c:	79 32                	jns    f01003d0 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010039e:	8b 15 80 23 11 f0    	mov    0xf0112380,%edx
f01003a4:	f6 c2 40             	test   $0x40,%dl
f01003a7:	75 03                	jne    f01003ac <kbd_proc_data+0x44>
f01003a9:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01003ac:	0f b6 c0             	movzbl %al,%eax
f01003af:	0f b6 80 a0 20 10 f0 	movzbl -0xfefdf60(%eax),%eax
f01003b6:	83 c8 40             	or     $0x40,%eax
f01003b9:	0f b6 c0             	movzbl %al,%eax
f01003bc:	f7 d0                	not    %eax
f01003be:	21 c2                	and    %eax,%edx
f01003c0:	89 15 80 23 11 f0    	mov    %edx,0xf0112380
f01003c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003cb:	e9 8b 00 00 00       	jmp    f010045b <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f01003d0:	8b 15 80 23 11 f0    	mov    0xf0112380,%edx
f01003d6:	f6 c2 40             	test   $0x40,%dl
f01003d9:	74 0c                	je     f01003e7 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003db:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01003de:	83 e2 bf             	and    $0xffffffbf,%edx
f01003e1:	89 15 80 23 11 f0    	mov    %edx,0xf0112380
	}

	shift |= shiftcode[data];
f01003e7:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01003ea:	0f b6 90 a0 20 10 f0 	movzbl -0xfefdf60(%eax),%edx
f01003f1:	0b 15 80 23 11 f0    	or     0xf0112380,%edx
f01003f7:	0f b6 88 a0 21 10 f0 	movzbl -0xfefde60(%eax),%ecx
f01003fe:	31 ca                	xor    %ecx,%edx
f0100400:	89 15 80 23 11 f0    	mov    %edx,0xf0112380

	c = charcode[shift & (CTL | SHIFT)][data];
f0100406:	89 d1                	mov    %edx,%ecx
f0100408:	83 e1 03             	and    $0x3,%ecx
f010040b:	8b 0c 8d a0 22 10 f0 	mov    -0xfefdd60(,%ecx,4),%ecx
f0100412:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100416:	f6 c2 08             	test   $0x8,%dl
f0100419:	74 1a                	je     f0100435 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010041b:	89 d9                	mov    %ebx,%ecx
f010041d:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100420:	83 f8 19             	cmp    $0x19,%eax
f0100423:	77 05                	ja     f010042a <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100425:	83 eb 20             	sub    $0x20,%ebx
f0100428:	eb 0b                	jmp    f0100435 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010042a:	83 e9 41             	sub    $0x41,%ecx
f010042d:	83 f9 19             	cmp    $0x19,%ecx
f0100430:	77 03                	ja     f0100435 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100432:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100435:	f7 d2                	not    %edx
f0100437:	f6 c2 06             	test   $0x6,%dl
f010043a:	75 1f                	jne    f010045b <kbd_proc_data+0xf3>
f010043c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100442:	75 17                	jne    f010045b <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f0100444:	c7 04 24 8a 20 10 f0 	movl   $0xf010208a,(%esp)
f010044b:	e8 7b 0b 00 00       	call   f0100fcb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100450:	ba 92 00 00 00       	mov    $0x92,%edx
f0100455:	b8 03 00 00 00       	mov    $0x3,%eax
f010045a:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010045b:	89 d8                	mov    %ebx,%eax
f010045d:	83 c4 14             	add    $0x14,%esp
f0100460:	5b                   	pop    %ebx
f0100461:	5d                   	pop    %ebp
f0100462:	c3                   	ret    

f0100463 <cga_putc>:



void
cga_putc(int c)
{
f0100463:	55                   	push   %ebp
f0100464:	89 e5                	mov    %esp,%ebp
f0100466:	56                   	push   %esi
f0100467:	53                   	push   %ebx
f0100468:	83 ec 10             	sub    $0x10,%esp
f010046b:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010046e:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100473:	75 03                	jne    f0100478 <cga_putc+0x15>
		c |= 0x0700;
f0100475:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f0100478:	0f b6 d0             	movzbl %al,%edx
f010047b:	83 fa 09             	cmp    $0x9,%edx
f010047e:	0f 84 89 00 00 00    	je     f010050d <cga_putc+0xaa>
f0100484:	83 fa 09             	cmp    $0x9,%edx
f0100487:	7f 11                	jg     f010049a <cga_putc+0x37>
f0100489:	83 fa 08             	cmp    $0x8,%edx
f010048c:	0f 85 b9 00 00 00    	jne    f010054b <cga_putc+0xe8>
f0100492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100498:	eb 18                	jmp    f01004b2 <cga_putc+0x4f>
f010049a:	83 fa 0a             	cmp    $0xa,%edx
f010049d:	8d 76 00             	lea    0x0(%esi),%esi
f01004a0:	74 41                	je     f01004e3 <cga_putc+0x80>
f01004a2:	83 fa 0d             	cmp    $0xd,%edx
f01004a5:	8d 76 00             	lea    0x0(%esi),%esi
f01004a8:	0f 85 9d 00 00 00    	jne    f010054b <cga_putc+0xe8>
f01004ae:	66 90                	xchg   %ax,%ax
f01004b0:	eb 39                	jmp    f01004eb <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f01004b2:	0f b7 15 90 23 11 f0 	movzwl 0xf0112390,%edx
f01004b9:	66 85 d2             	test   %dx,%dx
f01004bc:	0f 84 f4 00 00 00    	je     f01005b6 <cga_putc+0x153>
			crt_pos--;
f01004c2:	83 ea 01             	sub    $0x1,%edx
f01004c5:	66 89 15 90 23 11 f0 	mov    %dx,0xf0112390
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cc:	0f b7 d2             	movzwl %dx,%edx
f01004cf:	b0 00                	mov    $0x0,%al
f01004d1:	83 c8 20             	or     $0x20,%eax
f01004d4:	8b 0d 8c 23 11 f0    	mov    0xf011238c,%ecx
f01004da:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01004de:	e9 86 00 00 00       	jmp    f0100569 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e3:	66 83 05 90 23 11 f0 	addw   $0x50,0xf0112390
f01004ea:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004eb:	0f b7 05 90 23 11 f0 	movzwl 0xf0112390,%eax
f01004f2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f8:	c1 e8 10             	shr    $0x10,%eax
f01004fb:	66 c1 e8 06          	shr    $0x6,%ax
f01004ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100502:	c1 e0 04             	shl    $0x4,%eax
f0100505:	66 a3 90 23 11 f0    	mov    %ax,0xf0112390
		break;
f010050b:	eb 5c                	jmp    f0100569 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010050d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100514:	e8 d4 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100519:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100520:	e8 c8 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100525:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010052c:	e8 bc 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f0100531:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100538:	e8 b0 00 00 00       	call   f01005ed <cons_putc>
		cons_putc(' ');
f010053d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100544:	e8 a4 00 00 00       	call   f01005ed <cons_putc>
		break;
f0100549:	eb 1e                	jmp    f0100569 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010054b:	0f b7 15 90 23 11 f0 	movzwl 0xf0112390,%edx
f0100552:	0f b7 da             	movzwl %dx,%ebx
f0100555:	8b 0d 8c 23 11 f0    	mov    0xf011238c,%ecx
f010055b:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f010055f:	83 c2 01             	add    $0x1,%edx
f0100562:	66 89 15 90 23 11 f0 	mov    %dx,0xf0112390
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100569:	66 81 3d 90 23 11 f0 	cmpw   $0x7cf,0xf0112390
f0100570:	cf 07 
f0100572:	76 42                	jbe    f01005b6 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100574:	a1 8c 23 11 f0       	mov    0xf011238c,%eax
f0100579:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100580:	00 
f0100581:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100587:	89 54 24 04          	mov    %edx,0x4(%esp)
f010058b:	89 04 24             	mov    %eax,(%esp)
f010058e:	e8 28 16 00 00       	call   f0101bbb <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100593:	8b 15 8c 23 11 f0    	mov    0xf011238c,%edx
f0100599:	b8 80 07 00 00       	mov    $0x780,%eax
f010059e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a4:	83 c0 01             	add    $0x1,%eax
f01005a7:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005ac:	75 f0                	jne    f010059e <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005ae:	66 83 2d 90 23 11 f0 	subw   $0x50,0xf0112390
f01005b5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005b6:	8b 0d 88 23 11 f0    	mov    0xf0112388,%ecx
f01005bc:	89 cb                	mov    %ecx,%ebx
f01005be:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c3:	89 ca                	mov    %ecx,%edx
f01005c5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005c6:	0f b7 35 90 23 11 f0 	movzwl 0xf0112390,%esi
f01005cd:	83 c1 01             	add    $0x1,%ecx
f01005d0:	89 f0                	mov    %esi,%eax
f01005d2:	66 c1 e8 08          	shr    $0x8,%ax
f01005d6:	89 ca                	mov    %ecx,%edx
f01005d8:	ee                   	out    %al,(%dx)
f01005d9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005de:	89 da                	mov    %ebx,%edx
f01005e0:	ee                   	out    %al,(%dx)
f01005e1:	89 f0                	mov    %esi,%eax
f01005e3:	89 ca                	mov    %ecx,%edx
f01005e5:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f01005e6:	83 c4 10             	add    $0x10,%esp
f01005e9:	5b                   	pop    %ebx
f01005ea:	5e                   	pop    %esi
f01005eb:	5d                   	pop    %ebp
f01005ec:	c3                   	ret    

f01005ed <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	57                   	push   %edi
f01005f1:	56                   	push   %esi
f01005f2:	53                   	push   %ebx
f01005f3:	83 ec 1c             	sub    $0x1c,%esp
f01005f6:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f9:	ba 79 03 00 00       	mov    $0x379,%edx
f01005fe:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01005ff:	84 c0                	test   %al,%al
f0100601:	78 27                	js     f010062a <cons_putc+0x3d>
f0100603:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100608:	b9 84 00 00 00       	mov    $0x84,%ecx
f010060d:	be 79 03 00 00       	mov    $0x379,%esi
f0100612:	89 ca                	mov    %ecx,%edx
f0100614:	ec                   	in     (%dx),%al
f0100615:	ec                   	in     (%dx),%al
f0100616:	ec                   	in     (%dx),%al
f0100617:	ec                   	in     (%dx),%al
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ec                   	in     (%dx),%al
f010061b:	84 c0                	test   %al,%al
f010061d:	78 0b                	js     f010062a <cons_putc+0x3d>
f010061f:	83 c3 01             	add    $0x1,%ebx
f0100622:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100628:	75 e8                	jne    f0100612 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010062a:	ba 78 03 00 00       	mov    $0x378,%edx
f010062f:	89 f8                	mov    %edi,%eax
f0100631:	ee                   	out    %al,(%dx)
f0100632:	b2 7a                	mov    $0x7a,%dl
f0100634:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100639:	ee                   	out    %al,(%dx)
f010063a:	b8 08 00 00 00       	mov    $0x8,%eax
f010063f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f0100640:	89 3c 24             	mov    %edi,(%esp)
f0100643:	e8 1b fe ff ff       	call   f0100463 <cga_putc>
}
f0100648:	83 c4 1c             	add    $0x1c,%esp
f010064b:	5b                   	pop    %ebx
f010064c:	5e                   	pop    %esi
f010064d:	5f                   	pop    %edi
f010064e:	5d                   	pop    %ebp
f010064f:	c3                   	ret    

f0100650 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f0100656:	8b 45 08             	mov    0x8(%ebp),%eax
f0100659:	89 04 24             	mov    %eax,(%esp)
f010065c:	e8 8c ff ff ff       	call   f01005ed <cons_putc>
}
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    
	...

f0100670 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100670:	55                   	push   %ebp
f0100671:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100673:	b8 00 00 00 00       	mov    $0x0,%eax
f0100678:	5d                   	pop    %ebp
f0100679:	c3                   	ret    

f010067a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010067d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100680:	5d                   	pop    %ebp
f0100681:	c3                   	ret    

f0100682 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100682:	55                   	push   %ebp
f0100683:	89 e5                	mov    %esp,%ebp
f0100685:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100688:	c7 04 24 b0 22 10 f0 	movl   $0xf01022b0,(%esp)
f010068f:	e8 37 09 00 00       	call   f0100fcb <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100694:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010069b:	00 
f010069c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006a3:	f0 
f01006a4:	c7 04 24 3c 23 10 f0 	movl   $0xf010233c,(%esp)
f01006ab:	e8 1b 09 00 00       	call   f0100fcb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b0:	c7 44 24 08 15 20 10 	movl   $0x102015,0x8(%esp)
f01006b7:	00 
f01006b8:	c7 44 24 04 15 20 10 	movl   $0xf0102015,0x4(%esp)
f01006bf:	f0 
f01006c0:	c7 04 24 60 23 10 f0 	movl   $0xf0102360,(%esp)
f01006c7:	e8 ff 08 00 00       	call   f0100fcb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006cc:	c7 44 24 08 58 23 11 	movl   $0x112358,0x8(%esp)
f01006d3:	00 
f01006d4:	c7 44 24 04 58 23 11 	movl   $0xf0112358,0x4(%esp)
f01006db:	f0 
f01006dc:	c7 04 24 84 23 10 f0 	movl   $0xf0102384,(%esp)
f01006e3:	e8 e3 08 00 00       	call   f0100fcb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e8:	c7 44 24 08 f0 29 11 	movl   $0x1129f0,0x8(%esp)
f01006ef:	00 
f01006f0:	c7 44 24 04 f0 29 11 	movl   $0xf01129f0,0x4(%esp)
f01006f7:	f0 
f01006f8:	c7 04 24 a8 23 10 f0 	movl   $0xf01023a8,(%esp)
f01006ff:	e8 c7 08 00 00       	call   f0100fcb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100704:	b8 ef 2d 11 f0       	mov    $0xf0112def,%eax
f0100709:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010070e:	89 c2                	mov    %eax,%edx
f0100710:	c1 fa 1f             	sar    $0x1f,%edx
f0100713:	c1 ea 16             	shr    $0x16,%edx
f0100716:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100719:	c1 f8 0a             	sar    $0xa,%eax
f010071c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100720:	c7 04 24 cc 23 10 f0 	movl   $0xf01023cc,(%esp)
f0100727:	e8 9f 08 00 00       	call   f0100fcb <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010072c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100731:	c9                   	leave  
f0100732:	c3                   	ret    

f0100733 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100739:	a1 70 24 10 f0       	mov    0xf0102470,%eax
f010073e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100742:	a1 6c 24 10 f0       	mov    0xf010246c,%eax
f0100747:	89 44 24 04          	mov    %eax,0x4(%esp)
f010074b:	c7 04 24 c9 22 10 f0 	movl   $0xf01022c9,(%esp)
f0100752:	e8 74 08 00 00       	call   f0100fcb <cprintf>
f0100757:	a1 7c 24 10 f0       	mov    0xf010247c,%eax
f010075c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100760:	a1 78 24 10 f0       	mov    0xf0102478,%eax
f0100765:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100769:	c7 04 24 c9 22 10 f0 	movl   $0xf01022c9,(%esp)
f0100770:	e8 56 08 00 00       	call   f0100fcb <cprintf>
	return 0;
}
f0100775:	b8 00 00 00 00       	mov    $0x0,%eax
f010077a:	c9                   	leave  
f010077b:	c3                   	ret    

f010077c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010077c:	55                   	push   %ebp
f010077d:	89 e5                	mov    %esp,%ebp
f010077f:	57                   	push   %edi
f0100780:	56                   	push   %esi
f0100781:	53                   	push   %ebx
f0100782:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100785:	c7 04 24 f8 23 10 f0 	movl   $0xf01023f8,(%esp)
f010078c:	e8 3a 08 00 00       	call   f0100fcb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100791:	c7 04 24 1c 24 10 f0 	movl   $0xf010241c,(%esp)
f0100798:	e8 2e 08 00 00       	call   f0100fcb <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010079d:	bf 6c 24 10 f0       	mov    $0xf010246c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007a2:	c7 04 24 d2 22 10 f0 	movl   $0xf01022d2,(%esp)
f01007a9:	e8 72 11 00 00       	call   f0101920 <readline>
f01007ae:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007b0:	85 c0                	test   %eax,%eax
f01007b2:	74 ee                	je     f01007a2 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007b4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01007bb:	be 00 00 00 00       	mov    $0x0,%esi
f01007c0:	eb 06                	jmp    f01007c8 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007c2:	c6 03 00             	movb   $0x0,(%ebx)
f01007c5:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007c8:	0f b6 03             	movzbl (%ebx),%eax
f01007cb:	84 c0                	test   %al,%al
f01007cd:	74 6c                	je     f010083b <monitor+0xbf>
f01007cf:	0f be c0             	movsbl %al,%eax
f01007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d6:	c7 04 24 d6 22 10 f0 	movl   $0xf01022d6,(%esp)
f01007dd:	e8 5c 13 00 00       	call   f0101b3e <strchr>
f01007e2:	85 c0                	test   %eax,%eax
f01007e4:	75 dc                	jne    f01007c2 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007e6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007e9:	74 50                	je     f010083b <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007eb:	83 fe 0f             	cmp    $0xf,%esi
f01007ee:	66 90                	xchg   %ax,%ax
f01007f0:	75 16                	jne    f0100808 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007f2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007f9:	00 
f01007fa:	c7 04 24 db 22 10 f0 	movl   $0xf01022db,(%esp)
f0100801:	e8 c5 07 00 00       	call   f0100fcb <cprintf>
f0100806:	eb 9a                	jmp    f01007a2 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100808:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010080c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010080f:	0f b6 03             	movzbl (%ebx),%eax
f0100812:	84 c0                	test   %al,%al
f0100814:	75 0c                	jne    f0100822 <monitor+0xa6>
f0100816:	eb b0                	jmp    f01007c8 <monitor+0x4c>
			buf++;
f0100818:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010081b:	0f b6 03             	movzbl (%ebx),%eax
f010081e:	84 c0                	test   %al,%al
f0100820:	74 a6                	je     f01007c8 <monitor+0x4c>
f0100822:	0f be c0             	movsbl %al,%eax
f0100825:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100829:	c7 04 24 d6 22 10 f0 	movl   $0xf01022d6,(%esp)
f0100830:	e8 09 13 00 00       	call   f0101b3e <strchr>
f0100835:	85 c0                	test   %eax,%eax
f0100837:	74 df                	je     f0100818 <monitor+0x9c>
f0100839:	eb 8d                	jmp    f01007c8 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010083b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100842:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100843:	85 f6                	test   %esi,%esi
f0100845:	0f 84 57 ff ff ff    	je     f01007a2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010084b:	8b 07                	mov    (%edi),%eax
f010084d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100851:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100854:	89 04 24             	mov    %eax,(%esp)
f0100857:	e8 6d 12 00 00       	call   f0101ac9 <strcmp>
f010085c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100861:	85 c0                	test   %eax,%eax
f0100863:	74 1d                	je     f0100882 <monitor+0x106>
f0100865:	a1 78 24 10 f0       	mov    0xf0102478,%eax
f010086a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100871:	89 04 24             	mov    %eax,(%esp)
f0100874:	e8 50 12 00 00       	call   f0101ac9 <strcmp>
f0100879:	85 c0                	test   %eax,%eax
f010087b:	75 28                	jne    f01008a5 <monitor+0x129>
f010087d:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100882:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100885:	8b 45 08             	mov    0x8(%ebp),%eax
f0100888:	89 44 24 08          	mov    %eax,0x8(%esp)
f010088c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	89 34 24             	mov    %esi,(%esp)
f0100896:	ff 92 74 24 10 f0    	call   *-0xfefdb8c(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010089c:	85 c0                	test   %eax,%eax
f010089e:	78 1d                	js     f01008bd <monitor+0x141>
f01008a0:	e9 fd fe ff ff       	jmp    f01007a2 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008a5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ac:	c7 04 24 f8 22 10 f0 	movl   $0xf01022f8,(%esp)
f01008b3:	e8 13 07 00 00       	call   f0100fcb <cprintf>
f01008b8:	e9 e5 fe ff ff       	jmp    f01007a2 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008bd:	83 c4 5c             	add    $0x5c,%esp
f01008c0:	5b                   	pop    %ebx
f01008c1:	5e                   	pop    %esi
f01008c2:	5f                   	pop    %edi
f01008c3:	5d                   	pop    %ebp
f01008c4:	c3                   	ret    
f01008c5:	00 00                	add    %al,(%eax)
	...

f01008c8 <page_init>:
// to allocate and deallocate physical memory via the page_free_list,
// and NEVER use boot_alloc() or the related boot-time functions above.
//
void
page_init(void)
{
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
f01008cb:	53                   	push   %ebx
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
f01008cc:	c7 05 b4 25 11 f0 00 	movl   $0x0,0xf01125b4
f01008d3:	00 00 00 
	for (i = 0; i < npage; i++) {
f01008d6:	83 3d e0 29 11 f0 00 	cmpl   $0x0,0xf01129e0
f01008dd:	74 60                	je     f010093f <page_init+0x77>
f01008df:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e4:	ba 00 00 00 00       	mov    $0x0,%edx
		pages[i].pp_ref = 0;
f01008e9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01008ec:	c1 e0 02             	shl    $0x2,%eax
f01008ef:	8b 0d ec 29 11 f0    	mov    0xf01129ec,%ecx
f01008f5:	66 c7 44 01 08 00 00 	movw   $0x0,0x8(%ecx,%eax,1)
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
f01008fc:	8b 0d b4 25 11 f0    	mov    0xf01125b4,%ecx
f0100902:	8b 1d ec 29 11 f0    	mov    0xf01129ec,%ebx
f0100908:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
f010090b:	85 c9                	test   %ecx,%ecx
f010090d:	74 11                	je     f0100920 <page_init+0x58>
f010090f:	89 c3                	mov    %eax,%ebx
f0100911:	03 1d ec 29 11 f0    	add    0xf01129ec,%ebx
f0100917:	8b 0d b4 25 11 f0    	mov    0xf01125b4,%ecx
f010091d:	89 59 04             	mov    %ebx,0x4(%ecx)
f0100920:	03 05 ec 29 11 f0    	add    0xf01129ec,%eax
f0100926:	a3 b4 25 11 f0       	mov    %eax,0xf01125b4
f010092b:	c7 40 04 b4 25 11 f0 	movl   $0xf01125b4,0x4(%eax)
	//     Which pages are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&page_free_list);
	for (i = 0; i < npage; i++) {
f0100932:	83 c2 01             	add    $0x1,%edx
f0100935:	89 d0                	mov    %edx,%eax
f0100937:	39 15 e0 29 11 f0    	cmp    %edx,0xf01129e0
f010093d:	77 aa                	ja     f01008e9 <page_init+0x21>
		pages[i].pp_ref = 0;
		LIST_INSERT_HEAD(&page_free_list, &pages[i], pp_link);
	}
}
f010093f:	5b                   	pop    %ebx
f0100940:	5d                   	pop    %ebp
f0100941:	c3                   	ret    

f0100942 <page_alloc>:
//
// Hint: use LIST_FIRST, LIST_REMOVE, and page_initpp
// Hint: pp_ref should not be incremented 
int
page_alloc(struct Page **pp_store)
{
f0100942:	55                   	push   %ebp
f0100943:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return -E_NO_MEM;
}
f0100945:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010094a:	5d                   	pop    %ebp
f010094b:	c3                   	ret    

f010094c <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f010094c:	55                   	push   %ebp
f010094d:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010094f:	5d                   	pop    %ebp
f0100950:	c3                   	ret    

f0100951 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100957:	66 83 68 08 01       	subw   $0x1,0x8(%eax)
		page_free(pp);
}
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    

f010095e <pgdir_walk>:
//
// Hint: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010095e:	55                   	push   %ebp
f010095f:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100961:	b8 00 00 00 00       	mov    $0x0,%eax
f0100966:	5d                   	pop    %ebp
f0100967:	c3                   	ret    

f0100968 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm) 
{
f0100968:	55                   	push   %ebp
f0100969:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f010096b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100970:	5d                   	pop    %ebp
f0100971:	c3                   	ret    

f0100972 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100972:	55                   	push   %ebp
f0100973:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100975:	b8 00 00 00 00       	mov    $0x0,%eax
f010097a:	5d                   	pop    %ebp
f010097b:	c3                   	ret    

f010097c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010097c:	55                   	push   %ebp
f010097d:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010097f:	5d                   	pop    %ebp
f0100980:	c3                   	ret    

f0100981 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100981:	55                   	push   %ebp
f0100982:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100984:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100987:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010098a:	5d                   	pop    %ebp
f010098b:	c3                   	ret    

f010098c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010098c:	55                   	push   %ebp
f010098d:	89 e5                	mov    %esp,%ebp
f010098f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100992:	89 d1                	mov    %edx,%ecx
f0100994:	c1 e9 16             	shr    $0x16,%ecx
f0100997:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010099a:	a8 01                	test   $0x1,%al
f010099c:	74 4d                	je     f01009eb <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010099e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009a3:	89 c1                	mov    %eax,%ecx
f01009a5:	c1 e9 0c             	shr    $0xc,%ecx
f01009a8:	3b 0d e0 29 11 f0    	cmp    0xf01129e0,%ecx
f01009ae:	72 20                	jb     f01009d0 <check_va2pa+0x44>
f01009b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009b4:	c7 44 24 08 84 24 10 	movl   $0xf0102484,0x8(%esp)
f01009bb:	f0 
f01009bc:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f01009c3:	00 
f01009c4:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f01009cb:	e8 b0 f6 ff ff       	call   f0100080 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01009d0:	c1 ea 0c             	shr    $0xc,%edx
f01009d3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009d9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009e0:	a8 01                	test   $0x1,%al
f01009e2:	74 07                	je     f01009eb <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e9:	eb 05                	jmp    f01009f0 <check_va2pa+0x64>
f01009eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01009f0:	c9                   	leave  
f01009f1:	c3                   	ret    

f01009f2 <i386_vm_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read (or write). 
void
i386_vm_init(void)
{
f01009f2:	55                   	push   %ebp
f01009f3:	89 e5                	mov    %esp,%ebp
f01009f5:	83 ec 18             	sub    $0x18,%esp
	pde_t* pgdir;
	uint32_t cr0;
	size_t n;

	// Remove this line when you're ready to test this function.
	panic("i386_vm_init: This function is not finished\n");
f01009f8:	c7 44 24 08 a8 24 10 	movl   $0xf01024a8,0x8(%esp)
f01009ff:	f0 
f0100a00:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f0100a07:	00 
f0100a08:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f0100a0f:	e8 6c f6 ff ff       	call   f0100080 <_panic>

f0100a14 <page_check>:
	invlpg(va);
}

void
page_check(void)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
f0100a17:	83 ec 28             	sub    $0x28,%esp
	struct Page *pp, *pp0, *pp1, *pp2;
	struct Page_list fl;
	pte_t *ptep;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
f0100a1a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
f0100a21:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100a28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	assert(page_alloc(&pp0) == 0);
f0100a2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a32:	89 04 24             	mov    %eax,(%esp)
f0100a35:	e8 08 ff ff ff       	call   f0100942 <page_alloc>
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	74 24                	je     f0100a62 <page_check+0x4e>
f0100a3e:	c7 44 24 0c 05 25 10 	movl   $0xf0102505,0xc(%esp)
f0100a45:	f0 
f0100a46:	c7 44 24 08 1b 25 10 	movl   $0xf010251b,0x8(%esp)
f0100a4d:	f0 
f0100a4e:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
f0100a55:	00 
f0100a56:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f0100a5d:	e8 1e f6 ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp1) == 0);
f0100a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0100a65:	89 04 24             	mov    %eax,(%esp)
f0100a68:	e8 d5 fe ff ff       	call   f0100942 <page_alloc>
f0100a6d:	85 c0                	test   %eax,%eax
f0100a6f:	74 24                	je     f0100a95 <page_check+0x81>
f0100a71:	c7 44 24 0c 30 25 10 	movl   $0xf0102530,0xc(%esp)
f0100a78:	f0 
f0100a79:	c7 44 24 08 1b 25 10 	movl   $0xf010251b,0x8(%esp)
f0100a80:	f0 
f0100a81:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
f0100a88:	00 
f0100a89:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f0100a90:	e8 eb f5 ff ff       	call   f0100080 <_panic>
	assert(page_alloc(&pp2) == 0);
f0100a95:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100a98:	89 04 24             	mov    %eax,(%esp)
f0100a9b:	e8 a2 fe ff ff       	call   f0100942 <page_alloc>
f0100aa0:	85 c0                	test   %eax,%eax
f0100aa2:	74 24                	je     f0100ac8 <page_check+0xb4>
f0100aa4:	c7 44 24 0c 46 25 10 	movl   $0xf0102546,0xc(%esp)
f0100aab:	f0 
f0100aac:	c7 44 24 08 1b 25 10 	movl   $0xf010251b,0x8(%esp)
f0100ab3:	f0 
f0100ab4:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
f0100abb:	00 
f0100abc:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f0100ac3:	e8 b8 f5 ff ff       	call   f0100080 <_panic>

	assert(pp0);
f0100ac8:	c7 44 24 0c 5c 25 10 	movl   $0xf010255c,0xc(%esp)
f0100acf:	f0 
f0100ad0:	c7 44 24 08 1b 25 10 	movl   $0xf010251b,0x8(%esp)
f0100ad7:	f0 
f0100ad8:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0100adf:	00 
f0100ae0:	c7 04 24 f9 24 10 f0 	movl   $0xf01024f9,(%esp)
f0100ae7:	e8 94 f5 ff ff       	call   f0100080 <_panic>

f0100aec <nvram_read>:
	sizeof(gdt) - 1, (unsigned long) gdt
};

static int
nvram_read(int r)
{
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	83 ec 18             	sub    $0x18,%esp
f0100af2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100af5:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100af8:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100afa:	89 04 24             	mov    %eax,(%esp)
f0100afd:	e8 6e 04 00 00       	call   f0100f70 <mc146818_read>
f0100b02:	89 c6                	mov    %eax,%esi
f0100b04:	83 c3 01             	add    $0x1,%ebx
f0100b07:	89 1c 24             	mov    %ebx,(%esp)
f0100b0a:	e8 61 04 00 00       	call   f0100f70 <mc146818_read>
f0100b0f:	c1 e0 08             	shl    $0x8,%eax
f0100b12:	09 f0                	or     %esi,%eax
}
f0100b14:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100b17:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100b1a:	89 ec                	mov    %ebp,%esp
f0100b1c:	5d                   	pop    %ebp
f0100b1d:	c3                   	ret    

f0100b1e <i386_detect_memory>:

void
i386_detect_memory(void)
{
f0100b1e:	55                   	push   %ebp
f0100b1f:	89 e5                	mov    %esp,%ebp
f0100b21:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	basemem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PGSIZE);
f0100b24:	b8 15 00 00 00       	mov    $0x15,%eax
f0100b29:	e8 be ff ff ff       	call   f0100aec <nvram_read>
f0100b2e:	c1 e0 0a             	shl    $0xa,%eax
f0100b31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b36:	a3 ac 25 11 f0       	mov    %eax,0xf01125ac
	extmem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PGSIZE);
f0100b3b:	b8 17 00 00 00       	mov    $0x17,%eax
f0100b40:	e8 a7 ff ff ff       	call   f0100aec <nvram_read>
f0100b45:	c1 e0 0a             	shl    $0xa,%eax
f0100b48:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b4d:	a3 b0 25 11 f0       	mov    %eax,0xf01125b0

	// Calculate the maximum physical address based on whether
	// or not there is any extended memory.  See comment in <inc/mmu.h>.
	if (extmem)
f0100b52:	85 c0                	test   %eax,%eax
f0100b54:	74 0c                	je     f0100b62 <i386_detect_memory+0x44>
		maxpa = EXTPHYSMEM + extmem;
f0100b56:	05 00 00 10 00       	add    $0x100000,%eax
f0100b5b:	a3 a8 25 11 f0       	mov    %eax,0xf01125a8
f0100b60:	eb 0a                	jmp    f0100b6c <i386_detect_memory+0x4e>
	else
		maxpa = basemem;
f0100b62:	a1 ac 25 11 f0       	mov    0xf01125ac,%eax
f0100b67:	a3 a8 25 11 f0       	mov    %eax,0xf01125a8

	npage = maxpa / PGSIZE;
f0100b6c:	a1 a8 25 11 f0       	mov    0xf01125a8,%eax
f0100b71:	89 c2                	mov    %eax,%edx
f0100b73:	c1 ea 0c             	shr    $0xc,%edx
f0100b76:	89 15 e0 29 11 f0    	mov    %edx,0xf01129e0

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100b7c:	c1 e8 0a             	shr    $0xa,%eax
f0100b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b83:	c7 04 24 d8 24 10 f0 	movl   $0xf01024d8,(%esp)
f0100b8a:	e8 3c 04 00 00       	call   f0100fcb <cprintf>
	cprintf("base = %dK, extended = %dK\n", (int)(basemem/1024), (int)(extmem/1024));
f0100b8f:	a1 b0 25 11 f0       	mov    0xf01125b0,%eax
f0100b94:	c1 e8 0a             	shr    $0xa,%eax
f0100b97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b9b:	a1 ac 25 11 f0       	mov    0xf01125ac,%eax
f0100ba0:	c1 e8 0a             	shr    $0xa,%eax
f0100ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ba7:	c7 04 24 60 25 10 f0 	movl   $0xf0102560,(%esp)
f0100bae:	e8 18 04 00 00       	call   f0100fcb <cprintf>
}
f0100bb3:	c9                   	leave  
f0100bb4:	c3                   	ret    
	...

f0100bc0 <envid2env>:
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0100bc0:	55                   	push   %ebp
f0100bc1:	89 e5                	mov    %esp,%ebp
f0100bc3:	53                   	push   %ebx
f0100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0100bca:	85 c0                	test   %eax,%eax
f0100bcc:	75 0e                	jne    f0100bdc <envid2env+0x1c>
		*env_store = curenv;
f0100bce:	a1 bc 25 11 f0       	mov    0xf01125bc,%eax
f0100bd3:	89 01                	mov    %eax,(%ecx)
f0100bd5:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0100bda:	eb 54                	jmp    f0100c30 <envid2env+0x70>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0100bdc:	89 c2                	mov    %eax,%edx
f0100bde:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100be4:	6b d2 64             	imul   $0x64,%edx,%edx
f0100be7:	03 15 b8 25 11 f0    	add    0xf01125b8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0100bed:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0100bf1:	74 05                	je     f0100bf8 <envid2env+0x38>
f0100bf3:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0100bf6:	74 0d                	je     f0100c05 <envid2env+0x45>
		*env_store = 0;
f0100bf8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100bfe:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0100c03:	eb 2b                	jmp    f0100c30 <envid2env+0x70>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0100c05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100c09:	74 1e                	je     f0100c29 <envid2env+0x69>
f0100c0b:	a1 bc 25 11 f0       	mov    0xf01125bc,%eax
f0100c10:	39 c2                	cmp    %eax,%edx
f0100c12:	74 15                	je     f0100c29 <envid2env+0x69>
f0100c14:	8b 5a 50             	mov    0x50(%edx),%ebx
f0100c17:	3b 58 4c             	cmp    0x4c(%eax),%ebx
f0100c1a:	74 0d                	je     f0100c29 <envid2env+0x69>
		*env_store = 0;
f0100c1c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100c22:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0100c27:	eb 07                	jmp    f0100c30 <envid2env+0x70>
	}

	*env_store = e;
f0100c29:	89 11                	mov    %edx,(%ecx)
f0100c2b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0100c30:	5b                   	pop    %ebx
f0100c31:	5d                   	pop    %ebp
f0100c32:	c3                   	ret    

f0100c33 <env_init>:
// Insert in reverse order, so that the first call to env_alloc()
// returns envs[0].
//
void
env_init(void)
{
f0100c33:	55                   	push   %ebp
f0100c34:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0100c36:	5d                   	pop    %ebp
f0100c37:	c3                   	ret    

f0100c38 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size)
{
f0100c38:	55                   	push   %ebp
f0100c39:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0100c3b:	5d                   	pop    %ebp
f0100c3c:	c3                   	ret    

f0100c3d <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//  (This function does not return.)
//
void
env_run(struct Env *e)
{
f0100c3d:	55                   	push   %ebp
f0100c3e:	89 e5                	mov    %esp,%ebp
f0100c40:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	
	// LAB 3: Your code here.

        panic("env_run not yet implemented");
f0100c43:	c7 44 24 08 7c 25 10 	movl   $0xf010257c,0x8(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0100c52:	00 
f0100c53:	c7 04 24 98 25 10 f0 	movl   $0xf0102598,(%esp)
f0100c5a:	e8 21 f4 ff ff       	call   f0100080 <_panic>

f0100c5f <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0100c5f:	55                   	push   %ebp
f0100c60:	89 e5                	mov    %esp,%ebp
f0100c62:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0100c65:	8b 65 08             	mov    0x8(%ebp),%esp
f0100c68:	61                   	popa   
f0100c69:	07                   	pop    %es
f0100c6a:	1f                   	pop    %ds
f0100c6b:	83 c4 08             	add    $0x8,%esp
f0100c6e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0100c6f:	c7 44 24 08 a3 25 10 	movl   $0xf01025a3,0x8(%esp)
f0100c76:	f0 
f0100c77:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
f0100c7e:	00 
f0100c7f:	c7 04 24 98 25 10 f0 	movl   $0xf0102598,(%esp)
f0100c86:	e8 f5 f3 ff ff       	call   f0100080 <_panic>

f0100c8b <env_free>:
//
// Frees env e and all memory it uses.
// 
void
env_free(struct Env *e)
{
f0100c8b:	55                   	push   %ebp
f0100c8c:	89 e5                	mov    %esp,%ebp
f0100c8e:	57                   	push   %edi
f0100c8f:	56                   	push   %esi
f0100c90:	53                   	push   %ebx
f0100c91:	83 ec 2c             	sub    $0x2c,%esp
f0100c94:	8b 7d 08             	mov    0x8(%ebp),%edi
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0100c97:	8b 4f 4c             	mov    0x4c(%edi),%ecx
f0100c9a:	8b 15 bc 25 11 f0    	mov    0xf01125bc,%edx
f0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca5:	85 d2                	test   %edx,%edx
f0100ca7:	74 03                	je     f0100cac <env_free+0x21>
f0100ca9:	8b 42 4c             	mov    0x4c(%edx),%eax
f0100cac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb4:	c7 04 24 af 25 10 f0 	movl   $0xf01025af,(%esp)
f0100cbb:	e8 0b 03 00 00       	call   f0100fcb <cprintf>
f0100cc0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cca:	c1 e0 02             	shl    $0x2,%eax
f0100ccd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0100cd0:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100cd3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100cd6:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0100cd9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100cdf:	0f 84 bb 00 00 00    	je     f0100da0 <env_free+0x115>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0100ce5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		pt = (pte_t*) KADDR(pa);
f0100ceb:	89 f0                	mov    %esi,%eax
f0100ced:	c1 e8 0c             	shr    $0xc,%eax
f0100cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100cf3:	3b 05 e0 29 11 f0    	cmp    0xf01129e0,%eax
f0100cf9:	72 20                	jb     f0100d1b <env_free+0x90>
f0100cfb:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cff:	c7 44 24 08 84 24 10 	movl   $0xf0102484,0x8(%esp)
f0100d06:	f0 
f0100d07:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0100d0e:	00 
f0100d0f:	c7 04 24 98 25 10 f0 	movl   $0xf0102598,(%esp)
f0100d16:	e8 65 f3 ff ff       	call   f0100080 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0100d1b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d1e:	c1 e2 16             	shl    $0x16,%edx
f0100d21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100d24:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0100d29:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0100d30:	01 
f0100d31:	74 17                	je     f0100d4a <env_free+0xbf>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0100d33:	89 d8                	mov    %ebx,%eax
f0100d35:	c1 e0 0c             	shl    $0xc,%eax
f0100d38:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0100d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d3f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100d42:	89 04 24             	mov    %eax,(%esp)
f0100d45:	e8 32 fc ff ff       	call   f010097c <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0100d4a:	83 c3 01             	add    $0x1,%ebx
f0100d4d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100d53:	75 d4                	jne    f0100d29 <env_free+0x9e>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0100d55:	8b 47 5c             	mov    0x5c(%edi),%eax
f0100d58:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d5b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100d62:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d65:	3b 05 e0 29 11 f0    	cmp    0xf01129e0,%eax
f0100d6b:	72 1c                	jb     f0100d89 <env_free+0xfe>
		panic("pa2page called with invalid pa");
f0100d6d:	c7 44 24 08 e8 25 10 	movl   $0xf01025e8,0x8(%esp)
f0100d74:	f0 
f0100d75:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0100d7c:	00 
f0100d7d:	c7 04 24 c5 25 10 f0 	movl   $0xf01025c5,(%esp)
f0100d84:	e8 f7 f2 ff ff       	call   f0100080 <_panic>
		page_decref(pa2page(pa));
f0100d89:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d8c:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100d8f:	c1 e0 02             	shl    $0x2,%eax
f0100d92:	03 05 ec 29 11 f0    	add    0xf01129ec,%eax
f0100d98:	89 04 24             	mov    %eax,(%esp)
f0100d9b:	e8 b1 fb ff ff       	call   f0100951 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0100da0:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0100da4:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0100dab:	0f 85 16 ff ff ff    	jne    f0100cc7 <env_free+0x3c>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = e->env_cr3;
f0100db1:	8b 47 60             	mov    0x60(%edi),%eax
	e->env_pgdir = 0;
f0100db4:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	e->env_cr3 = 0;
f0100dbb:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PPN(pa) >= npage)
f0100dc2:	c1 e8 0c             	shr    $0xc,%eax
f0100dc5:	3b 05 e0 29 11 f0    	cmp    0xf01129e0,%eax
f0100dcb:	72 1c                	jb     f0100de9 <env_free+0x15e>
		panic("pa2page called with invalid pa");
f0100dcd:	c7 44 24 08 e8 25 10 	movl   $0xf01025e8,0x8(%esp)
f0100dd4:	f0 
f0100dd5:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0100ddc:	00 
f0100ddd:	c7 04 24 c5 25 10 f0 	movl   $0xf01025c5,(%esp)
f0100de4:	e8 97 f2 ff ff       	call   f0100080 <_panic>
	page_decref(pa2page(pa));
f0100de9:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100dec:	03 05 ec 29 11 f0    	add    0xf01129ec,%eax
f0100df2:	89 04 24             	mov    %eax,(%esp)
f0100df5:	e8 57 fb ff ff       	call   f0100951 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0100dfa:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	LIST_INSERT_HEAD(&env_free_list, e, env_link);
f0100e01:	a1 c0 25 11 f0       	mov    0xf01125c0,%eax
f0100e06:	89 47 44             	mov    %eax,0x44(%edi)
f0100e09:	85 c0                	test   %eax,%eax
f0100e0b:	74 0b                	je     f0100e18 <env_free+0x18d>
f0100e0d:	8d 57 44             	lea    0x44(%edi),%edx
f0100e10:	a1 c0 25 11 f0       	mov    0xf01125c0,%eax
f0100e15:	89 50 48             	mov    %edx,0x48(%eax)
f0100e18:	89 3d c0 25 11 f0    	mov    %edi,0xf01125c0
f0100e1e:	c7 47 48 c0 25 11 f0 	movl   $0xf01125c0,0x48(%edi)
}
f0100e25:	83 c4 2c             	add    $0x2c,%esp
f0100e28:	5b                   	pop    %ebx
f0100e29:	5e                   	pop    %esi
f0100e2a:	5f                   	pop    %edi
f0100e2b:	5d                   	pop    %ebp
f0100e2c:	c3                   	ret    

f0100e2d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0100e2d:	55                   	push   %ebp
f0100e2e:	89 e5                	mov    %esp,%ebp
f0100e30:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0100e33:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e36:	89 04 24             	mov    %eax,(%esp)
f0100e39:	e8 4d fe ff ff       	call   f0100c8b <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0100e3e:	c7 04 24 08 26 10 f0 	movl   $0xf0102608,(%esp)
f0100e45:	e8 81 01 00 00       	call   f0100fcb <cprintf>
	while (1)
		monitor(NULL);
f0100e4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100e51:	e8 26 f9 ff ff       	call   f010077c <monitor>
f0100e56:	eb f2                	jmp    f0100e4a <env_destroy+0x1d>

f0100e58 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0100e58:	55                   	push   %ebp
f0100e59:	89 e5                	mov    %esp,%ebp
f0100e5b:	53                   	push   %ebx
f0100e5c:	83 ec 24             	sub    $0x24,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = LIST_FIRST(&env_free_list)))
f0100e5f:	8b 1d c0 25 11 f0    	mov    0xf01125c0,%ebx
f0100e65:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0100e6a:	85 db                	test   %ebx,%ebx
f0100e6c:	0f 84 f5 00 00 00    	je     f0100f67 <env_alloc+0x10f>
//
static int
env_setup_vm(struct Env *e)
{
	int i, r;
	struct Page *p = NULL;
f0100e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	// Allocate a page for the page directory
	if ((r = page_alloc(&p)) < 0)
f0100e79:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100e7c:	89 04 24             	mov    %eax,(%esp)
f0100e7f:	e8 be fa ff ff       	call   f0100942 <page_alloc>
f0100e84:	85 c0                	test   %eax,%eax
f0100e86:	0f 88 db 00 00 00    	js     f0100f67 <env_alloc+0x10f>

	// LAB 3: Your code here.

	// VPT and UVPT map the env's own page table, with
	// different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PTE_P | PTE_W;
f0100e8c:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0100e8f:	8b 53 60             	mov    0x60(%ebx),%edx
f0100e92:	83 ca 03             	or     $0x3,%edx
f0100e95:	89 90 fc 0e 00 00    	mov    %edx,0xefc(%eax)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PTE_P | PTE_U;
f0100e9b:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0100e9e:	8b 53 60             	mov    0x60(%ebx),%edx
f0100ea1:	83 ca 05             	or     $0x5,%edx
f0100ea4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0100eaa:	8b 43 4c             	mov    0x4c(%ebx),%eax
f0100ead:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0100eb2:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100eb7:	7f 05                	jg     f0100ebe <env_alloc+0x66>
f0100eb9:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0100ebe:	89 da                	mov    %ebx,%edx
f0100ec0:	2b 15 b8 25 11 f0    	sub    0xf01125b8,%edx
f0100ec6:	c1 fa 02             	sar    $0x2,%edx
f0100ec9:	69 d2 29 5c 8f c2    	imul   $0xc28f5c29,%edx,%edx
f0100ecf:	09 d0                	or     %edx,%eax
f0100ed1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0100ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ed7:	89 43 50             	mov    %eax,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0100eda:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0100ee1:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0100ee8:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0100eef:	00 
f0100ef0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ef7:	00 
f0100ef8:	89 1c 24             	mov    %ebx,(%esp)
f0100efb:	e8 96 0c 00 00       	call   f0101b96 <memset>
	// Set up appropriate initial values for the segment registers.
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	e->env_tf.tf_ds = GD_UD | 3;
f0100f00:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0100f06:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0100f0c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0100f12:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0100f19:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e, env_link);
f0100f1f:	8b 43 44             	mov    0x44(%ebx),%eax
f0100f22:	85 c0                	test   %eax,%eax
f0100f24:	74 06                	je     f0100f2c <env_alloc+0xd4>
f0100f26:	8b 53 48             	mov    0x48(%ebx),%edx
f0100f29:	89 50 48             	mov    %edx,0x48(%eax)
f0100f2c:	8b 43 48             	mov    0x48(%ebx),%eax
f0100f2f:	8b 53 44             	mov    0x44(%ebx),%edx
f0100f32:	89 10                	mov    %edx,(%eax)
	*newenv_store = e;
f0100f34:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f37:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0100f39:	8b 4b 4c             	mov    0x4c(%ebx),%ecx
f0100f3c:	8b 15 bc 25 11 f0    	mov    0xf01125bc,%edx
f0100f42:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f47:	85 d2                	test   %edx,%edx
f0100f49:	74 03                	je     f0100f4e <env_alloc+0xf6>
f0100f4b:	8b 42 4c             	mov    0x4c(%edx),%eax
f0100f4e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100f52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f56:	c7 04 24 d3 25 10 f0 	movl   $0xf01025d3,(%esp)
f0100f5d:	e8 69 00 00 00       	call   f0100fcb <cprintf>
f0100f62:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0100f67:	83 c4 24             	add    $0x24,%esp
f0100f6a:	5b                   	pop    %ebx
f0100f6b:	5d                   	pop    %ebp
f0100f6c:	c3                   	ret    
f0100f6d:	00 00                	add    %al,(%eax)
	...

f0100f70 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100f70:	55                   	push   %ebp
f0100f71:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f73:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f78:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f7b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100f7c:	b2 71                	mov    $0x71,%dl
f0100f7e:	ec                   	in     (%dx),%al
f0100f7f:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0100f82:	5d                   	pop    %ebp
f0100f83:	c3                   	ret    

f0100f84 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100f87:	ba 70 00 00 00       	mov    $0x70,%edx
f0100f8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8f:	ee                   	out    %al,(%dx)
f0100f90:	b2 71                	mov    $0x71,%dl
f0100f92:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f95:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100f96:	5d                   	pop    %ebp
f0100f97:	c3                   	ret    

f0100f98 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100f98:	55                   	push   %ebp
f0100f99:	89 e5                	mov    %esp,%ebp
f0100f9b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100f9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fac:	8b 45 08             	mov    0x8(%ebp),%eax
f0100faf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fba:	c7 04 24 e5 0f 10 f0 	movl   $0xf0100fe5,(%esp)
f0100fc1:	e8 6a 04 00 00       	call   f0101430 <vprintfmt>
	return cnt;
}
f0100fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fc9:	c9                   	leave  
f0100fca:	c3                   	ret    

f0100fcb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100fcb:	55                   	push   %ebp
f0100fcc:	89 e5                	mov    %esp,%ebp
f0100fce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100fd1:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fdb:	89 04 24             	mov    %eax,(%esp)
f0100fde:	e8 b5 ff ff ff       	call   f0100f98 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100fe3:	c9                   	leave  
f0100fe4:	c3                   	ret    

f0100fe5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100fe5:	55                   	push   %ebp
f0100fe6:	89 e5                	mov    %esp,%ebp
f0100fe8:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100feb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fee:	89 04 24             	mov    %eax,(%esp)
f0100ff1:	e8 5a f6 ff ff       	call   f0100650 <cputchar>
	*cnt++;
}
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    
	...

f0101000 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101000:	55                   	push   %ebp
f0101001:	89 e5                	mov    %esp,%ebp
f0101003:	57                   	push   %edi
f0101004:	56                   	push   %esi
f0101005:	53                   	push   %ebx
f0101006:	83 ec 14             	sub    $0x14,%esp
f0101009:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010100c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010100f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101012:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101015:	8b 1a                	mov    (%edx),%ebx
f0101017:	8b 01                	mov    (%ecx),%eax
f0101019:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010101c:	39 c3                	cmp    %eax,%ebx
f010101e:	0f 8f 9c 00 00 00    	jg     f01010c0 <stab_binsearch+0xc0>
f0101024:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010102b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010102e:	01 d8                	add    %ebx,%eax
f0101030:	89 c7                	mov    %eax,%edi
f0101032:	c1 ef 1f             	shr    $0x1f,%edi
f0101035:	01 c7                	add    %eax,%edi
f0101037:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101039:	39 df                	cmp    %ebx,%edi
f010103b:	7c 33                	jl     f0101070 <stab_binsearch+0x70>
f010103d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0101040:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101043:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0101048:	39 f0                	cmp    %esi,%eax
f010104a:	0f 84 bc 00 00 00    	je     f010110c <stab_binsearch+0x10c>
f0101050:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0101054:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0101058:	89 f8                	mov    %edi,%eax
			m--;
f010105a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010105d:	39 d8                	cmp    %ebx,%eax
f010105f:	7c 0f                	jl     f0101070 <stab_binsearch+0x70>
f0101061:	0f b6 0a             	movzbl (%edx),%ecx
f0101064:	83 ea 0c             	sub    $0xc,%edx
f0101067:	39 f1                	cmp    %esi,%ecx
f0101069:	75 ef                	jne    f010105a <stab_binsearch+0x5a>
f010106b:	e9 9e 00 00 00       	jmp    f010110e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101070:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0101073:	eb 3c                	jmp    f01010b1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0101075:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101078:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010107a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010107d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0101084:	eb 2b                	jmp    f01010b1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0101086:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0101089:	76 14                	jbe    f010109f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010108b:	83 e8 01             	sub    $0x1,%eax
f010108e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101091:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101094:	89 02                	mov    %eax,(%edx)
f0101096:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010109d:	eb 12                	jmp    f01010b1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010109f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01010a2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f01010a4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01010a8:	89 c3                	mov    %eax,%ebx
f01010aa:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01010b1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01010b4:	0f 8d 71 ff ff ff    	jge    f010102b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01010ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010be:	75 0f                	jne    f01010cf <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01010c0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01010c3:	8b 03                	mov    (%ebx),%eax
f01010c5:	83 e8 01             	sub    $0x1,%eax
f01010c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01010cb:	89 02                	mov    %eax,(%edx)
f01010cd:	eb 57                	jmp    f0101126 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01010cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01010d2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01010d4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01010d7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01010d9:	39 c1                	cmp    %eax,%ecx
f01010db:	7d 28                	jge    f0101105 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01010dd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01010e0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01010e3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01010e8:	39 f2                	cmp    %esi,%edx
f01010ea:	74 19                	je     f0101105 <stab_binsearch+0x105>
f01010ec:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01010f0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f01010f4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01010f7:	39 c1                	cmp    %eax,%ecx
f01010f9:	7d 0a                	jge    f0101105 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01010fb:	0f b6 1a             	movzbl (%edx),%ebx
f01010fe:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101101:	39 f3                	cmp    %esi,%ebx
f0101103:	75 ef                	jne    f01010f4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0101105:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101108:	89 02                	mov    %eax,(%edx)
f010110a:	eb 1a                	jmp    f0101126 <stab_binsearch+0x126>
	}
}
f010110c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010110e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0101111:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101114:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101118:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010111b:	0f 82 54 ff ff ff    	jb     f0101075 <stab_binsearch+0x75>
f0101121:	e9 60 ff ff ff       	jmp    f0101086 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0101126:	83 c4 14             	add    $0x14,%esp
f0101129:	5b                   	pop    %ebx
f010112a:	5e                   	pop    %esi
f010112b:	5f                   	pop    %edi
f010112c:	5d                   	pop    %ebp
f010112d:	c3                   	ret    

f010112e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010112e:	55                   	push   %ebp
f010112f:	89 e5                	mov    %esp,%ebp
f0101131:	83 ec 28             	sub    $0x28,%esp
f0101134:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101137:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010113a:	8b 75 08             	mov    0x8(%ebp),%esi
f010113d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101140:	c7 03 40 26 10 f0    	movl   $0xf0102640,(%ebx)
	info->eip_line = 0;
f0101146:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010114d:	c7 43 08 40 26 10 f0 	movl   $0xf0102640,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101154:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010115b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010115e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101165:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010116b:	76 12                	jbe    f010117f <debuginfo_eip+0x51>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010116d:	b8 ff 95 10 f0       	mov    $0xf01095ff,%eax
f0101172:	3d e1 70 10 f0       	cmp    $0xf01070e1,%eax
f0101177:	0f 86 2b 01 00 00    	jbe    f01012a8 <debuginfo_eip+0x17a>
f010117d:	eb 1c                	jmp    f010119b <debuginfo_eip+0x6d>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010117f:	c7 44 24 08 4a 26 10 	movl   $0xf010264a,0x8(%esp)
f0101186:	f0 
f0101187:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
f010118e:	00 
f010118f:	c7 04 24 57 26 10 f0 	movl   $0xf0102657,(%esp)
f0101196:	e8 e5 ee ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010119b:	80 3d fe 95 10 f0 00 	cmpb   $0x0,0xf01095fe
f01011a2:	0f 85 00 01 00 00    	jne    f01012a8 <debuginfo_eip+0x17a>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01011a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	rfile = (stab_end - stabs) - 1;
f01011af:	b8 e0 70 10 f0       	mov    $0xf01070e0,%eax
f01011b4:	2d 74 28 10 f0       	sub    $0xf0102874,%eax
f01011b9:	c1 f8 02             	sar    $0x2,%eax
f01011bc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01011c2:	83 e8 01             	sub    $0x1,%eax
f01011c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01011c8:	8d 4d f0             	lea    -0x10(%ebp),%ecx
f01011cb:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01011ce:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011d2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01011d9:	b8 74 28 10 f0       	mov    $0xf0102874,%eax
f01011de:	e8 1d fe ff ff       	call   f0101000 <stab_binsearch>
	if (lfile == 0)
f01011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011e6:	85 c0                	test   %eax,%eax
f01011e8:	0f 84 ba 00 00 00    	je     f01012a8 <debuginfo_eip+0x17a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01011ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
	rfun = rfile;
f01011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01011f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01011f7:	8d 4d e8             	lea    -0x18(%ebp),%ecx
f01011fa:	8d 55 ec             	lea    -0x14(%ebp),%edx
f01011fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101201:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101208:	b8 74 28 10 f0       	mov    $0xf0102874,%eax
f010120d:	e8 ee fd ff ff       	call   f0101000 <stab_binsearch>

	if (lfun <= rfun) {
f0101212:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101215:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0101218:	7f 31                	jg     f010124b <debuginfo_eip+0x11d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010121a:	6b c0 0c             	imul   $0xc,%eax,%eax
f010121d:	8b 80 74 28 10 f0    	mov    -0xfefd78c(%eax),%eax
f0101223:	ba ff 95 10 f0       	mov    $0xf01095ff,%edx
f0101228:	81 ea e1 70 10 f0    	sub    $0xf01070e1,%edx
f010122e:	39 d0                	cmp    %edx,%eax
f0101230:	73 08                	jae    f010123a <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101232:	05 e1 70 10 f0       	add    $0xf01070e1,%eax
f0101237:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010123a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010123d:	6b c6 0c             	imul   $0xc,%esi,%eax
f0101240:	8b 80 7c 28 10 f0    	mov    -0xfefd784(%eax),%eax
f0101246:	89 43 10             	mov    %eax,0x10(%ebx)
f0101249:	eb 06                	jmp    f0101251 <debuginfo_eip+0x123>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010124b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010124e:	8b 75 f4             	mov    -0xc(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101251:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101258:	00 
f0101259:	8b 43 08             	mov    0x8(%ebx),%eax
f010125c:	89 04 24             	mov    %eax,(%esp)
f010125f:	e8 07 09 00 00       	call   f0101b6b <strfind>
f0101264:	2b 43 08             	sub    0x8(%ebx),%eax
f0101267:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f010126a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010126d:	6b c6 0c             	imul   $0xc,%esi,%eax
f0101270:	05 7c 28 10 f0       	add    $0xf010287c,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101275:	eb 06                	jmp    f010127d <debuginfo_eip+0x14f>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0101277:	83 ee 01             	sub    $0x1,%esi
f010127a:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010127d:	39 ce                	cmp    %ecx,%esi
f010127f:	7c 2e                	jl     f01012af <debuginfo_eip+0x181>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101281:	0f b6 50 fc          	movzbl -0x4(%eax),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101285:	80 fa 84             	cmp    $0x84,%dl
f0101288:	74 34                	je     f01012be <debuginfo_eip+0x190>
f010128a:	80 fa 64             	cmp    $0x64,%dl
f010128d:	75 e8                	jne    f0101277 <debuginfo_eip+0x149>
f010128f:	83 38 00             	cmpl   $0x0,(%eax)
f0101292:	74 e3                	je     f0101277 <debuginfo_eip+0x149>
f0101294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101298:	eb 24                	jmp    f01012be <debuginfo_eip+0x190>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010129a:	05 e1 70 10 f0       	add    $0xf01070e1,%eax
f010129f:	89 03                	mov    %eax,(%ebx)
f01012a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a6:	eb 0c                	jmp    f01012b4 <debuginfo_eip+0x186>
f01012a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012ad:	eb 05                	jmp    f01012b4 <debuginfo_eip+0x186>
f01012af:	b8 00 00 00 00       	mov    $0x0,%eax
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
}
f01012b4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012b7:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012ba:	89 ec                	mov    %ebp,%esp
f01012bc:	5d                   	pop    %ebp
f01012bd:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01012be:	6b f6 0c             	imul   $0xc,%esi,%esi
f01012c1:	8b 86 74 28 10 f0    	mov    -0xfefd78c(%esi),%eax
f01012c7:	ba ff 95 10 f0       	mov    $0xf01095ff,%edx
f01012cc:	81 ea e1 70 10 f0    	sub    $0xf01070e1,%edx
f01012d2:	39 d0                	cmp    %edx,%eax
f01012d4:	72 c4                	jb     f010129a <debuginfo_eip+0x16c>
f01012d6:	eb d7                	jmp    f01012af <debuginfo_eip+0x181>
	...

f01012e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01012e0:	55                   	push   %ebp
f01012e1:	89 e5                	mov    %esp,%ebp
f01012e3:	57                   	push   %edi
f01012e4:	56                   	push   %esi
f01012e5:	53                   	push   %ebx
f01012e6:	83 ec 4c             	sub    $0x4c,%esp
f01012e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012ec:	89 d6                	mov    %edx,%esi
f01012ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01012fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01012fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101300:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101303:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101306:	b9 00 00 00 00       	mov    $0x0,%ecx
f010130b:	39 d1                	cmp    %edx,%ecx
f010130d:	72 15                	jb     f0101324 <printnum+0x44>
f010130f:	77 07                	ja     f0101318 <printnum+0x38>
f0101311:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101314:	39 d0                	cmp    %edx,%eax
f0101316:	76 0c                	jbe    f0101324 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101318:	83 eb 01             	sub    $0x1,%ebx
f010131b:	85 db                	test   %ebx,%ebx
f010131d:	8d 76 00             	lea    0x0(%esi),%esi
f0101320:	7f 61                	jg     f0101383 <printnum+0xa3>
f0101322:	eb 70                	jmp    f0101394 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101324:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0101328:	83 eb 01             	sub    $0x1,%ebx
f010132b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010132f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101333:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101337:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010133b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010133e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0101341:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101344:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010134f:	00 
f0101350:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101353:	89 04 24             	mov    %eax,(%esp)
f0101356:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101359:	89 54 24 04          	mov    %edx,0x4(%esp)
f010135d:	e8 4e 0a 00 00       	call   f0101db0 <__udivdi3>
f0101362:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101365:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010136c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101370:	89 04 24             	mov    %eax,(%esp)
f0101373:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101377:	89 f2                	mov    %esi,%edx
f0101379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010137c:	e8 5f ff ff ff       	call   f01012e0 <printnum>
f0101381:	eb 11                	jmp    f0101394 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101383:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101387:	89 3c 24             	mov    %edi,(%esp)
f010138a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010138d:	83 eb 01             	sub    $0x1,%ebx
f0101390:	85 db                	test   %ebx,%ebx
f0101392:	7f ef                	jg     f0101383 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101394:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101398:	8b 74 24 04          	mov    0x4(%esp),%esi
f010139c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010139f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01013aa:	00 
f01013ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01013ae:	89 14 24             	mov    %edx,(%esp)
f01013b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01013b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01013b8:	e8 23 0b 00 00       	call   f0101ee0 <__umoddi3>
f01013bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013c1:	0f be 80 65 26 10 f0 	movsbl -0xfefd99b(%eax),%eax
f01013c8:	89 04 24             	mov    %eax,(%esp)
f01013cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01013ce:	83 c4 4c             	add    $0x4c,%esp
f01013d1:	5b                   	pop    %ebx
f01013d2:	5e                   	pop    %esi
f01013d3:	5f                   	pop    %edi
f01013d4:	5d                   	pop    %ebp
f01013d5:	c3                   	ret    

f01013d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01013d6:	55                   	push   %ebp
f01013d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01013d9:	83 fa 01             	cmp    $0x1,%edx
f01013dc:	7e 0f                	jle    f01013ed <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f01013de:	8b 10                	mov    (%eax),%edx
f01013e0:	83 c2 08             	add    $0x8,%edx
f01013e3:	89 10                	mov    %edx,(%eax)
f01013e5:	8b 42 f8             	mov    -0x8(%edx),%eax
f01013e8:	8b 52 fc             	mov    -0x4(%edx),%edx
f01013eb:	eb 24                	jmp    f0101411 <getuint+0x3b>
	else if (lflag)
f01013ed:	85 d2                	test   %edx,%edx
f01013ef:	74 11                	je     f0101402 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f01013f1:	8b 10                	mov    (%eax),%edx
f01013f3:	83 c2 04             	add    $0x4,%edx
f01013f6:	89 10                	mov    %edx,(%eax)
f01013f8:	8b 42 fc             	mov    -0x4(%edx),%eax
f01013fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101400:	eb 0f                	jmp    f0101411 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0101402:	8b 10                	mov    (%eax),%edx
f0101404:	83 c2 04             	add    $0x4,%edx
f0101407:	89 10                	mov    %edx,(%eax)
f0101409:	8b 42 fc             	mov    -0x4(%edx),%eax
f010140c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101411:	5d                   	pop    %ebp
f0101412:	c3                   	ret    

f0101413 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101413:	55                   	push   %ebp
f0101414:	89 e5                	mov    %esp,%ebp
f0101416:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101419:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010141d:	8b 10                	mov    (%eax),%edx
f010141f:	3b 50 04             	cmp    0x4(%eax),%edx
f0101422:	73 0a                	jae    f010142e <sprintputch+0x1b>
		*b->buf++ = ch;
f0101424:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101427:	88 0a                	mov    %cl,(%edx)
f0101429:	83 c2 01             	add    $0x1,%edx
f010142c:	89 10                	mov    %edx,(%eax)
}
f010142e:	5d                   	pop    %ebp
f010142f:	c3                   	ret    

f0101430 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101430:	55                   	push   %ebp
f0101431:	89 e5                	mov    %esp,%ebp
f0101433:	57                   	push   %edi
f0101434:	56                   	push   %esi
f0101435:	53                   	push   %ebx
f0101436:	83 ec 5c             	sub    $0x5c,%esp
f0101439:	8b 7d 08             	mov    0x8(%ebp),%edi
f010143c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010143f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101442:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0101449:	eb 11                	jmp    f010145c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010144b:	85 c0                	test   %eax,%eax
f010144d:	0f 84 11 04 00 00    	je     f0101864 <vprintfmt+0x434>
				return;
			putch(ch, putdat);
f0101453:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101457:	89 04 24             	mov    %eax,(%esp)
f010145a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010145c:	0f b6 03             	movzbl (%ebx),%eax
f010145f:	83 c3 01             	add    $0x1,%ebx
f0101462:	83 f8 25             	cmp    $0x25,%eax
f0101465:	75 e4                	jne    f010144b <vprintfmt+0x1b>
f0101467:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010146b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0101472:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101479:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101480:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101485:	eb 06                	jmp    f010148d <vprintfmt+0x5d>
f0101487:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f010148b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010148d:	0f b6 13             	movzbl (%ebx),%edx
f0101490:	0f b6 c2             	movzbl %dl,%eax
f0101493:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101496:	8d 43 01             	lea    0x1(%ebx),%eax
f0101499:	83 ea 23             	sub    $0x23,%edx
f010149c:	80 fa 55             	cmp    $0x55,%dl
f010149f:	0f 87 a2 03 00 00    	ja     f0101847 <vprintfmt+0x417>
f01014a5:	0f b6 d2             	movzbl %dl,%edx
f01014a8:	ff 24 95 f0 26 10 f0 	jmp    *-0xfefd910(,%edx,4)
f01014af:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f01014b3:	eb d6                	jmp    f010148b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01014b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01014b8:	83 ea 30             	sub    $0x30,%edx
f01014bb:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f01014be:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01014c1:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01014c4:	83 fb 09             	cmp    $0x9,%ebx
f01014c7:	77 4d                	ja     f0101516 <vprintfmt+0xe6>
f01014c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01014cc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01014cf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f01014d2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01014d5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f01014d9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01014dc:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01014df:	83 fb 09             	cmp    $0x9,%ebx
f01014e2:	76 eb                	jbe    f01014cf <vprintfmt+0x9f>
f01014e4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01014e7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01014ea:	eb 2a                	jmp    f0101516 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01014ec:	8b 55 14             	mov    0x14(%ebp),%edx
f01014ef:	83 c2 04             	add    $0x4,%edx
f01014f2:	89 55 14             	mov    %edx,0x14(%ebp)
f01014f5:	8b 52 fc             	mov    -0x4(%edx),%edx
f01014f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f01014fb:	eb 19                	jmp    f0101516 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f01014fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101500:	c1 fa 1f             	sar    $0x1f,%edx
f0101503:	f7 d2                	not    %edx
f0101505:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0101508:	eb 81                	jmp    f010148b <vprintfmt+0x5b>
f010150a:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0101511:	e9 75 ff ff ff       	jmp    f010148b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0101516:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010151a:	0f 89 6b ff ff ff    	jns    f010148b <vprintfmt+0x5b>
f0101520:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101523:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101526:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101529:	89 55 cc             	mov    %edx,-0x34(%ebp)
f010152c:	e9 5a ff ff ff       	jmp    f010148b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101531:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0101534:	e9 52 ff ff ff       	jmp    f010148b <vprintfmt+0x5b>
f0101539:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010153c:	8b 45 14             	mov    0x14(%ebp),%eax
f010153f:	83 c0 04             	add    $0x4,%eax
f0101542:	89 45 14             	mov    %eax,0x14(%ebp)
f0101545:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101549:	8b 40 fc             	mov    -0x4(%eax),%eax
f010154c:	89 04 24             	mov    %eax,(%esp)
f010154f:	ff d7                	call   *%edi
f0101551:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0101554:	e9 03 ff ff ff       	jmp    f010145c <vprintfmt+0x2c>
f0101559:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010155c:	8b 45 14             	mov    0x14(%ebp),%eax
f010155f:	83 c0 04             	add    $0x4,%eax
f0101562:	89 45 14             	mov    %eax,0x14(%ebp)
f0101565:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101568:	89 c2                	mov    %eax,%edx
f010156a:	c1 fa 1f             	sar    $0x1f,%edx
f010156d:	31 d0                	xor    %edx,%eax
f010156f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0101571:	83 f8 06             	cmp    $0x6,%eax
f0101574:	7f 0b                	jg     f0101581 <vprintfmt+0x151>
f0101576:	8b 14 85 48 28 10 f0 	mov    -0xfefd7b8(,%eax,4),%edx
f010157d:	85 d2                	test   %edx,%edx
f010157f:	75 20                	jne    f01015a1 <vprintfmt+0x171>
				printfmt(putch, putdat, "error %d", err);
f0101581:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101585:	c7 44 24 08 76 26 10 	movl   $0xf0102676,0x8(%esp)
f010158c:	f0 
f010158d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101591:	89 3c 24             	mov    %edi,(%esp)
f0101594:	e8 53 03 00 00       	call   f01018ec <printfmt>
f0101599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f010159c:	e9 bb fe ff ff       	jmp    f010145c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01015a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01015a5:	c7 44 24 08 2d 25 10 	movl   $0xf010252d,0x8(%esp)
f01015ac:	f0 
f01015ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01015b1:	89 3c 24             	mov    %edi,(%esp)
f01015b4:	e8 33 03 00 00       	call   f01018ec <printfmt>
f01015b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01015bc:	e9 9b fe ff ff       	jmp    f010145c <vprintfmt+0x2c>
f01015c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015c4:	89 c3                	mov    %eax,%ebx
f01015c6:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01015c9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01015cc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01015cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01015d2:	83 c0 04             	add    $0x4,%eax
f01015d5:	89 45 14             	mov    %eax,0x14(%ebp)
f01015d8:	8b 40 fc             	mov    -0x4(%eax),%eax
f01015db:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01015de:	85 c0                	test   %eax,%eax
f01015e0:	75 07                	jne    f01015e9 <vprintfmt+0x1b9>
f01015e2:	c7 45 c4 7f 26 10 f0 	movl   $0xf010267f,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f01015e9:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01015ed:	7e 06                	jle    f01015f5 <vprintfmt+0x1c5>
f01015ef:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01015f3:	75 13                	jne    f0101608 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01015f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01015f8:	0f be 02             	movsbl (%edx),%eax
f01015fb:	85 c0                	test   %eax,%eax
f01015fd:	0f 85 99 00 00 00    	jne    f010169c <vprintfmt+0x26c>
f0101603:	e9 86 00 00 00       	jmp    f010168e <vprintfmt+0x25e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101608:	89 54 24 04          	mov    %edx,0x4(%esp)
f010160c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010160f:	89 0c 24             	mov    %ecx,(%esp)
f0101612:	e8 f4 03 00 00       	call   f0101a0b <strnlen>
f0101617:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010161a:	29 c2                	sub    %eax,%edx
f010161c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010161f:	85 d2                	test   %edx,%edx
f0101621:	7e d2                	jle    f01015f5 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0101623:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f0101627:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010162a:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f010162d:	89 d3                	mov    %edx,%ebx
f010162f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101633:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101636:	89 04 24             	mov    %eax,(%esp)
f0101639:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010163b:	83 eb 01             	sub    $0x1,%ebx
f010163e:	85 db                	test   %ebx,%ebx
f0101640:	7f ed                	jg     f010162f <vprintfmt+0x1ff>
f0101642:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0101645:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010164c:	eb a7                	jmp    f01015f5 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010164e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101652:	74 18                	je     f010166c <vprintfmt+0x23c>
f0101654:	8d 50 e0             	lea    -0x20(%eax),%edx
f0101657:	83 fa 5e             	cmp    $0x5e,%edx
f010165a:	76 10                	jbe    f010166c <vprintfmt+0x23c>
					putch('?', putdat);
f010165c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101660:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101667:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010166a:	eb 0a                	jmp    f0101676 <vprintfmt+0x246>
					putch('?', putdat);
				else
					putch(ch, putdat);
f010166c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101670:	89 04 24             	mov    %eax,(%esp)
f0101673:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101676:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010167a:	0f be 03             	movsbl (%ebx),%eax
f010167d:	85 c0                	test   %eax,%eax
f010167f:	74 05                	je     f0101686 <vprintfmt+0x256>
f0101681:	83 c3 01             	add    $0x1,%ebx
f0101684:	eb 29                	jmp    f01016af <vprintfmt+0x27f>
f0101686:	89 fe                	mov    %edi,%esi
f0101688:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010168b:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010168e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101692:	7f 2e                	jg     f01016c2 <vprintfmt+0x292>
f0101694:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101697:	e9 c0 fd ff ff       	jmp    f010145c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010169c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010169f:	83 c2 01             	add    $0x1,%edx
f01016a2:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01016a5:	89 f7                	mov    %esi,%edi
f01016a7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01016aa:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01016ad:	89 d3                	mov    %edx,%ebx
f01016af:	85 f6                	test   %esi,%esi
f01016b1:	78 9b                	js     f010164e <vprintfmt+0x21e>
f01016b3:	83 ee 01             	sub    $0x1,%esi
f01016b6:	79 96                	jns    f010164e <vprintfmt+0x21e>
f01016b8:	89 fe                	mov    %edi,%esi
f01016ba:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01016bd:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f01016c0:	eb cc                	jmp    f010168e <vprintfmt+0x25e>
f01016c2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01016c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01016c8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016cc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01016d3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01016d5:	83 eb 01             	sub    $0x1,%ebx
f01016d8:	85 db                	test   %ebx,%ebx
f01016da:	7f ec                	jg     f01016c8 <vprintfmt+0x298>
f01016dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01016df:	e9 78 fd ff ff       	jmp    f010145c <vprintfmt+0x2c>
f01016e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01016e7:	83 f9 01             	cmp    $0x1,%ecx
f01016ea:	7e 17                	jle    f0101703 <vprintfmt+0x2d3>
		return va_arg(*ap, long long);
f01016ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01016ef:	83 c0 08             	add    $0x8,%eax
f01016f2:	89 45 14             	mov    %eax,0x14(%ebp)
f01016f5:	8b 50 f8             	mov    -0x8(%eax),%edx
f01016f8:	8b 48 fc             	mov    -0x4(%eax),%ecx
f01016fb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01016fe:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101701:	eb 34                	jmp    f0101737 <vprintfmt+0x307>
	else if (lflag)
f0101703:	85 c9                	test   %ecx,%ecx
f0101705:	74 19                	je     f0101720 <vprintfmt+0x2f0>
		return va_arg(*ap, long);
f0101707:	8b 45 14             	mov    0x14(%ebp),%eax
f010170a:	83 c0 04             	add    $0x4,%eax
f010170d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101710:	8b 40 fc             	mov    -0x4(%eax),%eax
f0101713:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101716:	89 c1                	mov    %eax,%ecx
f0101718:	c1 f9 1f             	sar    $0x1f,%ecx
f010171b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010171e:	eb 17                	jmp    f0101737 <vprintfmt+0x307>
	else
		return va_arg(*ap, int);
f0101720:	8b 45 14             	mov    0x14(%ebp),%eax
f0101723:	83 c0 04             	add    $0x4,%eax
f0101726:	89 45 14             	mov    %eax,0x14(%ebp)
f0101729:	8b 40 fc             	mov    -0x4(%eax),%eax
f010172c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010172f:	89 c2                	mov    %eax,%edx
f0101731:	c1 fa 1f             	sar    $0x1f,%edx
f0101734:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101737:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010173a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010173d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101742:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101746:	0f 89 b9 00 00 00    	jns    f0101805 <vprintfmt+0x3d5>
				putch('-', putdat);
f010174c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101750:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101757:	ff d7                	call   *%edi
				num = -(long long) num;
f0101759:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010175c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010175f:	f7 d9                	neg    %ecx
f0101761:	83 d3 00             	adc    $0x0,%ebx
f0101764:	f7 db                	neg    %ebx
f0101766:	b8 0a 00 00 00       	mov    $0xa,%eax
f010176b:	e9 95 00 00 00       	jmp    f0101805 <vprintfmt+0x3d5>
f0101770:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101773:	89 ca                	mov    %ecx,%edx
f0101775:	8d 45 14             	lea    0x14(%ebp),%eax
f0101778:	e8 59 fc ff ff       	call   f01013d6 <getuint>
f010177d:	89 c1                	mov    %eax,%ecx
f010177f:	89 d3                	mov    %edx,%ebx
f0101781:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0101786:	eb 7d                	jmp    f0101805 <vprintfmt+0x3d5>
f0101788:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010178b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010178f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101796:	ff d7                	call   *%edi
			putch('X', putdat);
f0101798:	89 74 24 04          	mov    %esi,0x4(%esp)
f010179c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01017a3:	ff d7                	call   *%edi
			putch('X', putdat);
f01017a5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017a9:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01017b0:	ff d7                	call   *%edi
f01017b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01017b5:	e9 a2 fc ff ff       	jmp    f010145c <vprintfmt+0x2c>
f01017ba:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01017bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017c1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01017c8:	ff d7                	call   *%edi
			putch('x', putdat);
f01017ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01017d5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01017d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01017da:	83 c0 04             	add    $0x4,%eax
f01017dd:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01017e0:	8b 48 fc             	mov    -0x4(%eax),%ecx
f01017e3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01017e8:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01017ed:	eb 16                	jmp    f0101805 <vprintfmt+0x3d5>
f01017ef:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01017f2:	89 ca                	mov    %ecx,%edx
f01017f4:	8d 45 14             	lea    0x14(%ebp),%eax
f01017f7:	e8 da fb ff ff       	call   f01013d6 <getuint>
f01017fc:	89 c1                	mov    %eax,%ecx
f01017fe:	89 d3                	mov    %edx,%ebx
f0101800:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101805:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f0101809:	89 54 24 10          	mov    %edx,0x10(%esp)
f010180d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101810:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101814:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101818:	89 0c 24             	mov    %ecx,(%esp)
f010181b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010181f:	89 f2                	mov    %esi,%edx
f0101821:	89 f8                	mov    %edi,%eax
f0101823:	e8 b8 fa ff ff       	call   f01012e0 <printnum>
f0101828:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f010182b:	e9 2c fc ff ff       	jmp    f010145c <vprintfmt+0x2c>
f0101830:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101833:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101836:	89 74 24 04          	mov    %esi,0x4(%esp)
f010183a:	89 14 24             	mov    %edx,(%esp)
f010183d:	ff d7                	call   *%edi
f010183f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0101842:	e9 15 fc ff ff       	jmp    f010145c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101847:	89 74 24 04          	mov    %esi,0x4(%esp)
f010184b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101852:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101854:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101857:	80 38 25             	cmpb   $0x25,(%eax)
f010185a:	0f 84 fc fb ff ff    	je     f010145c <vprintfmt+0x2c>
f0101860:	89 c3                	mov    %eax,%ebx
f0101862:	eb f0                	jmp    f0101854 <vprintfmt+0x424>
				/* do nothing */;
			break;
		}
	}
}
f0101864:	83 c4 5c             	add    $0x5c,%esp
f0101867:	5b                   	pop    %ebx
f0101868:	5e                   	pop    %esi
f0101869:	5f                   	pop    %edi
f010186a:	5d                   	pop    %ebp
f010186b:	c3                   	ret    

f010186c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010186c:	55                   	push   %ebp
f010186d:	89 e5                	mov    %esp,%ebp
f010186f:	83 ec 28             	sub    $0x28,%esp
f0101872:	8b 45 08             	mov    0x8(%ebp),%eax
f0101875:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101878:	85 c0                	test   %eax,%eax
f010187a:	74 04                	je     f0101880 <vsnprintf+0x14>
f010187c:	85 d2                	test   %edx,%edx
f010187e:	7f 07                	jg     f0101887 <vsnprintf+0x1b>
f0101880:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101885:	eb 3b                	jmp    f01018c2 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101887:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010188a:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f010188e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101891:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101898:	8b 45 14             	mov    0x14(%ebp),%eax
f010189b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010189f:	8b 45 10             	mov    0x10(%ebp),%eax
f01018a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01018a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018ad:	c7 04 24 13 14 10 f0 	movl   $0xf0101413,(%esp)
f01018b4:	e8 77 fb ff ff       	call   f0101430 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01018b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01018c2:	c9                   	leave  
f01018c3:	c3                   	ret    

f01018c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01018c4:	55                   	push   %ebp
f01018c5:	89 e5                	mov    %esp,%ebp
f01018c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01018ca:	8d 45 14             	lea    0x14(%ebp),%eax
f01018cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018d1:	8b 45 10             	mov    0x10(%ebp),%eax
f01018d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018df:	8b 45 08             	mov    0x8(%ebp),%eax
f01018e2:	89 04 24             	mov    %eax,(%esp)
f01018e5:	e8 82 ff ff ff       	call   f010186c <vsnprintf>
	va_end(ap);

	return rc;
}
f01018ea:	c9                   	leave  
f01018eb:	c3                   	ret    

f01018ec <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01018ec:	55                   	push   %ebp
f01018ed:	89 e5                	mov    %esp,%ebp
f01018ef:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01018f2:	8d 45 14             	lea    0x14(%ebp),%eax
f01018f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018f9:	8b 45 10             	mov    0x10(%ebp),%eax
f01018fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101900:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101903:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101907:	8b 45 08             	mov    0x8(%ebp),%eax
f010190a:	89 04 24             	mov    %eax,(%esp)
f010190d:	e8 1e fb ff ff       	call   f0101430 <vprintfmt>
	va_end(ap);
}
f0101912:	c9                   	leave  
f0101913:	c3                   	ret    
	...

f0101920 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101920:	55                   	push   %ebp
f0101921:	89 e5                	mov    %esp,%ebp
f0101923:	57                   	push   %edi
f0101924:	56                   	push   %esi
f0101925:	53                   	push   %ebx
f0101926:	83 ec 1c             	sub    $0x1c,%esp
f0101929:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010192c:	85 c0                	test   %eax,%eax
f010192e:	74 10                	je     f0101940 <readline+0x20>
		cprintf("%s", prompt);
f0101930:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101934:	c7 04 24 2d 25 10 f0 	movl   $0xf010252d,(%esp)
f010193b:	e8 8b f6 ff ff       	call   f0100fcb <cprintf>

	i = 0;
	echoing = iscons(0);
f0101940:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101947:	e8 eb e9 ff ff       	call   f0100337 <iscons>
f010194c:	89 c7                	mov    %eax,%edi
f010194e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101953:	e8 ce e9 ff ff       	call   f0100326 <getchar>
f0101958:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010195a:	85 c0                	test   %eax,%eax
f010195c:	79 17                	jns    f0101975 <readline+0x55>
			cprintf("read error: %e\n", c);
f010195e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101962:	c7 04 24 64 28 10 f0 	movl   $0xf0102864,(%esp)
f0101969:	e8 5d f6 ff ff       	call   f0100fcb <cprintf>
f010196e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101973:	eb 65                	jmp    f01019da <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101975:	83 f8 1f             	cmp    $0x1f,%eax
f0101978:	7e 1f                	jle    f0101999 <readline+0x79>
f010197a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101980:	7f 17                	jg     f0101999 <readline+0x79>
			if (echoing)
f0101982:	85 ff                	test   %edi,%edi
f0101984:	74 08                	je     f010198e <readline+0x6e>
				cputchar(c);
f0101986:	89 04 24             	mov    %eax,(%esp)
f0101989:	e8 c2 ec ff ff       	call   f0100650 <cputchar>
			buf[i++] = c;
f010198e:	88 9e e0 25 11 f0    	mov    %bl,-0xfeeda20(%esi)
f0101994:	83 c6 01             	add    $0x1,%esi
f0101997:	eb ba                	jmp    f0101953 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101999:	83 fb 08             	cmp    $0x8,%ebx
f010199c:	75 15                	jne    f01019b3 <readline+0x93>
f010199e:	85 f6                	test   %esi,%esi
f01019a0:	7e 11                	jle    f01019b3 <readline+0x93>
			if (echoing)
f01019a2:	85 ff                	test   %edi,%edi
f01019a4:	74 08                	je     f01019ae <readline+0x8e>
				cputchar(c);
f01019a6:	89 1c 24             	mov    %ebx,(%esp)
f01019a9:	e8 a2 ec ff ff       	call   f0100650 <cputchar>
			i--;
f01019ae:	83 ee 01             	sub    $0x1,%esi
f01019b1:	eb a0                	jmp    f0101953 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01019b3:	83 fb 0a             	cmp    $0xa,%ebx
f01019b6:	74 0a                	je     f01019c2 <readline+0xa2>
f01019b8:	83 fb 0d             	cmp    $0xd,%ebx
f01019bb:	90                   	nop
f01019bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	75 91                	jne    f0101953 <readline+0x33>
			if (echoing)
f01019c2:	85 ff                	test   %edi,%edi
f01019c4:	74 08                	je     f01019ce <readline+0xae>
				cputchar(c);
f01019c6:	89 1c 24             	mov    %ebx,(%esp)
f01019c9:	e8 82 ec ff ff       	call   f0100650 <cputchar>
			buf[i] = 0;
f01019ce:	c6 86 e0 25 11 f0 00 	movb   $0x0,-0xfeeda20(%esi)
f01019d5:	b8 e0 25 11 f0       	mov    $0xf01125e0,%eax
			return buf;
		}
	}
}
f01019da:	83 c4 1c             	add    $0x1c,%esp
f01019dd:	5b                   	pop    %ebx
f01019de:	5e                   	pop    %esi
f01019df:	5f                   	pop    %edi
f01019e0:	5d                   	pop    %ebp
f01019e1:	c3                   	ret    
	...

f01019f0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01019f0:	55                   	push   %ebp
f01019f1:	89 e5                	mov    %esp,%ebp
f01019f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01019f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01019fb:	80 3a 00             	cmpb   $0x0,(%edx)
f01019fe:	74 09                	je     f0101a09 <strlen+0x19>
		n++;
f0101a00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101a03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101a07:	75 f7                	jne    f0101a00 <strlen+0x10>
		n++;
	return n;
}
f0101a09:	5d                   	pop    %ebp
f0101a0a:	c3                   	ret    

f0101a0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101a0b:	55                   	push   %ebp
f0101a0c:	89 e5                	mov    %esp,%ebp
f0101a0e:	53                   	push   %ebx
f0101a0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101a15:	85 c9                	test   %ecx,%ecx
f0101a17:	74 19                	je     f0101a32 <strnlen+0x27>
f0101a19:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101a1c:	74 14                	je     f0101a32 <strnlen+0x27>
f0101a1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0101a23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101a26:	39 c8                	cmp    %ecx,%eax
f0101a28:	74 0d                	je     f0101a37 <strnlen+0x2c>
f0101a2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0101a2e:	75 f3                	jne    f0101a23 <strnlen+0x18>
f0101a30:	eb 05                	jmp    f0101a37 <strnlen+0x2c>
f0101a32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101a37:	5b                   	pop    %ebx
f0101a38:	5d                   	pop    %ebp
f0101a39:	c3                   	ret    

f0101a3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101a3a:	55                   	push   %ebp
f0101a3b:	89 e5                	mov    %esp,%ebp
f0101a3d:	53                   	push   %ebx
f0101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101a49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101a50:	83 c2 01             	add    $0x1,%edx
f0101a53:	84 c9                	test   %cl,%cl
f0101a55:	75 f2                	jne    f0101a49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101a57:	5b                   	pop    %ebx
f0101a58:	5d                   	pop    %ebp
f0101a59:	c3                   	ret    

f0101a5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101a5a:	55                   	push   %ebp
f0101a5b:	89 e5                	mov    %esp,%ebp
f0101a5d:	56                   	push   %esi
f0101a5e:	53                   	push   %ebx
f0101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a62:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a65:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101a68:	85 f6                	test   %esi,%esi
f0101a6a:	74 18                	je     f0101a84 <strncpy+0x2a>
f0101a6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101a71:	0f b6 1a             	movzbl (%edx),%ebx
f0101a74:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101a77:	80 3a 01             	cmpb   $0x1,(%edx)
f0101a7a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101a7d:	83 c1 01             	add    $0x1,%ecx
f0101a80:	39 ce                	cmp    %ecx,%esi
f0101a82:	77 ed                	ja     f0101a71 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101a84:	5b                   	pop    %ebx
f0101a85:	5e                   	pop    %esi
f0101a86:	5d                   	pop    %ebp
f0101a87:	c3                   	ret    

f0101a88 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101a88:	55                   	push   %ebp
f0101a89:	89 e5                	mov    %esp,%ebp
f0101a8b:	56                   	push   %esi
f0101a8c:	53                   	push   %ebx
f0101a8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a90:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101a93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101a96:	89 f0                	mov    %esi,%eax
f0101a98:	85 c9                	test   %ecx,%ecx
f0101a9a:	74 27                	je     f0101ac3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0101a9c:	83 e9 01             	sub    $0x1,%ecx
f0101a9f:	74 1d                	je     f0101abe <strlcpy+0x36>
f0101aa1:	0f b6 1a             	movzbl (%edx),%ebx
f0101aa4:	84 db                	test   %bl,%bl
f0101aa6:	74 16                	je     f0101abe <strlcpy+0x36>
			*dst++ = *src++;
f0101aa8:	88 18                	mov    %bl,(%eax)
f0101aaa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101aad:	83 e9 01             	sub    $0x1,%ecx
f0101ab0:	74 0e                	je     f0101ac0 <strlcpy+0x38>
			*dst++ = *src++;
f0101ab2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101ab5:	0f b6 1a             	movzbl (%edx),%ebx
f0101ab8:	84 db                	test   %bl,%bl
f0101aba:	75 ec                	jne    f0101aa8 <strlcpy+0x20>
f0101abc:	eb 02                	jmp    f0101ac0 <strlcpy+0x38>
f0101abe:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101ac0:	c6 00 00             	movb   $0x0,(%eax)
f0101ac3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101ac5:	5b                   	pop    %ebx
f0101ac6:	5e                   	pop    %esi
f0101ac7:	5d                   	pop    %ebp
f0101ac8:	c3                   	ret    

f0101ac9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101ac9:	55                   	push   %ebp
f0101aca:	89 e5                	mov    %esp,%ebp
f0101acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101acf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101ad2:	0f b6 01             	movzbl (%ecx),%eax
f0101ad5:	84 c0                	test   %al,%al
f0101ad7:	74 15                	je     f0101aee <strcmp+0x25>
f0101ad9:	3a 02                	cmp    (%edx),%al
f0101adb:	75 11                	jne    f0101aee <strcmp+0x25>
		p++, q++;
f0101add:	83 c1 01             	add    $0x1,%ecx
f0101ae0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101ae3:	0f b6 01             	movzbl (%ecx),%eax
f0101ae6:	84 c0                	test   %al,%al
f0101ae8:	74 04                	je     f0101aee <strcmp+0x25>
f0101aea:	3a 02                	cmp    (%edx),%al
f0101aec:	74 ef                	je     f0101add <strcmp+0x14>
f0101aee:	0f b6 c0             	movzbl %al,%eax
f0101af1:	0f b6 12             	movzbl (%edx),%edx
f0101af4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101af6:	5d                   	pop    %ebp
f0101af7:	c3                   	ret    

f0101af8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101af8:	55                   	push   %ebp
f0101af9:	89 e5                	mov    %esp,%ebp
f0101afb:	53                   	push   %ebx
f0101afc:	8b 55 08             	mov    0x8(%ebp),%edx
f0101aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101b02:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	74 23                	je     f0101b2c <strncmp+0x34>
f0101b09:	0f b6 1a             	movzbl (%edx),%ebx
f0101b0c:	84 db                	test   %bl,%bl
f0101b0e:	74 24                	je     f0101b34 <strncmp+0x3c>
f0101b10:	3a 19                	cmp    (%ecx),%bl
f0101b12:	75 20                	jne    f0101b34 <strncmp+0x3c>
f0101b14:	83 e8 01             	sub    $0x1,%eax
f0101b17:	74 13                	je     f0101b2c <strncmp+0x34>
		n--, p++, q++;
f0101b19:	83 c2 01             	add    $0x1,%edx
f0101b1c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101b1f:	0f b6 1a             	movzbl (%edx),%ebx
f0101b22:	84 db                	test   %bl,%bl
f0101b24:	74 0e                	je     f0101b34 <strncmp+0x3c>
f0101b26:	3a 19                	cmp    (%ecx),%bl
f0101b28:	74 ea                	je     f0101b14 <strncmp+0x1c>
f0101b2a:	eb 08                	jmp    f0101b34 <strncmp+0x3c>
f0101b2c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101b31:	5b                   	pop    %ebx
f0101b32:	5d                   	pop    %ebp
f0101b33:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101b34:	0f b6 02             	movzbl (%edx),%eax
f0101b37:	0f b6 11             	movzbl (%ecx),%edx
f0101b3a:	29 d0                	sub    %edx,%eax
f0101b3c:	eb f3                	jmp    f0101b31 <strncmp+0x39>

f0101b3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101b3e:	55                   	push   %ebp
f0101b3f:	89 e5                	mov    %esp,%ebp
f0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101b48:	0f b6 10             	movzbl (%eax),%edx
f0101b4b:	84 d2                	test   %dl,%dl
f0101b4d:	74 15                	je     f0101b64 <strchr+0x26>
		if (*s == c)
f0101b4f:	38 ca                	cmp    %cl,%dl
f0101b51:	75 07                	jne    f0101b5a <strchr+0x1c>
f0101b53:	eb 14                	jmp    f0101b69 <strchr+0x2b>
f0101b55:	38 ca                	cmp    %cl,%dl
f0101b57:	90                   	nop
f0101b58:	74 0f                	je     f0101b69 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101b5a:	83 c0 01             	add    $0x1,%eax
f0101b5d:	0f b6 10             	movzbl (%eax),%edx
f0101b60:	84 d2                	test   %dl,%dl
f0101b62:	75 f1                	jne    f0101b55 <strchr+0x17>
f0101b64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101b69:	5d                   	pop    %ebp
f0101b6a:	c3                   	ret    

f0101b6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101b6b:	55                   	push   %ebp
f0101b6c:	89 e5                	mov    %esp,%ebp
f0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101b75:	0f b6 10             	movzbl (%eax),%edx
f0101b78:	84 d2                	test   %dl,%dl
f0101b7a:	74 18                	je     f0101b94 <strfind+0x29>
		if (*s == c)
f0101b7c:	38 ca                	cmp    %cl,%dl
f0101b7e:	75 0a                	jne    f0101b8a <strfind+0x1f>
f0101b80:	eb 12                	jmp    f0101b94 <strfind+0x29>
f0101b82:	38 ca                	cmp    %cl,%dl
f0101b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b88:	74 0a                	je     f0101b94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101b8a:	83 c0 01             	add    $0x1,%eax
f0101b8d:	0f b6 10             	movzbl (%eax),%edx
f0101b90:	84 d2                	test   %dl,%dl
f0101b92:	75 ee                	jne    f0101b82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101b94:	5d                   	pop    %ebp
f0101b95:	c3                   	ret    

f0101b96 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101b96:	55                   	push   %ebp
f0101b97:	89 e5                	mov    %esp,%ebp
f0101b99:	53                   	push   %ebx
f0101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101ba3:	89 da                	mov    %ebx,%edx
f0101ba5:	83 ea 01             	sub    $0x1,%edx
f0101ba8:	78 0e                	js     f0101bb8 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f0101baa:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f0101bac:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f0101baf:	88 0a                	mov    %cl,(%edx)
f0101bb1:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101bb4:	39 da                	cmp    %ebx,%edx
f0101bb6:	75 f7                	jne    f0101baf <memset+0x19>
		*p++ = c;

	return v;
}
f0101bb8:	5b                   	pop    %ebx
f0101bb9:	5d                   	pop    %ebp
f0101bba:	c3                   	ret    

f0101bbb <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101bbb:	55                   	push   %ebp
f0101bbc:	89 e5                	mov    %esp,%ebp
f0101bbe:	56                   	push   %esi
f0101bbf:	53                   	push   %ebx
f0101bc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bc3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101bc9:	85 db                	test   %ebx,%ebx
f0101bcb:	74 13                	je     f0101be0 <memcpy+0x25>
f0101bcd:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0101bd2:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101bd6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101bd9:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101bdc:	39 da                	cmp    %ebx,%edx
f0101bde:	75 f2                	jne    f0101bd2 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f0101be0:	5b                   	pop    %ebx
f0101be1:	5e                   	pop    %esi
f0101be2:	5d                   	pop    %ebp
f0101be3:	c3                   	ret    

f0101be4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101be4:	55                   	push   %ebp
f0101be5:	89 e5                	mov    %esp,%ebp
f0101be7:	57                   	push   %edi
f0101be8:	56                   	push   %esi
f0101be9:	53                   	push   %ebx
f0101bea:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bed:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0101bf3:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0101bf5:	39 c6                	cmp    %eax,%esi
f0101bf7:	72 0b                	jb     f0101c04 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0101bf9:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f0101bfe:	85 db                	test   %ebx,%ebx
f0101c00:	75 2d                	jne    f0101c2f <memmove+0x4b>
f0101c02:	eb 39                	jmp    f0101c3d <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101c04:	01 df                	add    %ebx,%edi
f0101c06:	39 f8                	cmp    %edi,%eax
f0101c08:	73 ef                	jae    f0101bf9 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f0101c0a:	85 db                	test   %ebx,%ebx
f0101c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c10:	74 2b                	je     f0101c3d <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f0101c12:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f0101c15:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f0101c1a:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f0101c1f:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f0101c23:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0101c26:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0101c29:	85 c9                	test   %ecx,%ecx
f0101c2b:	75 ed                	jne    f0101c1a <memmove+0x36>
f0101c2d:	eb 0e                	jmp    f0101c3d <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0101c2f:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101c33:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101c36:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101c39:	39 d3                	cmp    %edx,%ebx
f0101c3b:	75 f2                	jne    f0101c2f <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f0101c3d:	5b                   	pop    %ebx
f0101c3e:	5e                   	pop    %esi
f0101c3f:	5f                   	pop    %edi
f0101c40:	5d                   	pop    %ebp
f0101c41:	c3                   	ret    

f0101c42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101c42:	55                   	push   %ebp
f0101c43:	89 e5                	mov    %esp,%ebp
f0101c45:	57                   	push   %edi
f0101c46:	56                   	push   %esi
f0101c47:	53                   	push   %ebx
f0101c48:	8b 75 08             	mov    0x8(%ebp),%esi
f0101c4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101c4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101c51:	85 c9                	test   %ecx,%ecx
f0101c53:	74 36                	je     f0101c8b <memcmp+0x49>
		if (*s1 != *s2)
f0101c55:	0f b6 06             	movzbl (%esi),%eax
f0101c58:	0f b6 1f             	movzbl (%edi),%ebx
f0101c5b:	38 d8                	cmp    %bl,%al
f0101c5d:	74 20                	je     f0101c7f <memcmp+0x3d>
f0101c5f:	eb 14                	jmp    f0101c75 <memcmp+0x33>
f0101c61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101c66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0101c6b:	83 c2 01             	add    $0x1,%edx
f0101c6e:	83 e9 01             	sub    $0x1,%ecx
f0101c71:	38 d8                	cmp    %bl,%al
f0101c73:	74 12                	je     f0101c87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101c75:	0f b6 c0             	movzbl %al,%eax
f0101c78:	0f b6 db             	movzbl %bl,%ebx
f0101c7b:	29 d8                	sub    %ebx,%eax
f0101c7d:	eb 11                	jmp    f0101c90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101c7f:	83 e9 01             	sub    $0x1,%ecx
f0101c82:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c87:	85 c9                	test   %ecx,%ecx
f0101c89:	75 d6                	jne    f0101c61 <memcmp+0x1f>
f0101c8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101c90:	5b                   	pop    %ebx
f0101c91:	5e                   	pop    %esi
f0101c92:	5f                   	pop    %edi
f0101c93:	5d                   	pop    %ebp
f0101c94:	c3                   	ret    

f0101c95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101c95:	55                   	push   %ebp
f0101c96:	89 e5                	mov    %esp,%ebp
f0101c98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101c9b:	89 c2                	mov    %eax,%edx
f0101c9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101ca0:	39 d0                	cmp    %edx,%eax
f0101ca2:	73 15                	jae    f0101cb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101ca4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101ca8:	38 08                	cmp    %cl,(%eax)
f0101caa:	75 06                	jne    f0101cb2 <memfind+0x1d>
f0101cac:	eb 0b                	jmp    f0101cb9 <memfind+0x24>
f0101cae:	38 08                	cmp    %cl,(%eax)
f0101cb0:	74 07                	je     f0101cb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101cb2:	83 c0 01             	add    $0x1,%eax
f0101cb5:	39 c2                	cmp    %eax,%edx
f0101cb7:	77 f5                	ja     f0101cae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101cb9:	5d                   	pop    %ebp
f0101cba:	c3                   	ret    

f0101cbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101cbb:	55                   	push   %ebp
f0101cbc:	89 e5                	mov    %esp,%ebp
f0101cbe:	57                   	push   %edi
f0101cbf:	56                   	push   %esi
f0101cc0:	53                   	push   %ebx
f0101cc1:	83 ec 04             	sub    $0x4,%esp
f0101cc4:	8b 55 08             	mov    0x8(%ebp),%edx
f0101cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101cca:	0f b6 02             	movzbl (%edx),%eax
f0101ccd:	3c 20                	cmp    $0x20,%al
f0101ccf:	74 04                	je     f0101cd5 <strtol+0x1a>
f0101cd1:	3c 09                	cmp    $0x9,%al
f0101cd3:	75 0e                	jne    f0101ce3 <strtol+0x28>
		s++;
f0101cd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101cd8:	0f b6 02             	movzbl (%edx),%eax
f0101cdb:	3c 20                	cmp    $0x20,%al
f0101cdd:	74 f6                	je     f0101cd5 <strtol+0x1a>
f0101cdf:	3c 09                	cmp    $0x9,%al
f0101ce1:	74 f2                	je     f0101cd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101ce3:	3c 2b                	cmp    $0x2b,%al
f0101ce5:	75 0c                	jne    f0101cf3 <strtol+0x38>
		s++;
f0101ce7:	83 c2 01             	add    $0x1,%edx
f0101cea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101cf1:	eb 15                	jmp    f0101d08 <strtol+0x4d>
	else if (*s == '-')
f0101cf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101cfa:	3c 2d                	cmp    $0x2d,%al
f0101cfc:	75 0a                	jne    f0101d08 <strtol+0x4d>
		s++, neg = 1;
f0101cfe:	83 c2 01             	add    $0x1,%edx
f0101d01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d08:	85 db                	test   %ebx,%ebx
f0101d0a:	0f 94 c0             	sete   %al
f0101d0d:	74 05                	je     f0101d14 <strtol+0x59>
f0101d0f:	83 fb 10             	cmp    $0x10,%ebx
f0101d12:	75 18                	jne    f0101d2c <strtol+0x71>
f0101d14:	80 3a 30             	cmpb   $0x30,(%edx)
f0101d17:	75 13                	jne    f0101d2c <strtol+0x71>
f0101d19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101d1d:	8d 76 00             	lea    0x0(%esi),%esi
f0101d20:	75 0a                	jne    f0101d2c <strtol+0x71>
		s += 2, base = 16;
f0101d22:	83 c2 02             	add    $0x2,%edx
f0101d25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101d2a:	eb 15                	jmp    f0101d41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101d2c:	84 c0                	test   %al,%al
f0101d2e:	66 90                	xchg   %ax,%ax
f0101d30:	74 0f                	je     f0101d41 <strtol+0x86>
f0101d32:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101d37:	80 3a 30             	cmpb   $0x30,(%edx)
f0101d3a:	75 05                	jne    f0101d41 <strtol+0x86>
		s++, base = 8;
f0101d3c:	83 c2 01             	add    $0x1,%edx
f0101d3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101d41:	b8 00 00 00 00       	mov    $0x0,%eax
f0101d46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101d48:	0f b6 0a             	movzbl (%edx),%ecx
f0101d4b:	89 cf                	mov    %ecx,%edi
f0101d4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101d50:	80 fb 09             	cmp    $0x9,%bl
f0101d53:	77 08                	ja     f0101d5d <strtol+0xa2>
			dig = *s - '0';
f0101d55:	0f be c9             	movsbl %cl,%ecx
f0101d58:	83 e9 30             	sub    $0x30,%ecx
f0101d5b:	eb 1e                	jmp    f0101d7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0101d5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101d60:	80 fb 19             	cmp    $0x19,%bl
f0101d63:	77 08                	ja     f0101d6d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101d65:	0f be c9             	movsbl %cl,%ecx
f0101d68:	83 e9 57             	sub    $0x57,%ecx
f0101d6b:	eb 0e                	jmp    f0101d7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0101d6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101d70:	80 fb 19             	cmp    $0x19,%bl
f0101d73:	77 15                	ja     f0101d8a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101d75:	0f be c9             	movsbl %cl,%ecx
f0101d78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101d7b:	39 f1                	cmp    %esi,%ecx
f0101d7d:	7d 0b                	jge    f0101d8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0101d7f:	83 c2 01             	add    $0x1,%edx
f0101d82:	0f af c6             	imul   %esi,%eax
f0101d85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101d88:	eb be                	jmp    f0101d48 <strtol+0x8d>
f0101d8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0101d8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101d90:	74 05                	je     f0101d97 <strtol+0xdc>
		*endptr = (char *) s;
f0101d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101d95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101d97:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0101d9b:	74 04                	je     f0101da1 <strtol+0xe6>
f0101d9d:	89 c8                	mov    %ecx,%eax
f0101d9f:	f7 d8                	neg    %eax
}
f0101da1:	83 c4 04             	add    $0x4,%esp
f0101da4:	5b                   	pop    %ebx
f0101da5:	5e                   	pop    %esi
f0101da6:	5f                   	pop    %edi
f0101da7:	5d                   	pop    %ebp
f0101da8:	c3                   	ret    
f0101da9:	00 00                	add    %al,(%eax)
f0101dab:	00 00                	add    %al,(%eax)
f0101dad:	00 00                	add    %al,(%eax)
	...

f0101db0 <__udivdi3>:
f0101db0:	55                   	push   %ebp
f0101db1:	89 e5                	mov    %esp,%ebp
f0101db3:	57                   	push   %edi
f0101db4:	56                   	push   %esi
f0101db5:	83 ec 10             	sub    $0x10,%esp
f0101db8:	8b 45 14             	mov    0x14(%ebp),%eax
f0101dbb:	8b 55 08             	mov    0x8(%ebp),%edx
f0101dbe:	8b 75 10             	mov    0x10(%ebp),%esi
f0101dc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101dc4:	85 c0                	test   %eax,%eax
f0101dc6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101dc9:	75 35                	jne    f0101e00 <__udivdi3+0x50>
f0101dcb:	39 fe                	cmp    %edi,%esi
f0101dcd:	77 61                	ja     f0101e30 <__udivdi3+0x80>
f0101dcf:	85 f6                	test   %esi,%esi
f0101dd1:	75 0b                	jne    f0101dde <__udivdi3+0x2e>
f0101dd3:	b8 01 00 00 00       	mov    $0x1,%eax
f0101dd8:	31 d2                	xor    %edx,%edx
f0101dda:	f7 f6                	div    %esi
f0101ddc:	89 c6                	mov    %eax,%esi
f0101dde:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101de1:	31 d2                	xor    %edx,%edx
f0101de3:	89 f8                	mov    %edi,%eax
f0101de5:	f7 f6                	div    %esi
f0101de7:	89 c7                	mov    %eax,%edi
f0101de9:	89 c8                	mov    %ecx,%eax
f0101deb:	f7 f6                	div    %esi
f0101ded:	89 c1                	mov    %eax,%ecx
f0101def:	89 fa                	mov    %edi,%edx
f0101df1:	89 c8                	mov    %ecx,%eax
f0101df3:	83 c4 10             	add    $0x10,%esp
f0101df6:	5e                   	pop    %esi
f0101df7:	5f                   	pop    %edi
f0101df8:	5d                   	pop    %ebp
f0101df9:	c3                   	ret    
f0101dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101e00:	39 f8                	cmp    %edi,%eax
f0101e02:	77 1c                	ja     f0101e20 <__udivdi3+0x70>
f0101e04:	0f bd d0             	bsr    %eax,%edx
f0101e07:	83 f2 1f             	xor    $0x1f,%edx
f0101e0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101e0d:	75 39                	jne    f0101e48 <__udivdi3+0x98>
f0101e0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101e12:	0f 86 a0 00 00 00    	jbe    f0101eb8 <__udivdi3+0x108>
f0101e18:	39 f8                	cmp    %edi,%eax
f0101e1a:	0f 82 98 00 00 00    	jb     f0101eb8 <__udivdi3+0x108>
f0101e20:	31 ff                	xor    %edi,%edi
f0101e22:	31 c9                	xor    %ecx,%ecx
f0101e24:	89 c8                	mov    %ecx,%eax
f0101e26:	89 fa                	mov    %edi,%edx
f0101e28:	83 c4 10             	add    $0x10,%esp
f0101e2b:	5e                   	pop    %esi
f0101e2c:	5f                   	pop    %edi
f0101e2d:	5d                   	pop    %ebp
f0101e2e:	c3                   	ret    
f0101e2f:	90                   	nop
f0101e30:	89 d1                	mov    %edx,%ecx
f0101e32:	89 fa                	mov    %edi,%edx
f0101e34:	89 c8                	mov    %ecx,%eax
f0101e36:	31 ff                	xor    %edi,%edi
f0101e38:	f7 f6                	div    %esi
f0101e3a:	89 c1                	mov    %eax,%ecx
f0101e3c:	89 fa                	mov    %edi,%edx
f0101e3e:	89 c8                	mov    %ecx,%eax
f0101e40:	83 c4 10             	add    $0x10,%esp
f0101e43:	5e                   	pop    %esi
f0101e44:	5f                   	pop    %edi
f0101e45:	5d                   	pop    %ebp
f0101e46:	c3                   	ret    
f0101e47:	90                   	nop
f0101e48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e4c:	89 f2                	mov    %esi,%edx
f0101e4e:	d3 e0                	shl    %cl,%eax
f0101e50:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101e53:	b8 20 00 00 00       	mov    $0x20,%eax
f0101e58:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0101e5b:	89 c1                	mov    %eax,%ecx
f0101e5d:	d3 ea                	shr    %cl,%edx
f0101e5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e63:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101e66:	d3 e6                	shl    %cl,%esi
f0101e68:	89 c1                	mov    %eax,%ecx
f0101e6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101e6d:	89 fe                	mov    %edi,%esi
f0101e6f:	d3 ee                	shr    %cl,%esi
f0101e71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e75:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101e7b:	d3 e7                	shl    %cl,%edi
f0101e7d:	89 c1                	mov    %eax,%ecx
f0101e7f:	d3 ea                	shr    %cl,%edx
f0101e81:	09 d7                	or     %edx,%edi
f0101e83:	89 f2                	mov    %esi,%edx
f0101e85:	89 f8                	mov    %edi,%eax
f0101e87:	f7 75 ec             	divl   -0x14(%ebp)
f0101e8a:	89 d6                	mov    %edx,%esi
f0101e8c:	89 c7                	mov    %eax,%edi
f0101e8e:	f7 65 e8             	mull   -0x18(%ebp)
f0101e91:	39 d6                	cmp    %edx,%esi
f0101e93:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101e96:	72 30                	jb     f0101ec8 <__udivdi3+0x118>
f0101e98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101e9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101e9f:	d3 e2                	shl    %cl,%edx
f0101ea1:	39 c2                	cmp    %eax,%edx
f0101ea3:	73 05                	jae    f0101eaa <__udivdi3+0xfa>
f0101ea5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101ea8:	74 1e                	je     f0101ec8 <__udivdi3+0x118>
f0101eaa:	89 f9                	mov    %edi,%ecx
f0101eac:	31 ff                	xor    %edi,%edi
f0101eae:	e9 71 ff ff ff       	jmp    f0101e24 <__udivdi3+0x74>
f0101eb3:	90                   	nop
f0101eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101eb8:	31 ff                	xor    %edi,%edi
f0101eba:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101ebf:	e9 60 ff ff ff       	jmp    f0101e24 <__udivdi3+0x74>
f0101ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ec8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101ecb:	31 ff                	xor    %edi,%edi
f0101ecd:	89 c8                	mov    %ecx,%eax
f0101ecf:	89 fa                	mov    %edi,%edx
f0101ed1:	83 c4 10             	add    $0x10,%esp
f0101ed4:	5e                   	pop    %esi
f0101ed5:	5f                   	pop    %edi
f0101ed6:	5d                   	pop    %ebp
f0101ed7:	c3                   	ret    
	...

f0101ee0 <__umoddi3>:
f0101ee0:	55                   	push   %ebp
f0101ee1:	89 e5                	mov    %esp,%ebp
f0101ee3:	57                   	push   %edi
f0101ee4:	56                   	push   %esi
f0101ee5:	83 ec 20             	sub    $0x20,%esp
f0101ee8:	8b 55 14             	mov    0x14(%ebp),%edx
f0101eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101eee:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101ef1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ef4:	85 d2                	test   %edx,%edx
f0101ef6:	89 c8                	mov    %ecx,%eax
f0101ef8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101efb:	75 13                	jne    f0101f10 <__umoddi3+0x30>
f0101efd:	39 f7                	cmp    %esi,%edi
f0101eff:	76 3f                	jbe    f0101f40 <__umoddi3+0x60>
f0101f01:	89 f2                	mov    %esi,%edx
f0101f03:	f7 f7                	div    %edi
f0101f05:	89 d0                	mov    %edx,%eax
f0101f07:	31 d2                	xor    %edx,%edx
f0101f09:	83 c4 20             	add    $0x20,%esp
f0101f0c:	5e                   	pop    %esi
f0101f0d:	5f                   	pop    %edi
f0101f0e:	5d                   	pop    %ebp
f0101f0f:	c3                   	ret    
f0101f10:	39 f2                	cmp    %esi,%edx
f0101f12:	77 4c                	ja     f0101f60 <__umoddi3+0x80>
f0101f14:	0f bd ca             	bsr    %edx,%ecx
f0101f17:	83 f1 1f             	xor    $0x1f,%ecx
f0101f1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101f1d:	75 51                	jne    f0101f70 <__umoddi3+0x90>
f0101f1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101f22:	0f 87 e0 00 00 00    	ja     f0102008 <__umoddi3+0x128>
f0101f28:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f2b:	29 f8                	sub    %edi,%eax
f0101f2d:	19 d6                	sbb    %edx,%esi
f0101f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f35:	89 f2                	mov    %esi,%edx
f0101f37:	83 c4 20             	add    $0x20,%esp
f0101f3a:	5e                   	pop    %esi
f0101f3b:	5f                   	pop    %edi
f0101f3c:	5d                   	pop    %ebp
f0101f3d:	c3                   	ret    
f0101f3e:	66 90                	xchg   %ax,%ax
f0101f40:	85 ff                	test   %edi,%edi
f0101f42:	75 0b                	jne    f0101f4f <__umoddi3+0x6f>
f0101f44:	b8 01 00 00 00       	mov    $0x1,%eax
f0101f49:	31 d2                	xor    %edx,%edx
f0101f4b:	f7 f7                	div    %edi
f0101f4d:	89 c7                	mov    %eax,%edi
f0101f4f:	89 f0                	mov    %esi,%eax
f0101f51:	31 d2                	xor    %edx,%edx
f0101f53:	f7 f7                	div    %edi
f0101f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f58:	f7 f7                	div    %edi
f0101f5a:	eb a9                	jmp    f0101f05 <__umoddi3+0x25>
f0101f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f60:	89 c8                	mov    %ecx,%eax
f0101f62:	89 f2                	mov    %esi,%edx
f0101f64:	83 c4 20             	add    $0x20,%esp
f0101f67:	5e                   	pop    %esi
f0101f68:	5f                   	pop    %edi
f0101f69:	5d                   	pop    %ebp
f0101f6a:	c3                   	ret    
f0101f6b:	90                   	nop
f0101f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101f70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f74:	d3 e2                	shl    %cl,%edx
f0101f76:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101f79:	ba 20 00 00 00       	mov    $0x20,%edx
f0101f7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101f81:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101f84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f88:	89 fa                	mov    %edi,%edx
f0101f8a:	d3 ea                	shr    %cl,%edx
f0101f8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101f90:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101f93:	d3 e7                	shl    %cl,%edi
f0101f95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101f99:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101f9c:	89 f2                	mov    %esi,%edx
f0101f9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101fa1:	89 c7                	mov    %eax,%edi
f0101fa3:	d3 ea                	shr    %cl,%edx
f0101fa5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fa9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101fac:	89 c2                	mov    %eax,%edx
f0101fae:	d3 e6                	shl    %cl,%esi
f0101fb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101fb4:	d3 ea                	shr    %cl,%edx
f0101fb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fba:	09 d6                	or     %edx,%esi
f0101fbc:	89 f0                	mov    %esi,%eax
f0101fbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101fc1:	d3 e7                	shl    %cl,%edi
f0101fc3:	89 f2                	mov    %esi,%edx
f0101fc5:	f7 75 f4             	divl   -0xc(%ebp)
f0101fc8:	89 d6                	mov    %edx,%esi
f0101fca:	f7 65 e8             	mull   -0x18(%ebp)
f0101fcd:	39 d6                	cmp    %edx,%esi
f0101fcf:	72 2b                	jb     f0101ffc <__umoddi3+0x11c>
f0101fd1:	39 c7                	cmp    %eax,%edi
f0101fd3:	72 23                	jb     f0101ff8 <__umoddi3+0x118>
f0101fd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fd9:	29 c7                	sub    %eax,%edi
f0101fdb:	19 d6                	sbb    %edx,%esi
f0101fdd:	89 f0                	mov    %esi,%eax
f0101fdf:	89 f2                	mov    %esi,%edx
f0101fe1:	d3 ef                	shr    %cl,%edi
f0101fe3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101fe7:	d3 e0                	shl    %cl,%eax
f0101fe9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101fed:	09 f8                	or     %edi,%eax
f0101fef:	d3 ea                	shr    %cl,%edx
f0101ff1:	83 c4 20             	add    $0x20,%esp
f0101ff4:	5e                   	pop    %esi
f0101ff5:	5f                   	pop    %edi
f0101ff6:	5d                   	pop    %ebp
f0101ff7:	c3                   	ret    
f0101ff8:	39 d6                	cmp    %edx,%esi
f0101ffa:	75 d9                	jne    f0101fd5 <__umoddi3+0xf5>
f0101ffc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0101fff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0102002:	eb d1                	jmp    f0101fd5 <__umoddi3+0xf5>
f0102004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102008:	39 f2                	cmp    %esi,%edx
f010200a:	0f 82 18 ff ff ff    	jb     f0101f28 <__umoddi3+0x48>
f0102010:	e9 1d ff ff ff       	jmp    f0101f32 <__umoddi3+0x52>
