void sendcommand(char commandline[])
{
  int pos = 0;
  while (commandline[pos] != '\0')
  {
    uart_write(commandline[pos]);
    pos++;
	uart_delay10k();
  }
  uart_write('\r');
	uart_delay10k();
  uart_write('\n');
	uart_delay10k();

}
