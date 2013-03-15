
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
f0100015:	0f 01 15 18 f0 10 00 	lgdtl  0x10f018

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
f0100033:	bc 00 f0 10 f0       	mov    $0xf010f000,%esp

	# now to C code
	call	i386_init
f0100038:	e8 fd 00 00 00       	call   f010013a <i386_init>

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
f0100054:	c7 04 24 00 17 10 f0 	movl   $0xf0101700,(%esp)
f010005b:	e8 fb 08 00 00       	call   f010095b <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 b6 08 00 00       	call   f0100928 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 da 17 10 f0 	movl   $0xf01017da,(%esp)
f0100079:	e8 dd 08 00 00       	call   f010095b <cprintf>
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
f0100086:	83 3d 20 f3 10 f0 00 	cmpl   $0x0,0xf010f320
f010008d:	75 40                	jne    f01000cf <_panic+0x4f>
		goto dead;
	panicstr = fmt;
f010008f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100092:	a3 20 f3 10 f0       	mov    %eax,0xf010f320

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f0100097:	8b 45 0c             	mov    0xc(%ebp),%eax
f010009a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010009e:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000a5:	c7 04 24 1a 17 10 f0 	movl   $0xf010171a,(%esp)
f01000ac:	e8 aa 08 00 00       	call   f010095b <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 65 08 00 00       	call   f0100928 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 da 17 10 f0 	movl   $0xf01017da,(%esp)
f01000ca:	e8 8c 08 00 00       	call   f010095b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 01 07 00 00       	call   f01007dc <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	53                   	push   %ebx
f01000e1:	83 ec 14             	sub    $0x14,%esp
f01000e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
        int a = 1;
        char b = 'c';
        a += 5;
	cprintf("entering test_backtrace %d\n", x);
f01000e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000eb:	c7 04 24 32 17 10 f0 	movl   $0xf0101732,(%esp)
f01000f2:	e8 64 08 00 00       	call   f010095b <cprintf>
	if (x > 0)
f01000f7:	85 db                	test   %ebx,%ebx
f01000f9:	7e 0d                	jle    f0100108 <test_backtrace+0x2b>
		test_backtrace(x-1);
f01000fb:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01000fe:	89 04 24             	mov    %eax,(%esp)
f0100101:	e8 d7 ff ff ff       	call   f01000dd <test_backtrace>
f0100106:	eb 1c                	jmp    f0100124 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100108:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010010f:	00 
f0100110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100117:	00 
f0100118:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010011f:	e8 ac 05 00 00       	call   f01006d0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100128:	c7 04 24 4e 17 10 f0 	movl   $0xf010174e,(%esp)
f010012f:	e8 27 08 00 00       	call   f010095b <cprintf>
}
f0100134:	83 c4 14             	add    $0x14,%esp
f0100137:	5b                   	pop    %ebx
f0100138:	5d                   	pop    %ebp
f0100139:	c3                   	ret    

f010013a <i386_init>:

void
i386_init(void)
{
f010013a:	55                   	push   %ebp
f010013b:	89 e5                	mov    %esp,%ebp
f010013d:	83 ec 18             	sub    $0x18,%esp
        int x = -1, y = -3, z = -4;

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100140:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f0100145:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f010014a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010014e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100155:	00 
f0100156:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f010015d:	e8 04 11 00 00       	call   f0101266 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100162:	e8 3a 02 00 00       	call   f01003a1 <cons_init>
        cprintf("this is $G foreground color\n");
f0100167:	c7 04 24 69 17 10 f0 	movl   $0xf0101769,(%esp)
f010016e:	e8 e8 07 00 00       	call   f010095b <cprintf>
        cprintf("$R xxxxxxxxxxxxx\n");
f0100173:	c7 04 24 86 17 10 f0 	movl   $0xf0101786,(%esp)
f010017a:	e8 dc 07 00 00       	call   f010095b <cprintf>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010017f:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100186:	00 
f0100187:	c7 04 24 98 17 10 f0 	movl   $0xf0101798,(%esp)
f010018e:	e8 c8 07 00 00       	call   f010095b <cprintf>


        

	// Test the stack backtrace function (lab 1 only)
        test_backtrace(5);
f0100193:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010019a:	e8 3e ff ff ff       	call   f01000dd <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010019f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001a6:	e8 31 06 00 00       	call   f01007dc <monitor>
f01001ab:	eb f2                	jmp    f010019f <i386_init+0x65>
f01001ad:	00 00                	add    %al,(%eax)
	...

f01001b0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b8:	ec                   	in     (%dx),%al
f01001b9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001c0:	f6 c2 01             	test   $0x1,%dl
f01001c3:	74 09                	je     f01001ce <serial_proc_data+0x1e>
f01001c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ca:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001cb:	0f b6 c0             	movzbl %al,%eax
}
f01001ce:	5d                   	pop    %ebp
f01001cf:	c3                   	ret    

f01001d0 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01001d0:	55                   	push   %ebp
f01001d1:	89 e5                	mov    %esp,%ebp
f01001d3:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001de:	89 da                	mov    %ebx,%edx
f01001e0:	ee                   	out    %al,(%dx)
f01001e1:	b2 fb                	mov    $0xfb,%dl
f01001e3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01001e8:	ee                   	out    %al,(%dx)
f01001e9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001ee:	b8 0c 00 00 00       	mov    $0xc,%eax
f01001f3:	89 ca                	mov    %ecx,%edx
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	b2 f9                	mov    $0xf9,%dl
f01001f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fd:	ee                   	out    %al,(%dx)
f01001fe:	b2 fb                	mov    $0xfb,%dl
f0100200:	b8 03 00 00 00       	mov    $0x3,%eax
f0100205:	ee                   	out    %al,(%dx)
f0100206:	b2 fc                	mov    $0xfc,%dl
f0100208:	b8 00 00 00 00       	mov    $0x0,%eax
f010020d:	ee                   	out    %al,(%dx)
f010020e:	b2 f9                	mov    $0xf9,%dl
f0100210:	b8 01 00 00 00       	mov    $0x1,%eax
f0100215:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100216:	b2 fd                	mov    $0xfd,%dl
f0100218:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100219:	3c ff                	cmp    $0xff,%al
f010021b:	0f 95 c0             	setne  %al
f010021e:	0f b6 c0             	movzbl %al,%eax
f0100221:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100226:	89 da                	mov    %ebx,%edx
f0100228:	ec                   	in     (%dx),%al
f0100229:	89 ca                	mov    %ecx,%edx
f010022b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010022c:	5b                   	pop    %ebx
f010022d:	5d                   	pop    %ebp
f010022e:	c3                   	ret    

f010022f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010022f:	55                   	push   %ebp
f0100230:	89 e5                	mov    %esp,%ebp
f0100232:	83 ec 0c             	sub    $0xc,%esp
f0100235:	89 1c 24             	mov    %ebx,(%esp)
f0100238:	89 74 24 04          	mov    %esi,0x4(%esp)
f010023c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100240:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100245:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100248:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010024d:	0f b7 00             	movzwl (%eax),%eax
f0100250:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100254:	74 11                	je     f0100267 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100256:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010025d:	03 00 00 
f0100260:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100265:	eb 16                	jmp    f010027d <cga_init+0x4e>
	} else {
		*cp = was;
f0100267:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010026e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f0100275:	03 00 00 
f0100278:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010027d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100283:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100285:	b8 0e 00 00 00       	mov    $0xe,%eax
f010028a:	89 ca                	mov    %ecx,%edx
f010028c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010028d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100290:	89 ca                	mov    %ecx,%edx
f0100292:	ec                   	in     (%dx),%al
f0100293:	0f b6 f8             	movzbl %al,%edi
f0100296:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100299:	b8 0f 00 00 00       	mov    $0xf,%eax
f010029e:	89 da                	mov    %ebx,%edx
f01002a0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a1:	89 ca                	mov    %ecx,%edx
f01002a3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01002a4:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f01002aa:	0f b6 c8             	movzbl %al,%ecx
f01002ad:	09 cf                	or     %ecx,%edi
f01002af:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002b6:	8b 1c 24             	mov    (%esp),%ebx
f01002b9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002c1:	89 ec                	mov    %ebp,%esp
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002c5:	55                   	push   %ebp
f01002c6:	89 e5                	mov    %esp,%ebp
}
f01002c8:	5d                   	pop    %ebp
f01002c9:	c3                   	ret    

f01002ca <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002ca:	55                   	push   %ebp
f01002cb:	89 e5                	mov    %esp,%ebp
f01002cd:	57                   	push   %edi
f01002ce:	56                   	push   %esi
f01002cf:	53                   	push   %ebx
f01002d0:	83 ec 0c             	sub    $0xc,%esp
f01002d3:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002d6:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f01002db:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002e0:	eb 1e                	jmp    f0100300 <cons_intr+0x36>
		if (c == 0)
f01002e2:	85 c0                	test   %eax,%eax
f01002e4:	74 1a                	je     f0100300 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002e6:	8b 13                	mov    (%ebx),%edx
f01002e8:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002eb:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002ee:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01002f3:	0f 94 c2             	sete   %dl
f01002f6:	0f b6 d2             	movzbl %dl,%edx
f01002f9:	83 ea 01             	sub    $0x1,%edx
f01002fc:	21 d0                	and    %edx,%eax
f01002fe:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100300:	ff d6                	call   *%esi
f0100302:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100305:	75 db                	jne    f01002e2 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100307:	83 c4 0c             	add    $0xc,%esp
f010030a:	5b                   	pop    %ebx
f010030b:	5e                   	pop    %esi
f010030c:	5f                   	pop    %edi
f010030d:	5d                   	pop    %ebp
f010030e:	c3                   	ret    

f010030f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010030f:	55                   	push   %ebp
f0100310:	89 e5                	mov    %esp,%ebp
f0100312:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100315:	c7 04 24 c8 03 10 f0 	movl   $0xf01003c8,(%esp)
f010031c:	e8 a9 ff ff ff       	call   f01002ca <cons_intr>
}
f0100321:	c9                   	leave  
f0100322:	c3                   	ret    

f0100323 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100323:	55                   	push   %ebp
f0100324:	89 e5                	mov    %esp,%ebp
f0100326:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100329:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100330:	74 0c                	je     f010033e <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100332:	c7 04 24 b0 01 10 f0 	movl   $0xf01001b0,(%esp)
f0100339:	e8 8c ff ff ff       	call   f01002ca <cons_intr>
}
f010033e:	c9                   	leave  
f010033f:	c3                   	ret    

f0100340 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100340:	55                   	push   %ebp
f0100341:	89 e5                	mov    %esp,%ebp
f0100343:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100346:	e8 d8 ff ff ff       	call   f0100323 <serial_intr>
	kbd_intr();
f010034b:	e8 bf ff ff ff       	call   f010030f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100350:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100356:	b8 00 00 00 00       	mov    $0x0,%eax
f010035b:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f0100361:	74 21                	je     f0100384 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100363:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f010036a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010036d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100373:	0f 94 c1             	sete   %cl
f0100376:	0f b6 c9             	movzbl %cl,%ecx
f0100379:	83 e9 01             	sub    $0x1,%ecx
f010037c:	21 ca                	and    %ecx,%edx
f010037e:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f0100384:	c9                   	leave  
f0100385:	c3                   	ret    

f0100386 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100386:	55                   	push   %ebp
f0100387:	89 e5                	mov    %esp,%ebp
f0100389:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010038c:	e8 af ff ff ff       	call   f0100340 <cons_getc>
f0100391:	85 c0                	test   %eax,%eax
f0100393:	74 f7                	je     f010038c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100395:	c9                   	leave  
f0100396:	c3                   	ret    

f0100397 <iscons>:

