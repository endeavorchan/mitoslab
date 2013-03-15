
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
f0100054:	c7 04 24 e0 16 10 f0 	movl   $0xf01016e0,(%esp)
f010005b:	e8 2b 09 00 00       	call   f010098b <cprintf>
	vcprintf(fmt, ap);
f0100060:	8d 45 14             	lea    0x14(%ebp),%eax
f0100063:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100067:	8b 45 10             	mov    0x10(%ebp),%eax
f010006a:	89 04 24             	mov    %eax,(%esp)
f010006d:	e8 e6 08 00 00       	call   f0100958 <vcprintf>
	cprintf("\n");
f0100072:	c7 04 24 af 17 10 f0 	movl   $0xf01017af,(%esp)
f0100079:	e8 0d 09 00 00       	call   f010098b <cprintf>
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
f01000a5:	c7 04 24 fa 16 10 f0 	movl   $0xf01016fa,(%esp)
f01000ac:	e8 da 08 00 00       	call   f010098b <cprintf>
	vcprintf(fmt, ap);
f01000b1:	8d 45 14             	lea    0x14(%ebp),%eax
f01000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01000bb:	89 04 24             	mov    %eax,(%esp)
f01000be:	e8 95 08 00 00       	call   f0100958 <vcprintf>
	cprintf("\n");
f01000c3:	c7 04 24 af 17 10 f0 	movl   $0xf01017af,(%esp)
f01000ca:	e8 bc 08 00 00       	call   f010098b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d6:	e8 31 07 00 00       	call   f010080c <monitor>
f01000db:	eb f2                	jmp    f01000cf <_panic+0x4f>

f01000dd <i386_init>:
	cprintf("leaving test_backtrace %d\n", x);
}

void
i386_init(void)
{
f01000dd:	55                   	push   %ebp
f01000de:	89 e5                	mov    %esp,%ebp
f01000e0:	83 ec 28             	sub    $0x28,%esp
        int x = -1, y = -3, z = -4;

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
f0100100:	e8 51 11 00 00       	call   f0101256 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 c7 02 00 00       	call   f01003d1 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 12 17 10 f0 	movl   $0xf0101712,(%esp)
f0100119:	e8 6d 08 00 00       	call   f010098b <cprintf>

        

	// Test the stack backtrace function (lab 1 only)
        //test_backtrace(5);
        cprintf("my test\n");
f010011e:	c7 04 24 2d 17 10 f0 	movl   $0xf010172d,(%esp)
f0100125:	e8 61 08 00 00       	call   f010098b <cprintf>
        cprintf("x %d, y %x, z %d\n", x, y, z);
f010012a:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0100131:	ff 
f0100132:	c7 44 24 08 fd ff ff 	movl   $0xfffffffd,0x8(%esp)
f0100139:	ff 
f010013a:	c7 44 24 04 ff ff ff 	movl   $0xffffffff,0x4(%esp)
f0100141:	ff 
f0100142:	c7 04 24 36 17 10 f0 	movl   $0xf0101736,(%esp)
f0100149:	e8 3d 08 00 00       	call   f010098b <cprintf>
        unsigned int i = 0x00646c72; cprintf("H%x Wo%s", 57616, &i);
f010014e:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
f0100155:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100158:	89 44 24 08          	mov    %eax,0x8(%esp)
f010015c:	c7 44 24 04 10 e1 00 	movl   $0xe110,0x4(%esp)
f0100163:	00 
f0100164:	c7 04 24 48 17 10 f0 	movl   $0xf0101748,(%esp)
f010016b:	e8 1b 08 00 00       	call   f010098b <cprintf>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100177:	e8 90 06 00 00       	call   f010080c <monitor>
f010017c:	eb f2                	jmp    f0100170 <i386_init+0x93>

f010017e <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f010017e:	55                   	push   %ebp
f010017f:	89 e5                	mov    %esp,%ebp
f0100181:	53                   	push   %ebx
f0100182:	83 ec 14             	sub    $0x14,%esp
f0100185:	8b 5d 08             	mov    0x8(%ebp),%ebx
        int a = 1;
        char b = 'c';
	cprintf("entering test_backtrace %d\n", x);
f0100188:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010018c:	c7 04 24 51 17 10 f0 	movl   $0xf0101751,(%esp)
f0100193:	e8 f3 07 00 00       	call   f010098b <cprintf>
	if (x > 0)
f0100198:	85 db                	test   %ebx,%ebx
f010019a:	7e 0d                	jle    f01001a9 <test_backtrace+0x2b>
		test_backtrace(x-1);
f010019c:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010019f:	89 04 24             	mov    %eax,(%esp)
f01001a2:	e8 d7 ff ff ff       	call   f010017e <test_backtrace>
f01001a7:	eb 1c                	jmp    f01001c5 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f01001a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01001b0:	00 
f01001b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001b8:	00 
f01001b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001c0:	e8 3b 05 00 00       	call   f0100700 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f01001c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01001c9:	c7 04 24 6d 17 10 f0 	movl   $0xf010176d,(%esp)
f01001d0:	e8 b6 07 00 00       	call   f010098b <cprintf>
}
f01001d5:	83 c4 14             	add    $0x14,%esp
f01001d8:	5b                   	pop    %ebx
f01001d9:	5d                   	pop    %ebp
f01001da:	c3                   	ret    
f01001db:	00 00                	add    %al,(%eax)
f01001dd:	00 00                	add    %al,(%eax)
	...

f01001e0 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e8:	ec                   	in     (%dx),%al
f01001e9:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001f0:	f6 c2 01             	test   $0x1,%dl
f01001f3:	74 09                	je     f01001fe <serial_proc_data+0x1e>
f01001f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001fa:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001fb:	0f b6 c0             	movzbl %al,%eax
}
f01001fe:	5d                   	pop    %ebp
f01001ff:	c3                   	ret    

f0100200 <serial_init>:
		cons_intr(serial_proc_data);
}

void
serial_init(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	53                   	push   %ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100204:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100209:	b8 00 00 00 00       	mov    $0x0,%eax
f010020e:	89 da                	mov    %ebx,%edx
f0100210:	ee                   	out    %al,(%dx)
f0100211:	b2 fb                	mov    $0xfb,%dl
f0100213:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100218:	ee                   	out    %al,(%dx)
f0100219:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010021e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100223:	89 ca                	mov    %ecx,%edx
f0100225:	ee                   	out    %al,(%dx)
f0100226:	b2 f9                	mov    $0xf9,%dl
f0100228:	b8 00 00 00 00       	mov    $0x0,%eax
f010022d:	ee                   	out    %al,(%dx)
f010022e:	b2 fb                	mov    $0xfb,%dl
f0100230:	b8 03 00 00 00       	mov    $0x3,%eax
f0100235:	ee                   	out    %al,(%dx)
f0100236:	b2 fc                	mov    $0xfc,%dl
f0100238:	b8 00 00 00 00       	mov    $0x0,%eax
f010023d:	ee                   	out    %al,(%dx)
f010023e:	b2 f9                	mov    $0xf9,%dl
f0100240:	b8 01 00 00 00       	mov    $0x1,%eax
f0100245:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100246:	b2 fd                	mov    $0xfd,%dl
f0100248:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100249:	3c ff                	cmp    $0xff,%al
f010024b:	0f 95 c0             	setne  %al
f010024e:	0f b6 c0             	movzbl %al,%eax
f0100251:	a3 44 f3 10 f0       	mov    %eax,0xf010f344
f0100256:	89 da                	mov    %ebx,%edx
f0100258:	ec                   	in     (%dx),%al
f0100259:	89 ca                	mov    %ecx,%edx
f010025b:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f010025c:	5b                   	pop    %ebx
f010025d:	5d                   	pop    %ebp
f010025e:	c3                   	ret    

f010025f <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

void
cga_init(void)
{
f010025f:	55                   	push   %ebp
f0100260:	89 e5                	mov    %esp,%ebp
f0100262:	83 ec 0c             	sub    $0xc,%esp
f0100265:	89 1c 24             	mov    %ebx,(%esp)
f0100268:	89 74 24 04          	mov    %esi,0x4(%esp)
f010026c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100270:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100275:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100278:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010027d:	0f b7 00             	movzwl (%eax),%eax
f0100280:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100284:	74 11                	je     f0100297 <cga_init+0x38>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100286:	c7 05 48 f3 10 f0 b4 	movl   $0x3b4,0xf010f348
f010028d:	03 00 00 
f0100290:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100295:	eb 16                	jmp    f01002ad <cga_init+0x4e>
	} else {
		*cp = was;
f0100297:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010029e:	c7 05 48 f3 10 f0 d4 	movl   $0x3d4,0xf010f348
f01002a5:	03 00 00 
f01002a8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f01002ad:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f01002b3:	89 cb                	mov    %ecx,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002b5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01002ba:	89 ca                	mov    %ecx,%edx
f01002bc:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01002bd:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c0:	89 ca                	mov    %ecx,%edx
f01002c2:	ec                   	in     (%dx),%al
f01002c3:	0f b6 f8             	movzbl %al,%edi
f01002c6:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01002ce:	89 da                	mov    %ebx,%edx
f01002d0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d1:	89 ca                	mov    %ecx,%edx
f01002d3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01002d4:	89 35 4c f3 10 f0    	mov    %esi,0xf010f34c
	crt_pos = pos;
f01002da:	0f b6 c8             	movzbl %al,%ecx
f01002dd:	09 cf                	or     %ecx,%edi
f01002df:	66 89 3d 50 f3 10 f0 	mov    %di,0xf010f350
}
f01002e6:	8b 1c 24             	mov    (%esp),%ebx
f01002e9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01002ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01002f1:	89 ec                	mov    %ebp,%esp
f01002f3:	5d                   	pop    %ebp
f01002f4:	c3                   	ret    

f01002f5 <kbd_init>:
	cons_intr(kbd_proc_data);
}

void
kbd_init(void)
{
f01002f5:	55                   	push   %ebp
f01002f6:	89 e5                	mov    %esp,%ebp
}
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	57                   	push   %edi
f01002fe:	56                   	push   %esi
f01002ff:	53                   	push   %ebx
f0100300:	83 ec 0c             	sub    $0xc,%esp
f0100303:	8b 75 08             	mov    0x8(%ebp),%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100306:	bb 64 f5 10 f0       	mov    $0xf010f564,%ebx
f010030b:	bf 60 f3 10 f0       	mov    $0xf010f360,%edi
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100310:	eb 1e                	jmp    f0100330 <cons_intr+0x36>
		if (c == 0)
f0100312:	85 c0                	test   %eax,%eax
f0100314:	74 1a                	je     f0100330 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100316:	8b 13                	mov    (%ebx),%edx
f0100318:	88 04 17             	mov    %al,(%edi,%edx,1)
f010031b:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f010031e:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100323:	0f 94 c2             	sete   %dl
f0100326:	0f b6 d2             	movzbl %dl,%edx
f0100329:	83 ea 01             	sub    $0x1,%edx
f010032c:	21 d0                	and    %edx,%eax
f010032e:	89 03                	mov    %eax,(%ebx)
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100330:	ff d6                	call   *%esi
f0100332:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100335:	75 db                	jne    f0100312 <cons_intr+0x18>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100337:	83 c4 0c             	add    $0xc,%esp
f010033a:	5b                   	pop    %ebx
f010033b:	5e                   	pop    %esi
f010033c:	5f                   	pop    %edi
f010033d:	5d                   	pop    %ebp
f010033e:	c3                   	ret    

f010033f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	83 ec 18             	sub    $0x18,%esp
	cons_intr(kbd_proc_data);
f0100345:	c7 04 24 f8 03 10 f0 	movl   $0xf01003f8,(%esp)
f010034c:	e8 a9 ff ff ff       	call   f01002fa <cons_intr>
}
f0100351:	c9                   	leave  
f0100352:	c3                   	ret    

f0100353 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100353:	55                   	push   %ebp
f0100354:	89 e5                	mov    %esp,%ebp
f0100356:	83 ec 18             	sub    $0x18,%esp
	if (serial_exists)
f0100359:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f0100360:	74 0c                	je     f010036e <serial_intr+0x1b>
		cons_intr(serial_proc_data);
f0100362:	c7 04 24 e0 01 10 f0 	movl   $0xf01001e0,(%esp)
f0100369:	e8 8c ff ff ff       	call   f01002fa <cons_intr>
}
f010036e:	c9                   	leave  
f010036f:	c3                   	ret    

