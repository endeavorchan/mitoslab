
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
f0100054:	c7 04 24 c0 16 10 f0 	movl   $0xf01016c0,(%esp)
f010005b:	e8 0b 09 00 00       	call   f010096b <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 c6 08 00 00       	call   f0100938 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 86 17 10 f0 	movl   $0xf0101786,(%esp)
f0100079:	e8 ed 08 00 00       	call   f010096b <cprintf>
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
f01000a5:	c7 04 24 da 16 10 f0 	movl   $0xf01016da,(%esp)
f01000ac:	e8 ba 08 00 00       	call   f010096b <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 75 08 00 00       	call   f0100938 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 86 17 10 f0 	movl   $0xf0101786,(%esp)
f01000ca:	e8 9c 08 00 00       	call   f010096b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 11 07 00 00       	call   f01007ec <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
	cprintf("leaving test_backtrace %d\n", x);
}

void
i386_init(void)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	83 ec 18             	sub    $0x18,%esp
        int x = 1, y = 3, z = 4;

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000e3:	b8 80 f9 10 f0       	mov    $0xf010f980,%eax
f01000e8:	2d 20 f3 10 f0       	sub    $0xf010f320,%eax
f01000ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f8:	00 
f01000f9:	c7 04 24 20 f3 10 f0 	movl   $0xf010f320,(%esp)
f0100100:	e8 31 11 00 00       	call   f0101236 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 a7 02 00 00       	call   f01003b1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 f2 16 10 f0 	movl   $0xf01016f2,(%esp)
f0100119:	e8 4d 08 00 00       	call   f010096b <cprintf>

        

	// Test the stack backtrace function (lab 1 only)
        //test_backtrace(5);
        cprintf("my test\n");
f010011e:	c7 04 24 0d 17 10 f0 	movl   $0xf010170d,(%esp)
f0100125:	e8 41 08 00 00       	call   f010096b <cprintf>
        cprintf("x %d, y %x, z %d\n", x, y, z);
f010012a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0100131:	00 
f0100132:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
f0100139:	00 
f010013a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 16 17 10 f0 	movl   $0xf0101716,(%esp)
f0100149:	e8 1d 08 00 00       	call   f010096b <cprintf>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100155:	e8 92 06 00 00       	call   f01007ec <monitor>
f010015a:	eb f2                	jmp    f010014e <i386_init+0x71>

f010015c <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp
f010015f:	53                   	push   %ebx
f0100160:	83 ec 14             	sub    $0x14,%esp
f0100163:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f0100166:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010016a:	c7 04 24 28 17 10 f0 	movl   $0xf0101728,(%esp)
f0100171:	e8 f5 07 00 00       	call   f010096b <cprintf>
	if (x > 0)
f0100176:	85 db                	test   %ebx,%ebx
f0100178:	7e 0d                	jle    f0100187 <test_backtrace+0x2b>
		test_backtrace(x-1);
f010017a:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010017d:	89 04 24             	mov    %eax,(%esp)
f0100180:	e8 d7 ff ff ff       	call   f010015c <test_backtrace>
f0100185:	eb 1c                	jmp    f01001a3 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f0100187:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010018e:	00 
f010018f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100196:	00 
f0100197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010019e:	e8 3d 05 00 00       	call   f01006e0 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f01001a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01001a7:	c7 04 24 44 17 10 f0 	movl   $0xf0101744,(%esp)
f01001ae:	e8 b8 07 00 00       	call   f010096b <cprintf>
}
f01001b3:	83 c4 14             	add    $0x14,%esp
f01001b6:	5b                   	pop    %ebx
f01001b7:	5d                   	pop    %ebp
f01001b8:	c3                   	ret    
f01001b9:	00 00                	add    %al,(%eax)
f01001bb:	00 00                	add    %al,(%eax)
f01001bd:	00 00                	add    %al,(%eax)
	...

f01001c0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
f01001c9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001d0:	f6 c2 01             	test   $0x1,%dl
f01001d3:	74 09                	je     f01001de <serial_proc_data+0x1e>
f01001d5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001da:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001db:	0f b6 c0             	movzbl %al,%eax
}
f01001de:	5d                   	pop    %ebp
f01001df:	c3                   	ret    

f01001e0 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp
f01001e3:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001e4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01001e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ee:	89 da                	mov    %ebx,%edx
f01001f0:	ee                   	out    %al,(%dx)
f01001f1:	b2 fb                	mov    $0xfb,%dl
f01001f3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01001f8:	ee                   	out    %al,(%dx)
f01001f9:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01001fe:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100203:	89 ca                	mov    %ecx,%edx
f0100205:	ee                   	out    %al,(%dx)
f0100206:	b2 f9                	mov    $0xf9,%dl
f0100208:	b8 00 00 00 00       	mov    $0x0,%eax
f010020d:	ee                   	out    %al,(%dx)
f010020e:	b2 fb                	mov    $0xfb,%dl
f0100210:	b8 03 00 00 00       	mov    $0x3,%eax
f0100215:	ee                   	out    %al,(%dx)
f0100216:	b2 fc                	mov    $0xfc,%dl
f0100218:	b8 00 00 00 00       	mov    $0x0,%eax
f010021d:	ee                   	out    %al,(%dx)
f010021e:	b2 f9                	mov    $0xf9,%dl
f0100220:	b8 01 00 00 00       	mov    $0x1,%eax
f0100225:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100226:	b2 fd                	mov    $0xfd,%dl
f0100228:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100229:	3c ff                	cmp    $0xff,%al
f010022b:	0f 95 c0             	setne  %al
f010022e:	0f b6 c0             	movzbl %al,%eax
f0100231:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100236:	89 da                	mov    %ebx,%edx
f0100238:	ec                   	in     (%dx),%al
f0100239:	89 ca                	mov    %ecx,%edx
f010023b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010023c:	5b                   	pop    %ebx
f010023d:	5d                   	pop    %ebp
f010023e:	c3                   	ret    

f010023f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010023f:	55                   	push   %ebp
f0100240:	89 e5                	mov    %esp,%ebp
f0100242:	83 ec 0c             	sub    $0xc,%esp
f0100245:	89 1c 24             	mov    %ebx,(%esp)
f0100248:	89 74 24 04          	mov    %esi,0x4(%esp)
f010024c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100250:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100255:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100258:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010025d:	0f b7 00             	movzwl (%eax),%eax
f0100260:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100264:	74 11                	je     f0100277 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100266:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010026d:	03 00 00 
f0100270:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100275:	eb 16                	jmp    f010028d <cga_init+0x4e>
	} else {
		*cp = was;
f0100277:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010027e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f0100285:	03 00 00 
f0100288:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010028d:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f0100293:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100295:	b8 0e 00 00 00       	mov    $0xe,%eax
f010029a:	89 ca                	mov    %ecx,%edx
f010029c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010029d:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a0:	89 ca                	mov    %ecx,%edx
f01002a2:	ec                   	in     (%dx),%al
f01002a3:	0f b6 f8             	movzbl %al,%edi
f01002a6:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01002ae:	89 da                	mov    %ebx,%edx
f01002b0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b1:	89 ca                	mov    %ecx,%edx
f01002b3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01002b4:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f01002ba:	0f b6 c8             	movzbl %al,%ecx
f01002bd:	09 cf                	or     %ecx,%edi
f01002bf:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002c6:	8b 1c 24             	mov    (%esp),%ebx
f01002c9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002cd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002d1:	89 ec                	mov    %ebp,%esp
f01002d3:	5d                   	pop    %ebp
f01002d4:	c3                   	ret    

f01002d5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002d5:	55                   	push   %ebp
f01002d6:	89 e5                	mov    %esp,%ebp
}
f01002d8:	5d                   	pop    %ebp
f01002d9:	c3                   	ret    

f01002da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	57                   	push   %edi
f01002de:	56                   	push   %esi
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 0c             	sub    $0xc,%esp
f01002e3:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002e6:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f01002eb:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002f0:	eb 1e                	jmp    f0100310 <cons_intr+0x36>
		if (c == 0)
f01002f2:	85 c0                	test   %eax,%eax
f01002f4:	74 1a                	je     f0100310 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f6:	8b 13                	mov    (%ebx),%edx
f01002f8:	88 04 17             	mov    %al,(%edi,%edx,1)
f01002fb:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01002fe:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100303:	0f 94 c2             	sete   %dl
f0100306:	0f b6 d2             	movzbl %dl,%edx
f0100309:	83 ea 01             	sub    $0x1,%edx
f010030c:	21 d0                	and    %edx,%eax
f010030e:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100310:	ff d6                	call   *%esi
f0100312:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100315:	75 db                	jne    f01002f2 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100317:	83 c4 0c             	add    $0xc,%esp
f010031a:	5b                   	pop    %ebx
f010031b:	5e                   	pop    %esi
f010031c:	5f                   	pop    %edi
f010031d:	5d                   	pop    %ebp
f010031e:	c3                   	ret    

f010031f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010031f:	55                   	push   %ebp
f0100320:	89 e5                	mov    %esp,%ebp
f0100322:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100325:	c7 04 24 d8 03 10 f0 	movl   $0xf01003d8,(%esp)
f010032c:	e8 a9 ff ff ff       	call   f01002da <cons_intr>
}
f0100331:	c9                   	leave  
f0100332:	c3                   	ret    

f0100333 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100333:	55                   	push   %ebp
f0100334:	89 e5                	mov    %esp,%ebp
f0100336:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100339:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100340:	74 0c                	je     f010034e <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100342:	c7 04 24 c0 01 10 f0 	movl   $0xf01001c0,(%esp)
f0100349:	e8 8c ff ff ff       	call   f01002da <cons_intr>
}
f010034e:	c9                   	leave  
f010034f:	c3                   	ret    

f0100350 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100350:	55                   	push   %ebp
f0100351:	89 e5                	mov    %esp,%ebp
f0100353:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100356:	e8 d8 ff ff ff       	call   f0100333 <serial_intr>
	kbd_intr();
f010035b:	e8 bf ff ff ff       	call   f010031f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100360:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100366:	b8 00 00 00 00       	mov    $0x0,%eax
f010036b:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f0100371:	74 21                	je     f0100394 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100373:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f010037a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010037d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100383:	0f 94 c1             	sete   %cl
f0100386:	0f b6 c9             	movzbl %cl,%ecx
f0100389:	83 e9 01             	sub    $0x1,%ecx
f010038c:	21 ca                	and    %ecx,%edx
f010038e:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f0100394:	c9                   	leave  
f0100395:	c3                   	ret    

f0100396 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f0100396:	55                   	push   %ebp
f0100397:	89 e5                	mov    %esp,%ebp
f0100399:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010039c:	e8 af ff ff ff       	call   f0100350 <cons_getc>
f01003a1:	85 c0                	test   %eax,%eax
f01003a3:	74 f7                	je     f010039c <getchar+0x6>
		/* do nothing */;
	return c;
}
f01003a5:	c9                   	leave  
f01003a6:	c3                   	ret    