int
iscons(int fdnum)
{
f0100397:	55                   	push   %ebp
f0100398:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010039a:	b8 01 00 00 00       	mov    $0x1,%eax
f010039f:	5d                   	pop    %ebp
f01003a0:	c3                   	ret    

f01003a1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01003a1:	55                   	push   %ebp
f01003a2:	89 e5                	mov    %esp,%ebp
f01003a4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01003a7:	e8 83 fe ff ff       	call   f010022f <cga_init>
	kbd_init();
	serial_init();
f01003ac:	e8 1f fe ff ff       	call   f01001d0 <serial_init>

	if (!serial_exists)
f01003b1:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003b8:	75 0c                	jne    f01003c6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003ba:	c7 04 24 b3 17 10 f0 	movl   $0xf01017b3,(%esp)
f01003c1:	e8 95 05 00 00       	call   f010095b <cprintf>
}
f01003c6:	c9                   	leave  
f01003c7:	c3                   	ret    

f01003c8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003c8:	55                   	push   %ebp
f01003c9:	89 e5                	mov    %esp,%ebp
f01003cb:	53                   	push   %ebx
f01003cc:	83 ec 14             	sub    $0x14,%esp
f01003cf:	ba 64 00 00 00       	mov    $0x64,%edx
f01003d4:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003d5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003da:	a8 01                	test   $0x1,%al
f01003dc:	0f 84 d9 00 00 00    	je     f01004bb <kbd_proc_data+0xf3>
f01003e2:	b2 60                	mov    $0x60,%dl
f01003e4:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003e5:	3c e0                	cmp    $0xe0,%al
f01003e7:	75 11                	jne    f01003fa <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01003e9:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f01003f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01003f5:	e9 c1 00 00 00       	jmp    f01004bb <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01003fa:	84 c0                	test   %al,%al
f01003fc:	79 32                	jns    f0100430 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003fe:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100404:	f6 c2 40             	test   $0x40,%dl
f0100407:	75 03                	jne    f010040c <kbd_proc_data+0x44>
f0100409:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010040c:	0f b6 c0             	movzbl %al,%eax
f010040f:	0f b6 80 e0 17 10 f0 	movzbl -0xfefe820(%eax),%eax
f0100416:	83 c8 40             	or     $0x40,%eax
f0100419:	0f b6 c0             	movzbl %al,%eax
f010041c:	f7 d0                	not    %eax
f010041e:	21 c2                	and    %eax,%edx
f0100420:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100426:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010042b:	e9 8b 00 00 00       	jmp    f01004bb <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100430:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100436:	f6 c2 40             	test   $0x40,%dl
f0100439:	74 0c                	je     f0100447 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010043b:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010043e:	83 e2 bf             	and    $0xffffffbf,%edx
f0100441:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100447:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010044a:	0f b6 90 e0 17 10 f0 	movzbl -0xfefe820(%eax),%edx
f0100451:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100457:	0f b6 88 e0 18 10 f0 	movzbl -0xfefe720(%eax),%ecx
f010045e:	31 ca                	xor    %ecx,%edx
f0100460:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100466:	89 d1                	mov    %edx,%ecx
f0100468:	83 e1 03             	and    $0x3,%ecx
f010046b:	8b 0c 8d e0 19 10 f0 	mov    -0xfefe620(,%ecx,4),%ecx
f0100472:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100476:	f6 c2 08             	test   $0x8,%dl
f0100479:	74 1a                	je     f0100495 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010047b:	89 d9                	mov    %ebx,%ecx
f010047d:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100480:	83 f8 19             	cmp    $0x19,%eax
f0100483:	77 05                	ja     f010048a <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100485:	83 eb 20             	sub    $0x20,%ebx
f0100488:	eb 0b                	jmp    f0100495 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010048a:	83 e9 41             	sub    $0x41,%ecx
f010048d:	83 f9 19             	cmp    $0x19,%ecx
f0100490:	77 03                	ja     f0100495 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f0100492:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100495:	f7 d2                	not    %edx
f0100497:	f6 c2 06             	test   $0x6,%dl
f010049a:	75 1f                	jne    f01004bb <kbd_proc_data+0xf3>
f010049c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004a2:	75 17                	jne    f01004bb <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01004a4:	c7 04 24 d0 17 10 f0 	movl   $0xf01017d0,(%esp)
f01004ab:	e8 ab 04 00 00       	call   f010095b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b0:	ba 92 00 00 00       	mov    $0x92,%edx
f01004b5:	b8 03 00 00 00       	mov    $0x3,%eax
f01004ba:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004bb:	89 d8                	mov    %ebx,%eax
f01004bd:	83 c4 14             	add    $0x14,%esp
f01004c0:	5b                   	pop    %ebx
f01004c1:	5d                   	pop    %ebp
f01004c2:	c3                   	ret    

f01004c3 <cga_putc>:



void
cga_putc(int c)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	56                   	push   %esi
f01004c7:	53                   	push   %ebx
f01004c8:	83 ec 10             	sub    $0x10,%esp
f01004cb:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004ce:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004d3:	75 03                	jne    f01004d8 <cga_putc+0x15>
		c |= 0x0700;
f01004d5:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f01004d8:	0f b6 d0             	movzbl %al,%edx
f01004db:	83 fa 09             	cmp    $0x9,%edx
f01004de:	0f 84 89 00 00 00    	je     f010056d <cga_putc+0xaa>
f01004e4:	83 fa 09             	cmp    $0x9,%edx
f01004e7:	7f 11                	jg     f01004fa <cga_putc+0x37>
f01004e9:	83 fa 08             	cmp    $0x8,%edx
f01004ec:	0f 85 b9 00 00 00    	jne    f01005ab <cga_putc+0xe8>
f01004f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01004f8:	eb 18                	jmp    f0100512 <cga_putc+0x4f>
f01004fa:	83 fa 0a             	cmp    $0xa,%edx
f01004fd:	8d 76 00             	lea    0x0(%esi),%esi
f0100500:	74 41                	je     f0100543 <cga_putc+0x80>
f0100502:	83 fa 0d             	cmp    $0xd,%edx
f0100505:	8d 76 00             	lea    0x0(%esi),%esi
f0100508:	0f 85 9d 00 00 00    	jne    f01005ab <cga_putc+0xe8>
f010050e:	66 90                	xchg   %ax,%ax
f0100510:	eb 39                	jmp    f010054b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100512:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100519:	66 85 d2             	test   %dx,%dx
f010051c:	0f 84 f4 00 00 00    	je     f0100616 <cga_putc+0x153>
			crt_pos--;
f0100522:	83 ea 01             	sub    $0x1,%edx
f0100525:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010052c:	0f b7 d2             	movzwl %dx,%edx
f010052f:	b0 00                	mov    $0x0,%al
f0100531:	83 c8 20             	or     $0x20,%eax
f0100534:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010053a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010053e:	e9 86 00 00 00       	jmp    f01005c9 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100543:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010054a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010054b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100552:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100558:	c1 e8 10             	shr    $0x10,%eax
f010055b:	66 c1 e8 06          	shr    $0x6,%ax
f010055f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100562:	c1 e0 04             	shl    $0x4,%eax
f0100565:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010056b:	eb 5c                	jmp    f01005c9 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010056d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100574:	e8 d4 00 00 00       	call   f010064d <cons_putc>
		cons_putc(' ');
f0100579:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100580:	e8 c8 00 00 00       	call   f010064d <cons_putc>
		cons_putc(' ');
f0100585:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010058c:	e8 bc 00 00 00       	call   f010064d <cons_putc>
		cons_putc(' ');
f0100591:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100598:	e8 b0 00 00 00       	call   f010064d <cons_putc>
		cons_putc(' ');
f010059d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005a4:	e8 a4 00 00 00       	call   f010064d <cons_putc>
		break;
f01005a9:	eb 1e                	jmp    f01005c9 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005ab:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005b2:	0f b7 da             	movzwl %dx,%ebx
f01005b5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005bb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005bf:	83 c2 01             	add    $0x1,%edx
f01005c2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005c9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f01005d0:	cf 07 
f01005d2:	76 42                	jbe    f0100616 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005d4:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f01005d9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005e0:	00 
f01005e1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005e7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005eb:	89 04 24             	mov    %eax,(%esp)
f01005ee:	e8 98 0c 00 00       	call   f010128b <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005f3:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f01005f9:	b8 80 07 00 00       	mov    $0x780,%eax
f01005fe:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100604:	83 c0 01             	add    $0x1,%eax
f0100607:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010060c:	75 f0                	jne    f01005fe <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010060e:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100615:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100616:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010061c:	89 cb                	mov    %ecx,%ebx
f010061e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100623:	89 ca                	mov    %ecx,%edx
f0100625:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100626:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010062d:	83 c1 01             	add    $0x1,%ecx
f0100630:	89 f0                	mov    %esi,%eax
f0100632:	66 c1 e8 08          	shr    $0x8,%ax
f0100636:	89 ca                	mov    %ecx,%edx
f0100638:	ee                   	out    %al,(%dx)
f0100639:	b8 0f 00 00 00       	mov    $0xf,%eax
f010063e:	89 da                	mov    %ebx,%edx
f0100640:	ee                   	out    %al,(%dx)
f0100641:	89 f0                	mov    %esi,%eax
f0100643:	89 ca                	mov    %ecx,%edx
f0100645:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100646:	83 c4 10             	add    $0x10,%esp
f0100649:	5b                   	pop    %ebx
f010064a:	5e                   	pop    %esi
f010064b:	5d                   	pop    %ebp
f010064c:	c3                   	ret    

f010064d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	57                   	push   %edi
f0100651:	56                   	push   %esi
f0100652:	53                   	push   %ebx
f0100653:	83 ec 1c             	sub    $0x1c,%esp
f0100656:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100659:	ba 79 03 00 00       	mov    $0x379,%edx
f010065e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010065f:	84 c0                	test   %al,%al
f0100661:	78 27                	js     f010068a <cons_putc+0x3d>
f0100663:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100668:	b9 84 00 00 00       	mov    $0x84,%ecx
f010066d:	be 79 03 00 00       	mov    $0x379,%esi
f0100672:	89 ca                	mov    %ecx,%edx
f0100674:	ec                   	in     (%dx),%al
f0100675:	ec                   	in     (%dx),%al
f0100676:	ec                   	in     (%dx),%al
f0100677:	ec                   	in     (%dx),%al
f0100678:	89 f2                	mov    %esi,%edx
f010067a:	ec                   	in     (%dx),%al
f010067b:	84 c0                	test   %al,%al
f010067d:	78 0b                	js     f010068a <cons_putc+0x3d>
f010067f:	83 c3 01             	add    $0x1,%ebx
f0100682:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100688:	75 e8                	jne    f0100672 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068a:	ba 78 03 00 00       	mov    $0x378,%edx
f010068f:	89 f8                	mov    %edi,%eax
f0100691:	ee                   	out    %al,(%dx)
f0100692:	b2 7a                	mov    $0x7a,%dl
f0100694:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100699:	ee                   	out    %al,(%dx)
f010069a:	b8 08 00 00 00       	mov    $0x8,%eax
f010069f:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01006a0:	89 3c 24             	mov    %edi,(%esp)
f01006a3:	e8 1b fe ff ff       	call   f01004c3 <cga_putc>
}
f01006a8:	83 c4 1c             	add    $0x1c,%esp
f01006ab:	5b                   	pop    %ebx
f01006ac:	5e                   	pop    %esi
f01006ad:	5f                   	pop    %edi
f01006ae:	5d                   	pop    %ebp
f01006af:	c3                   	ret    

f01006b0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006b9:	89 04 24             	mov    %eax,(%esp)
f01006bc:	e8 8c ff ff ff       	call   f010064d <cons_putc>
}
f01006c1:	c9                   	leave  
f01006c2:	c3                   	ret    
	...

