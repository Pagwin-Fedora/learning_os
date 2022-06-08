// GCC provides these header files automatically
// They give us access to useful things like fixed-width types
#include <stddef.h>
#include <stdint.h>
// First, let's do some basic checks to make sure we are using our x86-elf cross-compiler correctly
#if defined(__linux__)
	#error "This code must be compiled with a cross-compiler"
#elif !defined(__i386__)
	#error "This code must be compiled with an x86-elf compiler"
#endif
 
void scroll(uint8_t num);

// This is the x86's VGA textmode buffer. To display text, we write data to this memory location
volatile uint16_t* vga_buffer = (uint16_t*)0xB8000;
// By default, the VGA textmode buffer has a size of 80x25 characters
const int VGA_COLS = 80;
const int VGA_ROWS = 25;
 
// We start displaying text in the top-left of the screen (column = 0, row = 0)
int term_col = 0;
int term_row = 0;
uint8_t term_color = 0x0F; // Black background, White foreground
 
// This function initiates the terminal by clearing it
void term_init()
{
	// Clear the textmode buffer
	for (int col = 0; col < VGA_COLS; col ++)
	{
		for (int row = 0; row < VGA_ROWS; row ++)
		{
			// The VGA textmode buffer has size (VGA_COLS * VGA_ROWS).
			// Given this, we find an index into the buffer for our character
			const size_t index = (VGA_COLS * row) + col;
			// Entries in the VGA buffer take the binary form BBBBFFFFCCCCCCCC, where:
			// - B is the background color
			// - F is the foreground color
			// - C is the ASCII character
			vga_buffer[index] = ((uint16_t)term_color << 8) | ' '; // Set the character to blank (a space character)
		}
	}
}
 
// This function places a single character onto the screen
void term_putc(char c)
{
	// Remember - we don't want to display ALL characters!
	switch (c)
	{
	case '\n': // Newline characters should return the column to 0, and increment the row
		{
			term_col = 0;
			term_row ++;
			break;
		}
 
	default: // Normal characters just get displayed and then increment the column
		{
			const size_t index = (VGA_COLS * term_row) + term_col; // Like before, calculate the buffer index
			vga_buffer[index] = ((uint16_t)term_color << 8) | c;
			term_col ++;
			break;
		}
	}
 
	// What happens if we get past the last column? We need to reset the column to 0, and increment the row to get to a new line
	if (term_col >= VGA_COLS)
	{
		term_col = 0;
		term_row ++;
	}
 
	// What happens if we get past the last row? We need to reset both column and row to 0 in order to loop back to the top of the screen
	if (term_row >= VGA_ROWS)
	{
		scroll(1);
		term_row = 0;
	}
}
void memcpy(char* dest, char* src, size_t size){
    for(int i = 0;i<size;i++){
	dest[i] = src[i];
    }
}
void scroll(uint8_t num){
    for(int i = 0;i<80-num;i++) memcpy(vga_buffer+i*VGA_COLS, vga_buffer+(num+i)*VGA_COLS, VGA_COLS*2);
}
// This function prints an entire string onto the screen
void term_print(const char* str)
{
	for (size_t i = 0; str[i] != '\0'; i ++) // Keep placing characters until we hit the null-terminating character ('\0')
		term_putc(str[i]);
}
 
void term_hex_disp(long val){
    char store[16];
    const char* lookup_table = "0123456789abcdef";
    term_print("0x");
    int i = 0;
    for(int curr = val & 0xf; val != 0; val >>= 4, curr = val & 0xf,i++){
	store[i] = lookup_table[curr];
    }
    if(i==0) term_putc('0');
    for(int k = i-1;k>=0;k--)term_putc(store[k]);
    term_putc('\n');
}
void term_bin_disp(long val){
    term_print("0b");
    unsigned long inv = 0;
    for(int i = 0;i<32;i++){
	inv |= val & 1;
	val >>= 1;
	inv <<= 1;
    }
    for(int i = 0;i<32;i++){
	if(inv & 1) term_putc('1');
	else term_putc('0');
	inv >>= 1;
    }
    term_putc('\n');
}
// This is our kernel's main function
void kernel_main(long multiboot_val, long* boot_info)
{
	// We're here! Let's initiate the terminal and display a message to show we got here.
 
	// Initiate terminal
	term_init();
 
	// Display some messages
	term_print("Hello, World!\n");
	term_print("Welcome to the kernel.\n");
	term_hex_disp(0xfe);
	term_hex_disp(multiboot_val);
	term_hex_disp(boot_info);
	//https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Boot-information-format
	int flags = boot_info[0];
	int mem_lower = boot_info[1];
	int mem_upper = boot_info[2];
	int boot_device = boot_info[3];
	term_bin_disp(flags);
	term_hex_disp(mem_lower);
	term_hex_disp(mem_upper);
	//term_hex_disp(boot_device);
	while(1)for(int i = 0;i<27;i++){
	    term_putc('a'+i);
	    term_putc('\n');
	}
}