f0100370 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100370:	55                   	push   %ebp
f0100371:	89 e5                	mov    %esp,%ebp
f0100373:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100376:	e8 d8 ff ff ff       	call   f0100353 <serial_intr>
	kbd_intr();
f010037b:	e8 bf ff ff ff       	call   f010033f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100380:	8b 15 60 f5 10 f0    	mov    0xf010f560,%edx
f0100386:	b8 00 00 00 00       	mov    $0x0,%eax
f010038b:	3b 15 64 f5 10 f0    	cmp    0xf010f564,%edx
f0100391:	74 21                	je     f01003b4 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100393:	0f b6 82 60 f3 10 f0 	movzbl -0xfef0ca0(%edx),%eax
f010039a:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010039d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01003a3:	0f 94 c1             	sete   %cl
f01003a6:	0f b6 c9             	movzbl %cl,%ecx
f01003a9:	83 e9 01             	sub    $0x1,%ecx
f01003ac:	21 ca                	and    %ecx,%edx
f01003ae:	89 15 60 f5 10 f0    	mov    %edx,0xf010f560
		return c;
	}
	return 0;
}
f01003b4:	c9                   	leave  
f01003b5:	c3                   	ret    

f01003b6 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01003b6:	55                   	push   %ebp
f01003b7:	89 e5                	mov    %esp,%ebp
f01003b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01003bc:	e8 af ff ff ff       	call   f0100370 <cons_getc>
f01003c1:	85 c0                	test   %eax,%eax
f01003c3:	74 f7                	je     f01003bc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01003c5:	c9                   	leave  
f01003c6:	c3                   	ret    

f01003c7 <iscons>:

int
iscons(int fdnum)
{
f01003c7:	55                   	push   %ebp
f01003c8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01003ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01003cf:	5d                   	pop    %ebp
f01003d0:	c3                   	ret    

f01003d1 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01003d1:	55                   	push   %ebp
f01003d2:	89 e5                	mov    %esp,%ebp
f01003d4:	83 ec 18             	sub    $0x18,%esp
	cga_init();
f01003d7:	e8 83 fe ff ff       	call   f010025f <cga_init>
	kbd_init();
	serial_init();
f01003dc:	e8 1f fe ff ff       	call   f0100200 <serial_init>

	if (!serial_exists)
f01003e1:	83 3d 44 f3 10 f0 00 	cmpl   $0x0,0xf010f344
f01003e8:	75 0c                	jne    f01003f6 <cons_init+0x25>
		cprintf("Serial port does not exist!\n");
f01003ea:	c7 04 24 88 17 10 f0 	movl   $0xf0101788,(%esp)
f01003f1:	e8 95 05 00 00       	call   f010098b <cprintf>
}
f01003f6:	c9                   	leave  
f01003f7:	c3                   	ret    

f01003f8 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003f8:	55                   	push   %ebp
f01003f9:	89 e5                	mov    %esp,%ebp
f01003fb:	53                   	push   %ebx
f01003fc:	83 ec 14             	sub    $0x14,%esp
f01003ff:	ba 64 00 00 00       	mov    $0x64,%edx
f0100404:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100405:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010040a:	a8 01                	test   $0x1,%al
f010040c:	0f 84 d9 00 00 00    	je     f01004eb <kbd_proc_data+0xf3>
f0100412:	b2 60                	mov    $0x60,%dl
f0100414:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100415:	3c e0                	cmp    $0xe0,%al
f0100417:	75 11                	jne    f010042a <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100419:	83 0d 40 f3 10 f0 40 	orl    $0x40,0xf010f340
f0100420:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100425:	e9 c1 00 00 00       	jmp    f01004eb <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f010042a:	84 c0                	test   %al,%al
f010042c:	79 32                	jns    f0100460 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010042e:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100434:	f6 c2 40             	test   $0x40,%dl
f0100437:	75 03                	jne    f010043c <kbd_proc_data+0x44>
f0100439:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f010043c:	0f b6 c0             	movzbl %al,%eax
f010043f:	0f b6 80 c0 17 10 f0 	movzbl -0xfefe840(%eax),%eax
f0100446:	83 c8 40             	or     $0x40,%eax
f0100449:	0f b6 c0             	movzbl %al,%eax
f010044c:	f7 d0                	not    %eax
f010044e:	21 c2                	and    %eax,%edx
f0100450:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
f0100456:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010045b:	e9 8b 00 00 00       	jmp    f01004eb <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f0100460:	8b 15 40 f3 10 f0    	mov    0xf010f340,%edx
f0100466:	f6 c2 40             	test   $0x40,%dl
f0100469:	74 0c                	je     f0100477 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010046b:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010046e:	83 e2 bf             	and    $0xffffffbf,%edx
f0100471:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340
	}

	shift |= shiftcode[data];
f0100477:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010047a:	0f b6 90 c0 17 10 f0 	movzbl -0xfefe840(%eax),%edx
f0100481:	0b 15 40 f3 10 f0    	or     0xf010f340,%edx
f0100487:	0f b6 88 c0 18 10 f0 	movzbl -0xfefe740(%eax),%ecx
f010048e:	31 ca                	xor    %ecx,%edx
f0100490:	89 15 40 f3 10 f0    	mov    %edx,0xf010f340

	c = charcode[shift & (CTL | SHIFT)][data];
f0100496:	89 d1                	mov    %edx,%ecx
f0100498:	83 e1 03             	and    $0x3,%ecx
f010049b:	8b 0c 8d c0 19 10 f0 	mov    -0xfefe640(,%ecx,4),%ecx
f01004a2:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01004a6:	f6 c2 08             	test   $0x8,%dl
f01004a9:	74 1a                	je     f01004c5 <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f01004ab:	89 d9                	mov    %ebx,%ecx
f01004ad:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01004b0:	83 f8 19             	cmp    $0x19,%eax
f01004b3:	77 05                	ja     f01004ba <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f01004b5:	83 eb 20             	sub    $0x20,%ebx
f01004b8:	eb 0b                	jmp    f01004c5 <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f01004ba:	83 e9 41             	sub    $0x41,%ecx
f01004bd:	83 f9 19             	cmp    $0x19,%ecx
f01004c0:	77 03                	ja     f01004c5 <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f01004c2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01004c5:	f7 d2                	not    %edx
f01004c7:	f6 c2 06             	test   $0x6,%dl
f01004ca:	75 1f                	jne    f01004eb <kbd_proc_data+0xf3>
f01004cc:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004d2:	75 17                	jne    f01004eb <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f01004d4:	c7 04 24 a5 17 10 f0 	movl   $0xf01017a5,(%esp)
f01004db:	e8 ab 04 00 00       	call   f010098b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004e0:	ba 92 00 00 00       	mov    $0x92,%edx
f01004e5:	b8 03 00 00 00       	mov    $0x3,%eax
f01004ea:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004eb:	89 d8                	mov    %ebx,%eax
f01004ed:	83 c4 14             	add    $0x14,%esp
f01004f0:	5b                   	pop    %ebx
f01004f1:	5d                   	pop    %ebp
f01004f2:	c3                   	ret    

f01004f3 <cga_putc>:



void
cga_putc(int c)
{
f01004f3:	55                   	push   %ebp
f01004f4:	89 e5                	mov    %esp,%ebp
f01004f6:	56                   	push   %esi
f01004f7:	53                   	push   %ebx
f01004f8:	83 ec 10             	sub    $0x10,%esp
f01004fb:	8b 45 08             	mov    0x8(%ebp),%eax
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004fe:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f0100503:	75 03                	jne    f0100508 <cga_putc+0x15>
		c |= 0x0700;
f0100505:	80 cc 07             	or     $0x7,%ah

	switch (c & 0xff) {
f0100508:	0f b6 d0             	movzbl %al,%edx
f010050b:	83 fa 09             	cmp    $0x9,%edx
f010050e:	0f 84 89 00 00 00    	je     f010059d <cga_putc+0xaa>
f0100514:	83 fa 09             	cmp    $0x9,%edx
f0100517:	7f 11                	jg     f010052a <cga_putc+0x37>
f0100519:	83 fa 08             	cmp    $0x8,%edx
f010051c:	0f 85 b9 00 00 00    	jne    f01005db <cga_putc+0xe8>
f0100522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100528:	eb 18                	jmp    f0100542 <cga_putc+0x4f>
f010052a:	83 fa 0a             	cmp    $0xa,%edx
f010052d:	8d 76 00             	lea    0x0(%esi),%esi
f0100530:	74 41                	je     f0100573 <cga_putc+0x80>
f0100532:	83 fa 0d             	cmp    $0xd,%edx
f0100535:	8d 76 00             	lea    0x0(%esi),%esi
f0100538:	0f 85 9d 00 00 00    	jne    f01005db <cga_putc+0xe8>
f010053e:	66 90                	xchg   %ax,%ax
f0100540:	eb 39                	jmp    f010057b <cga_putc+0x88>
	case '\b':
		if (crt_pos > 0) {
f0100542:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f0100549:	66 85 d2             	test   %dx,%dx
f010054c:	0f 84 f4 00 00 00    	je     f0100646 <cga_putc+0x153>
			crt_pos--;
f0100552:	83 ea 01             	sub    $0x1,%edx
f0100555:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010055c:	0f b7 d2             	movzwl %dx,%edx
f010055f:	b0 00                	mov    $0x0,%al
f0100561:	83 c8 20             	or     $0x20,%eax
f0100564:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f010056a:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f010056e:	e9 86 00 00 00       	jmp    f01005f9 <cga_putc+0x106>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100573:	66 83 05 50 f3 10 f0 	addw   $0x50,0xf010f350
f010057a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010057b:	0f b7 05 50 f3 10 f0 	movzwl 0xf010f350,%eax
f0100582:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100588:	c1 e8 10             	shr    $0x10,%eax
f010058b:	66 c1 e8 06          	shr    $0x6,%ax
f010058f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100592:	c1 e0 04             	shl    $0x4,%eax
f0100595:	66 a3 50 f3 10 f0    	mov    %ax,0xf010f350
		break;
f010059b:	eb 5c                	jmp    f01005f9 <cga_putc+0x106>
	case '\t':
		cons_putc(' ');
f010059d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005a4:	e8 d4 00 00 00       	call   f010067d <cons_putc>
		cons_putc(' ');
f01005a9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005b0:	e8 c8 00 00 00       	call   f010067d <cons_putc>
		cons_putc(' ');
f01005b5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005bc:	e8 bc 00 00 00       	call   f010067d <cons_putc>
		cons_putc(' ');
f01005c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005c8:	e8 b0 00 00 00       	call   f010067d <cons_putc>
		cons_putc(' ');
f01005cd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01005d4:	e8 a4 00 00 00       	call   f010067d <cons_putc>
		break;
f01005d9:	eb 1e                	jmp    f01005f9 <cga_putc+0x106>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005db:	0f b7 15 50 f3 10 f0 	movzwl 0xf010f350,%edx
f01005e2:	0f b7 da             	movzwl %dx,%ebx
f01005e5:	8b 0d 4c f3 10 f0    	mov    0xf010f34c,%ecx
f01005eb:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
f01005ef:	83 c2 01             	add    $0x1,%edx
f01005f2:	66 89 15 50 f3 10 f0 	mov    %dx,0xf010f350
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005f9:	66 81 3d 50 f3 10 f0 	cmpw   $0x7cf,0xf010f350
f0100600:	cf 07 
f0100602:	76 42                	jbe    f0100646 <cga_putc+0x153>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100604:	a1 4c f3 10 f0       	mov    0xf010f34c,%eax
f0100609:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100610:	00 
f0100611:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100617:	89 54 24 04          	mov    %edx,0x4(%esp)
f010061b:	89 04 24             	mov    %eax,(%esp)
f010061e:	e8 58 0c 00 00       	call   f010127b <memcpy>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100623:	8b 15 4c f3 10 f0    	mov    0xf010f34c,%edx
f0100629:	b8 80 07 00 00       	mov    $0x780,%eax
f010062e:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100634:	83 c0 01             	add    $0x1,%eax
f0100637:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010063c:	75 f0                	jne    f010062e <cga_putc+0x13b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010063e:	66 83 2d 50 f3 10 f0 	subw   $0x50,0xf010f350
f0100645:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100646:	8b 0d 48 f3 10 f0    	mov    0xf010f348,%ecx
f010064c:	89 cb                	mov    %ecx,%ebx
f010064e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100653:	89 ca                	mov    %ecx,%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100656:	0f b7 35 50 f3 10 f0 	movzwl 0xf010f350,%esi
f010065d:	83 c1 01             	add    $0x1,%ecx
f0100660:	89 f0                	mov    %esi,%eax
f0100662:	66 c1 e8 08          	shr    $0x8,%ax
f0100666:	89 ca                	mov    %ecx,%edx
f0100668:	ee                   	out    %al,(%dx)
f0100669:	b8 0f 00 00 00       	mov    $0xf,%eax
f010066e:	89 da                	mov    %ebx,%edx
f0100670:	ee                   	out    %al,(%dx)
f0100671:	89 f0                	mov    %esi,%eax
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
	outb(addr_6845 + 1, crt_pos);
}
f0100676:	83 c4 10             	add    $0x10,%esp
f0100679:	5b                   	pop    %ebx
f010067a:	5e                   	pop    %esi
f010067b:	5d                   	pop    %ebp
f010067c:	c3                   	ret    

f010067d <cons_putc>:
}

// output a character to the console
void
cons_putc(int c)
{
f010067d:	55                   	push   %ebp
f010067e:	89 e5                	mov    %esp,%ebp
f0100680:	57                   	push   %edi
f0100681:	56                   	push   %esi
f0100682:	53                   	push   %ebx
f0100683:	83 ec 1c             	sub    $0x1c,%esp
f0100686:	8b 7d 08             	mov    0x8(%ebp),%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100689:	ba 79 03 00 00       	mov    $0x379,%edx
f010068e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010068f:	84 c0                	test   %al,%al
f0100691:	78 27                	js     f01006ba <cons_putc+0x3d>
f0100693:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100698:	b9 84 00 00 00       	mov    $0x84,%ecx
f010069d:	be 79 03 00 00       	mov    $0x379,%esi
f01006a2:	89 ca                	mov    %ecx,%edx
f01006a4:	ec                   	in     (%dx),%al
f01006a5:	ec                   	in     (%dx),%al
f01006a6:	ec                   	in     (%dx),%al
f01006a7:	ec                   	in     (%dx),%al
f01006a8:	89 f2                	mov    %esi,%edx
f01006aa:	ec                   	in     (%dx),%al
f01006ab:	84 c0                	test   %al,%al
f01006ad:	78 0b                	js     f01006ba <cons_putc+0x3d>
f01006af:	83 c3 01             	add    $0x1,%ebx
f01006b2:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01006b8:	75 e8                	jne    f01006a2 <cons_putc+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ba:	ba 78 03 00 00       	mov    $0x378,%edx
f01006bf:	89 f8                	mov    %edi,%eax
f01006c1:	ee                   	out    %al,(%dx)
f01006c2:	b2 7a                	mov    $0x7a,%dl
f01006c4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01006c9:	ee                   	out    %al,(%dx)
f01006ca:	b8 08 00 00 00       	mov    $0x8,%eax
f01006cf:	ee                   	out    %al,(%dx)
// output a character to the console
void
cons_putc(int c)
{
	lpt_putc(c);
	cga_putc(c);
f01006d0:	89 3c 24             	mov    %edi,(%esp)
f01006d3:	e8 1b fe ff ff       	call   f01004f3 <cga_putc>
}
f01006d8:	83 c4 1c             	add    $0x1c,%esp
f01006db:	5b                   	pop    %ebx
f01006dc:	5e                   	pop    %esi
f01006dd:	5f                   	pop    %edi
f01006de:	5d                   	pop    %ebp
f01006df:	c3                   	ret    

f01006e0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006e0:	55                   	push   %ebp
f01006e1:	89 e5                	mov    %esp,%ebp
f01006e3:	83 ec 18             	sub    $0x18,%esp
	cons_putc(c);
f01006e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e9:	89 04 24             	mov    %eax,(%esp)
f01006ec:	e8 8c ff ff ff       	call   f010067d <cons_putc>
}
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    
	...

f0100700 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100700:	55                   	push   %ebp
f0100701:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	5d                   	pop    %ebp
f0100709:	c3                   	ret    

f010070a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010070d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100710:	5d                   	pop    %ebp
f0100711:	c3                   	ret    

f0100712 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100712:	55                   	push   %ebp
f0100713:	89 e5                	mov    %esp,%ebp
f0100715:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100718:	c7 04 24 d0 19 10 f0 	movl   $0xf01019d0,(%esp)
f010071f:	e8 67 02 00 00       	call   f010098b <cprintf>
	cprintf("  _start %08x (virt)  %08x (phys)\n", _start, _start - KERNBASE);
f0100724:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010072b:	00 
f010072c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100733:	f0 
f0100734:	c7 04 24 5c 1a 10 f0 	movl   $0xf0101a5c,(%esp)
f010073b:	e8 4b 02 00 00       	call   f010098b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100740:	c7 44 24 08 d5 16 10 	movl   $0x1016d5,0x8(%esp)
f0100747:	00 
f0100748:	c7 44 24 04 d5 16 10 	movl   $0xf01016d5,0x4(%esp)
f010074f:	f0 
f0100750:	c7 04 24 80 1a 10 f0 	movl   $0xf0101a80,(%esp)
f0100757:	e8 2f 02 00 00       	call   f010098b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010075c:	c7 44 24 08 20 f3 10 	movl   $0x10f320,0x8(%esp)
f0100763:	00 
f0100764:	c7 44 24 04 20 f3 10 	movl   $0xf010f320,0x4(%esp)
f010076b:	f0 
f010076c:	c7 04 24 a4 1a 10 f0 	movl   $0xf0101aa4,(%esp)
f0100773:	e8 13 02 00 00       	call   f010098b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100778:	c7 44 24 08 80 f9 10 	movl   $0x10f980,0x8(%esp)
f010077f:	00 
f0100780:	c7 44 24 04 80 f9 10 	movl   $0xf010f980,0x4(%esp)
f0100787:	f0 
f0100788:	c7 04 24 c8 1a 10 f0 	movl   $0xf0101ac8,(%esp)
f010078f:	e8 f7 01 00 00       	call   f010098b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100794:	b8 7f fd 10 f0       	mov    $0xf010fd7f,%eax
f0100799:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010079e:	89 c2                	mov    %eax,%edx
f01007a0:	c1 fa 1f             	sar    $0x1f,%edx
f01007a3:	c1 ea 16             	shr    $0x16,%edx
f01007a6:	8d 04 02             	lea    (%edx,%eax,1),%eax
f01007a9:	c1 f8 0a             	sar    $0xa,%eax
f01007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b0:	c7 04 24 ec 1a 10 f0 	movl   $0xf0101aec,(%esp)
f01007b7:	e8 cf 01 00 00       	call   f010098b <cprintf>
		(end-_start+1023)/1024);
	return 0;
}
f01007bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c1:	c9                   	leave  
f01007c2:	c3                   	ret    

f01007c3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c3:	55                   	push   %ebp
f01007c4:	89 e5                	mov    %esp,%ebp
f01007c6:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c9:	a1 90 1b 10 f0       	mov    0xf0101b90,%eax
f01007ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d2:	a1 8c 1b 10 f0       	mov    0xf0101b8c,%eax
f01007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007db:	c7 04 24 e9 19 10 f0 	movl   $0xf01019e9,(%esp)
f01007e2:	e8 a4 01 00 00       	call   f010098b <cprintf>
f01007e7:	a1 9c 1b 10 f0       	mov    0xf0101b9c,%eax
f01007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007f0:	a1 98 1b 10 f0       	mov    0xf0101b98,%eax
f01007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007f9:	c7 04 24 e9 19 10 f0 	movl   $0xf01019e9,(%esp)
f0100800:	e8 86 01 00 00       	call   f010098b <cprintf>
	return 0;
}
f0100805:	b8 00 00 00 00       	mov    $0x0,%eax
f010080a:	c9                   	leave  
f010080b:	c3                   	ret    

f010080c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010080c:	55                   	push   %ebp
f010080d:	89 e5                	mov    %esp,%ebp
f010080f:	57                   	push   %edi
f0100810:	56                   	push   %esi
f0100811:	53                   	push   %ebx
f0100812:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100815:	c7 04 24 18 1b 10 f0 	movl   $0xf0101b18,(%esp)
f010081c:	e8 6a 01 00 00       	call   f010098b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100821:	c7 04 24 3c 1b 10 f0 	movl   $0xf0101b3c,(%esp)
f0100828:	e8 5e 01 00 00       	call   f010098b <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010082d:	bf 8c 1b 10 f0       	mov    $0xf0101b8c,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100832:	c7 04 24 f2 19 10 f0 	movl   $0xf01019f2,(%esp)
f0100839:	e8 a2 07 00 00       	call   f0100fe0 <readline>
f010083e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100840:	85 c0                	test   %eax,%eax
f0100842:	74 ee                	je     f0100832 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100844:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010084b:	be 00 00 00 00       	mov    $0x0,%esi
f0100850:	eb 06                	jmp    f0100858 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100852:	c6 03 00             	movb   $0x0,(%ebx)
f0100855:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100858:	0f b6 03             	movzbl (%ebx),%eax
f010085b:	84 c0                	test   %al,%al
f010085d:	74 6c                	je     f01008cb <monitor+0xbf>
f010085f:	0f be c0             	movsbl %al,%eax
f0100862:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100866:	c7 04 24 f6 19 10 f0 	movl   $0xf01019f6,(%esp)
f010086d:	e8 8c 09 00 00       	call   f01011fe <strchr>
f0100872:	85 c0                	test   %eax,%eax
f0100874:	75 dc                	jne    f0100852 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100876:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100879:	74 50                	je     f01008cb <monitor+0xbf>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010087b:	83 fe 0f             	cmp    $0xf,%esi
f010087e:	66 90                	xchg   %ax,%ax
f0100880:	75 16                	jne    f0100898 <monitor+0x8c>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100882:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100889:	00 
f010088a:	c7 04 24 fb 19 10 f0 	movl   $0xf01019fb,(%esp)
f0100891:	e8 f5 00 00 00       	call   f010098b <cprintf>
f0100896:	eb 9a                	jmp    f0100832 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100898:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010089c:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010089f:	0f b6 03             	movzbl (%ebx),%eax
f01008a2:	84 c0                	test   %al,%al
f01008a4:	75 0c                	jne    f01008b2 <monitor+0xa6>
f01008a6:	eb b0                	jmp    f0100858 <monitor+0x4c>
			buf++;
f01008a8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ab:	0f b6 03             	movzbl (%ebx),%eax
f01008ae:	84 c0                	test   %al,%al
f01008b0:	74 a6                	je     f0100858 <monitor+0x4c>
f01008b2:	0f be c0             	movsbl %al,%eax
f01008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008b9:	c7 04 24 f6 19 10 f0 	movl   $0xf01019f6,(%esp)
f01008c0:	e8 39 09 00 00       	call   f01011fe <strchr>
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	74 df                	je     f01008a8 <monitor+0x9c>
f01008c9:	eb 8d                	jmp    f0100858 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f01008cb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008d3:	85 f6                	test   %esi,%esi
f01008d5:	0f 84 57 ff ff ff    	je     f0100832 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008db:	8b 07                	mov    (%edi),%eax
f01008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e1:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008e4:	89 04 24             	mov    %eax,(%esp)
f01008e7:	e8 9d 08 00 00       	call   f0101189 <strcmp>
f01008ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01008f1:	85 c0                	test   %eax,%eax
f01008f3:	74 1d                	je     f0100912 <monitor+0x106>
f01008f5:	a1 98 1b 10 f0       	mov    0xf0101b98,%eax
f01008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fe:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100901:	89 04 24             	mov    %eax,(%esp)
f0100904:	e8 80 08 00 00       	call   f0101189 <strcmp>
f0100909:	85 c0                	test   %eax,%eax
f010090b:	75 28                	jne    f0100935 <monitor+0x129>
f010090d:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100912:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100915:	8b 45 08             	mov    0x8(%ebp),%eax
f0100918:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010091f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100923:	89 34 24             	mov    %esi,(%esp)
f0100926:	ff 92 94 1b 10 f0    	call   *-0xfefe46c(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010092c:	85 c0                	test   %eax,%eax
f010092e:	78 1d                	js     f010094d <monitor+0x141>
f0100930:	e9 fd fe ff ff       	jmp    f0100832 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100935:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100938:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093c:	c7 04 24 18 1a 10 f0 	movl   $0xf0101a18,(%esp)
f0100943:	e8 43 00 00 00       	call   f010098b <cprintf>
f0100948:	e9 e5 fe ff ff       	jmp    f0100832 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010094d:	83 c4 5c             	add    $0x5c,%esp
f0100950:	5b                   	pop    %ebx
f0100951:	5e                   	pop    %esi
f0100952:	5f                   	pop    %edi
f0100953:	5d                   	pop    %ebp
f0100954:	c3                   	ret    
f0100955:	00 00                	add    %al,(%eax)
	...

f0100958 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010095e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100965:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100968:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010096c:	8b 45 08             	mov    0x8(%ebp),%eax
f010096f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100973:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100976:	89 44 24 04          	mov    %eax,0x4(%esp)
f010097a:	c7 04 24 a5 09 10 f0 	movl   $0xf01009a5,(%esp)
f0100981:	e8 8a 01 00 00       	call   f0100b10 <vprintfmt>
	return cnt;
}
f0100986:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100989:	c9                   	leave  
f010098a:	c3                   	ret    