f01006d0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006d0:	55                   	push   %ebp
f01006d1:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	5d                   	pop    %ebp
f01006d9:	c3                   	ret    

f01006da <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006da:	55                   	push   %ebp
f01006db:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006dd:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006e0:	5d                   	pop    %ebp
f01006e1:	c3                   	ret    

f01006e2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006e2:	55                   	push   %ebp
f01006e3:	89 e5                	mov    %esp,%ebp
f01006e5:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006e8:	c7 04 24 f0 19 10 f0 	movl   $0xf01019f0,(%esp)
f01006ef:	e8 67 02 00 00       	call   f010095b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f01006f4:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006fb:	00 
f01006fc:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100703:	f0 
f0100704:	c7 04 24 7c 1a 10 f0 	movl   $0xf0101a7c,(%esp)
f010070b:	e8 4b 02 00 00       	call   f010095b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100710:	c7 44 24 08 e5 16 10 	movl   $0x1016e5,0x8(%esp)
f0100717:	00 
f0100718:	c7 44 24 04 e5 16 10 	movl   $0xf01016e5,0x4(%esp)
f010071f:	f0 
f0100720:	c7 04 24 a0 1a 10 f0 	movl   $0xf0101aa0,(%esp)
f0100727:	e8 2f 02 00 00       	call   f010095b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010072c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100733:	00 
f0100734:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010073b:	f0 
f010073c:	c7 04 24 c4 1a 10 f0 	movl   $0xf0101ac4,(%esp)
f0100743:	e8 13 02 00 00       	call   f010095b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100748:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010074f:	00 
f0100750:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100757:	f0 
f0100758:	c7 04 24 e8 1a 10 f0 	movl   $0xf0101ae8,(%esp)
f010075f:	e8 f7 01 00 00       	call   f010095b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100764:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100769:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010076e:	89 c2                	mov    %eax,%edx
f0100770:	c1 fa 1f             	sar    $0x1f,%edx
f0100773:	c1 ea 16             	shr    $0x16,%edx
f0100776:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100779:	c1 f8 0a             	sar    $0xa,%eax
f010077c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100780:	c7 04 24 0c 1b 10 f0 	movl   $0xf0101b0c,(%esp)
f0100787:	e8 cf 01 00 00       	call   f010095b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010078c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100791:	c9                   	leave  
f0100792:	c3                   	ret    

f0100793 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100793:	55                   	push   %ebp
f0100794:	89 e5                	mov    %esp,%ebp
f0100796:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100799:	a1 b0 1b 10 f0       	mov    0xf0101bb0,%eax
f010079e:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a2:	a1 ac 1b 10 f0       	mov    0xf0101bac,%eax
f01007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ab:	c7 04 24 09 1a 10 f0 	movl   $0xf0101a09,(%esp)
f01007b2:	e8 a4 01 00 00       	call   f010095b <cprintf>
f01007b7:	a1 bc 1b 10 f0       	mov    0xf0101bbc,%eax
f01007bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c0:	a1 b8 1b 10 f0       	mov    0xf0101bb8,%eax
f01007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c9:	c7 04 24 09 1a 10 f0 	movl   $0xf0101a09,(%esp)
f01007d0:	e8 86 01 00 00       	call   f010095b <cprintf>
	return 0;
}
f01007d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007da:	c9                   	leave  
f01007db:	c3                   	ret    

f01007dc <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	57                   	push   %edi
f01007e0:	56                   	push   %esi
f01007e1:	53                   	push   %ebx
f01007e2:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007e5:	c7 04 24 38 1b 10 f0 	movl   $0xf0101b38,(%esp)
f01007ec:	e8 6a 01 00 00       	call   f010095b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007f1:	c7 04 24 5c 1b 10 f0 	movl   $0xf0101b5c,(%esp)
f01007f8:	e8 5e 01 00 00       	call   f010095b <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007fd:	bf ac 1b 10 f0       	mov    $0xf0101bac,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100802:	c7 04 24 12 1a 10 f0 	movl   $0xf0101a12,(%esp)
f0100809:	e8 e2 07 00 00       	call   f0100ff0 <readline>
f010080e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100810:	85 c0                	test   %eax,%eax
f0100812:	74 ee                	je     f0100802 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100814:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010081b:	be 00 00 00 00       	mov    $0x0,%esi
f0100820:	eb 06                	jmp    f0100828 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100822:	c6 03 00             	movb   $0x0,(%ebx)
f0100825:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100828:	0f b6 03             	movzbl (%ebx),%eax
f010082b:	84 c0                	test   %al,%al
f010082d:	74 6c                	je     f010089b <monitor+0xbf>
f010082f:	0f be c0             	movsbl %al,%eax
f0100832:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100836:	c7 04 24 16 1a 10 f0 	movl   $0xf0101a16,(%esp)
f010083d:	e8 cc 09 00 00       	call   f010120e <strchr>
f0100842:	85 c0                	test   %eax,%eax
f0100844:	75 dc                	jne    f0100822 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100846:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100849:	74 50                	je     f010089b <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010084b:	83 fe 0f             	cmp    $0xf,%esi
f010084e:	66 90                	xchg   %ax,%ax
f0100850:	75 16                	jne    f0100868 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100852:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100859:	00 
f010085a:	c7 04 24 1b 1a 10 f0 	movl   $0xf0101a1b,(%esp)
f0100861:	e8 f5 00 00 00       	call   f010095b <cprintf>
f0100866:	eb 9a                	jmp    f0100802 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100868:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010086c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010086f:	0f b6 03             	movzbl (%ebx),%eax
f0100872:	84 c0                	test   %al,%al
f0100874:	75 0c                	jne    f0100882 <monitor+0xa6>
f0100876:	eb b0                	jmp    f0100828 <monitor+0x4c>
			buf++;
f0100878:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010087b:	0f b6 03             	movzbl (%ebx),%eax
f010087e:	84 c0                	test   %al,%al
f0100880:	74 a6                	je     f0100828 <monitor+0x4c>
f0100882:	0f be c0             	movsbl %al,%eax
f0100885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100889:	c7 04 24 16 1a 10 f0 	movl   $0xf0101a16,(%esp)
f0100890:	e8 79 09 00 00       	call   f010120e <strchr>
f0100895:	85 c0                	test   %eax,%eax
f0100897:	74 df                	je     f0100878 <monitor+0x9c>
f0100899:	eb 8d                	jmp    f0100828 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f010089b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008a2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008a3:	85 f6                	test   %esi,%esi
f01008a5:	0f 84 57 ff ff ff    	je     f0100802 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ab:	8b 07                	mov    (%edi),%eax
f01008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008b4:	89 04 24             	mov    %eax,(%esp)
f01008b7:	e8 dd 08 00 00       	call   f0101199 <strcmp>
f01008bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01008c1:	85 c0                	test   %eax,%eax
f01008c3:	74 1d                	je     f01008e2 <monitor+0x106>
f01008c5:	a1 b8 1b 10 f0       	mov    0xf0101bb8,%eax
f01008ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d1:	89 04 24             	mov    %eax,(%esp)
f01008d4:	e8 c0 08 00 00       	call   f0101199 <strcmp>
f01008d9:	85 c0                	test   %eax,%eax
f01008db:	75 28                	jne    f0100905 <monitor+0x129>
f01008dd:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008e2:	6b d2 0c             	imul   $0xc,%edx,%edx
f01008e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01008e8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008ec:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f3:	89 34 24             	mov    %esi,(%esp)
f01008f6:	ff 92 b4 1b 10 f0    	call   *-0xfefe44c(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008fc:	85 c0                	test   %eax,%eax
f01008fe:	78 1d                	js     f010091d <monitor+0x141>
f0100900:	e9 fd fe ff ff       	jmp    f0100802 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100905:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100908:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090c:	c7 04 24 38 1a 10 f0 	movl   $0xf0101a38,(%esp)
f0100913:	e8 43 00 00 00       	call   f010095b <cprintf>
f0100918:	e9 e5 fe ff ff       	jmp    f0100802 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010091d:	83 c4 5c             	add    $0x5c,%esp
f0100920:	5b                   	pop    %ebx
f0100921:	5e                   	pop    %esi
f0100922:	5f                   	pop    %edi
f0100923:	5d                   	pop    %ebp
f0100924:	c3                   	ret    
f0100925:	00 00                	add    %al,(%eax)
	...

f0100928 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010092e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100935:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100938:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010093c:	8b 45 08             	mov    0x8(%ebp),%eax
f010093f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100943:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100946:	89 44 24 04          	mov    %eax,0x4(%esp)
f010094a:	c7 04 24 75 09 10 f0 	movl   $0xf0100975,(%esp)
f0100951:	e8 c3 01 00 00       	call   f0100b19 <vprintfmt>
	return cnt;
}
f0100956:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100959:	c9                   	leave  
f010095a:	c3                   	ret    

f010095b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010095b:	55                   	push   %ebp
f010095c:	89 e5                	mov    %esp,%ebp
f010095e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100961:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100964:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100968:	8b 45 08             	mov    0x8(%ebp),%eax
f010096b:	89 04 24             	mov    %eax,(%esp)
f010096e:	e8 b5 ff ff ff       	call   f0100928 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100973:	c9                   	leave  
f0100974:	c3                   	ret    

f0100975 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100975:	55                   	push   %ebp
f0100976:	89 e5                	mov    %esp,%ebp
f0100978:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010097b:	8b 45 08             	mov    0x8(%ebp),%eax
f010097e:	89 04 24             	mov    %eax,(%esp)
f0100981:	e8 2a fd ff ff       	call   f01006b0 <cputchar>
	*cnt++;
}
f0100986:	c9                   	leave  
f0100987:	c3                   	ret    
	...

f0100990 <get_color>:
 * so that -E_NO_MEM and E_NO_MEM are equivalent.
 */

  /* choose colors of back and fore ground*/
int get_color(int fore_back, char type)  
{  
f0100990:	55                   	push   %ebp
f0100991:	89 e5                	mov    %esp,%ebp
f0100993:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
    int color = 0;  
  
    if (fore_back == 1) //foreground  
f0100997:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010099b:	75 14                	jne    f01009b1 <get_color+0x21>
f010099d:	8d 50 be             	lea    -0x42(%eax),%edx
f01009a0:	80 fa 15             	cmp    $0x15,%dl
f01009a3:	77 20                	ja     f01009c5 <get_color+0x35>
f01009a5:	0f be c0             	movsbl %al,%eax
f01009a8:	8b 04 85 d8 1c 10 f0 	mov    -0xfefe328(,%eax,4),%eax
f01009af:	eb 19                	jmp    f01009ca <get_color+0x3a>
f01009b1:	8d 50 be             	lea    -0x42(%eax),%edx
f01009b4:	80 fa 15             	cmp    $0x15,%dl
f01009b7:	77 0c                	ja     f01009c5 <get_color+0x35>
f01009b9:	0f be c0             	movsbl %al,%eax
f01009bc:	8b 04 85 38 1d 10 f0 	mov    -0xfefe2c8(,%eax,4),%eax
f01009c3:	eb 05                	jmp    f01009ca <get_color+0x3a>
f01009c5:	b8 00 00 00 00       	mov    $0x0,%eax
            default:  
                break;  
        }  
    }  
    return color;  
}  
f01009ca:	5d                   	pop    %ebp
f01009cb:	c3                   	ret    