f01003a7 <iscons>:

int
iscons(int fdnum)
{
f01003a7:	55                   	push   %ebp
f01003a8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01003aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01003af:	5d                   	pop    %ebp
f01003b0:	c3                   	ret    

f01003b1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01003b1:	55                   	push   %ebp
f01003b2:	89 e5                	mov    %esp,%ebp
f01003b4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01003b7:	e8 83 fe ff ff       	call   f010023f <cga_init>
	kbd_init();
	serial_init();
f01003bc:	e8 1f fe ff ff       	call   f01001e0 <serial_init>

	if (!serial_exists)
f01003c1:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003c8:	75 0c                	jne    f01003d6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003ca:	c7 04 24 5f 17 10 f0 	movl   $0xf010175f,(%esp)
f01003d1:	e8 95 05 00 00       	call   f010096b <cprintf>
}
f01003d6:	c9                   	leave  
f01003d7:	c3                   	ret    

f01003d8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003d8:	55                   	push   %ebp
f01003d9:	89 e5                	mov    %esp,%ebp
f01003db:	53                   	push   %ebx
f01003dc:	83 ec 14             	sub    $0x14,%esp
f01003df:	ba 64 00 00 00       	mov    $0x64,%edx
f01003e4:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003e5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ea:	a8 01                	test   $0x1,%al
f01003ec:	0f 84 d9 00 00 00    	je     f01004cb <kbd_proc_data+0xf3>
f01003f2:	b2 60                	mov    $0x60,%dl
f01003f4:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003f5:	3c e0                	cmp    $0xe0,%al
f01003f7:	75 11                	jne    f010040a <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01003f9:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f0100400:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100405:	e9 c1 00 00 00       	jmp    f01004cb <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010040a:	84 c0                	test   %al,%al
f010040c:	79 32                	jns    f0100440 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010040e:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100414:	f6 c2 40             	test   $0x40,%dl
f0100417:	75 03                	jne    f010041c <kbd_proc_data+0x44>
f0100419:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010041c:	0f b6 c0             	movzbl %al,%eax
f010041f:	0f b6 80 a0 17 10 f0 	movzbl -0xfefe860(%eax),%eax
f0100426:	83 c8 40             	or     $0x40,%eax
f0100429:	0f b6 c0             	movzbl %al,%eax
f010042c:	f7 d0                	not    %eax
f010042e:	21 c2                	and    %eax,%edx
f0100430:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100436:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010043b:	e9 8b 00 00 00       	jmp    f01004cb <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100440:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100446:	f6 c2 40             	test   $0x40,%dl
f0100449:	74 0c                	je     f0100457 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010044b:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010044e:	83 e2 bf             	and    $0xffffffbf,%edx
f0100451:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100457:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010045a:	0f b6 90 a0 17 10 f0 	movzbl -0xfefe860(%eax),%edx
f0100461:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100467:	0f b6 88 a0 18 10 f0 	movzbl -0xfefe760(%eax),%ecx
f010046e:	31 ca                	xor    %ecx,%edx
f0100470:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100476:	89 d1                	mov    %edx,%ecx
f0100478:	83 e1 03             	and    $0x3,%ecx
f010047b:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
f0100482:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100486:	f6 c2 08             	test   $0x8,%dl
f0100489:	74 1a                	je     f01004a5 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f010048b:	89 d9                	mov    %ebx,%ecx
f010048d:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100490:	83 f8 19             	cmp    $0x19,%eax
f0100493:	77 05                	ja     f010049a <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f0100495:	83 eb 20             	sub    $0x20,%ebx
f0100498:	eb 0b                	jmp    f01004a5 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f010049a:	83 e9 41             	sub    $0x41,%ecx
f010049d:	83 f9 19             	cmp    $0x19,%ecx
f01004a0:	77 03                	ja     f01004a5 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f01004a2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004a5:	f7 d2                	not    %edx
f01004a7:	f6 c2 06             	test   $0x6,%dl
f01004aa:	75 1f                	jne    f01004cb <kbd_proc_data+0xf3>
f01004ac:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004b2:	75 17                	jne    f01004cb <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01004b4:	c7 04 24 7c 17 10 f0 	movl   $0xf010177c,(%esp)
f01004bb:	e8 ab 04 00 00       	call   f010096b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c0:	ba 92 00 00 00       	mov    $0x92,%edx
f01004c5:	b8 03 00 00 00       	mov    $0x3,%eax
f01004ca:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004cb:	89 d8                	mov    %ebx,%eax
f01004cd:	83 c4 14             	add    $0x14,%esp
f01004d0:	5b                   	pop    %ebx
f01004d1:	5d                   	pop    %ebp
f01004d2:	c3                   	ret    

f01004d3 <cga_putc>:



void
cga_putc(int c)
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	56                   	push   %esi
f01004d7:	53                   	push   %ebx
f01004d8:	83 ec 10             	sub    $0x10,%esp
f01004db:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004de:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01004e3:	75 03                	jne    f01004e8 <cga_putc+0x15>
		c |= 0x0700;
f01004e5:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f01004e8:	0f b6 d0             	movzbl %al,%edx
f01004eb:	83 fa 09             	cmp    $0x9,%edx
f01004ee:	0f 84 89 00 00 00    	je     f010057d <cga_putc+0xaa>
f01004f4:	83 fa 09             	cmp    $0x9,%edx
f01004f7:	7f 11                	jg     f010050a <cga_putc+0x37>
f01004f9:	83 fa 08             	cmp    $0x8,%edx
f01004fc:	0f 85 b9 00 00 00    	jne    f01005bb <cga_putc+0xe8>
f0100502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100508:	eb 18                	jmp    f0100522 <cga_putc+0x4f>
f010050a:	83 fa 0a             	cmp    $0xa,%edx
f010050d:	8d 76 00             	lea    0x0(%esi),%esi
f0100510:	74 41                	je     f0100553 <cga_putc+0x80>
f0100512:	83 fa 0d             	cmp    $0xd,%edx
f0100515:	8d 76 00             	lea    0x0(%esi),%esi
f0100518:	0f 85 9d 00 00 00    	jne    f01005bb <cga_putc+0xe8>
f010051e:	66 90                	xchg   %ax,%ax
f0100520:	eb 39                	jmp    f010055b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100522:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100529:	66 85 d2             	test   %dx,%dx
f010052c:	0f 84 f4 00 00 00    	je     f0100626 <cga_putc+0x153>
			crt_pos--;
f0100532:	83 ea 01             	sub    $0x1,%edx
f0100535:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053c:	0f b7 d2             	movzwl %dx,%edx
f010053f:	b0 00                	mov    $0x0,%al
f0100541:	83 c8 20             	or     $0x20,%eax
f0100544:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010054a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010054e:	e9 86 00 00 00       	jmp    f01005d9 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100553:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010055a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010055b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100562:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100568:	c1 e8 10             	shr    $0x10,%eax
f010056b:	66 c1 e8 06          	shr    $0x6,%ax
f010056f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100572:	c1 e0 04             	shl    $0x4,%eax
f0100575:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010057b:	eb 5c                	jmp    f01005d9 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010057d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100584:	e8 d4 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f0100589:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100590:	e8 c8 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f0100595:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010059c:	e8 bc 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f01005a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005a8:	e8 b0 00 00 00       	call   f010065d <cons_putc>
		cons_putc(' ');
f01005ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005b4:	e8 a4 00 00 00       	call   f010065d <cons_putc>
		break;
f01005b9:	eb 1e                	jmp    f01005d9 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005bb:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005c2:	0f b7 da             	movzwl %dx,%ebx
f01005c5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005cb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005cf:	83 c2 01             	add    $0x1,%edx
f01005d2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005d9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f01005e0:	cf 07 
f01005e2:	76 42                	jbe    f0100626 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005e4:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f01005e9:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005f0:	00 
f01005f1:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005fb:	89 04 24             	mov    %eax,(%esp)
f01005fe:	e8 58 0c 00 00       	call   f010125b <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100603:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f0100609:	b8 80 07 00 00       	mov    $0x780,%eax
f010060e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100614:	83 c0 01             	add    $0x1,%eax
f0100617:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010061c:	75 f0                	jne    f010060e <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010061e:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100625:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100626:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010062c:	89 cb                	mov    %ecx,%ebx
f010062e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100633:	89 ca                	mov    %ecx,%edx
f0100635:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100636:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010063d:	83 c1 01             	add    $0x1,%ecx
f0100640:	89 f0                	mov    %esi,%eax
f0100642:	66 c1 e8 08          	shr    $0x8,%ax
f0100646:	89 ca                	mov    %ecx,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	b8 0f 00 00 00       	mov    $0xf,%eax
f010064e:	89 da                	mov    %ebx,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	89 f0                	mov    %esi,%eax
f0100653:	89 ca                	mov    %ecx,%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100656:	83 c4 10             	add    $0x10,%esp
f0100659:	5b                   	pop    %ebx
f010065a:	5e                   	pop    %esi
f010065b:	5d                   	pop    %ebp
f010065c:	c3                   	ret    

f010065d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	57                   	push   %edi
f0100661:	56                   	push   %esi
f0100662:	53                   	push   %ebx
f0100663:	83 ec 1c             	sub    $0x1c,%esp
f0100666:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100669:	ba 79 03 00 00       	mov    $0x379,%edx
f010066e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010066f:	84 c0                	test   %al,%al
f0100671:	78 27                	js     f010069a <cons_putc+0x3d>
f0100673:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100678:	b9 84 00 00 00       	mov    $0x84,%ecx
f010067d:	be 79 03 00 00       	mov    $0x379,%esi
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	ec                   	in     (%dx),%al
f0100686:	ec                   	in     (%dx),%al
f0100687:	ec                   	in     (%dx),%al
f0100688:	89 f2                	mov    %esi,%edx
f010068a:	ec                   	in     (%dx),%al
f010068b:	84 c0                	test   %al,%al
f010068d:	78 0b                	js     f010069a <cons_putc+0x3d>
f010068f:	83 c3 01             	add    $0x1,%ebx
f0100692:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100698:	75 e8                	jne    f0100682 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069a:	ba 78 03 00 00       	mov    $0x378,%edx
f010069f:	89 f8                	mov    %edi,%eax
f01006a1:	ee                   	out    %al,(%dx)
f01006a2:	b2 7a                	mov    $0x7a,%dl
f01006a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01006a9:	ee                   	out    %al,(%dx)
f01006aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01006af:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01006b0:	89 3c 24             	mov    %edi,(%esp)
f01006b3:	e8 1b fe ff ff       	call   f01004d3 <cga_putc>
}
f01006b8:	83 c4 1c             	add    $0x1c,%esp
f01006bb:	5b                   	pop    %ebx
f01006bc:	5e                   	pop    %esi
f01006bd:	5f                   	pop    %edi
f01006be:	5d                   	pop    %ebp
f01006bf:	c3                   	ret    

