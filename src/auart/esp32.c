void sendcommand(char commandline[])
{
  int pos = 0;
  while (commandline[pos] != '\0')
  {
    uart_write(commandline[pos]);
    pos++;
	uart_delayXk(12);
  }
  uart_write('\r');
	uart_delayXk(12);
  uart_write('\n');
	uart_delayXk(12);

}