f01009cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01009cc:	55                   	push   %ebp
f01009cd:	89 e5                	mov    %esp,%ebp
f01009cf:	57                   	push   %edi
f01009d0:	56                   	push   %esi
f01009d1:	53                   	push   %ebx
f01009d2:	83 ec 4c             	sub    $0x4c,%esp
f01009d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01009d8:	89 d6                	mov    %edx,%esi
f01009da:	8b 45 08             	mov    0x8(%ebp),%eax
f01009dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01009e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009e6:	8b 45 10             	mov    0x10(%ebp),%eax
f01009e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01009ec:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01009ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01009f2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01009f7:	39 d1                	cmp    %edx,%ecx
f01009f9:	72 12                	jb     f0100a0d <printnum+0x41>
f01009fb:	77 07                	ja     f0100a04 <printnum+0x38>
f01009fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a00:	39 d0                	cmp    %edx,%eax
f0100a02:	76 09                	jbe    f0100a0d <printnum+0x41>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a04:	83 eb 01             	sub    $0x1,%ebx
f0100a07:	85 db                	test   %ebx,%ebx
f0100a09:	7f 61                	jg     f0100a6c <printnum+0xa0>
f0100a0b:	eb 70                	jmp    f0100a7d <printnum+0xb1>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100a0d:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100a11:	83 eb 01             	sub    $0x1,%ebx
f0100a14:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a18:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a1c:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100a20:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100a24:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100a27:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100a2a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a2d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a38:	00 
f0100a39:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a3c:	89 04 24             	mov    %eax,(%esp)
f0100a3f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a42:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a46:	e8 35 0a 00 00       	call   f0101480 <__udivdi3>
f0100a4b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a51:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a55:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a59:	89 04 24             	mov    %eax,(%esp)
f0100a5c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a60:	89 f2                	mov    %esi,%edx
f0100a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a65:	e8 62 ff ff ff       	call   f01009cc <printnum>
f0100a6a:	eb 11                	jmp    f0100a7d <printnum+0xb1>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a6c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a70:	89 3c 24             	mov    %edi,(%esp)
f0100a73:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a76:	83 eb 01             	sub    $0x1,%ebx
f0100a79:	85 db                	test   %ebx,%ebx
f0100a7b:	7f ef                	jg     f0100a6c <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a7d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a81:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a85:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a93:	00 
f0100a94:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a97:	89 14 24             	mov    %edx,(%esp)
f0100a9a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a9d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100aa1:	e8 0a 0b 00 00       	call   f01015b0 <__umoddi3>
f0100aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aaa:	0f be 80 c4 1b 10 f0 	movsbl -0xfefe43c(%eax),%eax
f0100ab1:	89 04 24             	mov    %eax,(%esp)
f0100ab4:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100ab7:	83 c4 4c             	add    $0x4c,%esp
f0100aba:	5b                   	pop    %ebx
f0100abb:	5e                   	pop    %esi
f0100abc:	5f                   	pop    %edi
f0100abd:	5d                   	pop    %ebp
f0100abe:	c3                   	ret    

f0100abf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ac2:	83 fa 01             	cmp    $0x1,%edx
f0100ac5:	7e 0f                	jle    f0100ad6 <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100ac7:	8b 10                	mov    (%eax),%edx
f0100ac9:	83 c2 08             	add    $0x8,%edx
f0100acc:	89 10                	mov    %edx,(%eax)
f0100ace:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100ad1:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100ad4:	eb 24                	jmp    f0100afa <getuint+0x3b>
	else if (lflag)
f0100ad6:	85 d2                	test   %edx,%edx
f0100ad8:	74 11                	je     f0100aeb <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100ada:	8b 10                	mov    (%eax),%edx
f0100adc:	83 c2 04             	add    $0x4,%edx
f0100adf:	89 10                	mov    %edx,(%eax)
f0100ae1:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100ae4:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ae9:	eb 0f                	jmp    f0100afa <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100aeb:	8b 10                	mov    (%eax),%edx
f0100aed:	83 c2 04             	add    $0x4,%edx
f0100af0:	89 10                	mov    %edx,(%eax)
f0100af2:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100af5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100afa:	5d                   	pop    %ebp
f0100afb:	c3                   	ret    

f0100afc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100afc:	55                   	push   %ebp
f0100afd:	89 e5                	mov    %esp,%ebp
f0100aff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100b02:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100b06:	8b 10                	mov    (%eax),%edx
f0100b08:	3b 50 04             	cmp    0x4(%eax),%edx
f0100b0b:	73 0a                	jae    f0100b17 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100b10:	88 0a                	mov    %cl,(%edx)
f0100b12:	83 c2 01             	add    $0x1,%edx
f0100b15:	89 10                	mov    %edx,(%eax)
}
f0100b17:	5d                   	pop    %ebp
f0100b18:	c3                   	ret    

f0100b19 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100b19:	55                   	push   %ebp
f0100b1a:	89 e5                	mov    %esp,%ebp
f0100b1c:	57                   	push   %edi
f0100b1d:	56                   	push   %esi
f0100b1e:	53                   	push   %ebx
f0100b1f:	83 ec 4c             	sub    $0x4c,%esp
f0100b22:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100b25:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100b28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100b2f:	eb 32                	jmp    f0100b63 <vprintfmt+0x4a>
	char padc;
        int c_flag, color;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100b31:	85 c0                	test   %eax,%eax
f0100b33:	0f 84 03 04 00 00    	je     f0100f3c <vprintfmt+0x423>
				return;
		        c_flag = 1;  
            		if (ch == '$') //foreground color  
f0100b39:	ba 01 00 00 00       	mov    $0x1,%edx
f0100b3e:	83 f8 24             	cmp    $0x24,%eax
f0100b41:	75 08                	jne    f0100b4b <vprintfmt+0x32>
            		{  
                		ch = *(unsigned char *)fmt++;  
f0100b43:	0f b6 03             	movzbl (%ebx),%eax
f0100b46:	83 c3 01             	add    $0x1,%ebx
f0100b49:	b2 00                	mov    $0x0,%dl
                		color |= get_color(1, ch);  
                		c_flag = 0;  
            		}  
            		if (ch == '#') //background color  
f0100b4b:	83 f8 23             	cmp    $0x23,%eax
f0100b4e:	75 05                	jne    f0100b55 <vprintfmt+0x3c>
            {  
                ch = *(unsigned char *)fmt++;  
f0100b50:	83 c3 01             	add    $0x1,%ebx
f0100b53:	eb 0e                	jmp    f0100b63 <vprintfmt+0x4a>
                color |= get_color(0, ch);  
                c_flag = 0;  
            }  
            if (c_flag)  
f0100b55:	85 d2                	test   %edx,%edx
f0100b57:	74 0a                	je     f0100b63 <vprintfmt+0x4a>
                putch(ch, putdat);  
f0100b59:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b5d:	89 04 24             	mov    %eax,(%esp)
f0100b60:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;
        int c_flag, color;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b63:	0f b6 03             	movzbl (%ebx),%eax
f0100b66:	83 c3 01             	add    $0x1,%ebx
f0100b69:	83 f8 25             	cmp    $0x25,%eax
f0100b6c:	75 c3                	jne    f0100b31 <vprintfmt+0x18>
f0100b6e:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0100b72:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100b79:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100b80:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100b85:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b8a:	eb 06                	jmp    f0100b92 <vprintfmt+0x79>
f0100b8c:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0100b90:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b92:	0f b6 13             	movzbl (%ebx),%edx
f0100b95:	0f b6 c2             	movzbl %dl,%eax
f0100b98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b9b:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b9e:	83 ea 23             	sub    $0x23,%edx
f0100ba1:	80 fa 55             	cmp    $0x55,%dl
f0100ba4:	0f 87 74 03 00 00    	ja     f0100f1e <vprintfmt+0x405>
f0100baa:	0f b6 d2             	movzbl %dl,%edx
f0100bad:	ff 24 95 60 1c 10 f0 	jmp    *-0xfefe3a0(,%edx,4)
f0100bb4:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0100bb8:	eb d6                	jmp    f0100b90 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100bba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bbd:	83 ea 30             	sub    $0x30,%edx
f0100bc0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				ch = *fmt;
f0100bc3:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100bc6:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100bc9:	83 fb 09             	cmp    $0x9,%ebx
f0100bcc:	77 4b                	ja     f0100c19 <vprintfmt+0x100>
f0100bce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bd1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100bd4:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100bd7:	8d 1c 9b             	lea    (%ebx,%ebx,4),%ebx
f0100bda:	8d 5c 5a d0          	lea    -0x30(%edx,%ebx,2),%ebx
				ch = *fmt;
f0100bde:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100be1:	8d 7a d0             	lea    -0x30(%edx),%edi
f0100be4:	83 ff 09             	cmp    $0x9,%edi
f0100be7:	76 eb                	jbe    f0100bd4 <vprintfmt+0xbb>
f0100be9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100bec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bef:	eb 28                	jmp    f0100c19 <vprintfmt+0x100>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100bf1:	8b 55 14             	mov    0x14(%ebp),%edx
f0100bf4:	83 c2 04             	add    $0x4,%edx
f0100bf7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100bfa:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100bfd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto process_precision;
f0100c00:	eb 17                	jmp    f0100c19 <vprintfmt+0x100>

		case '.':
			if (width < 0)
f0100c02:	89 fa                	mov    %edi,%edx
f0100c04:	c1 fa 1f             	sar    $0x1f,%edx
f0100c07:	f7 d2                	not    %edx
f0100c09:	21 d7                	and    %edx,%edi
f0100c0b:	eb 83                	jmp    f0100b90 <vprintfmt+0x77>
f0100c0d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100c14:	e9 77 ff ff ff       	jmp    f0100b90 <vprintfmt+0x77>

		process_precision:
			if (width < 0)
f0100c19:	85 ff                	test   %edi,%edi
f0100c1b:	0f 89 6f ff ff ff    	jns    f0100b90 <vprintfmt+0x77>
f0100c21:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100c24:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c27:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0100c2a:	e9 61 ff ff ff       	jmp    f0100b90 <vprintfmt+0x77>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100c2f:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100c32:	e9 59 ff ff ff       	jmp    f0100b90 <vprintfmt+0x77>
f0100c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100c3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c3d:	83 c0 04             	add    $0x4,%eax
f0100c40:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c43:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c47:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c4a:	89 04 24             	mov    %eax,(%esp)
f0100c4d:	ff 55 08             	call   *0x8(%ebp)
f0100c50:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0100c53:	e9 0b ff ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
f0100c58:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c5e:	83 c0 04             	add    $0x4,%eax
f0100c61:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c64:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c67:	89 c2                	mov    %eax,%edx
f0100c69:	c1 fa 1f             	sar    $0x1f,%edx
f0100c6c:	31 d0                	xor    %edx,%eax
f0100c6e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c70:	83 f8 06             	cmp    $0x6,%eax
f0100c73:	7f 0b                	jg     f0100c80 <vprintfmt+0x167>
f0100c75:	8b 14 85 b8 1d 10 f0 	mov    -0xfefe248(,%eax,4),%edx
f0100c7c:	85 d2                	test   %edx,%edx
f0100c7e:	75 23                	jne    f0100ca3 <vprintfmt+0x18a>
				printfmt(putch, putdat, "error %d", err);