f01006c0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
f01006c3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006c9:	89 04 24             	mov    %eax,(%esp)
f01006cc:	e8 8c ff ff ff       	call   f010065d <cons_putc>
}
f01006d1:	c9                   	leave  
f01006d2:	c3                   	ret    
	...

f01006e0 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01006e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e8:	5d                   	pop    %ebp
f01006e9:	c3                   	ret    

f01006ea <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f01006ea:	55                   	push   %ebp
f01006eb:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f01006ed:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f01006f0:	5d                   	pop    %ebp
f01006f1:	c3                   	ret    

f01006f2 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006f2:	55                   	push   %ebp
f01006f3:	89 e5                	mov    %esp,%ebp
f01006f5:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f8:	c7 04 24 b0 19 10 f0 	movl   $0xf01019b0,(%esp)
f01006ff:	e8 67 02 00 00       	call   f010096b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100704:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010070b:	00 
f010070c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100713:	f0 
f0100714:	c7 04 24 3c 1a 10 f0 	movl   $0xf0101a3c,(%esp)
f010071b:	e8 4b 02 00 00       	call   f010096b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100720:	c7 44 24 08 b5 16 10 	movl   $0x1016b5,0x8(%esp)
f0100727:	00 
f0100728:	c7 44 24 04 b5 16 10 	movl   $0xf01016b5,0x4(%esp)
f010072f:	f0 
f0100730:	c7 04 24 60 1a 10 f0 	movl   $0xf0101a60,(%esp)
f0100737:	e8 2f 02 00 00       	call   f010096b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100743:	00 
f0100744:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010074b:	f0 
f010074c:	c7 04 24 84 1a 10 f0 	movl   $0xf0101a84,(%esp)
f0100753:	e8 13 02 00 00       	call   f010096b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100758:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010075f:	00 
f0100760:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100767:	f0 
f0100768:	c7 04 24 a8 1a 10 f0 	movl   $0xf0101aa8,(%esp)
f010076f:	e8 f7 01 00 00       	call   f010096b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100774:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100779:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010077e:	89 c2                	mov    %eax,%edx
f0100780:	c1 fa 1f             	sar    $0x1f,%edx
f0100783:	c1 ea 16             	shr    $0x16,%edx
f0100786:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100789:	c1 f8 0a             	sar    $0xa,%eax
f010078c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100790:	c7 04 24 cc 1a 10 f0 	movl   $0xf0101acc,(%esp)
f0100797:	e8 cf 01 00 00       	call   f010096b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f010079c:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
f01007a6:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007a9:	a1 70 1b 10 f0       	mov    0xf0101b70,%eax
f01007ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b2:	a1 6c 1b 10 f0       	mov    0xf0101b6c,%eax
f01007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007bb:	c7 04 24 c9 19 10 f0 	movl   $0xf01019c9,(%esp)
f01007c2:	e8 a4 01 00 00       	call   f010096b <cprintf>
f01007c7:	a1 7c 1b 10 f0       	mov    0xf0101b7c,%eax
f01007cc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d0:	a1 78 1b 10 f0       	mov    0xf0101b78,%eax
f01007d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d9:	c7 04 24 c9 19 10 f0 	movl   $0xf01019c9,(%esp)
f01007e0:	e8 86 01 00 00       	call   f010096b <cprintf>
	return 0;
}
f01007e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ea:	c9                   	leave  
f01007eb:	c3                   	ret    

f01007ec <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ec:	55                   	push   %ebp
f01007ed:	89 e5                	mov    %esp,%ebp
f01007ef:	57                   	push   %edi
f01007f0:	56                   	push   %esi
f01007f1:	53                   	push   %ebx
f01007f2:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007f5:	c7 04 24 f8 1a 10 f0 	movl   $0xf0101af8,(%esp)
f01007fc:	e8 6a 01 00 00       	call   f010096b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100801:	c7 04 24 1c 1b 10 f0 	movl   $0xf0101b1c,(%esp)
f0100808:	e8 5e 01 00 00       	call   f010096b <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010080d:	bf 6c 1b 10 f0       	mov    $0xf0101b6c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100812:	c7 04 24 d2 19 10 f0 	movl   $0xf01019d2,(%esp)
f0100819:	e8 a2 07 00 00       	call   f0100fc0 <readline>
f010081e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100820:	85 c0                	test   %eax,%eax
f0100822:	74 ee                	je     f0100812 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100824:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010082b:	be 00 00 00 00       	mov    $0x0,%esi
f0100830:	eb 06                	jmp    f0100838 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100832:	c6 03 00             	movb   $0x0,(%ebx)
f0100835:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100838:	0f b6 03             	movzbl (%ebx),%eax
f010083b:	84 c0                	test   %al,%al
f010083d:	74 6c                	je     f01008ab <monitor+0xbf>
f010083f:	0f be c0             	movsbl %al,%eax
f0100842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100846:	c7 04 24 d6 19 10 f0 	movl   $0xf01019d6,(%esp)
f010084d:	e8 8c 09 00 00       	call   f01011de <strchr>
f0100852:	85 c0                	test   %eax,%eax
f0100854:	75 dc                	jne    f0100832 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100856:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100859:	74 50                	je     f01008ab <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010085b:	83 fe 0f             	cmp    $0xf,%esi
f010085e:	66 90                	xchg   %ax,%ax
f0100860:	75 16                	jne    f0100878 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100862:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100869:	00 
f010086a:	c7 04 24 db 19 10 f0 	movl   $0xf01019db,(%esp)
f0100871:	e8 f5 00 00 00       	call   f010096b <cprintf>
f0100876:	eb 9a                	jmp    f0100812 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100878:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010087c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010087f:	0f b6 03             	movzbl (%ebx),%eax
f0100882:	84 c0                	test   %al,%al
f0100884:	75 0c                	jne    f0100892 <monitor+0xa6>
f0100886:	eb b0                	jmp    f0100838 <monitor+0x4c>
			buf++;
f0100888:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010088b:	0f b6 03             	movzbl (%ebx),%eax
f010088e:	84 c0                	test   %al,%al
f0100890:	74 a6                	je     f0100838 <monitor+0x4c>
f0100892:	0f be c0             	movsbl %al,%eax
f0100895:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100899:	c7 04 24 d6 19 10 f0 	movl   $0xf01019d6,(%esp)
f01008a0:	e8 39 09 00 00       	call   f01011de <strchr>
f01008a5:	85 c0                	test   %eax,%eax
f01008a7:	74 df                	je     f0100888 <monitor+0x9c>
f01008a9:	eb 8d                	jmp    f0100838 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f01008ab:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008b2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008b3:	85 f6                	test   %esi,%esi
f01008b5:	0f 84 57 ff ff ff    	je     f0100812 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008bb:	8b 07                	mov    (%edi),%eax
f01008bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c4:	89 04 24             	mov    %eax,(%esp)
f01008c7:	e8 9d 08 00 00       	call   f0101169 <strcmp>
f01008cc:	ba 00 00 00 00       	mov    $0x0,%edx
f01008d1:	85 c0                	test   %eax,%eax
f01008d3:	74 1d                	je     f01008f2 <monitor+0x106>
f01008d5:	a1 78 1b 10 f0       	mov    0xf0101b78,%eax
f01008da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008de:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008e1:	89 04 24             	mov    %eax,(%esp)
f01008e4:	e8 80 08 00 00       	call   f0101169 <strcmp>
f01008e9:	85 c0                	test   %eax,%eax
f01008eb:	75 28                	jne    f0100915 <monitor+0x129>
f01008ed:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008f2:	6b d2 0c             	imul   $0xc,%edx,%edx
f01008f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01008f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008fc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100903:	89 34 24             	mov    %esi,(%esp)
f0100906:	ff 92 74 1b 10 f0    	call   *-0xfefe48c(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010090c:	85 c0                	test   %eax,%eax
f010090e:	78 1d                	js     f010092d <monitor+0x141>
f0100910:	e9 fd fe ff ff       	jmp    f0100812 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100915:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100918:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091c:	c7 04 24 f8 19 10 f0 	movl   $0xf01019f8,(%esp)
f0100923:	e8 43 00 00 00       	call   f010096b <cprintf>
f0100928:	e9 e5 fe ff ff       	jmp    f0100812 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092d:	83 c4 5c             	add    $0x5c,%esp
f0100930:	5b                   	pop    %ebx
f0100931:	5e                   	pop    %esi
f0100932:	5f                   	pop    %edi
f0100933:	5d                   	pop    %ebp
f0100934:	c3                   	ret    
f0100935:	00 00                	add    %al,(%eax)
	...

f0100938 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010093e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100945:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100948:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010094c:	8b 45 08             	mov    0x8(%ebp),%eax
f010094f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100953:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100956:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095a:	c7 04 24 85 09 10 f0 	movl   $0xf0100985,(%esp)
f0100961:	e8 8a 01 00 00       	call   f0100af0 <vprintfmt>
	return cnt;
}
f0100966:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100969:	c9                   	leave  
f010096a:	c3                   	ret    

f010096b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010096b:	55                   	push   %ebp
f010096c:	89 e5                	mov    %esp,%ebp
f010096e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100971:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	8b 45 08             	mov    0x8(%ebp),%eax
f010097b:	89 04 24             	mov    %eax,(%esp)
f010097e:	e8 b5 ff ff ff       	call   f0100938 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100983:	c9                   	leave  
f0100984:	c3                   	ret    

f0100985 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100985:	55                   	push   %ebp
f0100986:	89 e5                	mov    %esp,%ebp
f0100988:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010098b:	8b 45 08             	mov    0x8(%ebp),%eax
f010098e:	89 04 24             	mov    %eax,(%esp)
f0100991:	e8 2a fd ff ff       	call   f01006c0 <cputchar>
	*cnt++;
}
f0100996:	c9                   	leave  
f0100997:	c3                   	ret    
	...

