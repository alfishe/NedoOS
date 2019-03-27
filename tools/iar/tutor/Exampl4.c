void recursive(int value)
{
  int my_int;
  my_int=1;
  value-=my_int;
  if (value>10) recursive(value);
}
void main(void)
{
  recursive(50);
}