f010098b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010098b:	55                   	push   %ebp
f010098c:	89 e5                	mov    %esp,%ebp
f010098e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100991:	8d 45 0c             	lea    0xc(%ebp),%eax
f0100994:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100998:	8b 45 08             	mov    0x8(%ebp),%eax
f010099b:	89 04 24             	mov    %eax,(%esp)
f010099e:	e8 b5 ff ff ff       	call   f0100958 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009a3:	c9                   	leave  
f01009a4:	c3                   	ret    

f01009a5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009a5:	55                   	push   %ebp
f01009a6:	89 e5                	mov    %esp,%ebp
f01009a8:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01009ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01009ae:	89 04 24             	mov    %eax,(%esp)
f01009b1:	e8 2a fd ff ff       	call   f01006e0 <cputchar>
	*cnt++;
}
f01009b6:	c9                   	leave  
f01009b7:	c3                   	ret    
	...

f01009c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01009c0:	55                   	push   %ebp
f01009c1:	89 e5                	mov    %esp,%ebp
f01009c3:	57                   	push   %edi
f01009c4:	56                   	push   %esi
f01009c5:	53                   	push   %ebx
f01009c6:	83 ec 4c             	sub    $0x4c,%esp
f01009c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01009cc:	89 d6                	mov    %edx,%esi
f01009ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01009d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01009d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009da:	8b 45 10             	mov    0x10(%ebp),%eax
f01009dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01009e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01009e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01009e6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01009eb:	39 d1                	cmp    %edx,%ecx
f01009ed:	72 15                	jb     f0100a04 <printnum+0x44>
f01009ef:	77 07                	ja     f01009f8 <printnum+0x38>
f01009f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01009f4:	39 d0                	cmp    %edx,%eax
f01009f6:	76 0c                	jbe    f0100a04 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01009f8:	83 eb 01             	sub    $0x1,%ebx
f01009fb:	85 db                	test   %ebx,%ebx
f01009fd:	8d 76 00             	lea    0x0(%esi),%esi
f0100a00:	7f 61                	jg     f0100a63 <printnum+0xa3>
f0100a02:	eb 70                	jmp    f0100a74 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100a04:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100a08:	83 eb 01             	sub    $0x1,%ebx
f0100a0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a13:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100a17:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100a1b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100a1e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100a21:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a28:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a2f:	00 
f0100a30:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a33:	89 04 24             	mov    %eax,(%esp)
f0100a36:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100a39:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a3d:	e8 2e 0a 00 00       	call   f0101470 <__udivdi3>
f0100a42:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100a48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100a4c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100a50:	89 04 24             	mov    %eax,(%esp)
f0100a53:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a57:	89 f2                	mov    %esi,%edx
f0100a59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a5c:	e8 5f ff ff ff       	call   f01009c0 <printnum>
f0100a61:	eb 11                	jmp    f0100a74 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100a63:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a67:	89 3c 24             	mov    %edi,(%esp)
f0100a6a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100a6d:	83 eb 01             	sub    $0x1,%ebx
f0100a70:	85 db                	test   %ebx,%ebx
f0100a72:	7f ef                	jg     f0100a63 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100a74:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a78:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a83:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100a8a:	00 
f0100a8b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a8e:	89 14 24             	mov    %edx,(%esp)
f0100a91:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100a98:	e8 03 0b 00 00       	call   f01015a0 <__umoddi3>
f0100a9d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100aa1:	0f be 80 a4 1b 10 f0 	movsbl -0xfefe45c(%eax),%eax
f0100aa8:	89 04 24             	mov    %eax,(%esp)
f0100aab:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100aae:	83 c4 4c             	add    $0x4c,%esp
f0100ab1:	5b                   	pop    %ebx
f0100ab2:	5e                   	pop    %esi
f0100ab3:	5f                   	pop    %edi
f0100ab4:	5d                   	pop    %ebp
f0100ab5:	c3                   	ret    

f0100ab6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100ab6:	55                   	push   %ebp
f0100ab7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100ab9:	83 fa 01             	cmp    $0x1,%edx
f0100abc:	7e 0f                	jle    f0100acd <getuint+0x17>
		return va_arg(*ap, unsigned long long);
f0100abe:	8b 10                	mov    (%eax),%edx
f0100ac0:	83 c2 08             	add    $0x8,%edx
f0100ac3:	89 10                	mov    %edx,(%eax)
f0100ac5:	8b 42 f8             	mov    -0x8(%edx),%eax
f0100ac8:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100acb:	eb 24                	jmp    f0100af1 <getuint+0x3b>
	else if (lflag)
f0100acd:	85 d2                	test   %edx,%edx
f0100acf:	74 11                	je     f0100ae2 <getuint+0x2c>
		return va_arg(*ap, unsigned long);
f0100ad1:	8b 10                	mov    (%eax),%edx
f0100ad3:	83 c2 04             	add    $0x4,%edx
f0100ad6:	89 10                	mov    %edx,(%eax)
f0100ad8:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100adb:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ae0:	eb 0f                	jmp    f0100af1 <getuint+0x3b>
	else
		return va_arg(*ap, unsigned int);
f0100ae2:	8b 10                	mov    (%eax),%edx
f0100ae4:	83 c2 04             	add    $0x4,%edx
f0100ae7:	89 10                	mov    %edx,(%eax)
f0100ae9:	8b 42 fc             	mov    -0x4(%edx),%eax
f0100aec:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100af1:	5d                   	pop    %ebp
f0100af2:	c3                   	ret    

f0100af3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100af9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100afd:	8b 10                	mov    (%eax),%edx
f0100aff:	3b 50 04             	cmp    0x4(%eax),%edx
f0100b02:	73 0a                	jae    f0100b0e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100b07:	88 0a                	mov    %cl,(%edx)
f0100b09:	83 c2 01             	add    $0x1,%edx
f0100b0c:	89 10                	mov    %edx,(%eax)
}
f0100b0e:	5d                   	pop    %ebp
f0100b0f:	c3                   	ret    

f0100b10 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	57                   	push   %edi
f0100b14:	56                   	push   %esi
f0100b15:	53                   	push   %ebx
f0100b16:	83 ec 5c             	sub    $0x5c,%esp
f0100b19:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100b1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100b22:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100b29:	eb 11                	jmp    f0100b3c <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100b2b:	85 c0                	test   %eax,%eax
f0100b2d:	0f 84 f4 03 00 00    	je     f0100f27 <vprintfmt+0x417>
				return;
			putch(ch, putdat);
f0100b33:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b37:	89 04 24             	mov    %eax,(%esp)
f0100b3a:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b3c:	0f b6 03             	movzbl (%ebx),%eax
f0100b3f:	83 c3 01             	add    $0x1,%ebx
f0100b42:	83 f8 25             	cmp    $0x25,%eax
f0100b45:	75 e4                	jne    f0100b2b <vprintfmt+0x1b>
f0100b47:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100b4b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100b52:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100b59:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100b60:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b65:	eb 06                	jmp    f0100b6d <vprintfmt+0x5d>
f0100b67:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100b6b:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100b6d:	0f b6 13             	movzbl (%ebx),%edx
f0100b70:	0f b6 c2             	movzbl %dl,%eax
f0100b73:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100b76:	8d 43 01             	lea    0x1(%ebx),%eax
f0100b79:	83 ea 23             	sub    $0x23,%edx
f0100b7c:	80 fa 55             	cmp    $0x55,%dl
f0100b7f:	0f 87 85 03 00 00    	ja     f0100f0a <vprintfmt+0x3fa>
f0100b85:	0f b6 d2             	movzbl %dl,%edx
f0100b88:	ff 24 95 30 1c 10 f0 	jmp    *-0xfefe3d0(,%edx,4)
f0100b8f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100b93:	eb d6                	jmp    f0100b6b <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100b95:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100b98:	83 ea 30             	sub    $0x30,%edx
f0100b9b:	89 55 d0             	mov    %edx,-0x30(%ebp)
				ch = *fmt;
f0100b9e:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100ba1:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100ba4:	83 fb 09             	cmp    $0x9,%ebx
f0100ba7:	77 4d                	ja     f0100bf6 <vprintfmt+0xe6>
f0100ba9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100baf:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0100bb2:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100bb5:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0100bb9:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0100bbc:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0100bbf:	83 fb 09             	cmp    $0x9,%ebx
f0100bc2:	76 eb                	jbe    f0100baf <vprintfmt+0x9f>
f0100bc4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100bc7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100bca:	eb 2a                	jmp    f0100bf6 <vprintfmt+0xe6>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100bcc:	8b 55 14             	mov    0x14(%ebp),%edx
f0100bcf:	83 c2 04             	add    $0x4,%edx
f0100bd2:	89 55 14             	mov    %edx,0x14(%ebp)
f0100bd5:	8b 52 fc             	mov    -0x4(%edx),%edx
f0100bd8:	89 55 d0             	mov    %edx,-0x30(%ebp)
			goto process_precision;
f0100bdb:	eb 19                	jmp    f0100bf6 <vprintfmt+0xe6>

		case '.':
			if (width < 0)
f0100bdd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100be0:	c1 fa 1f             	sar    $0x1f,%edx
f0100be3:	f7 d2                	not    %edx
f0100be5:	21 55 e4             	and    %edx,-0x1c(%ebp)
f0100be8:	eb 81                	jmp    f0100b6b <vprintfmt+0x5b>
f0100bea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100bf1:	e9 75 ff ff ff       	jmp    f0100b6b <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f0100bf6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100bfa:	0f 89 6b ff ff ff    	jns    f0100b6b <vprintfmt+0x5b>
f0100c00:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c03:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c06:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0100c09:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c0c:	e9 5a ff ff ff       	jmp    f0100b6b <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100c11:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0100c14:	e9 52 ff ff ff       	jmp    f0100b6b <vprintfmt+0x5b>
f0100c19:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100c1c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c1f:	83 c0 04             	add    $0x4,%eax
f0100c22:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c25:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c29:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c2c:	89 04 24             	mov    %eax,(%esp)
f0100c2f:	ff d7                	call   *%edi
f0100c31:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100c34:	e9 03 ff ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
f0100c39:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100c3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c3f:	83 c0 04             	add    $0x4,%eax
f0100c42:	89 45 14             	mov    %eax,0x14(%ebp)
f0100c45:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100c48:	89 c2                	mov    %eax,%edx
f0100c4a:	c1 fa 1f             	sar    $0x1f,%edx
f0100c4d:	31 d0                	xor    %edx,%eax
f0100c4f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c51:	83 f8 06             	cmp    $0x6,%eax
f0100c54:	7f 0b                	jg     f0100c61 <vprintfmt+0x151>
f0100c56:	8b 14 85 88 1d 10 f0 	mov    -0xfefe278(,%eax,4),%edx
f0100c5d:	85 d2                	test   %edx,%edx
f0100c5f:	75 20                	jne    f0100c81 <vprintfmt+0x171>
				printfmt(putch, putdat, "error %d", err);