f01009a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01009a0:	55                   	push   %ebp
f01009a1:	89 e5                	mov    %esp,%ebp
f01009a3:	57                   	push   %edi
f01009a4:	56                   	push   %esi
f01009a5:	53                   	push   %ebx
f01009a6:	83 ec 4c             	sub    $0x4c,%esp
f01009a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01009ac:	89 d6                	mov    %edx,%esi
f01009ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01009b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01009b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01009bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01009c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01009c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01009c6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01009cb:	39 d1                	cmp    %edx,%ecx
f01009cd:	72 15                	jb     f01009e4 <printnum+0x44>
f01009cf:	77 07                	ja     f01009d8 <printnum+0x38>
f01009d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01009d4:	39 d0                	cmp    %edx,%eax
f01009d6:	76 0c                	jbe    f01009e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01009d8:	83 eb 01             	sub    $0x1,%ebx
f01009db:	85 db                	test   %ebx,%ebx
f01009dd:	8d 76 00             	lea    0x0(%esi),%esi
f01009e0:	7f 61                	jg     f0100a43 <printnum+0xa3>
f01009e2:	eb 70                	jmp    f0100a54 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01009e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f01009e8:	83 eb 01             	sub    $0x1,%ebx
f01009eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01009ef:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01009f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f01009fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01009fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100a01:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a04:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a0f:	00 
f0100a10:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a13:	89 04 24             	mov    %eax,(%esp)
f0100a16:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a1d:	e8 2e 0a 00 00       	call   f0101450 <__udivdi3>
f0100a22:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a25:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a2c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a30:	89 04 24             	mov    %eax,(%esp)
f0100a33:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a37:	89 f2                	mov    %esi,%edx
f0100a39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a3c:	e8 5f ff ff ff       	call   f01009a0 <printnum>
f0100a41:	eb 11                	jmp    f0100a54 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a43:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a47:	89 3c 24             	mov    %edi,(%esp)
f0100a4a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a4d:	83 eb 01             	sub    $0x1,%ebx
f0100a50:	85 db                	test   %ebx,%ebx
f0100a52:	7f ef                	jg     f0100a43 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a54:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a58:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a63:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a6a:	00 
f0100a6b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a6e:	89 14 24             	mov    %edx,(%esp)
f0100a71:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100a78:	e8 03 0b 00 00       	call   f0101580 <__umoddi3>
f0100a7d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a81:	0f be 80 84 1b 10 f0 	movsbl -0xfefe47c(%eax),%eax
f0100a88:	89 04 24             	mov    %eax,(%esp)
f0100a8b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100a8e:	83 c4 4c             	add    $0x4c,%esp
f0100a91:	5b                   	pop    %ebx
f0100a92:	5e                   	pop    %esi
f0100a93:	5f                   	pop    %edi
f0100a94:	5d                   	pop    %ebp
f0100a95:	c3                   	ret    

f0100a96 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100a96:	55                   	push   %ebp
f0100a97:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100a99:	83 fa 01             	cmp    $0x1,%edx
f0100a9c:	7e 0f                	jle    f0100aad <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100a9e:	8b 10                	mov    (%eax),%edx
f0100aa0:	83 c2 08             	add    $0x8,%edx
f0100aa3:	89 10                	mov    %edx,(%eax)
f0100aa5:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100aa8:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100aab:	eb 24                	jmp    f0100ad1 <getuint+0x3b>
	else if (lflag)
f0100aad:	85 d2                	test   %edx,%edx
f0100aaf:	74 11                	je     f0100ac2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100ab1:	8b 10                	mov    (%eax),%edx
f0100ab3:	83 c2 04             	add    $0x4,%edx
f0100ab6:	89 10                	mov    %edx,(%eax)
f0100ab8:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100abb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ac0:	eb 0f                	jmp    f0100ad1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100ac2:	8b 10                	mov    (%eax),%edx
f0100ac4:	83 c2 04             	add    $0x4,%edx
f0100ac7:	89 10                	mov    %edx,(%eax)
f0100ac9:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100acc:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ad1:	5d                   	pop    %ebp
f0100ad2:	c3                   	ret    

f0100ad3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ad3:	55                   	push   %ebp
f0100ad4:	89 e5                	mov    %esp,%ebp
f0100ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ad9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100add:	8b 10                	mov    (%eax),%edx
f0100adf:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ae2:	73 0a                	jae    f0100aee <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ae4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ae7:	88 0a                	mov    %cl,(%edx)
f0100ae9:	83 c2 01             	add    $0x1,%edx
f0100aec:	89 10                	mov    %edx,(%eax)
}
f0100aee:	5d                   	pop    %ebp
f0100aef:	c3                   	ret    

f0100af0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100af0:	55                   	push   %ebp
f0100af1:	89 e5                	mov    %esp,%ebp
f0100af3:	57                   	push   %edi
f0100af4:	56                   	push   %esi
f0100af5:	53                   	push   %ebx
f0100af6:	83 ec 5c             	sub    $0x5c,%esp
f0100af9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100afc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100b02:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100b09:	eb 11                	jmp    f0100b1c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100b0b:	85 c0                	test   %eax,%eax
f0100b0d:	0f 84 f4 03 00 00    	je     f0100f07 <vprintfmt+0x417>
				return;
			putch(ch, putdat);
f0100b13:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b17:	89 04 24             	mov    %eax,(%esp)
f0100b1a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b1c:	0f b6 03             	movzbl (%ebx),%eax
f0100b1f:	83 c3 01             	add    $0x1,%ebx
f0100b22:	83 f8 25             	cmp    $0x25,%eax
f0100b25:	75 e4                	jne    f0100b0b <vprintfmt+0x1b>
f0100b27:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100b2b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100b32:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100b39:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100b40:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b45:	eb 06                	jmp    f0100b4d <vprintfmt+0x5d>
f0100b47:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100b4b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b4d:	0f b6 13             	movzbl (%ebx),%edx
f0100b50:	0f b6 c2             	movzbl %dl,%eax
f0100b53:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100b56:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b59:	83 ea 23             	sub    $0x23,%edx
f0100b5c:	80 fa 55             	cmp    $0x55,%dl
f0100b5f:	0f 87 85 03 00 00    	ja     f0100eea <vprintfmt+0x3fa>
f0100b65:	0f b6 d2             	movzbl %dl,%edx
f0100b68:	ff 24 95 14 1c 10 f0 	jmp    *-0xfefe3ec(,%edx,4)
f0100b6f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100b73:	eb d6                	jmp    f0100b4b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100b75:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b78:	83 ea 30             	sub    $0x30,%edx
f0100b7b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0100b7e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b81:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b84:	83 fb 09             	cmp    $0x9,%ebx
f0100b87:	77 4d                	ja     f0100bd6 <vprintfmt+0xe6>
f0100b89:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b8c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100b8f:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100b92:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100b95:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100b99:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100b9c:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100b9f:	83 fb 09             	cmp    $0x9,%ebx
f0100ba2:	76 eb                	jbe    f0100b8f <vprintfmt+0x9f>
f0100ba4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100ba7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100baa:	eb 2a                	jmp    f0100bd6 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100bac:	8b 55 14             	mov    0x14(%ebp),%edx
f0100baf:	83 c2 04             	add    $0x4,%edx
f0100bb2:	89 55 14             	mov    %edx,0x14(%ebp)
f0100bb5:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100bb8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0100bbb:	eb 19                	jmp    f0100bd6 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f0100bbd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bc0:	c1 fa 1f             	sar    $0x1f,%edx
f0100bc3:	f7 d2                	not    %edx
f0100bc5:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0100bc8:	eb 81                	jmp    f0100b4b <vprintfmt+0x5b>
f0100bca:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100bd1:	e9 75 ff ff ff       	jmp    f0100b4b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100bd6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100bda:	0f 89 6b ff ff ff    	jns    f0100b4b <vprintfmt+0x5b>
f0100be0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100be3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100be6:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100be9:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bec:	e9 5a ff ff ff       	jmp    f0100b4b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100bf1:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100bf4:	e9 52 ff ff ff       	jmp    f0100b4b <vprintfmt+0x5b>
f0100bf9:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100bfc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bff:	83 c0 04             	add    $0x4,%eax
f0100c02:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c05:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c09:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c0c:	89 04 24             	mov    %eax,(%esp)
f0100c0f:	ff d7                	call   *%edi
f0100c11:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100c14:	e9 03 ff ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
f0100c19:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c1c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c1f:	83 c0 04             	add    $0x4,%eax
f0100c22:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c25:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c28:	89 c2                	mov    %eax,%edx
f0100c2a:	c1 fa 1f             	sar    $0x1f,%edx
f0100c2d:	31 d0                	xor    %edx,%eax
f0100c2f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c31:	83 f8 06             	cmp    $0x6,%eax
f0100c34:	7f 0b                	jg     f0100c41 <vprintfmt+0x151>
f0100c36:	8b 14 85 6c 1d 10 f0 	mov    -0xfefe294(,%eax,4),%edx
f0100c3d:	85 d2                	test   %edx,%edx
f0100c3f:	75 20                	jne    f0100c61 <vprintfmt+0x171>
				printfmt(putch, putdat, "error %d", err);
f0100c41:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c45:	c7 44 24 08 95 1b 10 	movl   $0xf0101b95,0x8(%esp)
f0100c4c:	f0 
f0100c4d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c51:	89 3c 24             	mov    %edi,(%esp)
f0100c54:	e8 36 03 00 00       	call   f0100f8f <printfmt>
f0100c59:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c5c:	e9 bb fe ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100c61:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c65:	c7 44 24 08 9e 1b 10 	movl   $0xf0101b9e,0x8(%esp)
f0100c6c:	f0 
f0100c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c71:	89 3c 24             	mov    %edi,(%esp)
f0100c74:	e8 16 03 00 00       	call   f0100f8f <printfmt>
f0100c79:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100c7c:	e9 9b fe ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
f0100c81:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c84:	89 c3                	mov    %eax,%ebx
f0100c86:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c89:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100c8c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100c8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c92:	83 c0 04             	add    $0x4,%eax
f0100c95:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c98:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c9e:	85 c0                	test   %eax,%eax
f0100ca0:	75 07                	jne    f0100ca9 <vprintfmt+0x1b9>
f0100ca2:	c7 45 e0 a1 1b 10 f0 	movl   $0xf0101ba1,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100ca9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0100cad:	7e 06                	jle    f0100cb5 <vprintfmt+0x1c5>
f0100caf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100cb3:	75 13                	jne    f0100cc8 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100cb5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100cb8:	0f be 02             	movsbl (%edx),%eax
f0100cbb:	85 c0                	test   %eax,%eax
f0100cbd:	0f 85 99 00 00 00    	jne    f0100d5c <vprintfmt+0x26c>
f0100cc3:	e9 86 00 00 00       	jmp    f0100d4e <vprintfmt+0x25e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ccc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ccf:	89 0c 24             	mov    %ecx,(%esp)
f0100cd2:	e8 d4 03 00 00       	call   f01010ab <strnlen>
f0100cd7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100cda:	29 c2                	sub    %eax,%edx
f0100cdc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100cdf:	85 d2                	test   %edx,%edx
f0100ce1:	7e d2                	jle    f0100cb5 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100ce3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0100ce7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100cea:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100ced:	89 d3                	mov    %edx,%ebx
f0100cef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cf3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cf6:	89 04 24             	mov    %eax,(%esp)
f0100cf9:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100cfb:	83 eb 01             	sub    $0x1,%ebx
f0100cfe:	85 db                	test   %ebx,%ebx
f0100d00:	7f ed                	jg     f0100cef <vprintfmt+0x1ff>
f0100d02:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d05:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d0c:	eb a7                	jmp    f0100cb5 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d0e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100d12:	74 18                	je     f0100d2c <vprintfmt+0x23c>
f0100d14:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d17:	83 fa 5e             	cmp    $0x5e,%edx
f0100d1a:	76 10                	jbe    f0100d2c <vprintfmt+0x23c>
					putch('?', putdat);