f0100c80:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c84:	c7 44 24 08 d5 1b 10 	movl   $0xf0101bd5,0x8(%esp)
f0100c8b:	f0 
f0100c8c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100c93:	89 0c 24             	mov    %ecx,(%esp)
f0100c96:	e8 29 03 00 00       	call   f0100fc4 <printfmt>
f0100c9b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c9e:	e9 c0 fe ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100ca3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ca7:	c7 44 24 08 de 1b 10 	movl   $0xf0101bde,0x8(%esp)
f0100cae:	f0 
f0100caf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb6:	89 04 24             	mov    %eax,(%esp)
f0100cb9:	e8 06 03 00 00       	call   f0100fc4 <printfmt>
f0100cbe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cc1:	e9 9d fe ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
f0100cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cc9:	89 c3                	mov    %eax,%ebx
f0100ccb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100cce:	89 7d c8             	mov    %edi,-0x38(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100cd1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cd4:	83 c0 04             	add    $0x4,%eax
f0100cd7:	89 45 14             	mov    %eax,0x14(%ebp)
f0100cda:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100cdd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ce0:	85 c0                	test   %eax,%eax
f0100ce2:	75 07                	jne    f0100ceb <vprintfmt+0x1d2>
f0100ce4:	c7 45 cc e1 1b 10 f0 	movl   $0xf0101be1,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100ceb:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0100cef:	7e 06                	jle    f0100cf7 <vprintfmt+0x1de>
f0100cf1:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f0100cf5:	75 10                	jne    f0100d07 <vprintfmt+0x1ee>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100cf7:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100cfa:	0f be 02             	movsbl (%edx),%eax
f0100cfd:	85 c0                	test   %eax,%eax
f0100cff:	0f 85 8d 00 00 00    	jne    f0100d92 <vprintfmt+0x279>
f0100d05:	eb 7f                	jmp    f0100d86 <vprintfmt+0x26d>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d07:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d0b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100d0e:	89 0c 24             	mov    %ecx,(%esp)
f0100d11:	e8 c5 03 00 00       	call   f01010db <strnlen>
f0100d16:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0100d19:	29 c7                	sub    %eax,%edi
f0100d1b:	85 ff                	test   %edi,%edi
f0100d1d:	7e d8                	jle    f0100cf7 <vprintfmt+0x1de>
					putch(padc, putdat);
f0100d1f:	0f be 45 e0          	movsbl -0x20(%ebp),%eax
f0100d23:	89 5d c8             	mov    %ebx,-0x38(%ebp)
f0100d26:	89 c3                	mov    %eax,%ebx
f0100d28:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d2c:	89 1c 24             	mov    %ebx,(%esp)
f0100d2f:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d32:	83 ef 01             	sub    $0x1,%edi
f0100d35:	85 ff                	test   %edi,%edi
f0100d37:	7f ef                	jg     f0100d28 <vprintfmt+0x20f>
f0100d39:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0100d3c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d41:	eb b4                	jmp    f0100cf7 <vprintfmt+0x1de>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d43:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100d47:	74 1b                	je     f0100d64 <vprintfmt+0x24b>
f0100d49:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d4c:	83 fa 5e             	cmp    $0x5e,%edx
f0100d4f:	76 13                	jbe    f0100d64 <vprintfmt+0x24b>
					putch('?', putdat);
f0100d51:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d54:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d58:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d5f:	ff 55 08             	call   *0x8(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d62:	eb 0d                	jmp    f0100d71 <vprintfmt+0x258>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d64:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100d6b:	89 04 24             	mov    %eax,(%esp)
f0100d6e:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d71:	83 ef 01             	sub    $0x1,%edi
f0100d74:	0f be 03             	movsbl (%ebx),%eax
f0100d77:	85 c0                	test   %eax,%eax
f0100d79:	74 05                	je     f0100d80 <vprintfmt+0x267>
f0100d7b:	83 c3 01             	add    $0x1,%ebx
f0100d7e:	eb 23                	jmp    f0100da3 <vprintfmt+0x28a>
f0100d80:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100d83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d86:	85 ff                	test   %edi,%edi
f0100d88:	7f 2a                	jg     f0100db4 <vprintfmt+0x29b>
f0100d8a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100d8d:	e9 d1 fd ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d92:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100d95:	83 c2 01             	add    $0x1,%edx
f0100d98:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0100d9b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100d9e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100da1:	89 d3                	mov    %edx,%ebx
f0100da3:	85 f6                	test   %esi,%esi
f0100da5:	78 9c                	js     f0100d43 <vprintfmt+0x22a>
f0100da7:	83 ee 01             	sub    $0x1,%esi
f0100daa:	79 97                	jns    f0100d43 <vprintfmt+0x22a>
f0100dac:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100daf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100db2:	eb d2                	jmp    f0100d86 <vprintfmt+0x26d>
f0100db4:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100db7:	8b 5d 08             	mov    0x8(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100dba:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dbe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100dc5:	ff d3                	call   *%ebx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100dc7:	83 ef 01             	sub    $0x1,%edi
f0100dca:	85 ff                	test   %edi,%edi
f0100dcc:	7f ec                	jg     f0100dba <vprintfmt+0x2a1>
f0100dce:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100dd1:	e9 8d fd ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
f0100dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100dd9:	83 f9 01             	cmp    $0x1,%ecx
f0100ddc:	7e 17                	jle    f0100df5 <vprintfmt+0x2dc>
		return va_arg(*ap, long long);
f0100dde:	8b 45 14             	mov    0x14(%ebp),%eax
f0100de1:	83 c0 08             	add    $0x8,%eax
f0100de4:	89 45 14             	mov    %eax,0x14(%ebp)
f0100de7:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100dea:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100ded:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100df0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100df3:	eb 34                	jmp    f0100e29 <vprintfmt+0x310>
	else if (lflag)
f0100df5:	85 c9                	test   %ecx,%ecx
f0100df7:	74 19                	je     f0100e12 <vprintfmt+0x2f9>
		return va_arg(*ap, long);
f0100df9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dfc:	83 c0 04             	add    $0x4,%eax
f0100dff:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e02:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e05:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e08:	89 c1                	mov    %eax,%ecx
f0100e0a:	c1 f9 1f             	sar    $0x1f,%ecx
f0100e0d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e10:	eb 17                	jmp    f0100e29 <vprintfmt+0x310>
	else
		return va_arg(*ap, int);
f0100e12:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e15:	83 c0 04             	add    $0x4,%eax
f0100e18:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e1b:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e21:	89 c2                	mov    %eax,%edx
f0100e23:	c1 fa 1f             	sar    $0x1f,%edx
f0100e26:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100e29:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e2c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e2f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100e34:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e38:	0f 89 9f 00 00 00    	jns    f0100edd <vprintfmt+0x3c4>
				putch('-', putdat);
f0100e3e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e42:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e49:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0100e4c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e4f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e52:	f7 d9                	neg    %ecx
f0100e54:	83 d3 00             	adc    $0x0,%ebx
f0100e57:	f7 db                	neg    %ebx
f0100e59:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e5e:	eb 7d                	jmp    f0100edd <vprintfmt+0x3c4>
f0100e60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e63:	89 ca                	mov    %ecx,%edx
f0100e65:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e68:	e8 52 fc ff ff       	call   f0100abf <getuint>
f0100e6d:	89 c1                	mov    %eax,%ecx
f0100e6f:	89 d3                	mov    %edx,%ebx
f0100e71:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e76:	eb 65                	jmp    f0100edd <vprintfmt+0x3c4>
f0100e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
                        num = getuint(&ap, lflag);
f0100e7b:	89 ca                	mov    %ecx,%edx
f0100e7d:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e80:	e8 3a fc ff ff       	call   f0100abf <getuint>
f0100e85:	89 c1                	mov    %eax,%ecx
f0100e87:	89 d3                	mov    %edx,%ebx
f0100e89:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
                        goto number;
f0100e8e:	eb 4d                	jmp    f0100edd <vprintfmt+0x3c4>
f0100e90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0100e93:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e97:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e9e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0100ea1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ea5:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100eac:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100eaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb2:	83 c0 04             	add    $0x4,%eax
f0100eb5:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100eb8:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ec0:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100ec5:	eb 16                	jmp    f0100edd <vprintfmt+0x3c4>
f0100ec7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100eca:	89 ca                	mov    %ecx,%edx
f0100ecc:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ecf:	e8 eb fb ff ff       	call   f0100abf <getuint>
f0100ed4:	89 c1                	mov    %eax,%ecx
f0100ed6:	89 d3                	mov    %edx,%ebx
f0100ed8:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100edd:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
f0100ee1:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100ee5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0100ee9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100eed:	89 0c 24             	mov    %ecx,(%esp)
f0100ef0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ef4:	89 f2                	mov    %esi,%edx
f0100ef6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ef9:	e8 ce fa ff ff       	call   f01009cc <printnum>
f0100efe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0100f01:	e9 5d fc ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
f0100f06:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100f0c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f10:	89 14 24             	mov    %edx,(%esp)
f0100f13:	ff 55 08             	call   *0x8(%ebp)
f0100f16:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0100f19:	e9 45 fc ff ff       	jmp    f0100b63 <vprintfmt+0x4a>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100f1e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f22:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100f29:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100f2c:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f2f:	80 38 25             	cmpb   $0x25,(%eax)
f0100f32:	0f 84 2b fc ff ff    	je     f0100b63 <vprintfmt+0x4a>
f0100f38:	89 c3                	mov    %eax,%ebx
f0100f3a:	eb f0                	jmp    f0100f2c <vprintfmt+0x413>
				/* do nothing */;
			break;
		}
	}
}
f0100f3c:	83 c4 4c             	add    $0x4c,%esp
f0100f3f:	5b                   	pop    %ebx
f0100f40:	5e                   	pop    %esi
f0100f41:	5f                   	pop    %edi
f0100f42:	5d                   	pop    %ebp
f0100f43:	c3                   	ret    

f0100f44 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f44:	55                   	push   %ebp
f0100f45:	89 e5                	mov    %esp,%ebp
f0100f47:	83 ec 28             	sub    $0x28,%esp
f0100f4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f50:	85 c0                	test   %eax,%eax
f0100f52:	74 04                	je     f0100f58 <vsnprintf+0x14>
f0100f54:	85 d2                	test   %edx,%edx
f0100f56:	7f 07                	jg     f0100f5f <vsnprintf+0x1b>
f0100f58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f5d:	eb 3b                	jmp    f0100f9a <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f62:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f66:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f70:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f77:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f85:	c7 04 24 fc 0a 10 f0 	movl   $0xf0100afc,(%esp)
f0100f8c:	e8 88 fb ff ff       	call   f0100b19 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f94:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100f9a:	c9                   	leave  
f0100f9b:	c3                   	ret    

f0100f9c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f9c:	55                   	push   %ebp
f0100f9d:	89 e5                	mov    %esp,%ebp
f0100f9f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100fa2:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa9:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fac:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fba:	89 04 24             	mov    %eax,(%esp)
f0100fbd:	e8 82 ff ff ff       	call   f0100f44 <vsnprintf>
	va_end(ap);

	return rc;
}
f0100fc2:	c9                   	leave  
f0100fc3:	c3                   	ret    

f0100fc4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100fc4:	55                   	push   %ebp
f0100fc5:	89 e5                	mov    %esp,%ebp
f0100fc7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100fca:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fd1:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fd4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe2:	89 04 24             	mov    %eax,(%esp)
f0100fe5:	e8 2f fb ff ff       	call   f0100b19 <vprintfmt>
	va_end(ap);
}
f0100fea:	c9                   	leave  
f0100feb:	c3                   	ret    
f0100fec:	00 00                	add    %al,(%eax)
	...

f0100ff0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100ff0:	55                   	push   %ebp
f0100ff1:	89 e5                	mov    %esp,%ebp
f0100ff3:	57                   	push   %edi
f0100ff4:	56                   	push   %esi
f0100ff5:	53                   	push   %ebx
f0100ff6:	83 ec 1c             	sub    $0x1c,%esp
f0100ff9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100ffc:	85 c0                	test   %eax,%eax
f0100ffe:	74 10                	je     f0101010 <readline+0x20>
		cprintf("%s", prompt);
f0101000:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101004:	c7 04 24 de 1b 10 f0 	movl   $0xf0101bde,(%esp)
f010100b:	e8 4b f9 ff ff       	call   f010095b <cprintf>

	i = 0;
	echoing = iscons(0);
f0101010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101017:	e8 7b f3 ff ff       	call   f0100397 <iscons>
f010101c:	89 c7                	mov    %eax,%edi
f010101e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101023:	e8 5e f3 ff ff       	call   f0100386 <getchar>
f0101028:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010102a:	85 c0                	test   %eax,%eax
f010102c:	79 17                	jns    f0101045 <readline+0x55>
			cprintf("read error: %e\n", c);
