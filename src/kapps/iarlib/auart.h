void uart_init(unsigned char divisor);
void uart_write(unsigned char data);
void uart_startrts(void);
void uart_stoprts(void);
void uart_flashrts(void);
unsigned char uart_read(void);
unsigned char uart_queue(void);
void uart_delay10k(void);