f0100d1c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d20:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d27:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d2a:	eb 0a                	jmp    f0100d36 <vprintfmt+0x246>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d30:	89 04 24             	mov    %eax,(%esp)
f0100d33:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d36:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100d3a:	0f be 03             	movsbl (%ebx),%eax
f0100d3d:	85 c0                	test   %eax,%eax
f0100d3f:	74 05                	je     f0100d46 <vprintfmt+0x256>
f0100d41:	83 c3 01             	add    $0x1,%ebx
f0100d44:	eb 29                	jmp    f0100d6f <vprintfmt+0x27f>
f0100d46:	89 fe                	mov    %edi,%esi
f0100d48:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d4b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d52:	7f 2e                	jg     f0100d82 <vprintfmt+0x292>
f0100d54:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100d57:	e9 c0 fd ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d5c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d5f:	83 c2 01             	add    $0x1,%edx
f0100d62:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100d65:	89 f7                	mov    %esi,%edi
f0100d67:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100d6a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d6d:	89 d3                	mov    %edx,%ebx
f0100d6f:	85 f6                	test   %esi,%esi
f0100d71:	78 9b                	js     f0100d0e <vprintfmt+0x21e>
f0100d73:	83 ee 01             	sub    $0x1,%esi
f0100d76:	79 96                	jns    f0100d0e <vprintfmt+0x21e>
f0100d78:	89 fe                	mov    %edi,%esi
f0100d7a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d7d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d80:	eb cc                	jmp    f0100d4e <vprintfmt+0x25e>
f0100d82:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100d85:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100d88:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d8c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100d93:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d95:	83 eb 01             	sub    $0x1,%ebx
f0100d98:	85 db                	test   %ebx,%ebx
f0100d9a:	7f ec                	jg     f0100d88 <vprintfmt+0x298>
f0100d9c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100d9f:	e9 78 fd ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
f0100da4:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100da7:	83 f9 01             	cmp    $0x1,%ecx
f0100daa:	7e 17                	jle    f0100dc3 <vprintfmt+0x2d3>
		return va_arg(*ap, long long);
f0100dac:	8b 45 14             	mov    0x14(%ebp),%eax
f0100daf:	83 c0 08             	add    $0x8,%eax
f0100db2:	89 45 14             	mov    %eax,0x14(%ebp)
f0100db5:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100db8:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100dbb:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100dbe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dc1:	eb 34                	jmp    f0100df7 <vprintfmt+0x307>
	else if (lflag)
f0100dc3:	85 c9                	test   %ecx,%ecx
f0100dc5:	74 19                	je     f0100de0 <vprintfmt+0x2f0>
		return va_arg(*ap, long);
f0100dc7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dca:	83 c0 04             	add    $0x4,%eax
f0100dcd:	89 45 14             	mov    %eax,0x14(%ebp)
f0100dd0:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dd3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100dd6:	89 c1                	mov    %eax,%ecx
f0100dd8:	c1 f9 1f             	sar    $0x1f,%ecx
f0100ddb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dde:	eb 17                	jmp    f0100df7 <vprintfmt+0x307>
	else
		return va_arg(*ap, int);
f0100de0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100de3:	83 c0 04             	add    $0x4,%eax
f0100de6:	89 45 14             	mov    %eax,0x14(%ebp)
f0100de9:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100dec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100def:	89 c2                	mov    %eax,%edx
f0100df1:	c1 fa 1f             	sar    $0x1f,%edx
f0100df4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100df7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100dfa:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100dfd:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100e02:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e06:	0f 89 9c 00 00 00    	jns    f0100ea8 <vprintfmt+0x3b8>
				putch('-', putdat);
f0100e0c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e10:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e17:	ff d7                	call   *%edi
				num = -(long long) num;
f0100e19:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e1c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e1f:	f7 d9                	neg    %ecx
f0100e21:	83 d3 00             	adc    $0x0,%ebx
f0100e24:	f7 db                	neg    %ebx
f0100e26:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e2b:	eb 7b                	jmp    f0100ea8 <vprintfmt+0x3b8>
f0100e2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e30:	89 ca                	mov    %ecx,%edx
f0100e32:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e35:	e8 5c fc ff ff       	call   f0100a96 <getuint>
f0100e3a:	89 c1                	mov    %eax,%ecx
f0100e3c:	89 d3                	mov    %edx,%ebx
f0100e3e:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e43:	eb 63                	jmp    f0100ea8 <vprintfmt+0x3b8>
f0100e45:	89 45 cc             	mov    %eax,-0x34(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
                        num = getuint(&ap, lflag);
f0100e48:	89 ca                	mov    %ecx,%edx
f0100e4a:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e4d:	e8 44 fc ff ff       	call   f0100a96 <getuint>
f0100e52:	89 c1                	mov    %eax,%ecx
f0100e54:	89 d3                	mov    %edx,%ebx
f0100e56:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
                        goto number;
f0100e5b:	eb 4b                	jmp    f0100ea8 <vprintfmt+0x3b8>
f0100e5d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0100e60:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e64:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e6b:	ff d7                	call   *%edi
			putch('x', putdat);
f0100e6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e71:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100e78:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100e7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7d:	83 c0 04             	add    $0x4,%eax
f0100e80:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100e83:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100e86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e8b:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100e90:	eb 16                	jmp    f0100ea8 <vprintfmt+0x3b8>
f0100e92:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100e95:	89 ca                	mov    %ecx,%edx
f0100e97:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e9a:	e8 f7 fb ff ff       	call   f0100a96 <getuint>
f0100e9f:	89 c1                	mov    %eax,%ecx
f0100ea1:	89 d3                	mov    %edx,%ebx
f0100ea3:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100ea8:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0100eac:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100eb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100eb7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ebb:	89 0c 24             	mov    %ecx,(%esp)
f0100ebe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ec2:	89 f2                	mov    %esi,%edx
f0100ec4:	89 f8                	mov    %edi,%eax
f0100ec6:	e8 d5 fa ff ff       	call   f01009a0 <printnum>
f0100ecb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100ece:	e9 49 fc ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
f0100ed3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ed6:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100ed9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100edd:	89 14 24             	mov    %edx,(%esp)
f0100ee0:	ff d7                	call   *%edi
f0100ee2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100ee5:	e9 32 fc ff ff       	jmp    f0100b1c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100eea:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100ef5:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100ef7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100efa:	80 38 25             	cmpb   $0x25,(%eax)
f0100efd:	0f 84 19 fc ff ff    	je     f0100b1c <vprintfmt+0x2c>
f0100f03:	89 c3                	mov    %eax,%ebx
f0100f05:	eb f0                	jmp    f0100ef7 <vprintfmt+0x407>
				/* do nothing */;
			break;
		}
	}
}
f0100f07:	83 c4 5c             	add    $0x5c,%esp
f0100f0a:	5b                   	pop    %ebx
f0100f0b:	5e                   	pop    %esi
f0100f0c:	5f                   	pop    %edi
f0100f0d:	5d                   	pop    %ebp
f0100f0e:	c3                   	ret    

f0100f0f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f0f:	55                   	push   %ebp
f0100f10:	89 e5                	mov    %esp,%ebp
f0100f12:	83 ec 28             	sub    $0x28,%esp
f0100f15:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f18:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f1b:	85 c0                	test   %eax,%eax
f0100f1d:	74 04                	je     f0100f23 <vsnprintf+0x14>
f0100f1f:	85 d2                	test   %edx,%edx
f0100f21:	7f 07                	jg     f0100f2a <vsnprintf+0x1b>
f0100f23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f28:	eb 3b                	jmp    f0100f65 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f2d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f3b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f42:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f49:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f50:	c7 04 24 d3 0a 10 f0 	movl   $0xf0100ad3,(%esp)
f0100f57:	e8 94 fb ff ff       	call   f0100af0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f5f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100f65:	c9                   	leave  
f0100f66:	c3                   	ret    

f0100f67 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f67:	55                   	push   %ebp
f0100f68:	89 e5                	mov    %esp,%ebp
f0100f6a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100f6d:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f70:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f74:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f77:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f82:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f85:	89 04 24             	mov    %eax,(%esp)
f0100f88:	e8 82 ff ff ff       	call   f0100f0f <vsnprintf>
	va_end(ap);

	return rc;
}
f0100f8d:	c9                   	leave  
f0100f8e:	c3                   	ret    

f0100f8f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100f8f:	55                   	push   %ebp
f0100f90:	89 e5                	mov    %esp,%ebp
f0100f92:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100f95:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f98:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f9c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f9f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100faa:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fad:	89 04 24             	mov    %eax,(%esp)
f0100fb0:	e8 3b fb ff ff       	call   f0100af0 <vprintfmt>
	va_end(ap);
}
f0100fb5:	c9                   	leave  
f0100fb6:	c3                   	ret    
	...

f0100fc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100fc0:	55                   	push   %ebp
f0100fc1:	89 e5                	mov    %esp,%ebp
f0100fc3:	57                   	push   %edi
f0100fc4:	56                   	push   %esi
f0100fc5:	53                   	push   %ebx
f0100fc6:	83 ec 1c             	sub    $0x1c,%esp
f0100fc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100fcc:	85 c0                	test   %eax,%eax
f0100fce:	74 10                	je     f0100fe0 <readline+0x20>
		cprintf("%s", prompt);
f0100fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fd4:	c7 04 24 9e 1b 10 f0 	movl   $0xf0101b9e,(%esp)
f0100fdb:	e8 8b f9 ff ff       	call   f010096b <cprintf>

	i = 0;
	echoing = iscons(0);
f0100fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100fe7:	e8 bb f3 ff ff       	call   f01003a7 <iscons>
f0100fec:	89 c7                	mov    %eax,%edi
f0100fee:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0100ff3:	e8 9e f3 ff ff       	call   f0100396 <getchar>
f0100ff8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0100ffa:	85 c0                	test   %eax,%eax
f0100ffc:	79 17                	jns    f0101015 <readline+0x55>
			cprintf("read error: %e\n", c);
f0100ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101002:	c7 04 24 88 1d 10 f0 	movl   $0xf0101d88,(%esp)
f0101009:	e8 5d f9 ff ff       	call   f010096b <cprintf>
f010100e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101013:	eb 65                	jmp    f010107a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101015:	83 f8 1f             	cmp    $0x1f,%eax
f0101018:	7e 1f                	jle    f0101039 <readline+0x79>
f010101a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101020:	7f 17                	jg     f0101039 <readline+0x79>
			if (echoing)
f0101022:	85 ff                	test   %edi,%edi
f0101024:	74 08                	je     f010102e <readline+0x6e>
				cputchar(c);
f0101026:	89 04 24             	mov    %eax,(%esp)
f0101029:	e8 92 f6 ff ff       	call   f01006c0 <cputchar>
			buf[i++] = c;
f010102e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101034:	83 c6 01             	add    $0x1,%esi
f0101037:	eb ba                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101039:	83 fb 08             	cmp    $0x8,%ebx
f010103c:	75 15                	jne    f0101053 <readline+0x93>
f010103e:	85 f6                	test   %esi,%esi
f0101040:	7e 11                	jle    f0101053 <readline+0x93>
			if (echoing)