f010102e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101032:	c7 04 24 98 1e 10 f0 	movl   $0xf0101e98,(%esp)
f0101039:	e8 1d f9 ff ff       	call   f010095b <cprintf>
f010103e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101043:	eb 65                	jmp    f01010aa <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101045:	83 f8 1f             	cmp    $0x1f,%eax
f0101048:	7e 1f                	jle    f0101069 <readline+0x79>
f010104a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101050:	7f 17                	jg     f0101069 <readline+0x79>
			if (echoing)
f0101052:	85 ff                	test   %edi,%edi
f0101054:	74 08                	je     f010105e <readline+0x6e>
				cputchar(c);
f0101056:	89 04 24             	mov    %eax,(%esp)
f0101059:	e8 52 f6 ff ff       	call   f01006b0 <cputchar>
			buf[i++] = c;
f010105e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101064:	83 c6 01             	add    $0x1,%esi
f0101067:	eb ba                	jmp    f0101023 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101069:	83 fb 08             	cmp    $0x8,%ebx
f010106c:	75 15                	jne    f0101083 <readline+0x93>
f010106e:	85 f6                	test   %esi,%esi
f0101070:	7e 11                	jle    f0101083 <readline+0x93>
			if (echoing)
f0101072:	85 ff                	test   %edi,%edi
f0101074:	74 08                	je     f010107e <readline+0x8e>
				cputchar(c);
f0101076:	89 1c 24             	mov    %ebx,(%esp)
f0101079:	e8 32 f6 ff ff       	call   f01006b0 <cputchar>
			i--;
f010107e:	83 ee 01             	sub    $0x1,%esi
f0101081:	eb a0                	jmp    f0101023 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101083:	83 fb 0a             	cmp    $0xa,%ebx
f0101086:	74 0a                	je     f0101092 <readline+0xa2>
f0101088:	83 fb 0d             	cmp    $0xd,%ebx
f010108b:	90                   	nop
f010108c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101090:	75 91                	jne    f0101023 <readline+0x33>
			if (echoing)
f0101092:	85 ff                	test   %edi,%edi
f0101094:	74 08                	je     f010109e <readline+0xae>
				cputchar(c);
f0101096:	89 1c 24             	mov    %ebx,(%esp)
f0101099:	e8 12 f6 ff ff       	call   f01006b0 <cputchar>
			buf[i] = 0;
f010109e:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f01010a5:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f01010aa:	83 c4 1c             	add    $0x1c,%esp
f01010ad:	5b                   	pop    %ebx
f01010ae:	5e                   	pop    %esi
f01010af:	5f                   	pop    %edi
f01010b0:	5d                   	pop    %ebp
f01010b1:	c3                   	ret    
	...

f01010c0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01010c0:	55                   	push   %ebp
f01010c1:	89 e5                	mov    %esp,%ebp
f01010c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01010c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010cb:	80 3a 00             	cmpb   $0x0,(%edx)
f01010ce:	74 09                	je     f01010d9 <strlen+0x19>
		n++;
f01010d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010d7:	75 f7                	jne    f01010d0 <strlen+0x10>
		n++;
	return n;
}
f01010d9:	5d                   	pop    %ebp
f01010da:	c3                   	ret    

f01010db <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010db:	55                   	push   %ebp
f01010dc:	89 e5                	mov    %esp,%ebp
f01010de:	53                   	push   %ebx
f01010df:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010e5:	85 c9                	test   %ecx,%ecx
f01010e7:	74 19                	je     f0101102 <strnlen+0x27>
f01010e9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010ec:	74 14                	je     f0101102 <strnlen+0x27>
f01010ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01010f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010f6:	39 c8                	cmp    %ecx,%eax
f01010f8:	74 0d                	je     f0101107 <strnlen+0x2c>
f01010fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01010fe:	75 f3                	jne    f01010f3 <strnlen+0x18>
f0101100:	eb 05                	jmp    f0101107 <strnlen+0x2c>
f0101102:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0101107:	5b                   	pop    %ebx
f0101108:	5d                   	pop    %ebp
f0101109:	c3                   	ret    

f010110a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010110a:	55                   	push   %ebp
f010110b:	89 e5                	mov    %esp,%ebp
f010110d:	53                   	push   %ebx
f010110e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101111:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101114:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101119:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010111d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101120:	83 c2 01             	add    $0x1,%edx
f0101123:	84 c9                	test   %cl,%cl
f0101125:	75 f2                	jne    f0101119 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101127:	5b                   	pop    %ebx
f0101128:	5d                   	pop    %ebp
f0101129:	c3                   	ret    

f010112a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010112a:	55                   	push   %ebp
f010112b:	89 e5                	mov    %esp,%ebp
f010112d:	56                   	push   %esi
f010112e:	53                   	push   %ebx
f010112f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101132:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101135:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101138:	85 f6                	test   %esi,%esi
f010113a:	74 18                	je     f0101154 <strncpy+0x2a>
f010113c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101141:	0f b6 1a             	movzbl (%edx),%ebx
f0101144:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101147:	80 3a 01             	cmpb   $0x1,(%edx)
f010114a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010114d:	83 c1 01             	add    $0x1,%ecx
f0101150:	39 ce                	cmp    %ecx,%esi
f0101152:	77 ed                	ja     f0101141 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101154:	5b                   	pop    %ebx
f0101155:	5e                   	pop    %esi
f0101156:	5d                   	pop    %ebp
f0101157:	c3                   	ret    

f0101158 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101158:	55                   	push   %ebp
f0101159:	89 e5                	mov    %esp,%ebp
f010115b:	56                   	push   %esi
f010115c:	53                   	push   %ebx
f010115d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101160:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101163:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101166:	89 f0                	mov    %esi,%eax
f0101168:	85 c9                	test   %ecx,%ecx
f010116a:	74 27                	je     f0101193 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010116c:	83 e9 01             	sub    $0x1,%ecx
f010116f:	74 1d                	je     f010118e <strlcpy+0x36>
f0101171:	0f b6 1a             	movzbl (%edx),%ebx
f0101174:	84 db                	test   %bl,%bl
f0101176:	74 16                	je     f010118e <strlcpy+0x36>
			*dst++ = *src++;
f0101178:	88 18                	mov    %bl,(%eax)
f010117a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010117d:	83 e9 01             	sub    $0x1,%ecx
f0101180:	74 0e                	je     f0101190 <strlcpy+0x38>
			*dst++ = *src++;
f0101182:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101185:	0f b6 1a             	movzbl (%edx),%ebx
f0101188:	84 db                	test   %bl,%bl
f010118a:	75 ec                	jne    f0101178 <strlcpy+0x20>
f010118c:	eb 02                	jmp    f0101190 <strlcpy+0x38>
f010118e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101190:	c6 00 00             	movb   $0x0,(%eax)
f0101193:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101195:	5b                   	pop    %ebx
f0101196:	5e                   	pop    %esi
f0101197:	5d                   	pop    %ebp
f0101198:	c3                   	ret    

f0101199 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101199:	55                   	push   %ebp
f010119a:	89 e5                	mov    %esp,%ebp
f010119c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010119f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01011a2:	0f b6 01             	movzbl (%ecx),%eax
f01011a5:	84 c0                	test   %al,%al
f01011a7:	74 15                	je     f01011be <strcmp+0x25>
f01011a9:	3a 02                	cmp    (%edx),%al
f01011ab:	75 11                	jne    f01011be <strcmp+0x25>
		p++, q++;
f01011ad:	83 c1 01             	add    $0x1,%ecx
f01011b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01011b3:	0f b6 01             	movzbl (%ecx),%eax
f01011b6:	84 c0                	test   %al,%al
f01011b8:	74 04                	je     f01011be <strcmp+0x25>
f01011ba:	3a 02                	cmp    (%edx),%al
f01011bc:	74 ef                	je     f01011ad <strcmp+0x14>
f01011be:	0f b6 c0             	movzbl %al,%eax
f01011c1:	0f b6 12             	movzbl (%edx),%edx
f01011c4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011c6:	5d                   	pop    %ebp
f01011c7:	c3                   	ret    

f01011c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01011c8:	55                   	push   %ebp
f01011c9:	89 e5                	mov    %esp,%ebp
f01011cb:	53                   	push   %ebx
f01011cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011d2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011d5:	85 c0                	test   %eax,%eax
f01011d7:	74 23                	je     f01011fc <strncmp+0x34>
f01011d9:	0f b6 1a             	movzbl (%edx),%ebx
f01011dc:	84 db                	test   %bl,%bl
f01011de:	74 24                	je     f0101204 <strncmp+0x3c>
f01011e0:	3a 19                	cmp    (%ecx),%bl
f01011e2:	75 20                	jne    f0101204 <strncmp+0x3c>
f01011e4:	83 e8 01             	sub    $0x1,%eax
f01011e7:	74 13                	je     f01011fc <strncmp+0x34>
		n--, p++, q++;
f01011e9:	83 c2 01             	add    $0x1,%edx
f01011ec:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011ef:	0f b6 1a             	movzbl (%edx),%ebx
f01011f2:	84 db                	test   %bl,%bl
f01011f4:	74 0e                	je     f0101204 <strncmp+0x3c>
f01011f6:	3a 19                	cmp    (%ecx),%bl
f01011f8:	74 ea                	je     f01011e4 <strncmp+0x1c>
f01011fa:	eb 08                	jmp    f0101204 <strncmp+0x3c>
f01011fc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101201:	5b                   	pop    %ebx
f0101202:	5d                   	pop    %ebp
f0101203:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101204:	0f b6 02             	movzbl (%edx),%eax
f0101207:	0f b6 11             	movzbl (%ecx),%edx
f010120a:	29 d0                	sub    %edx,%eax
f010120c:	eb f3                	jmp    f0101201 <strncmp+0x39>

f010120e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010120e:	55                   	push   %ebp
f010120f:	89 e5                	mov    %esp,%ebp
f0101211:	8b 45 08             	mov    0x8(%ebp),%eax
f0101214:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101218:	0f b6 10             	movzbl (%eax),%edx
f010121b:	84 d2                	test   %dl,%dl
f010121d:	74 15                	je     f0101234 <strchr+0x26>
		if (*s == c)
f010121f:	38 ca                	cmp    %cl,%dl
f0101221:	75 07                	jne    f010122a <strchr+0x1c>
f0101223:	eb 14                	jmp    f0101239 <strchr+0x2b>
f0101225:	38 ca                	cmp    %cl,%dl
f0101227:	90                   	nop
f0101228:	74 0f                	je     f0101239 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010122a:	83 c0 01             	add    $0x1,%eax
f010122d:	0f b6 10             	movzbl (%eax),%edx
f0101230:	84 d2                	test   %dl,%dl
f0101232:	75 f1                	jne    f0101225 <strchr+0x17>
f0101234:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101239:	5d                   	pop    %ebp
f010123a:	c3                   	ret    

f010123b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010123b:	55                   	push   %ebp
f010123c:	89 e5                	mov    %esp,%ebp
f010123e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101241:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101245:	0f b6 10             	movzbl (%eax),%edx
f0101248:	84 d2                	test   %dl,%dl
f010124a:	74 18                	je     f0101264 <strfind+0x29>
		if (*s == c)
f010124c:	38 ca                	cmp    %cl,%dl
f010124e:	75 0a                	jne    f010125a <strfind+0x1f>
f0101250:	eb 12                	jmp    f0101264 <strfind+0x29>
f0101252:	38 ca                	cmp    %cl,%dl
f0101254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101258:	74 0a                	je     f0101264 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010125a:	83 c0 01             	add    $0x1,%eax
f010125d:	0f b6 10             	movzbl (%eax),%edx
f0101260:	84 d2                	test   %dl,%dl
f0101262:	75 ee                	jne    f0101252 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101264:	5d                   	pop    %ebp
f0101265:	c3                   	ret    

