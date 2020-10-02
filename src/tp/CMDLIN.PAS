program CommandLine;
{
  COMMANDLINE PARAMETERS DEMONSTRATION PROGRAM  Version 1.00A

  This program gets parameters from the command line:

  INSTRUCTIONS
    1.  Load the TURBO compiler and compile to a .COM file
    2.  Quit the TURBO compiler and execute the program with
        parameters.  Try:

                cmdlin abc def
                cmdlin Greetings from Frank Borland!
                cmdlin

  NOTE:  For information about these functions, please refer to your
         TURBO 3.0 Reference Manual.
}


var
  i : integer;
  a : integer;
  F: file of integer{Text};

begin
  for i := 1 to ParamCount do
    writeln(ParamSTR(i));
  assign(F,'pastest.dat');
  Rewrite(F);
  a := 5;
  write(F,a);
  Close(F);
end.