f0101042:	85 ff                	test   %edi,%edi
f0101044:	74 08                	je     f010104e <readline+0x8e>
				cputchar(c);
f0101046:	89 1c 24             	mov    %ebx,(%esp)
f0101049:	e8 72 f6 ff ff       	call   f01006c0 <cputchar>
			i--;
f010104e:	83 ee 01             	sub    $0x1,%esi
f0101051:	eb a0                	jmp    f0100ff3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101053:	83 fb 0a             	cmp    $0xa,%ebx
f0101056:	74 0a                	je     f0101062 <readline+0xa2>
f0101058:	83 fb 0d             	cmp    $0xd,%ebx
f010105b:	90                   	nop
f010105c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101060:	75 91                	jne    f0100ff3 <readline+0x33>
			if (echoing)
f0101062:	85 ff                	test   %edi,%edi
f0101064:	74 08                	je     f010106e <readline+0xae>
				cputchar(c);
f0101066:	89 1c 24             	mov    %ebx,(%esp)
f0101069:	e8 52 f6 ff ff       	call   f01006c0 <cputchar>
			buf[i] = 0;
f010106e:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f0101075:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f010107a:	83 c4 1c             	add    $0x1c,%esp
f010107d:	5b                   	pop    %ebx
f010107e:	5e                   	pop    %esi
f010107f:	5f                   	pop    %edi
f0101080:	5d                   	pop    %ebp
f0101081:	c3                   	ret    
	...

f0101090 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101096:	b8 00 00 00 00       	mov    $0x0,%eax
f010109b:	80 3a 00             	cmpb   $0x0,(%edx)
f010109e:	74 09                	je     f01010a9 <strlen+0x19>
		n++;
f01010a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010a7:	75 f7                	jne    f01010a0 <strlen+0x10>
		n++;
	return n;
}
f01010a9:	5d                   	pop    %ebp
f01010aa:	c3                   	ret    

f01010ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010ab:	55                   	push   %ebp
f01010ac:	89 e5                	mov    %esp,%ebp
f01010ae:	53                   	push   %ebx
f01010af:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010b5:	85 c9                	test   %ecx,%ecx
f01010b7:	74 19                	je     f01010d2 <strnlen+0x27>
f01010b9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010bc:	74 14                	je     f01010d2 <strnlen+0x27>
f01010be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01010c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010c6:	39 c8                	cmp    %ecx,%eax
f01010c8:	74 0d                	je     f01010d7 <strnlen+0x2c>
f01010ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01010ce:	75 f3                	jne    f01010c3 <strnlen+0x18>
f01010d0:	eb 05                	jmp    f01010d7 <strnlen+0x2c>
f01010d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01010d7:	5b                   	pop    %ebx
f01010d8:	5d                   	pop    %ebp
f01010d9:	c3                   	ret    

f01010da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01010da:	55                   	push   %ebp
f01010db:	89 e5                	mov    %esp,%ebp
f01010dd:	53                   	push   %ebx
f01010de:	8b 45 08             	mov    0x8(%ebp),%eax
f01010e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01010e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01010ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01010f0:	83 c2 01             	add    $0x1,%edx
f01010f3:	84 c9                	test   %cl,%cl
f01010f5:	75 f2                	jne    f01010e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01010f7:	5b                   	pop    %ebx
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    

f01010fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	56                   	push   %esi
f01010fe:	53                   	push   %ebx
f01010ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101102:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101105:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101108:	85 f6                	test   %esi,%esi
f010110a:	74 18                	je     f0101124 <strncpy+0x2a>
f010110c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101111:	0f b6 1a             	movzbl (%edx),%ebx
f0101114:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101117:	80 3a 01             	cmpb   $0x1,(%edx)
f010111a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010111d:	83 c1 01             	add    $0x1,%ecx
f0101120:	39 ce                	cmp    %ecx,%esi
f0101122:	77 ed                	ja     f0101111 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101124:	5b                   	pop    %ebx
f0101125:	5e                   	pop    %esi
f0101126:	5d                   	pop    %ebp
f0101127:	c3                   	ret    

f0101128 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101128:	55                   	push   %ebp
f0101129:	89 e5                	mov    %esp,%ebp
f010112b:	56                   	push   %esi
f010112c:	53                   	push   %ebx
f010112d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101130:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101133:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101136:	89 f0                	mov    %esi,%eax
f0101138:	85 c9                	test   %ecx,%ecx
f010113a:	74 27                	je     f0101163 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010113c:	83 e9 01             	sub    $0x1,%ecx
f010113f:	74 1d                	je     f010115e <strlcpy+0x36>
f0101141:	0f b6 1a             	movzbl (%edx),%ebx
f0101144:	84 db                	test   %bl,%bl
f0101146:	74 16                	je     f010115e <strlcpy+0x36>
			*dst++ = *src++;
f0101148:	88 18                	mov    %bl,(%eax)
f010114a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010114d:	83 e9 01             	sub    $0x1,%ecx
f0101150:	74 0e                	je     f0101160 <strlcpy+0x38>
			*dst++ = *src++;
f0101152:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101155:	0f b6 1a             	movzbl (%edx),%ebx
f0101158:	84 db                	test   %bl,%bl
f010115a:	75 ec                	jne    f0101148 <strlcpy+0x20>
f010115c:	eb 02                	jmp    f0101160 <strlcpy+0x38>
f010115e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101160:	c6 00 00             	movb   $0x0,(%eax)
f0101163:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101165:	5b                   	pop    %ebx
f0101166:	5e                   	pop    %esi
f0101167:	5d                   	pop    %ebp
f0101168:	c3                   	ret    

f0101169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010116f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101172:	0f b6 01             	movzbl (%ecx),%eax
f0101175:	84 c0                	test   %al,%al
f0101177:	74 15                	je     f010118e <strcmp+0x25>
f0101179:	3a 02                	cmp    (%edx),%al
f010117b:	75 11                	jne    f010118e <strcmp+0x25>
		p++, q++;
f010117d:	83 c1 01             	add    $0x1,%ecx
f0101180:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101183:	0f b6 01             	movzbl (%ecx),%eax
f0101186:	84 c0                	test   %al,%al
f0101188:	74 04                	je     f010118e <strcmp+0x25>
f010118a:	3a 02                	cmp    (%edx),%al
f010118c:	74 ef                	je     f010117d <strcmp+0x14>
f010118e:	0f b6 c0             	movzbl %al,%eax
f0101191:	0f b6 12             	movzbl (%edx),%edx
f0101194:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101196:	5d                   	pop    %ebp
f0101197:	c3                   	ret    

f0101198 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101198:	55                   	push   %ebp
f0101199:	89 e5                	mov    %esp,%ebp
f010119b:	53                   	push   %ebx
f010119c:	8b 55 08             	mov    0x8(%ebp),%edx
f010119f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011a2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	74 23                	je     f01011cc <strncmp+0x34>
f01011a9:	0f b6 1a             	movzbl (%edx),%ebx
f01011ac:	84 db                	test   %bl,%bl
f01011ae:	74 24                	je     f01011d4 <strncmp+0x3c>
f01011b0:	3a 19                	cmp    (%ecx),%bl
f01011b2:	75 20                	jne    f01011d4 <strncmp+0x3c>
f01011b4:	83 e8 01             	sub    $0x1,%eax
f01011b7:	74 13                	je     f01011cc <strncmp+0x34>
		n--, p++, q++;
f01011b9:	83 c2 01             	add    $0x1,%edx
f01011bc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011bf:	0f b6 1a             	movzbl (%edx),%ebx
f01011c2:	84 db                	test   %bl,%bl
f01011c4:	74 0e                	je     f01011d4 <strncmp+0x3c>
f01011c6:	3a 19                	cmp    (%ecx),%bl
f01011c8:	74 ea                	je     f01011b4 <strncmp+0x1c>
f01011ca:	eb 08                	jmp    f01011d4 <strncmp+0x3c>
f01011cc:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011d1:	5b                   	pop    %ebx
f01011d2:	5d                   	pop    %ebp
f01011d3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01011d4:	0f b6 02             	movzbl (%edx),%eax
f01011d7:	0f b6 11             	movzbl (%ecx),%edx
f01011da:	29 d0                	sub    %edx,%eax
f01011dc:	eb f3                	jmp    f01011d1 <strncmp+0x39>

f01011de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01011de:	55                   	push   %ebp
f01011df:	89 e5                	mov    %esp,%ebp
f01011e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01011e8:	0f b6 10             	movzbl (%eax),%edx
f01011eb:	84 d2                	test   %dl,%dl
f01011ed:	74 15                	je     f0101204 <strchr+0x26>
		if (*s == c)
f01011ef:	38 ca                	cmp    %cl,%dl
f01011f1:	75 07                	jne    f01011fa <strchr+0x1c>
f01011f3:	eb 14                	jmp    f0101209 <strchr+0x2b>
f01011f5:	38 ca                	cmp    %cl,%dl
f01011f7:	90                   	nop
f01011f8:	74 0f                	je     f0101209 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01011fa:	83 c0 01             	add    $0x1,%eax
f01011fd:	0f b6 10             	movzbl (%eax),%edx
f0101200:	84 d2                	test   %dl,%dl
f0101202:	75 f1                	jne    f01011f5 <strchr+0x17>
f0101204:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101209:	5d                   	pop    %ebp
f010120a:	c3                   	ret    

f010120b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010120b:	55                   	push   %ebp
f010120c:	89 e5                	mov    %esp,%ebp
f010120e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101211:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101215:	0f b6 10             	movzbl (%eax),%edx
f0101218:	84 d2                	test   %dl,%dl
f010121a:	74 18                	je     f0101234 <strfind+0x29>
		if (*s == c)
f010121c:	38 ca                	cmp    %cl,%dl
f010121e:	75 0a                	jne    f010122a <strfind+0x1f>
f0101220:	eb 12                	jmp    f0101234 <strfind+0x29>
f0101222:	38 ca                	cmp    %cl,%dl
f0101224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101228:	74 0a                	je     f0101234 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010122a:	83 c0 01             	add    $0x1,%eax
f010122d:	0f b6 10             	movzbl (%eax),%edx
f0101230:	84 d2                	test   %dl,%dl
f0101232:	75 ee                	jne    f0101222 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101234:	5d                   	pop    %ebp
f0101235:	c3                   	ret    

f0101236 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101236:	55                   	push   %ebp
f0101237:	89 e5                	mov    %esp,%ebp
f0101239:	53                   	push   %ebx
f010123a:	8b 45 08             	mov    0x8(%ebp),%eax
f010123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101240:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101243:	89 da                	mov    %ebx,%edx
f0101245:	83 ea 01             	sub    $0x1,%edx
f0101248:	78 0e                	js     f0101258 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010124a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010124c:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010124f:	88 0a                	mov    %cl,(%edx)
f0101251:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101254:	39 da                	cmp    %ebx,%edx
f0101256:	75 f7                	jne    f010124f <memset+0x19>
		*p++ = c;

	return v;
}
f0101258:	5b                   	pop    %ebx
f0101259:	5d                   	pop    %ebp
f010125a:	c3                   	ret    