f0100c61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c65:	c7 44 24 08 b5 1b 10 	movl   $0xf0101bb5,0x8(%esp)
f0100c6c:	f0 
f0100c6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c71:	89 3c 24             	mov    %edi,(%esp)
f0100c74:	e8 36 03 00 00       	call   f0100faf <printfmt>
f0100c79:	8b 5d cc             	mov    -0x34(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0100c7c:	e9 bb fe ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100c81:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c85:	c7 44 24 08 4e 17 10 	movl   $0xf010174e,0x8(%esp)
f0100c8c:	f0 
f0100c8d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c91:	89 3c 24             	mov    %edi,(%esp)
f0100c94:	e8 16 03 00 00       	call   f0100faf <printfmt>
f0100c99:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100c9c:	e9 9b fe ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
f0100ca1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ca4:	89 c3                	mov    %eax,%ebx
f0100ca6:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100ca9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100cac:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100caf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cb2:	83 c0 04             	add    $0x4,%eax
f0100cb5:	89 45 14             	mov    %eax,0x14(%ebp)
f0100cb8:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100cbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cbe:	85 c0                	test   %eax,%eax
f0100cc0:	75 07                	jne    f0100cc9 <vprintfmt+0x1b9>
f0100cc2:	c7 45 e0 be 1b 10 f0 	movl   $0xf0101bbe,-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0100cc9:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0100ccd:	7e 06                	jle    f0100cd5 <vprintfmt+0x1c5>
f0100ccf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100cd3:	75 13                	jne    f0100ce8 <vprintfmt+0x1d8>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100cd5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100cd8:	0f be 02             	movsbl (%edx),%eax
f0100cdb:	85 c0                	test   %eax,%eax
f0100cdd:	0f 85 99 00 00 00    	jne    f0100d7c <vprintfmt+0x26c>
f0100ce3:	e9 86 00 00 00       	jmp    f0100d6e <vprintfmt+0x25e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ce8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100cef:	89 0c 24             	mov    %ecx,(%esp)
f0100cf2:	e8 d4 03 00 00       	call   f01010cb <strnlen>
f0100cf7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100cfa:	29 c2                	sub    %eax,%edx
f0100cfc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100cff:	85 d2                	test   %edx,%edx
f0100d01:	7e d2                	jle    f0100cd5 <vprintfmt+0x1c5>
					putch(padc, putdat);
f0100d03:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0100d07:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d0a:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d0d:	89 d3                	mov    %edx,%ebx
f0100d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d16:	89 04 24             	mov    %eax,(%esp)
f0100d19:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100d1b:	83 eb 01             	sub    $0x1,%ebx
f0100d1e:	85 db                	test   %ebx,%ebx
f0100d20:	7f ed                	jg     f0100d0f <vprintfmt+0x1ff>
f0100d22:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d25:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d2c:	eb a7                	jmp    f0100cd5 <vprintfmt+0x1c5>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d2e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100d32:	74 18                	je     f0100d4c <vprintfmt+0x23c>
f0100d34:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100d37:	83 fa 5e             	cmp    $0x5e,%edx
f0100d3a:	76 10                	jbe    f0100d4c <vprintfmt+0x23c>
					putch('?', putdat);
f0100d3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d40:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100d47:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100d4a:	eb 0a                	jmp    f0100d56 <vprintfmt+0x246>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100d4c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d50:	89 04 24             	mov    %eax,(%esp)
f0100d53:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d56:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100d5a:	0f be 03             	movsbl (%ebx),%eax
f0100d5d:	85 c0                	test   %eax,%eax
f0100d5f:	74 05                	je     f0100d66 <vprintfmt+0x256>
f0100d61:	83 c3 01             	add    $0x1,%ebx
f0100d64:	eb 29                	jmp    f0100d8f <vprintfmt+0x27f>
f0100d66:	89 fe                	mov    %edi,%esi
f0100d68:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d6b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100d6e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d72:	7f 2e                	jg     f0100da2 <vprintfmt+0x292>
f0100d74:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0100d77:	e9 c0 fd ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100d7c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d7f:	83 c2 01             	add    $0x1,%edx
f0100d82:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100d85:	89 f7                	mov    %esi,%edi
f0100d87:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100d8a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100d8d:	89 d3                	mov    %edx,%ebx
f0100d8f:	85 f6                	test   %esi,%esi
f0100d91:	78 9b                	js     f0100d2e <vprintfmt+0x21e>
f0100d93:	83 ee 01             	sub    $0x1,%esi
f0100d96:	79 96                	jns    f0100d2e <vprintfmt+0x21e>
f0100d98:	89 fe                	mov    %edi,%esi
f0100d9a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d9d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100da0:	eb cc                	jmp    f0100d6e <vprintfmt+0x25e>
f0100da2:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f0100da5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100da8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dac:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100db3:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100db5:	83 eb 01             	sub    $0x1,%ebx
f0100db8:	85 db                	test   %ebx,%ebx
f0100dba:	7f ec                	jg     f0100da8 <vprintfmt+0x298>
f0100dbc:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100dbf:	e9 78 fd ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
f0100dc4:	89 45 cc             	mov    %eax,-0x34(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100dc7:	83 f9 01             	cmp    $0x1,%ecx
f0100dca:	7e 17                	jle    f0100de3 <vprintfmt+0x2d3>
		return va_arg(*ap, long long);
f0100dcc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dcf:	83 c0 08             	add    $0x8,%eax
f0100dd2:	89 45 14             	mov    %eax,0x14(%ebp)
f0100dd5:	8b 50 f8             	mov    -0x8(%eax),%edx
f0100dd8:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100ddb:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100dde:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100de1:	eb 34                	jmp    f0100e17 <vprintfmt+0x307>
	else if (lflag)
f0100de3:	85 c9                	test   %ecx,%ecx
f0100de5:	74 19                	je     f0100e00 <vprintfmt+0x2f0>
		return va_arg(*ap, long);
f0100de7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dea:	83 c0 04             	add    $0x4,%eax
f0100ded:	89 45 14             	mov    %eax,0x14(%ebp)
f0100df0:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100df3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100df6:	89 c1                	mov    %eax,%ecx
f0100df8:	c1 f9 1f             	sar    $0x1f,%ecx
f0100dfb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100dfe:	eb 17                	jmp    f0100e17 <vprintfmt+0x307>
	else
		return va_arg(*ap, int);
f0100e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e03:	83 c0 04             	add    $0x4,%eax
f0100e06:	89 45 14             	mov    %eax,0x14(%ebp)
f0100e09:	8b 40 fc             	mov    -0x4(%eax),%eax
f0100e0c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e0f:	89 c2                	mov    %eax,%edx
f0100e11:	c1 fa 1f             	sar    $0x1f,%edx
f0100e14:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100e17:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e1a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e1d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100e22:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100e26:	0f 89 9c 00 00 00    	jns    f0100ec8 <vprintfmt+0x3b8>
				putch('-', putdat);
f0100e2c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e30:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100e37:	ff d7                	call   *%edi
				num = -(long long) num;
f0100e39:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e3c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e3f:	f7 d9                	neg    %ecx
f0100e41:	83 d3 00             	adc    $0x0,%ebx
f0100e44:	f7 db                	neg    %ebx
f0100e46:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100e4b:	eb 7b                	jmp    f0100ec8 <vprintfmt+0x3b8>
f0100e4d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0100e50:	89 ca                	mov    %ecx,%edx
f0100e52:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e55:	e8 5c fc ff ff       	call   f0100ab6 <getuint>
f0100e5a:	89 c1                	mov    %eax,%ecx
f0100e5c:	89 d3                	mov    %edx,%ebx
f0100e5e:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0100e63:	eb 63                	jmp    f0100ec8 <vprintfmt+0x3b8>
f0100e65:	89 45 cc             	mov    %eax,-0x34(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
                        num = getuint(&ap, lflag);
f0100e68:	89 ca                	mov    %ecx,%edx
f0100e6a:	8d 45 14             	lea    0x14(%ebp),%eax
f0100e6d:	e8 44 fc ff ff       	call   f0100ab6 <getuint>
f0100e72:	89 c1                	mov    %eax,%ecx
f0100e74:	89 d3                	mov    %edx,%ebx
f0100e76:	b8 08 00 00 00       	mov    $0x8,%eax
                        base = 8;
                        goto number;
f0100e7b:	eb 4b                	jmp    f0100ec8 <vprintfmt+0x3b8>
f0100e7d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0100e80:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e84:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0100e8b:	ff d7                	call   *%edi
			putch('x', putdat);
f0100e8d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e91:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0100e98:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0100e9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e9d:	83 c0 04             	add    $0x4,%eax
f0100ea0:	89 45 14             	mov    %eax,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0100ea3:	8b 48 fc             	mov    -0x4(%eax),%ecx
f0100ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eab:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0100eb0:	eb 16                	jmp    f0100ec8 <vprintfmt+0x3b8>
f0100eb2:	89 45 cc             	mov    %eax,-0x34(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0100eb5:	89 ca                	mov    %ecx,%edx
f0100eb7:	8d 45 14             	lea    0x14(%ebp),%eax
f0100eba:	e8 f7 fb ff ff       	call   f0100ab6 <getuint>
f0100ebf:	89 c1                	mov    %eax,%ecx
f0100ec1:	89 d3                	mov    %edx,%ebx
f0100ec3:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0100ec8:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0100ecc:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100ed0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ed3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100edb:	89 0c 24             	mov    %ecx,(%esp)
f0100ede:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ee2:	89 f2                	mov    %esi,%edx
f0100ee4:	89 f8                	mov    %edi,%eax
f0100ee6:	e8 d5 fa ff ff       	call   f01009c0 <printnum>
f0100eeb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100eee:	e9 49 fc ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
f0100ef3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ef6:	8b 55 e0             	mov    -0x20(%ebp),%edx

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0100ef9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100efd:	89 14 24             	mov    %edx,(%esp)
f0100f00:	ff d7                	call   *%edi
f0100f02:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			break;
f0100f05:	e9 32 fc ff ff       	jmp    f0100b3c <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0100f0a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0100f15:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100f1a:	80 38 25             	cmpb   $0x25,(%eax)
f0100f1d:	0f 84 19 fc ff ff    	je     f0100b3c <vprintfmt+0x2c>
f0100f23:	89 c3                	mov    %eax,%ebx
f0100f25:	eb f0                	jmp    f0100f17 <vprintfmt+0x407>
				/* do nothing */;
			break;
		}
	}
}
f0100f27:	83 c4 5c             	add    $0x5c,%esp
f0100f2a:	5b                   	pop    %ebx
f0100f2b:	5e                   	pop    %esi
f0100f2c:	5f                   	pop    %edi
f0100f2d:	5d                   	pop    %ebp
f0100f2e:	c3                   	ret    

f0100f2f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100f2f:	55                   	push   %ebp
f0100f30:	89 e5                	mov    %esp,%ebp
f0100f32:	83 ec 28             	sub    $0x28,%esp
f0100f35:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f38:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0100f3b:	85 c0                	test   %eax,%eax
f0100f3d:	74 04                	je     f0100f43 <vsnprintf+0x14>
f0100f3f:	85 d2                	test   %edx,%edx
f0100f41:	7f 07                	jg     f0100f4a <vsnprintf+0x1b>
f0100f43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100f48:	eb 3b                	jmp    f0100f85 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100f4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100f4d:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0100f51:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100f5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f62:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f65:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f69:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f70:	c7 04 24 f3 0a 10 f0 	movl   $0xf0100af3,(%esp)
f0100f77:	e8 94 fb ff ff       	call   f0100b10 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100f85:	c9                   	leave  
f0100f86:	c3                   	ret    

f0100f87 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100f87:	55                   	push   %ebp
f0100f88:	89 e5                	mov    %esp,%ebp
f0100f8a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0100f8d:	8d 45 14             	lea    0x14(%ebp),%eax
f0100f90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f94:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f97:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa5:	89 04 24             	mov    %eax,(%esp)
f0100fa8:	e8 82 ff ff ff       	call   f0100f2f <vsnprintf>
	va_end(ap);

	return rc;
}
f0100fad:	c9                   	leave  
f0100fae:	c3                   	ret    

f0100faf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100faf:	55                   	push   %ebp
f0100fb0:	89 e5                	mov    %esp,%ebp
f0100fb2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0100fb5:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fbc:	8b 45 10             	mov    0x10(%ebp),%eax
f0100fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fca:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fcd:	89 04 24             	mov    %eax,(%esp)
f0100fd0:	e8 3b fb ff ff       	call   f0100b10 <vprintfmt>
	va_end(ap);
}
f0100fd5:	c9                   	leave  
f0100fd6:	c3                   	ret    
	...

f0100fe0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100fe0:	55                   	push   %ebp
f0100fe1:	89 e5                	mov    %esp,%ebp
f0100fe3:	57                   	push   %edi
f0100fe4:	56                   	push   %esi
f0100fe5:	53                   	push   %ebx
f0100fe6:	83 ec 1c             	sub    $0x1c,%esp
f0100fe9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100fec:	85 c0                	test   %eax,%eax
f0100fee:	74 10                	je     f0101000 <readline+0x20>
		cprintf("%s", prompt);
f0100ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ff4:	c7 04 24 4e 17 10 f0 	movl   $0xf010174e,(%esp)
f0100ffb:	e8 8b f9 ff ff       	call   f010098b <cprintf>

	i = 0;
	echoing = iscons(0);