f0101266 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101266:	55                   	push   %ebp
f0101267:	89 e5                	mov    %esp,%ebp
f0101269:	53                   	push   %ebx
f010126a:	8b 45 08             	mov    0x8(%ebp),%eax
f010126d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101270:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101273:	89 da                	mov    %ebx,%edx
f0101275:	83 ea 01             	sub    $0x1,%edx
f0101278:	78 0e                	js     f0101288 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010127a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010127c:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010127f:	88 0a                	mov    %cl,(%edx)
f0101281:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101284:	39 da                	cmp    %ebx,%edx
f0101286:	75 f7                	jne    f010127f <memset+0x19>
		*p++ = c;

	return v;
}
f0101288:	5b                   	pop    %ebx
f0101289:	5d                   	pop    %ebp
f010128a:	c3                   	ret    

f010128b <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f010128b:	55                   	push   %ebp
f010128c:	89 e5                	mov    %esp,%ebp
f010128e:	56                   	push   %esi
f010128f:	53                   	push   %ebx
f0101290:	8b 45 08             	mov    0x8(%ebp),%eax
f0101293:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101296:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101299:	85 db                	test   %ebx,%ebx
f010129b:	74 13                	je     f01012b0 <memcpy+0x25>
f010129d:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f01012a2:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012a6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012a9:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01012ac:	39 da                	cmp    %ebx,%edx
f01012ae:	75 f2                	jne    f01012a2 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f01012b0:	5b                   	pop    %ebx
f01012b1:	5e                   	pop    %esi
f01012b2:	5d                   	pop    %ebp
f01012b3:	c3                   	ret    

f01012b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01012b4:	55                   	push   %ebp
f01012b5:	89 e5                	mov    %esp,%ebp
f01012b7:	57                   	push   %edi
f01012b8:	56                   	push   %esi
f01012b9:	53                   	push   %ebx
f01012ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01012bd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f01012c3:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f01012c5:	39 c6                	cmp    %eax,%esi
f01012c7:	72 0b                	jb     f01012d4 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f01012c9:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f01012ce:	85 db                	test   %ebx,%ebx
f01012d0:	75 2d                	jne    f01012ff <memmove+0x4b>
f01012d2:	eb 39                	jmp    f010130d <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012d4:	01 df                	add    %ebx,%edi
f01012d6:	39 f8                	cmp    %edi,%eax
f01012d8:	73 ef                	jae    f01012c9 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f01012da:	85 db                	test   %ebx,%ebx
f01012dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012e0:	74 2b                	je     f010130d <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012e2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f01012e5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f01012ea:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f01012ef:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f01012f3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01012f6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01012f9:	85 c9                	test   %ecx,%ecx
f01012fb:	75 ed                	jne    f01012ea <memmove+0x36>
f01012fd:	eb 0e                	jmp    f010130d <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012ff:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101303:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101306:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0101309:	39 d3                	cmp    %edx,%ebx
f010130b:	75 f2                	jne    f01012ff <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f010130d:	5b                   	pop    %ebx
f010130e:	5e                   	pop    %esi
f010130f:	5f                   	pop    %edi
f0101310:	5d                   	pop    %ebp
f0101311:	c3                   	ret    

f0101312 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101312:	55                   	push   %ebp
f0101313:	89 e5                	mov    %esp,%ebp
f0101315:	57                   	push   %edi
f0101316:	56                   	push   %esi
f0101317:	53                   	push   %ebx
f0101318:	8b 75 08             	mov    0x8(%ebp),%esi
f010131b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010131e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101321:	85 c9                	test   %ecx,%ecx
f0101323:	74 36                	je     f010135b <memcmp+0x49>
		if (*s1 != *s2)
f0101325:	0f b6 06             	movzbl (%esi),%eax
f0101328:	0f b6 1f             	movzbl (%edi),%ebx
f010132b:	38 d8                	cmp    %bl,%al
f010132d:	74 20                	je     f010134f <memcmp+0x3d>
f010132f:	eb 14                	jmp    f0101345 <memcmp+0x33>
f0101331:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101336:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010133b:	83 c2 01             	add    $0x1,%edx
f010133e:	83 e9 01             	sub    $0x1,%ecx
f0101341:	38 d8                	cmp    %bl,%al
f0101343:	74 12                	je     f0101357 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101345:	0f b6 c0             	movzbl %al,%eax
f0101348:	0f b6 db             	movzbl %bl,%ebx
f010134b:	29 d8                	sub    %ebx,%eax
f010134d:	eb 11                	jmp    f0101360 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010134f:	83 e9 01             	sub    $0x1,%ecx
f0101352:	ba 00 00 00 00       	mov    $0x0,%edx
f0101357:	85 c9                	test   %ecx,%ecx
f0101359:	75 d6                	jne    f0101331 <memcmp+0x1f>
f010135b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101360:	5b                   	pop    %ebx
f0101361:	5e                   	pop    %esi
f0101362:	5f                   	pop    %edi
f0101363:	5d                   	pop    %ebp
f0101364:	c3                   	ret    

f0101365 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101365:	55                   	push   %ebp
f0101366:	89 e5                	mov    %esp,%ebp
f0101368:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010136b:	89 c2                	mov    %eax,%edx
f010136d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101370:	39 d0                	cmp    %edx,%eax
f0101372:	73 15                	jae    f0101389 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101374:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101378:	38 08                	cmp    %cl,(%eax)
f010137a:	75 06                	jne    f0101382 <memfind+0x1d>
f010137c:	eb 0b                	jmp    f0101389 <memfind+0x24>
f010137e:	38 08                	cmp    %cl,(%eax)
f0101380:	74 07                	je     f0101389 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101382:	83 c0 01             	add    $0x1,%eax
f0101385:	39 c2                	cmp    %eax,%edx
f0101387:	77 f5                	ja     f010137e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101389:	5d                   	pop    %ebp
f010138a:	c3                   	ret    

f010138b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010138b:	55                   	push   %ebp
f010138c:	89 e5                	mov    %esp,%ebp
f010138e:	57                   	push   %edi
f010138f:	56                   	push   %esi
f0101390:	53                   	push   %ebx
f0101391:	83 ec 04             	sub    $0x4,%esp
f0101394:	8b 55 08             	mov    0x8(%ebp),%edx
f0101397:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010139a:	0f b6 02             	movzbl (%edx),%eax
f010139d:	3c 20                	cmp    $0x20,%al
f010139f:	74 04                	je     f01013a5 <strtol+0x1a>
f01013a1:	3c 09                	cmp    $0x9,%al
f01013a3:	75 0e                	jne    f01013b3 <strtol+0x28>
		s++;
f01013a5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01013a8:	0f b6 02             	movzbl (%edx),%eax
f01013ab:	3c 20                	cmp    $0x20,%al
f01013ad:	74 f6                	je     f01013a5 <strtol+0x1a>
f01013af:	3c 09                	cmp    $0x9,%al
f01013b1:	74 f2                	je     f01013a5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01013b3:	3c 2b                	cmp    $0x2b,%al
f01013b5:	75 0c                	jne    f01013c3 <strtol+0x38>
		s++;
f01013b7:	83 c2 01             	add    $0x1,%edx
f01013ba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013c1:	eb 15                	jmp    f01013d8 <strtol+0x4d>
	else if (*s == '-')
f01013c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013ca:	3c 2d                	cmp    $0x2d,%al
f01013cc:	75 0a                	jne    f01013d8 <strtol+0x4d>
		s++, neg = 1;
f01013ce:	83 c2 01             	add    $0x1,%edx
f01013d1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013d8:	85 db                	test   %ebx,%ebx
f01013da:	0f 94 c0             	sete   %al
f01013dd:	74 05                	je     f01013e4 <strtol+0x59>
f01013df:	83 fb 10             	cmp    $0x10,%ebx
f01013e2:	75 18                	jne    f01013fc <strtol+0x71>
f01013e4:	80 3a 30             	cmpb   $0x30,(%edx)
f01013e7:	75 13                	jne    f01013fc <strtol+0x71>
f01013e9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013ed:	8d 76 00             	lea    0x0(%esi),%esi
f01013f0:	75 0a                	jne    f01013fc <strtol+0x71>
		s += 2, base = 16;
f01013f2:	83 c2 02             	add    $0x2,%edx
f01013f5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013fa:	eb 15                	jmp    f0101411 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013fc:	84 c0                	test   %al,%al
f01013fe:	66 90                	xchg   %ax,%ax
f0101400:	74 0f                	je     f0101411 <strtol+0x86>
f0101402:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101407:	80 3a 30             	cmpb   $0x30,(%edx)
f010140a:	75 05                	jne    f0101411 <strtol+0x86>
		s++, base = 8;
f010140c:	83 c2 01             	add    $0x1,%edx
f010140f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101411:	b8 00 00 00 00       	mov    $0x0,%eax
f0101416:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101418:	0f b6 0a             	movzbl (%edx),%ecx
f010141b:	89 cf                	mov    %ecx,%edi
f010141d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101420:	80 fb 09             	cmp    $0x9,%bl
f0101423:	77 08                	ja     f010142d <strtol+0xa2>
			dig = *s - '0';
f0101425:	0f be c9             	movsbl %cl,%ecx
f0101428:	83 e9 30             	sub    $0x30,%ecx
f010142b:	eb 1e                	jmp    f010144b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010142d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101430:	80 fb 19             	cmp    $0x19,%bl
f0101433:	77 08                	ja     f010143d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101435:	0f be c9             	movsbl %cl,%ecx
f0101438:	83 e9 57             	sub    $0x57,%ecx
f010143b:	eb 0e                	jmp    f010144b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010143d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101440:	80 fb 19             	cmp    $0x19,%bl
f0101443:	77 15                	ja     f010145a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101445:	0f be c9             	movsbl %cl,%ecx
f0101448:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010144b:	39 f1                	cmp    %esi,%ecx
f010144d:	7d 0b                	jge    f010145a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010144f:	83 c2 01             	add    $0x1,%edx
f0101452:	0f af c6             	imul   %esi,%eax
f0101455:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101458:	eb be                	jmp    f0101418 <strtol+0x8d>
f010145a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010145c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101460:	74 05                	je     f0101467 <strtol+0xdc>
		*endptr = (char *) s;
f0101462:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101465:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101467:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010146b:	74 04                	je     f0101471 <strtol+0xe6>
f010146d:	89 c8                	mov    %ecx,%eax
f010146f:	f7 d8                	neg    %eax
}
f0101471:	83 c4 04             	add    $0x4,%esp
f0101474:	5b                   	pop    %ebx
f0101475:	5e                   	pop    %esi
f0101476:	5f                   	pop    %edi
f0101477:	5d                   	pop    %ebp
f0101478:	c3                   	ret    
f0101479:	00 00                	add    %al,(%eax)
f010147b:	00 00                	add    %al,(%eax)
f010147d:	00 00                	add    %al,(%eax)
	...