f010125b <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	56                   	push   %esi
f010125f:	53                   	push   %ebx
f0101260:	8b 45 08             	mov    0x8(%ebp),%eax
f0101263:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101266:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101269:	85 db                	test   %ebx,%ebx
f010126b:	74 13                	je     f0101280 <memcpy+0x25>
f010126d:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0101272:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101276:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101279:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f010127c:	39 da                	cmp    %ebx,%edx
f010127e:	75 f2                	jne    f0101272 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f0101280:	5b                   	pop    %ebx
f0101281:	5e                   	pop    %esi
f0101282:	5d                   	pop    %ebp
f0101283:	c3                   	ret    

f0101284 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	57                   	push   %edi
f0101288:	56                   	push   %esi
f0101289:	53                   	push   %ebx
f010128a:	8b 45 08             	mov    0x8(%ebp),%eax
f010128d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101290:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f0101293:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f0101295:	39 c6                	cmp    %eax,%esi
f0101297:	72 0b                	jb     f01012a4 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f0101299:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f010129e:	85 db                	test   %ebx,%ebx
f01012a0:	75 2d                	jne    f01012cf <memmove+0x4b>
f01012a2:	eb 39                	jmp    f01012dd <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012a4:	01 df                	add    %ebx,%edi
f01012a6:	39 f8                	cmp    %edi,%eax
f01012a8:	73 ef                	jae    f0101299 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f01012aa:	85 db                	test   %ebx,%ebx
f01012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012b0:	74 2b                	je     f01012dd <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012b2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f01012b5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f01012ba:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f01012bf:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f01012c3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01012c6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01012c9:	85 c9                	test   %ecx,%ecx
f01012cb:	75 ed                	jne    f01012ba <memmove+0x36>
f01012cd:	eb 0e                	jmp    f01012dd <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012cf:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012d3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012d6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01012d9:	39 d3                	cmp    %edx,%ebx
f01012db:	75 f2                	jne    f01012cf <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f01012dd:	5b                   	pop    %ebx
f01012de:	5e                   	pop    %esi
f01012df:	5f                   	pop    %edi
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	8b 75 08             	mov    0x8(%ebp),%esi
f01012eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01012ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01012f1:	85 c9                	test   %ecx,%ecx
f01012f3:	74 36                	je     f010132b <memcmp+0x49>
		if (*s1 != *s2)
f01012f5:	0f b6 06             	movzbl (%esi),%eax
f01012f8:	0f b6 1f             	movzbl (%edi),%ebx
f01012fb:	38 d8                	cmp    %bl,%al
f01012fd:	74 20                	je     f010131f <memcmp+0x3d>
f01012ff:	eb 14                	jmp    f0101315 <memcmp+0x33>
f0101301:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101306:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010130b:	83 c2 01             	add    $0x1,%edx
f010130e:	83 e9 01             	sub    $0x1,%ecx
f0101311:	38 d8                	cmp    %bl,%al
f0101313:	74 12                	je     f0101327 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101315:	0f b6 c0             	movzbl %al,%eax
f0101318:	0f b6 db             	movzbl %bl,%ebx
f010131b:	29 d8                	sub    %ebx,%eax
f010131d:	eb 11                	jmp    f0101330 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010131f:	83 e9 01             	sub    $0x1,%ecx
f0101322:	ba 00 00 00 00       	mov    $0x0,%edx
f0101327:	85 c9                	test   %ecx,%ecx
f0101329:	75 d6                	jne    f0101301 <memcmp+0x1f>
f010132b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101330:	5b                   	pop    %ebx
f0101331:	5e                   	pop    %esi
f0101332:	5f                   	pop    %edi
f0101333:	5d                   	pop    %ebp
f0101334:	c3                   	ret    

f0101335 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101335:	55                   	push   %ebp
f0101336:	89 e5                	mov    %esp,%ebp
f0101338:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010133b:	89 c2                	mov    %eax,%edx
f010133d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101340:	39 d0                	cmp    %edx,%eax
f0101342:	73 15                	jae    f0101359 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101344:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101348:	38 08                	cmp    %cl,(%eax)
f010134a:	75 06                	jne    f0101352 <memfind+0x1d>
f010134c:	eb 0b                	jmp    f0101359 <memfind+0x24>
f010134e:	38 08                	cmp    %cl,(%eax)
f0101350:	74 07                	je     f0101359 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101352:	83 c0 01             	add    $0x1,%eax
f0101355:	39 c2                	cmp    %eax,%edx
f0101357:	77 f5                	ja     f010134e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101359:	5d                   	pop    %ebp
f010135a:	c3                   	ret    

f010135b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010135b:	55                   	push   %ebp
f010135c:	89 e5                	mov    %esp,%ebp
f010135e:	57                   	push   %edi
f010135f:	56                   	push   %esi
f0101360:	53                   	push   %ebx
f0101361:	83 ec 04             	sub    $0x4,%esp
f0101364:	8b 55 08             	mov    0x8(%ebp),%edx
f0101367:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010136a:	0f b6 02             	movzbl (%edx),%eax
f010136d:	3c 20                	cmp    $0x20,%al
f010136f:	74 04                	je     f0101375 <strtol+0x1a>
f0101371:	3c 09                	cmp    $0x9,%al
f0101373:	75 0e                	jne    f0101383 <strtol+0x28>
		s++;
f0101375:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101378:	0f b6 02             	movzbl (%edx),%eax
f010137b:	3c 20                	cmp    $0x20,%al
f010137d:	74 f6                	je     f0101375 <strtol+0x1a>
f010137f:	3c 09                	cmp    $0x9,%al
f0101381:	74 f2                	je     f0101375 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101383:	3c 2b                	cmp    $0x2b,%al
f0101385:	75 0c                	jne    f0101393 <strtol+0x38>
		s++;
f0101387:	83 c2 01             	add    $0x1,%edx
f010138a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101391:	eb 15                	jmp    f01013a8 <strtol+0x4d>
	else if (*s == '-')
f0101393:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010139a:	3c 2d                	cmp    $0x2d,%al
f010139c:	75 0a                	jne    f01013a8 <strtol+0x4d>
		s++, neg = 1;
f010139e:	83 c2 01             	add    $0x1,%edx
f01013a1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013a8:	85 db                	test   %ebx,%ebx
f01013aa:	0f 94 c0             	sete   %al
f01013ad:	74 05                	je     f01013b4 <strtol+0x59>
f01013af:	83 fb 10             	cmp    $0x10,%ebx
f01013b2:	75 18                	jne    f01013cc <strtol+0x71>
f01013b4:	80 3a 30             	cmpb   $0x30,(%edx)
f01013b7:	75 13                	jne    f01013cc <strtol+0x71>
f01013b9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013bd:	8d 76 00             	lea    0x0(%esi),%esi
f01013c0:	75 0a                	jne    f01013cc <strtol+0x71>
		s += 2, base = 16;
f01013c2:	83 c2 02             	add    $0x2,%edx
f01013c5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013ca:	eb 15                	jmp    f01013e1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013cc:	84 c0                	test   %al,%al
f01013ce:	66 90                	xchg   %ax,%ax
f01013d0:	74 0f                	je     f01013e1 <strtol+0x86>
f01013d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01013d7:	80 3a 30             	cmpb   $0x30,(%edx)
f01013da:	75 05                	jne    f01013e1 <strtol+0x86>
		s++, base = 8;
f01013dc:	83 c2 01             	add    $0x1,%edx
f01013df:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013e6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01013e8:	0f b6 0a             	movzbl (%edx),%ecx
f01013eb:	89 cf                	mov    %ecx,%edi
f01013ed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01013f0:	80 fb 09             	cmp    $0x9,%bl
f01013f3:	77 08                	ja     f01013fd <strtol+0xa2>
			dig = *s - '0';
f01013f5:	0f be c9             	movsbl %cl,%ecx
f01013f8:	83 e9 30             	sub    $0x30,%ecx
f01013fb:	eb 1e                	jmp    f010141b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f01013fd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101400:	80 fb 19             	cmp    $0x19,%bl
f0101403:	77 08                	ja     f010140d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101405:	0f be c9             	movsbl %cl,%ecx
f0101408:	83 e9 57             	sub    $0x57,%ecx
f010140b:	eb 0e                	jmp    f010141b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010140d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101410:	80 fb 19             	cmp    $0x19,%bl
f0101413:	77 15                	ja     f010142a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101415:	0f be c9             	movsbl %cl,%ecx
f0101418:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010141b:	39 f1                	cmp    %esi,%ecx
f010141d:	7d 0b                	jge    f010142a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010141f:	83 c2 01             	add    $0x1,%edx
f0101422:	0f af c6             	imul   %esi,%eax
f0101425:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101428:	eb be                	jmp    f01013e8 <strtol+0x8d>
f010142a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010142c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101430:	74 05                	je     f0101437 <strtol+0xdc>
		*endptr = (char *) s;
f0101432:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101435:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101437:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010143b:	74 04                	je     f0101441 <strtol+0xe6>
f010143d:	89 c8                	mov    %ecx,%eax
f010143f:	f7 d8                	neg    %eax
}
f0101441:	83 c4 04             	add    $0x4,%esp
f0101444:	5b                   	pop    %ebx
f0101445:	5e                   	pop    %esi
f0101446:	5f                   	pop    %edi
f0101447:	5d                   	pop    %ebp
f0101448:	c3                   	ret    
f0101449:	00 00                	add    %al,(%eax)
f010144b:	00 00                	add    %al,(%eax)
f010144d:	00 00                	add    %al,(%eax)
	...