f0101000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101007:	e8 bb f3 ff ff       	call   f01003c7 <iscons>
f010100c:	89 c7                	mov    %eax,%edi
f010100e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101013:	e8 9e f3 ff ff       	call   f01003b6 <getchar>
f0101018:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010101a:	85 c0                	test   %eax,%eax
f010101c:	79 17                	jns    f0101035 <readline+0x55>
			cprintf("read error: %e\n", c);
f010101e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101022:	c7 04 24 a4 1d 10 f0 	movl   $0xf0101da4,(%esp)
f0101029:	e8 5d f9 ff ff       	call   f010098b <cprintf>
f010102e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101033:	eb 65                	jmp    f010109a <readline+0xba>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101035:	83 f8 1f             	cmp    $0x1f,%eax
f0101038:	7e 1f                	jle    f0101059 <readline+0x79>
f010103a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101040:	7f 17                	jg     f0101059 <readline+0x79>
			if (echoing)
f0101042:	85 ff                	test   %edi,%edi
f0101044:	74 08                	je     f010104e <readline+0x6e>
				cputchar(c);
f0101046:	89 04 24             	mov    %eax,(%esp)
f0101049:	e8 92 f6 ff ff       	call   f01006e0 <cputchar>
			buf[i++] = c;
f010104e:	88 9e 80 f5 10 f0    	mov    %bl,-0xfef0a80(%esi)
f0101054:	83 c6 01             	add    $0x1,%esi
f0101057:	eb ba                	jmp    f0101013 <readline+0x33>
		} else if (c == '\b' && i > 0) {
f0101059:	83 fb 08             	cmp    $0x8,%ebx
f010105c:	75 15                	jne    f0101073 <readline+0x93>
f010105e:	85 f6                	test   %esi,%esi
f0101060:	7e 11                	jle    f0101073 <readline+0x93>
			if (echoing)
f0101062:	85 ff                	test   %edi,%edi
f0101064:	74 08                	je     f010106e <readline+0x8e>
				cputchar(c);
f0101066:	89 1c 24             	mov    %ebx,(%esp)
f0101069:	e8 72 f6 ff ff       	call   f01006e0 <cputchar>
			i--;
f010106e:	83 ee 01             	sub    $0x1,%esi
f0101071:	eb a0                	jmp    f0101013 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0101073:	83 fb 0a             	cmp    $0xa,%ebx
f0101076:	74 0a                	je     f0101082 <readline+0xa2>
f0101078:	83 fb 0d             	cmp    $0xd,%ebx
f010107b:	90                   	nop
f010107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101080:	75 91                	jne    f0101013 <readline+0x33>
			if (echoing)
f0101082:	85 ff                	test   %edi,%edi
f0101084:	74 08                	je     f010108e <readline+0xae>
				cputchar(c);
f0101086:	89 1c 24             	mov    %ebx,(%esp)
f0101089:	e8 52 f6 ff ff       	call   f01006e0 <cputchar>
			buf[i] = 0;
f010108e:	c6 86 80 f5 10 f0 00 	movb   $0x0,-0xfef0a80(%esi)
f0101095:	b8 80 f5 10 f0       	mov    $0xf010f580,%eax
			return buf;
		}
	}
}
f010109a:	83 c4 1c             	add    $0x1c,%esp
f010109d:	5b                   	pop    %ebx
f010109e:	5e                   	pop    %esi
f010109f:	5f                   	pop    %edi
f01010a0:	5d                   	pop    %ebp
f01010a1:	c3                   	ret    
	...

f01010b0 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01010b0:	55                   	push   %ebp
f01010b1:	89 e5                	mov    %esp,%ebp
f01010b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01010b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010bb:	80 3a 00             	cmpb   $0x0,(%edx)
f01010be:	74 09                	je     f01010c9 <strlen+0x19>
		n++;
f01010c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01010c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01010c7:	75 f7                	jne    f01010c0 <strlen+0x10>
		n++;
	return n;
}
f01010c9:	5d                   	pop    %ebp
f01010ca:	c3                   	ret    

f01010cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01010cb:	55                   	push   %ebp
f01010cc:	89 e5                	mov    %esp,%ebp
f01010ce:	53                   	push   %ebx
f01010cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010d5:	85 c9                	test   %ecx,%ecx
f01010d7:	74 19                	je     f01010f2 <strnlen+0x27>
f01010d9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01010dc:	74 14                	je     f01010f2 <strnlen+0x27>
f01010de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01010e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01010e6:	39 c8                	cmp    %ecx,%eax
f01010e8:	74 0d                	je     f01010f7 <strnlen+0x2c>
f01010ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01010ee:	75 f3                	jne    f01010e3 <strnlen+0x18>
f01010f0:	eb 05                	jmp    f01010f7 <strnlen+0x2c>
f01010f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01010f7:	5b                   	pop    %ebx
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    

f01010fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	53                   	push   %ebx
f01010fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101104:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101109:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010110d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101110:	83 c2 01             	add    $0x1,%edx
f0101113:	84 c9                	test   %cl,%cl
f0101115:	75 f2                	jne    f0101109 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101117:	5b                   	pop    %ebx
f0101118:	5d                   	pop    %ebp
f0101119:	c3                   	ret    

f010111a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010111a:	55                   	push   %ebp
f010111b:	89 e5                	mov    %esp,%ebp
f010111d:	56                   	push   %esi
f010111e:	53                   	push   %ebx
f010111f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101122:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101125:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101128:	85 f6                	test   %esi,%esi
f010112a:	74 18                	je     f0101144 <strncpy+0x2a>
f010112c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0101131:	0f b6 1a             	movzbl (%edx),%ebx
f0101134:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101137:	80 3a 01             	cmpb   $0x1,(%edx)
f010113a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010113d:	83 c1 01             	add    $0x1,%ecx
f0101140:	39 ce                	cmp    %ecx,%esi
f0101142:	77 ed                	ja     f0101131 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101144:	5b                   	pop    %ebx
f0101145:	5e                   	pop    %esi
f0101146:	5d                   	pop    %ebp
f0101147:	c3                   	ret    

f0101148 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101148:	55                   	push   %ebp
f0101149:	89 e5                	mov    %esp,%ebp
f010114b:	56                   	push   %esi
f010114c:	53                   	push   %ebx
f010114d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101150:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101153:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101156:	89 f0                	mov    %esi,%eax
f0101158:	85 c9                	test   %ecx,%ecx
f010115a:	74 27                	je     f0101183 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f010115c:	83 e9 01             	sub    $0x1,%ecx
f010115f:	74 1d                	je     f010117e <strlcpy+0x36>
f0101161:	0f b6 1a             	movzbl (%edx),%ebx
f0101164:	84 db                	test   %bl,%bl
f0101166:	74 16                	je     f010117e <strlcpy+0x36>
			*dst++ = *src++;
f0101168:	88 18                	mov    %bl,(%eax)
f010116a:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010116d:	83 e9 01             	sub    $0x1,%ecx
f0101170:	74 0e                	je     f0101180 <strlcpy+0x38>
			*dst++ = *src++;
f0101172:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101175:	0f b6 1a             	movzbl (%edx),%ebx
f0101178:	84 db                	test   %bl,%bl
f010117a:	75 ec                	jne    f0101168 <strlcpy+0x20>
f010117c:	eb 02                	jmp    f0101180 <strlcpy+0x38>
f010117e:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101180:	c6 00 00             	movb   $0x0,(%eax)
f0101183:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101185:	5b                   	pop    %ebx
f0101186:	5e                   	pop    %esi
f0101187:	5d                   	pop    %ebp
f0101188:	c3                   	ret    

f0101189 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101189:	55                   	push   %ebp
f010118a:	89 e5                	mov    %esp,%ebp
f010118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010118f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101192:	0f b6 01             	movzbl (%ecx),%eax
f0101195:	84 c0                	test   %al,%al
f0101197:	74 15                	je     f01011ae <strcmp+0x25>
f0101199:	3a 02                	cmp    (%edx),%al
f010119b:	75 11                	jne    f01011ae <strcmp+0x25>
		p++, q++;
f010119d:	83 c1 01             	add    $0x1,%ecx
f01011a0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01011a3:	0f b6 01             	movzbl (%ecx),%eax
f01011a6:	84 c0                	test   %al,%al
f01011a8:	74 04                	je     f01011ae <strcmp+0x25>
f01011aa:	3a 02                	cmp    (%edx),%al
f01011ac:	74 ef                	je     f010119d <strcmp+0x14>
f01011ae:	0f b6 c0             	movzbl %al,%eax
f01011b1:	0f b6 12             	movzbl (%edx),%edx
f01011b4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011b6:	5d                   	pop    %ebp
f01011b7:	c3                   	ret    

f01011b8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01011b8:	55                   	push   %ebp
f01011b9:	89 e5                	mov    %esp,%ebp
f01011bb:	53                   	push   %ebx
f01011bc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011c2:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01011c5:	85 c0                	test   %eax,%eax
f01011c7:	74 23                	je     f01011ec <strncmp+0x34>
f01011c9:	0f b6 1a             	movzbl (%edx),%ebx
f01011cc:	84 db                	test   %bl,%bl
f01011ce:	74 24                	je     f01011f4 <strncmp+0x3c>
f01011d0:	3a 19                	cmp    (%ecx),%bl
f01011d2:	75 20                	jne    f01011f4 <strncmp+0x3c>
f01011d4:	83 e8 01             	sub    $0x1,%eax
f01011d7:	74 13                	je     f01011ec <strncmp+0x34>
		n--, p++, q++;
f01011d9:	83 c2 01             	add    $0x1,%edx
f01011dc:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01011df:	0f b6 1a             	movzbl (%edx),%ebx
f01011e2:	84 db                	test   %bl,%bl
f01011e4:	74 0e                	je     f01011f4 <strncmp+0x3c>
f01011e6:	3a 19                	cmp    (%ecx),%bl
f01011e8:	74 ea                	je     f01011d4 <strncmp+0x1c>
f01011ea:	eb 08                	jmp    f01011f4 <strncmp+0x3c>
f01011ec:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01011f1:	5b                   	pop    %ebx
f01011f2:	5d                   	pop    %ebp
f01011f3:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01011f4:	0f b6 02             	movzbl (%edx),%eax
f01011f7:	0f b6 11             	movzbl (%ecx),%edx
f01011fa:	29 d0                	sub    %edx,%eax
f01011fc:	eb f3                	jmp    f01011f1 <strncmp+0x39>

f01011fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01011fe:	55                   	push   %ebp
f01011ff:	89 e5                	mov    %esp,%ebp
f0101201:	8b 45 08             	mov    0x8(%ebp),%eax
f0101204:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101208:	0f b6 10             	movzbl (%eax),%edx
f010120b:	84 d2                	test   %dl,%dl
f010120d:	74 15                	je     f0101224 <strchr+0x26>
		if (*s == c)
f010120f:	38 ca                	cmp    %cl,%dl
f0101211:	75 07                	jne    f010121a <strchr+0x1c>
f0101213:	eb 14                	jmp    f0101229 <strchr+0x2b>
f0101215:	38 ca                	cmp    %cl,%dl
f0101217:	90                   	nop
f0101218:	74 0f                	je     f0101229 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010121a:	83 c0 01             	add    $0x1,%eax
f010121d:	0f b6 10             	movzbl (%eax),%edx
f0101220:	84 d2                	test   %dl,%dl
f0101222:	75 f1                	jne    f0101215 <strchr+0x17>
f0101224:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101229:	5d                   	pop    %ebp
f010122a:	c3                   	ret    

f010122b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010122b:	55                   	push   %ebp
f010122c:	89 e5                	mov    %esp,%ebp
f010122e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101231:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101235:	0f b6 10             	movzbl (%eax),%edx
f0101238:	84 d2                	test   %dl,%dl
f010123a:	74 18                	je     f0101254 <strfind+0x29>
		if (*s == c)
f010123c:	38 ca                	cmp    %cl,%dl
f010123e:	75 0a                	jne    f010124a <strfind+0x1f>
f0101240:	eb 12                	jmp    f0101254 <strfind+0x29>
f0101242:	38 ca                	cmp    %cl,%dl
f0101244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101248:	74 0a                	je     f0101254 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010124a:	83 c0 01             	add    $0x1,%eax
f010124d:	0f b6 10             	movzbl (%eax),%edx
f0101250:	84 d2                	test   %dl,%dl
f0101252:	75 ee                	jne    f0101242 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0101254:	5d                   	pop    %ebp
f0101255:	c3                   	ret    