f0101480 <__udivdi3>:
f0101480:	55                   	push   %ebp
f0101481:	89 e5                	mov    %esp,%ebp
f0101483:	57                   	push   %edi
f0101484:	56                   	push   %esi
f0101485:	83 ec 10             	sub    $0x10,%esp
f0101488:	8b 45 14             	mov    0x14(%ebp),%eax
f010148b:	8b 55 08             	mov    0x8(%ebp),%edx
f010148e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101491:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101494:	85 c0                	test   %eax,%eax
f0101496:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101499:	75 35                	jne    f01014d0 <__udivdi3+0x50>
f010149b:	39 fe                	cmp    %edi,%esi
f010149d:	77 61                	ja     f0101500 <__udivdi3+0x80>
f010149f:	85 f6                	test   %esi,%esi
f01014a1:	75 0b                	jne    f01014ae <__udivdi3+0x2e>
f01014a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01014a8:	31 d2                	xor    %edx,%edx
f01014aa:	f7 f6                	div    %esi
f01014ac:	89 c6                	mov    %eax,%esi
f01014ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01014b1:	31 d2                	xor    %edx,%edx
f01014b3:	89 f8                	mov    %edi,%eax
f01014b5:	f7 f6                	div    %esi
f01014b7:	89 c7                	mov    %eax,%edi
f01014b9:	89 c8                	mov    %ecx,%eax
f01014bb:	f7 f6                	div    %esi
f01014bd:	89 c1                	mov    %eax,%ecx
f01014bf:	89 fa                	mov    %edi,%edx
f01014c1:	89 c8                	mov    %ecx,%eax
f01014c3:	83 c4 10             	add    $0x10,%esp
f01014c6:	5e                   	pop    %esi
f01014c7:	5f                   	pop    %edi
f01014c8:	5d                   	pop    %ebp
f01014c9:	c3                   	ret    
f01014ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01014d0:	39 f8                	cmp    %edi,%eax
f01014d2:	77 1c                	ja     f01014f0 <__udivdi3+0x70>
f01014d4:	0f bd d0             	bsr    %eax,%edx
f01014d7:	83 f2 1f             	xor    $0x1f,%edx
f01014da:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01014dd:	75 39                	jne    f0101518 <__udivdi3+0x98>
f01014df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014e2:	0f 86 a0 00 00 00    	jbe    f0101588 <__udivdi3+0x108>
f01014e8:	39 f8                	cmp    %edi,%eax
f01014ea:	0f 82 98 00 00 00    	jb     f0101588 <__udivdi3+0x108>
f01014f0:	31 ff                	xor    %edi,%edi
f01014f2:	31 c9                	xor    %ecx,%ecx
f01014f4:	89 c8                	mov    %ecx,%eax
f01014f6:	89 fa                	mov    %edi,%edx
f01014f8:	83 c4 10             	add    $0x10,%esp
f01014fb:	5e                   	pop    %esi
f01014fc:	5f                   	pop    %edi
f01014fd:	5d                   	pop    %ebp
f01014fe:	c3                   	ret    
f01014ff:	90                   	nop
f0101500:	89 d1                	mov    %edx,%ecx
f0101502:	89 fa                	mov    %edi,%edx
f0101504:	89 c8                	mov    %ecx,%eax
f0101506:	31 ff                	xor    %edi,%edi
f0101508:	f7 f6                	div    %esi
f010150a:	89 c1                	mov    %eax,%ecx
f010150c:	89 fa                	mov    %edi,%edx
f010150e:	89 c8                	mov    %ecx,%eax
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	5e                   	pop    %esi
f0101514:	5f                   	pop    %edi
f0101515:	5d                   	pop    %ebp
f0101516:	c3                   	ret    
f0101517:	90                   	nop
f0101518:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010151c:	89 f2                	mov    %esi,%edx
f010151e:	d3 e0                	shl    %cl,%eax
f0101520:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101523:	b8 20 00 00 00       	mov    $0x20,%eax
f0101528:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010152b:	89 c1                	mov    %eax,%ecx
f010152d:	d3 ea                	shr    %cl,%edx
f010152f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101533:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101536:	d3 e6                	shl    %cl,%esi
f0101538:	89 c1                	mov    %eax,%ecx
f010153a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010153d:	89 fe                	mov    %edi,%esi
f010153f:	d3 ee                	shr    %cl,%esi
f0101541:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101545:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101548:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010154b:	d3 e7                	shl    %cl,%edi
f010154d:	89 c1                	mov    %eax,%ecx
f010154f:	d3 ea                	shr    %cl,%edx
f0101551:	09 d7                	or     %edx,%edi
f0101553:	89 f2                	mov    %esi,%edx
f0101555:	89 f8                	mov    %edi,%eax
f0101557:	f7 75 ec             	divl   -0x14(%ebp)
f010155a:	89 d6                	mov    %edx,%esi
f010155c:	89 c7                	mov    %eax,%edi
f010155e:	f7 65 e8             	mull   -0x18(%ebp)
f0101561:	39 d6                	cmp    %edx,%esi
f0101563:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101566:	72 30                	jb     f0101598 <__udivdi3+0x118>
f0101568:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010156b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010156f:	d3 e2                	shl    %cl,%edx
f0101571:	39 c2                	cmp    %eax,%edx
f0101573:	73 05                	jae    f010157a <__udivdi3+0xfa>
f0101575:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101578:	74 1e                	je     f0101598 <__udivdi3+0x118>
f010157a:	89 f9                	mov    %edi,%ecx
f010157c:	31 ff                	xor    %edi,%edi
f010157e:	e9 71 ff ff ff       	jmp    f01014f4 <__udivdi3+0x74>
f0101583:	90                   	nop
f0101584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101588:	31 ff                	xor    %edi,%edi
f010158a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010158f:	e9 60 ff ff ff       	jmp    f01014f4 <__udivdi3+0x74>
f0101594:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101598:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010159b:	31 ff                	xor    %edi,%edi
f010159d:	89 c8                	mov    %ecx,%eax
f010159f:	89 fa                	mov    %edi,%edx
f01015a1:	83 c4 10             	add    $0x10,%esp
f01015a4:	5e                   	pop    %esi
f01015a5:	5f                   	pop    %edi
f01015a6:	5d                   	pop    %ebp
f01015a7:	c3                   	ret    
	...

f01015b0 <__umoddi3>:
f01015b0:	55                   	push   %ebp
f01015b1:	89 e5                	mov    %esp,%ebp
f01015b3:	57                   	push   %edi
f01015b4:	56                   	push   %esi
f01015b5:	83 ec 20             	sub    $0x20,%esp
f01015b8:	8b 55 14             	mov    0x14(%ebp),%edx
f01015bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015be:	8b 7d 10             	mov    0x10(%ebp),%edi
f01015c1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015c4:	85 d2                	test   %edx,%edx
f01015c6:	89 c8                	mov    %ecx,%eax
f01015c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01015cb:	75 13                	jne    f01015e0 <__umoddi3+0x30>
f01015cd:	39 f7                	cmp    %esi,%edi
f01015cf:	76 3f                	jbe    f0101610 <__umoddi3+0x60>
f01015d1:	89 f2                	mov    %esi,%edx
f01015d3:	f7 f7                	div    %edi
f01015d5:	89 d0                	mov    %edx,%eax
f01015d7:	31 d2                	xor    %edx,%edx
f01015d9:	83 c4 20             	add    $0x20,%esp
f01015dc:	5e                   	pop    %esi
f01015dd:	5f                   	pop    %edi
f01015de:	5d                   	pop    %ebp
f01015df:	c3                   	ret    
f01015e0:	39 f2                	cmp    %esi,%edx
f01015e2:	77 4c                	ja     f0101630 <__umoddi3+0x80>
f01015e4:	0f bd ca             	bsr    %edx,%ecx
f01015e7:	83 f1 1f             	xor    $0x1f,%ecx
f01015ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015ed:	75 51                	jne    f0101640 <__umoddi3+0x90>
f01015ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01015f2:	0f 87 e0 00 00 00    	ja     f01016d8 <__umoddi3+0x128>
f01015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015fb:	29 f8                	sub    %edi,%eax
f01015fd:	19 d6                	sbb    %edx,%esi
f01015ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101602:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101605:	89 f2                	mov    %esi,%edx
f0101607:	83 c4 20             	add    $0x20,%esp
f010160a:	5e                   	pop    %esi
f010160b:	5f                   	pop    %edi
f010160c:	5d                   	pop    %ebp
f010160d:	c3                   	ret    
f010160e:	66 90                	xchg   %ax,%ax
f0101610:	85 ff                	test   %edi,%edi
f0101612:	75 0b                	jne    f010161f <__umoddi3+0x6f>
f0101614:	b8 01 00 00 00       	mov    $0x1,%eax
f0101619:	31 d2                	xor    %edx,%edx
f010161b:	f7 f7                	div    %edi
f010161d:	89 c7                	mov    %eax,%edi
f010161f:	89 f0                	mov    %esi,%eax
f0101621:	31 d2                	xor    %edx,%edx
f0101623:	f7 f7                	div    %edi
f0101625:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101628:	f7 f7                	div    %edi
f010162a:	eb a9                	jmp    f01015d5 <__umoddi3+0x25>
f010162c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101630:	89 c8                	mov    %ecx,%eax
f0101632:	89 f2                	mov    %esi,%edx
f0101634:	83 c4 20             	add    $0x20,%esp
f0101637:	5e                   	pop    %esi
f0101638:	5f                   	pop    %edi
f0101639:	5d                   	pop    %ebp
f010163a:	c3                   	ret    
f010163b:	90                   	nop
f010163c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101640:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101644:	d3 e2                	shl    %cl,%edx
f0101646:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101649:	ba 20 00 00 00       	mov    $0x20,%edx
f010164e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101651:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101654:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101658:	89 fa                	mov    %edi,%edx
f010165a:	d3 ea                	shr    %cl,%edx
f010165c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101660:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101663:	d3 e7                	shl    %cl,%edi
f0101665:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101669:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010166c:	89 f2                	mov    %esi,%edx
f010166e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101671:	89 c7                	mov    %eax,%edi
f0101673:	d3 ea                	shr    %cl,%edx
f0101675:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101679:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010167c:	89 c2                	mov    %eax,%edx
f010167e:	d3 e6                	shl    %cl,%esi
f0101680:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101684:	d3 ea                	shr    %cl,%edx
f0101686:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010168a:	09 d6                	or     %edx,%esi
f010168c:	89 f0                	mov    %esi,%eax
f010168e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101691:	d3 e7                	shl    %cl,%edi
f0101693:	89 f2                	mov    %esi,%edx
f0101695:	f7 75 f4             	divl   -0xc(%ebp)
f0101698:	89 d6                	mov    %edx,%esi
f010169a:	f7 65 e8             	mull   -0x18(%ebp)
f010169d:	39 d6                	cmp    %edx,%esi
f010169f:	72 2b                	jb     f01016cc <__umoddi3+0x11c>
f01016a1:	39 c7                	cmp    %eax,%edi
f01016a3:	72 23                	jb     f01016c8 <__umoddi3+0x118>
f01016a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016a9:	29 c7                	sub    %eax,%edi
f01016ab:	19 d6                	sbb    %edx,%esi
f01016ad:	89 f0                	mov    %esi,%eax
f01016af:	89 f2                	mov    %esi,%edx
f01016b1:	d3 ef                	shr    %cl,%edi
f01016b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01016b7:	d3 e0                	shl    %cl,%eax
f01016b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016bd:	09 f8                	or     %edi,%eax
f01016bf:	d3 ea                	shr    %cl,%edx
f01016c1:	83 c4 20             	add    $0x20,%esp
f01016c4:	5e                   	pop    %esi
f01016c5:	5f                   	pop    %edi
f01016c6:	5d                   	pop    %ebp
f01016c7:	c3                   	ret    
f01016c8:	39 d6                	cmp    %edx,%esi
f01016ca:	75 d9                	jne    f01016a5 <__umoddi3+0xf5>
f01016cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01016cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01016d2:	eb d1                	jmp    f01016a5 <__umoddi3+0xf5>
f01016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016d8:	39 f2                	cmp    %esi,%edx
f01016da:	0f 82 18 ff ff ff    	jb     f01015f8 <__umoddi3+0x48>
f01016e0:	e9 1d ff ff ff       	jmp    f0101602 <__umoddi3+0x52>