f0101450 <__udivdi3>:
f0101450:	55                   	push   %ebp
f0101451:	89 e5                	mov    %esp,%ebp
f0101453:	57                   	push   %edi
f0101454:	56                   	push   %esi
f0101455:	83 ec 10             	sub    $0x10,%esp
f0101458:	8b 45 14             	mov    0x14(%ebp),%eax
f010145b:	8b 55 08             	mov    0x8(%ebp),%edx
f010145e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101461:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101464:	85 c0                	test   %eax,%eax
f0101466:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101469:	75 35                	jne    f01014a0 <__udivdi3+0x50>
f010146b:	39 fe                	cmp    %edi,%esi
f010146d:	77 61                	ja     f01014d0 <__udivdi3+0x80>
f010146f:	85 f6                	test   %esi,%esi
f0101471:	75 0b                	jne    f010147e <__udivdi3+0x2e>
f0101473:	b8 01 00 00 00       	mov    $0x1,%eax
f0101478:	31 d2                	xor    %edx,%edx
f010147a:	f7 f6                	div    %esi
f010147c:	89 c6                	mov    %eax,%esi
f010147e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101481:	31 d2                	xor    %edx,%edx
f0101483:	89 f8                	mov    %edi,%eax
f0101485:	f7 f6                	div    %esi
f0101487:	89 c7                	mov    %eax,%edi
f0101489:	89 c8                	mov    %ecx,%eax
f010148b:	f7 f6                	div    %esi
f010148d:	89 c1                	mov    %eax,%ecx
f010148f:	89 fa                	mov    %edi,%edx
f0101491:	89 c8                	mov    %ecx,%eax
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	5e                   	pop    %esi
f0101497:	5f                   	pop    %edi
f0101498:	5d                   	pop    %ebp
f0101499:	c3                   	ret    
f010149a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01014a0:	39 f8                	cmp    %edi,%eax
f01014a2:	77 1c                	ja     f01014c0 <__udivdi3+0x70>
f01014a4:	0f bd d0             	bsr    %eax,%edx
f01014a7:	83 f2 1f             	xor    $0x1f,%edx
f01014aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01014ad:	75 39                	jne    f01014e8 <__udivdi3+0x98>
f01014af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014b2:	0f 86 a0 00 00 00    	jbe    f0101558 <__udivdi3+0x108>
f01014b8:	39 f8                	cmp    %edi,%eax
f01014ba:	0f 82 98 00 00 00    	jb     f0101558 <__udivdi3+0x108>
f01014c0:	31 ff                	xor    %edi,%edi
f01014c2:	31 c9                	xor    %ecx,%ecx
f01014c4:	89 c8                	mov    %ecx,%eax
f01014c6:	89 fa                	mov    %edi,%edx
f01014c8:	83 c4 10             	add    $0x10,%esp
f01014cb:	5e                   	pop    %esi
f01014cc:	5f                   	pop    %edi
f01014cd:	5d                   	pop    %ebp
f01014ce:	c3                   	ret    
f01014cf:	90                   	nop
f01014d0:	89 d1                	mov    %edx,%ecx
f01014d2:	89 fa                	mov    %edi,%edx
f01014d4:	89 c8                	mov    %ecx,%eax
f01014d6:	31 ff                	xor    %edi,%edi
f01014d8:	f7 f6                	div    %esi
f01014da:	89 c1                	mov    %eax,%ecx
f01014dc:	89 fa                	mov    %edi,%edx
f01014de:	89 c8                	mov    %ecx,%eax
f01014e0:	83 c4 10             	add    $0x10,%esp
f01014e3:	5e                   	pop    %esi
f01014e4:	5f                   	pop    %edi
f01014e5:	5d                   	pop    %ebp
f01014e6:	c3                   	ret    
f01014e7:	90                   	nop
f01014e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01014ec:	89 f2                	mov    %esi,%edx
f01014ee:	d3 e0                	shl    %cl,%eax
f01014f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01014f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01014fb:	89 c1                	mov    %eax,%ecx
f01014fd:	d3 ea                	shr    %cl,%edx
f01014ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101503:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101506:	d3 e6                	shl    %cl,%esi
f0101508:	89 c1                	mov    %eax,%ecx
f010150a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010150d:	89 fe                	mov    %edi,%esi
f010150f:	d3 ee                	shr    %cl,%esi
f0101511:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101515:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101518:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010151b:	d3 e7                	shl    %cl,%edi
f010151d:	89 c1                	mov    %eax,%ecx
f010151f:	d3 ea                	shr    %cl,%edx
f0101521:	09 d7                	or     %edx,%edi
f0101523:	89 f2                	mov    %esi,%edx
f0101525:	89 f8                	mov    %edi,%eax
f0101527:	f7 75 ec             	divl   -0x14(%ebp)
f010152a:	89 d6                	mov    %edx,%esi
f010152c:	89 c7                	mov    %eax,%edi
f010152e:	f7 65 e8             	mull   -0x18(%ebp)
f0101531:	39 d6                	cmp    %edx,%esi
f0101533:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101536:	72 30                	jb     f0101568 <__udivdi3+0x118>
f0101538:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010153b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010153f:	d3 e2                	shl    %cl,%edx
f0101541:	39 c2                	cmp    %eax,%edx
f0101543:	73 05                	jae    f010154a <__udivdi3+0xfa>
f0101545:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101548:	74 1e                	je     f0101568 <__udivdi3+0x118>
f010154a:	89 f9                	mov    %edi,%ecx
f010154c:	31 ff                	xor    %edi,%edi
f010154e:	e9 71 ff ff ff       	jmp    f01014c4 <__udivdi3+0x74>
f0101553:	90                   	nop
f0101554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101558:	31 ff                	xor    %edi,%edi
f010155a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010155f:	e9 60 ff ff ff       	jmp    f01014c4 <__udivdi3+0x74>
f0101564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101568:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010156b:	31 ff                	xor    %edi,%edi
f010156d:	89 c8                	mov    %ecx,%eax
f010156f:	89 fa                	mov    %edi,%edx
f0101571:	83 c4 10             	add    $0x10,%esp
f0101574:	5e                   	pop    %esi
f0101575:	5f                   	pop    %edi
f0101576:	5d                   	pop    %ebp
f0101577:	c3                   	ret    
	...

f0101580 <__umoddi3>:
f0101580:	55                   	push   %ebp
f0101581:	89 e5                	mov    %esp,%ebp
f0101583:	57                   	push   %edi
f0101584:	56                   	push   %esi
f0101585:	83 ec 20             	sub    $0x20,%esp
f0101588:	8b 55 14             	mov    0x14(%ebp),%edx
f010158b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010158e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101591:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101594:	85 d2                	test   %edx,%edx
f0101596:	89 c8                	mov    %ecx,%eax
f0101598:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010159b:	75 13                	jne    f01015b0 <__umoddi3+0x30>
f010159d:	39 f7                	cmp    %esi,%edi
f010159f:	76 3f                	jbe    f01015e0 <__umoddi3+0x60>
f01015a1:	89 f2                	mov    %esi,%edx
f01015a3:	f7 f7                	div    %edi
f01015a5:	89 d0                	mov    %edx,%eax
f01015a7:	31 d2                	xor    %edx,%edx
f01015a9:	83 c4 20             	add    $0x20,%esp
f01015ac:	5e                   	pop    %esi
f01015ad:	5f                   	pop    %edi
f01015ae:	5d                   	pop    %ebp
f01015af:	c3                   	ret    
f01015b0:	39 f2                	cmp    %esi,%edx
f01015b2:	77 4c                	ja     f0101600 <__umoddi3+0x80>
f01015b4:	0f bd ca             	bsr    %edx,%ecx
f01015b7:	83 f1 1f             	xor    $0x1f,%ecx
f01015ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015bd:	75 51                	jne    f0101610 <__umoddi3+0x90>
f01015bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01015c2:	0f 87 e0 00 00 00    	ja     f01016a8 <__umoddi3+0x128>
f01015c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015cb:	29 f8                	sub    %edi,%eax
f01015cd:	19 d6                	sbb    %edx,%esi
f01015cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015d5:	89 f2                	mov    %esi,%edx
f01015d7:	83 c4 20             	add    $0x20,%esp
f01015da:	5e                   	pop    %esi
f01015db:	5f                   	pop    %edi
f01015dc:	5d                   	pop    %ebp
f01015dd:	c3                   	ret    
f01015de:	66 90                	xchg   %ax,%ax
f01015e0:	85 ff                	test   %edi,%edi
f01015e2:	75 0b                	jne    f01015ef <__umoddi3+0x6f>
f01015e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01015e9:	31 d2                	xor    %edx,%edx
f01015eb:	f7 f7                	div    %edi
f01015ed:	89 c7                	mov    %eax,%edi
f01015ef:	89 f0                	mov    %esi,%eax
f01015f1:	31 d2                	xor    %edx,%edx
f01015f3:	f7 f7                	div    %edi
f01015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015f8:	f7 f7                	div    %edi
f01015fa:	eb a9                	jmp    f01015a5 <__umoddi3+0x25>
f01015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101600:	89 c8                	mov    %ecx,%eax
f0101602:	89 f2                	mov    %esi,%edx
f0101604:	83 c4 20             	add    $0x20,%esp
f0101607:	5e                   	pop    %esi
f0101608:	5f                   	pop    %edi
f0101609:	5d                   	pop    %ebp
f010160a:	c3                   	ret    
f010160b:	90                   	nop
f010160c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101610:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101614:	d3 e2                	shl    %cl,%edx
f0101616:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101619:	ba 20 00 00 00       	mov    $0x20,%edx
f010161e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101621:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101624:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101628:	89 fa                	mov    %edi,%edx
f010162a:	d3 ea                	shr    %cl,%edx
f010162c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101630:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101633:	d3 e7                	shl    %cl,%edi
f0101635:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101639:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010163c:	89 f2                	mov    %esi,%edx
f010163e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101641:	89 c7                	mov    %eax,%edi
f0101643:	d3 ea                	shr    %cl,%edx
f0101645:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101649:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010164c:	89 c2                	mov    %eax,%edx
f010164e:	d3 e6                	shl    %cl,%esi
f0101650:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101654:	d3 ea                	shr    %cl,%edx
f0101656:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010165a:	09 d6                	or     %edx,%esi
f010165c:	89 f0                	mov    %esi,%eax
f010165e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101661:	d3 e7                	shl    %cl,%edi
f0101663:	89 f2                	mov    %esi,%edx
f0101665:	f7 75 f4             	divl   -0xc(%ebp)
f0101668:	89 d6                	mov    %edx,%esi
f010166a:	f7 65 e8             	mull   -0x18(%ebp)
f010166d:	39 d6                	cmp    %edx,%esi
f010166f:	72 2b                	jb     f010169c <__umoddi3+0x11c>
f0101671:	39 c7                	cmp    %eax,%edi
f0101673:	72 23                	jb     f0101698 <__umoddi3+0x118>
f0101675:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101679:	29 c7                	sub    %eax,%edi
f010167b:	19 d6                	sbb    %edx,%esi
f010167d:	89 f0                	mov    %esi,%eax
f010167f:	89 f2                	mov    %esi,%edx
f0101681:	d3 ef                	shr    %cl,%edi
f0101683:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101687:	d3 e0                	shl    %cl,%eax
f0101689:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010168d:	09 f8                	or     %edi,%eax
f010168f:	d3 ea                	shr    %cl,%edx
f0101691:	83 c4 20             	add    $0x20,%esp
f0101694:	5e                   	pop    %esi
f0101695:	5f                   	pop    %edi
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    
f0101698:	39 d6                	cmp    %edx,%esi
f010169a:	75 d9                	jne    f0101675 <__umoddi3+0xf5>
f010169c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010169f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01016a2:	eb d1                	jmp    f0101675 <__umoddi3+0xf5>
f01016a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016a8:	39 f2                	cmp    %esi,%edx
f01016aa:	0f 82 18 ff ff ff    	jb     f01015c8 <__umoddi3+0x48>
f01016b0:	e9 1d ff ff ff       	jmp    f01015d2 <__umoddi3+0x52>