f0101256 <memset>:


void *
memset(void *v, int c, size_t n)
{
f0101256:	55                   	push   %ebp
f0101257:	89 e5                	mov    %esp,%ebp
f0101259:	53                   	push   %ebx
f010125a:	8b 45 08             	mov    0x8(%ebp),%eax
f010125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101260:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101263:	89 da                	mov    %ebx,%edx
f0101265:	83 ea 01             	sub    $0x1,%edx
f0101268:	78 0e                	js     f0101278 <memset+0x22>
memset(void *v, int c, size_t n)
{
	char *p;
	int m;

	p = v;
f010126a:	89 c2                	mov    %eax,%edx
	return (char *) s;
}


void *
memset(void *v, int c, size_t n)
f010126c:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
	int m;

	p = v;
	m = n;
	while (--m >= 0)
		*p++ = c;
f010126f:	88 0a                	mov    %cl,(%edx)
f0101271:	83 c2 01             	add    $0x1,%edx
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0101274:	39 da                	cmp    %ebx,%edx
f0101276:	75 f7                	jne    f010126f <memset+0x19>
		*p++ = c;

	return v;
}
f0101278:	5b                   	pop    %ebx
f0101279:	5d                   	pop    %ebp
f010127a:	c3                   	ret    

f010127b <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	56                   	push   %esi
f010127f:	53                   	push   %ebx
f0101280:	8b 45 08             	mov    0x8(%ebp),%eax
f0101283:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101286:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0101289:	85 db                	test   %ebx,%ebx
f010128b:	74 13                	je     f01012a0 <memcpy+0x25>
f010128d:	ba 00 00 00 00       	mov    $0x0,%edx
		*d++ = *s++;
f0101292:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f0101296:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101299:	83 c2 01             	add    $0x1,%edx
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f010129c:	39 da                	cmp    %ebx,%edx
f010129e:	75 f2                	jne    f0101292 <memcpy+0x17>
		*d++ = *s++;

	return dst;
}
f01012a0:	5b                   	pop    %ebx
f01012a1:	5e                   	pop    %esi
f01012a2:	5d                   	pop    %ebp
f01012a3:	c3                   	ret    

f01012a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01012a4:	55                   	push   %ebp
f01012a5:	89 e5                	mov    %esp,%ebp
f01012a7:	57                   	push   %edi
f01012a8:	56                   	push   %esi
f01012a9:	53                   	push   %ebx
f01012aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ad:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const char *s;
	char *d;
	
	s = src;
f01012b3:	89 f7                	mov    %esi,%edi
	d = dst;
	if (s < d && s + n > d) {
f01012b5:	39 c6                	cmp    %eax,%esi
f01012b7:	72 0b                	jb     f01012c4 <memmove+0x20>
		s += n;
		d += n;
		while (n-- > 0)
f01012b9:	ba 00 00 00 00       	mov    $0x0,%edx
			*--d = *--s;
	} else
		while (n-- > 0)
f01012be:	85 db                	test   %ebx,%ebx
f01012c0:	75 2d                	jne    f01012ef <memmove+0x4b>
f01012c2:	eb 39                	jmp    f01012fd <memmove+0x59>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01012c4:	01 df                	add    %ebx,%edi
f01012c6:	39 f8                	cmp    %edi,%eax
f01012c8:	73 ef                	jae    f01012b9 <memmove+0x15>
		s += n;
		d += n;
		while (n-- > 0)
f01012ca:	85 db                	test   %ebx,%ebx
f01012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01012d0:	74 2b                	je     f01012fd <memmove+0x59>
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
f01012d2:	8d 34 18             	lea    (%eax,%ebx,1),%esi
f01012d5:	ba 00 00 00 00       	mov    $0x0,%edx
		while (n-- > 0)
			*--d = *--s;
f01012da:	0f b6 4c 17 ff       	movzbl -0x1(%edi,%edx,1),%ecx
f01012df:	88 4c 16 ff          	mov    %cl,-0x1(%esi,%edx,1)
f01012e3:	83 ea 01             	sub    $0x1,%edx
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01012e6:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f01012e9:	85 c9                	test   %ecx,%ecx
f01012eb:	75 ed                	jne    f01012da <memmove+0x36>
f01012ed:	eb 0e                	jmp    f01012fd <memmove+0x59>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01012ef:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
f01012f3:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012f6:	83 c2 01             	add    $0x1,%edx
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01012f9:	39 d3                	cmp    %edx,%ebx
f01012fb:	75 f2                	jne    f01012ef <memmove+0x4b>
			*d++ = *s++;

	return dst;
}
f01012fd:	5b                   	pop    %ebx
f01012fe:	5e                   	pop    %esi
f01012ff:	5f                   	pop    %edi
f0101300:	5d                   	pop    %ebp
f0101301:	c3                   	ret    

f0101302 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101302:	55                   	push   %ebp
f0101303:	89 e5                	mov    %esp,%ebp
f0101305:	57                   	push   %edi
f0101306:	56                   	push   %esi
f0101307:	53                   	push   %ebx
f0101308:	8b 75 08             	mov    0x8(%ebp),%esi
f010130b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010130e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101311:	85 c9                	test   %ecx,%ecx
f0101313:	74 36                	je     f010134b <memcmp+0x49>
		if (*s1 != *s2)
f0101315:	0f b6 06             	movzbl (%esi),%eax
f0101318:	0f b6 1f             	movzbl (%edi),%ebx
f010131b:	38 d8                	cmp    %bl,%al
f010131d:	74 20                	je     f010133f <memcmp+0x3d>
f010131f:	eb 14                	jmp    f0101335 <memcmp+0x33>
f0101321:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0101326:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f010132b:	83 c2 01             	add    $0x1,%edx
f010132e:	83 e9 01             	sub    $0x1,%ecx
f0101331:	38 d8                	cmp    %bl,%al
f0101333:	74 12                	je     f0101347 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0101335:	0f b6 c0             	movzbl %al,%eax
f0101338:	0f b6 db             	movzbl %bl,%ebx
f010133b:	29 d8                	sub    %ebx,%eax
f010133d:	eb 11                	jmp    f0101350 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010133f:	83 e9 01             	sub    $0x1,%ecx
f0101342:	ba 00 00 00 00       	mov    $0x0,%edx
f0101347:	85 c9                	test   %ecx,%ecx
f0101349:	75 d6                	jne    f0101321 <memcmp+0x1f>
f010134b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101350:	5b                   	pop    %ebx
f0101351:	5e                   	pop    %esi
f0101352:	5f                   	pop    %edi
f0101353:	5d                   	pop    %ebp
f0101354:	c3                   	ret    

f0101355 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101355:	55                   	push   %ebp
f0101356:	89 e5                	mov    %esp,%ebp
f0101358:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010135b:	89 c2                	mov    %eax,%edx
f010135d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101360:	39 d0                	cmp    %edx,%eax
f0101362:	73 15                	jae    f0101379 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101364:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0101368:	38 08                	cmp    %cl,(%eax)
f010136a:	75 06                	jne    f0101372 <memfind+0x1d>
f010136c:	eb 0b                	jmp    f0101379 <memfind+0x24>
f010136e:	38 08                	cmp    %cl,(%eax)
f0101370:	74 07                	je     f0101379 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101372:	83 c0 01             	add    $0x1,%eax
f0101375:	39 c2                	cmp    %eax,%edx
f0101377:	77 f5                	ja     f010136e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101379:	5d                   	pop    %ebp
f010137a:	c3                   	ret    

f010137b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010137b:	55                   	push   %ebp
f010137c:	89 e5                	mov    %esp,%ebp
f010137e:	57                   	push   %edi
f010137f:	56                   	push   %esi
f0101380:	53                   	push   %ebx
f0101381:	83 ec 04             	sub    $0x4,%esp
f0101384:	8b 55 08             	mov    0x8(%ebp),%edx
f0101387:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010138a:	0f b6 02             	movzbl (%edx),%eax
f010138d:	3c 20                	cmp    $0x20,%al
f010138f:	74 04                	je     f0101395 <strtol+0x1a>
f0101391:	3c 09                	cmp    $0x9,%al
f0101393:	75 0e                	jne    f01013a3 <strtol+0x28>
		s++;
f0101395:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101398:	0f b6 02             	movzbl (%edx),%eax
f010139b:	3c 20                	cmp    $0x20,%al
f010139d:	74 f6                	je     f0101395 <strtol+0x1a>
f010139f:	3c 09                	cmp    $0x9,%al
f01013a1:	74 f2                	je     f0101395 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f01013a3:	3c 2b                	cmp    $0x2b,%al
f01013a5:	75 0c                	jne    f01013b3 <strtol+0x38>
		s++;
f01013a7:	83 c2 01             	add    $0x1,%edx
f01013aa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013b1:	eb 15                	jmp    f01013c8 <strtol+0x4d>
	else if (*s == '-')
f01013b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01013ba:	3c 2d                	cmp    $0x2d,%al
f01013bc:	75 0a                	jne    f01013c8 <strtol+0x4d>
		s++, neg = 1;
f01013be:	83 c2 01             	add    $0x1,%edx
f01013c1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013c8:	85 db                	test   %ebx,%ebx
f01013ca:	0f 94 c0             	sete   %al
f01013cd:	74 05                	je     f01013d4 <strtol+0x59>
f01013cf:	83 fb 10             	cmp    $0x10,%ebx
f01013d2:	75 18                	jne    f01013ec <strtol+0x71>
f01013d4:	80 3a 30             	cmpb   $0x30,(%edx)
f01013d7:	75 13                	jne    f01013ec <strtol+0x71>
f01013d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01013dd:	8d 76 00             	lea    0x0(%esi),%esi
f01013e0:	75 0a                	jne    f01013ec <strtol+0x71>
		s += 2, base = 16;
f01013e2:	83 c2 02             	add    $0x2,%edx
f01013e5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01013ea:	eb 15                	jmp    f0101401 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01013ec:	84 c0                	test   %al,%al
f01013ee:	66 90                	xchg   %ax,%ax
f01013f0:	74 0f                	je     f0101401 <strtol+0x86>
f01013f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01013f7:	80 3a 30             	cmpb   $0x30,(%edx)
f01013fa:	75 05                	jne    f0101401 <strtol+0x86>
		s++, base = 8;
f01013fc:	83 c2 01             	add    $0x1,%edx
f01013ff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101401:	b8 00 00 00 00       	mov    $0x0,%eax
f0101406:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101408:	0f b6 0a             	movzbl (%edx),%ecx
f010140b:	89 cf                	mov    %ecx,%edi
f010140d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101410:	80 fb 09             	cmp    $0x9,%bl
f0101413:	77 08                	ja     f010141d <strtol+0xa2>
			dig = *s - '0';
f0101415:	0f be c9             	movsbl %cl,%ecx
f0101418:	83 e9 30             	sub    $0x30,%ecx
f010141b:	eb 1e                	jmp    f010143b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010141d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101420:	80 fb 19             	cmp    $0x19,%bl
f0101423:	77 08                	ja     f010142d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0101425:	0f be c9             	movsbl %cl,%ecx
f0101428:	83 e9 57             	sub    $0x57,%ecx
f010142b:	eb 0e                	jmp    f010143b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f010142d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101430:	80 fb 19             	cmp    $0x19,%bl
f0101433:	77 15                	ja     f010144a <strtol+0xcf>
			dig = *s - 'A' + 10;
f0101435:	0f be c9             	movsbl %cl,%ecx
f0101438:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010143b:	39 f1                	cmp    %esi,%ecx
f010143d:	7d 0b                	jge    f010144a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f010143f:	83 c2 01             	add    $0x1,%edx
f0101442:	0f af c6             	imul   %esi,%eax
f0101445:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101448:	eb be                	jmp    f0101408 <strtol+0x8d>
f010144a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010144c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101450:	74 05                	je     f0101457 <strtol+0xdc>
		*endptr = (char *) s;
f0101452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101455:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101457:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010145b:	74 04                	je     f0101461 <strtol+0xe6>
f010145d:	89 c8                	mov    %ecx,%eax
f010145f:	f7 d8                	neg    %eax
}
f0101461:	83 c4 04             	add    $0x4,%esp
f0101464:	5b                   	pop    %ebx
f0101465:	5e                   	pop    %esi
f0101466:	5f                   	pop    %edi
f0101467:	5d                   	pop    %ebp
f0101468:	c3                   	ret    
f0101469:	00 00                	add    %al,(%eax)
f010146b:	00 00                	add    %al,(%eax)
f010146d:	00 00                	add    %al,(%eax)
	...

f0101470 <__udivdi3>:
f0101470:	55                   	push   %ebp
f0101471:	89 e5                	mov    %esp,%ebp
f0101473:	57                   	push   %edi
f0101474:	56                   	push   %esi
f0101475:	83 ec 10             	sub    $0x10,%esp
f0101478:	8b 45 14             	mov    0x14(%ebp),%eax
f010147b:	8b 55 08             	mov    0x8(%ebp),%edx
f010147e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101481:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101484:	85 c0                	test   %eax,%eax
f0101486:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101489:	75 35                	jne    f01014c0 <__udivdi3+0x50>
f010148b:	39 fe                	cmp    %edi,%esi
f010148d:	77 61                	ja     f01014f0 <__udivdi3+0x80>
f010148f:	85 f6                	test   %esi,%esi
f0101491:	75 0b                	jne    f010149e <__udivdi3+0x2e>
f0101493:	b8 01 00 00 00       	mov    $0x1,%eax
f0101498:	31 d2                	xor    %edx,%edx
f010149a:	f7 f6                	div    %esi
f010149c:	89 c6                	mov    %eax,%esi
f010149e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01014a1:	31 d2                	xor    %edx,%edx
f01014a3:	89 f8                	mov    %edi,%eax
f01014a5:	f7 f6                	div    %esi
f01014a7:	89 c7                	mov    %eax,%edi
f01014a9:	89 c8                	mov    %ecx,%eax
f01014ab:	f7 f6                	div    %esi
f01014ad:	89 c1                	mov    %eax,%ecx
f01014af:	89 fa                	mov    %edi,%edx
f01014b1:	89 c8                	mov    %ecx,%eax
f01014b3:	83 c4 10             	add    $0x10,%esp
f01014b6:	5e                   	pop    %esi
f01014b7:	5f                   	pop    %edi
f01014b8:	5d                   	pop    %ebp
f01014b9:	c3                   	ret    
f01014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01014c0:	39 f8                	cmp    %edi,%eax
f01014c2:	77 1c                	ja     f01014e0 <__udivdi3+0x70>
f01014c4:	0f bd d0             	bsr    %eax,%edx
f01014c7:	83 f2 1f             	xor    $0x1f,%edx
f01014ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01014cd:	75 39                	jne    f0101508 <__udivdi3+0x98>
f01014cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01014d2:	0f 86 a0 00 00 00    	jbe    f0101578 <__udivdi3+0x108>
f01014d8:	39 f8                	cmp    %edi,%eax
f01014da:	0f 82 98 00 00 00    	jb     f0101578 <__udivdi3+0x108>
f01014e0:	31 ff                	xor    %edi,%edi
f01014e2:	31 c9                	xor    %ecx,%ecx
f01014e4:	89 c8                	mov    %ecx,%eax
f01014e6:	89 fa                	mov    %edi,%edx
f01014e8:	83 c4 10             	add    $0x10,%esp
f01014eb:	5e                   	pop    %esi
f01014ec:	5f                   	pop    %edi
f01014ed:	5d                   	pop    %ebp
f01014ee:	c3                   	ret    
f01014ef:	90                   	nop
f01014f0:	89 d1                	mov    %edx,%ecx
f01014f2:	89 fa                	mov    %edi,%edx
f01014f4:	89 c8                	mov    %ecx,%eax
f01014f6:	31 ff                	xor    %edi,%edi
f01014f8:	f7 f6                	div    %esi
f01014fa:	89 c1                	mov    %eax,%ecx
f01014fc:	89 fa                	mov    %edi,%edx
f01014fe:	89 c8                	mov    %ecx,%eax
f0101500:	83 c4 10             	add    $0x10,%esp
f0101503:	5e                   	pop    %esi
f0101504:	5f                   	pop    %edi
f0101505:	5d                   	pop    %ebp
f0101506:	c3                   	ret    
f0101507:	90                   	nop
f0101508:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010150c:	89 f2                	mov    %esi,%edx
f010150e:	d3 e0                	shl    %cl,%eax
f0101510:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101513:	b8 20 00 00 00       	mov    $0x20,%eax
f0101518:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010151b:	89 c1                	mov    %eax,%ecx
f010151d:	d3 ea                	shr    %cl,%edx
f010151f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101523:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101526:	d3 e6                	shl    %cl,%esi
f0101528:	89 c1                	mov    %eax,%ecx
f010152a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010152d:	89 fe                	mov    %edi,%esi
f010152f:	d3 ee                	shr    %cl,%esi
f0101531:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101535:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101538:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010153b:	d3 e7                	shl    %cl,%edi
f010153d:	89 c1                	mov    %eax,%ecx
f010153f:	d3 ea                	shr    %cl,%edx
f0101541:	09 d7                	or     %edx,%edi
f0101543:	89 f2                	mov    %esi,%edx
f0101545:	89 f8                	mov    %edi,%eax
f0101547:	f7 75 ec             	divl   -0x14(%ebp)
f010154a:	89 d6                	mov    %edx,%esi
f010154c:	89 c7                	mov    %eax,%edi
f010154e:	f7 65 e8             	mull   -0x18(%ebp)
f0101551:	39 d6                	cmp    %edx,%esi
f0101553:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101556:	72 30                	jb     f0101588 <__udivdi3+0x118>
f0101558:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010155b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010155f:	d3 e2                	shl    %cl,%edx
f0101561:	39 c2                	cmp    %eax,%edx
f0101563:	73 05                	jae    f010156a <__udivdi3+0xfa>
f0101565:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101568:	74 1e                	je     f0101588 <__udivdi3+0x118>
f010156a:	89 f9                	mov    %edi,%ecx
f010156c:	31 ff                	xor    %edi,%edi
f010156e:	e9 71 ff ff ff       	jmp    f01014e4 <__udivdi3+0x74>
f0101573:	90                   	nop
f0101574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101578:	31 ff                	xor    %edi,%edi
f010157a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010157f:	e9 60 ff ff ff       	jmp    f01014e4 <__udivdi3+0x74>
f0101584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101588:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010158b:	31 ff                	xor    %edi,%edi
f010158d:	89 c8                	mov    %ecx,%eax
f010158f:	89 fa                	mov    %edi,%edx
f0101591:	83 c4 10             	add    $0x10,%esp
f0101594:	5e                   	pop    %esi
f0101595:	5f                   	pop    %edi
f0101596:	5d                   	pop    %ebp
f0101597:	c3                   	ret    
	...

f01015a0 <__umoddi3>:
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	57                   	push   %edi
f01015a4:	56                   	push   %esi
f01015a5:	83 ec 20             	sub    $0x20,%esp
f01015a8:	8b 55 14             	mov    0x14(%ebp),%edx
f01015ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015ae:	8b 7d 10             	mov    0x10(%ebp),%edi
f01015b1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015b4:	85 d2                	test   %edx,%edx
f01015b6:	89 c8                	mov    %ecx,%eax
f01015b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01015bb:	75 13                	jne    f01015d0 <__umoddi3+0x30>
f01015bd:	39 f7                	cmp    %esi,%edi
f01015bf:	76 3f                	jbe    f0101600 <__umoddi3+0x60>
f01015c1:	89 f2                	mov    %esi,%edx
f01015c3:	f7 f7                	div    %edi
f01015c5:	89 d0                	mov    %edx,%eax
f01015c7:	31 d2                	xor    %edx,%edx
f01015c9:	83 c4 20             	add    $0x20,%esp
f01015cc:	5e                   	pop    %esi
f01015cd:	5f                   	pop    %edi
f01015ce:	5d                   	pop    %ebp
f01015cf:	c3                   	ret    
f01015d0:	39 f2                	cmp    %esi,%edx
f01015d2:	77 4c                	ja     f0101620 <__umoddi3+0x80>
f01015d4:	0f bd ca             	bsr    %edx,%ecx
f01015d7:	83 f1 1f             	xor    $0x1f,%ecx
f01015da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015dd:	75 51                	jne    f0101630 <__umoddi3+0x90>
f01015df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f01015e2:	0f 87 e0 00 00 00    	ja     f01016c8 <__umoddi3+0x128>
f01015e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015eb:	29 f8                	sub    %edi,%eax
f01015ed:	19 d6                	sbb    %edx,%esi
f01015ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015f5:	89 f2                	mov    %esi,%edx
f01015f7:	83 c4 20             	add    $0x20,%esp
f01015fa:	5e                   	pop    %esi
f01015fb:	5f                   	pop    %edi
f01015fc:	5d                   	pop    %ebp
f01015fd:	c3                   	ret    
f01015fe:	66 90                	xchg   %ax,%ax
f0101600:	85 ff                	test   %edi,%edi
f0101602:	75 0b                	jne    f010160f <__umoddi3+0x6f>
f0101604:	b8 01 00 00 00       	mov    $0x1,%eax
f0101609:	31 d2                	xor    %edx,%edx
f010160b:	f7 f7                	div    %edi
f010160d:	89 c7                	mov    %eax,%edi
f010160f:	89 f0                	mov    %esi,%eax
f0101611:	31 d2                	xor    %edx,%edx
f0101613:	f7 f7                	div    %edi
f0101615:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101618:	f7 f7                	div    %edi
f010161a:	eb a9                	jmp    f01015c5 <__umoddi3+0x25>
f010161c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101620:	89 c8                	mov    %ecx,%eax
f0101622:	89 f2                	mov    %esi,%edx
f0101624:	83 c4 20             	add    $0x20,%esp
f0101627:	5e                   	pop    %esi
f0101628:	5f                   	pop    %edi
f0101629:	5d                   	pop    %ebp
f010162a:	c3                   	ret    
f010162b:	90                   	nop
f010162c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101630:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101634:	d3 e2                	shl    %cl,%edx
f0101636:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101639:	ba 20 00 00 00       	mov    $0x20,%edx
f010163e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101641:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101644:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101648:	89 fa                	mov    %edi,%edx
f010164a:	d3 ea                	shr    %cl,%edx
f010164c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101650:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101653:	d3 e7                	shl    %cl,%edi
f0101655:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101659:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010165c:	89 f2                	mov    %esi,%edx
f010165e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101661:	89 c7                	mov    %eax,%edi
f0101663:	d3 ea                	shr    %cl,%edx
f0101665:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101669:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010166c:	89 c2                	mov    %eax,%edx
f010166e:	d3 e6                	shl    %cl,%esi
f0101670:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101674:	d3 ea                	shr    %cl,%edx
f0101676:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010167a:	09 d6                	or     %edx,%esi
f010167c:	89 f0                	mov    %esi,%eax
f010167e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101681:	d3 e7                	shl    %cl,%edi
f0101683:	89 f2                	mov    %esi,%edx
f0101685:	f7 75 f4             	divl   -0xc(%ebp)
f0101688:	89 d6                	mov    %edx,%esi
f010168a:	f7 65 e8             	mull   -0x18(%ebp)
f010168d:	39 d6                	cmp    %edx,%esi
f010168f:	72 2b                	jb     f01016bc <__umoddi3+0x11c>
f0101691:	39 c7                	cmp    %eax,%edi
f0101693:	72 23                	jb     f01016b8 <__umoddi3+0x118>
f0101695:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101699:	29 c7                	sub    %eax,%edi
f010169b:	19 d6                	sbb    %edx,%esi
f010169d:	89 f0                	mov    %esi,%eax
f010169f:	89 f2                	mov    %esi,%edx
f01016a1:	d3 ef                	shr    %cl,%edi
f01016a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01016a7:	d3 e0                	shl    %cl,%eax
f01016a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01016ad:	09 f8                	or     %edi,%eax
f01016af:	d3 ea                	shr    %cl,%edx
f01016b1:	83 c4 20             	add    $0x20,%esp
f01016b4:	5e                   	pop    %esi
f01016b5:	5f                   	pop    %edi
f01016b6:	5d                   	pop    %ebp
f01016b7:	c3                   	ret    
f01016b8:	39 d6                	cmp    %edx,%esi
f01016ba:	75 d9                	jne    f0101695 <__umoddi3+0xf5>
f01016bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01016bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01016c2:	eb d1                	jmp    f0101695 <__umoddi3+0xf5>
f01016c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016c8:	39 f2                	cmp    %esi,%edx
f01016ca:	0f 82 18 ff ff ff    	jb     f01015e8 <__umoddi3+0x48>
f01016d0:	e9 1d ff ff ff       	jmp    f01015f2 <__umoddi3+0x52>
