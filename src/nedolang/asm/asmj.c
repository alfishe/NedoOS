//// стандартные ветки

      case _CMDINCLUDE: {
        _inclfile[_ninclfiles] = _fin;
        INC _ninclfiles;
        _lenfn = 0;
        i = 0;
        readfin(); //tab
        readfin(); //"
        //readfin(); //TOK_WRSTR
        _token = readfin(); //TOK_TEXT
        inclfnloop:
          asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
          IF ((_token==+_TOKENDTEXT)||_waseof) goto inclfnq; //BREAK;
          //IF (_waseof) BREAK; //на всякий случай
          _lenfn = stradd(_fn, _lenfn, (CHAR)_token); //asmbyte(_prefixedtoken);
          IF ((CHAR)_token == '.') i = _lenfn;
          goto inclfnloop;
        inclfnq:
   //_lenfn = strjoineol(_fn, 0, _fn, '.'); //terminator is not copied
   //_lenfn = stradd(_fn, _lenfn, '.');
   _lenfn = i; //after last dot
   _lenfn = stradd(_fn, _lenfn, (CHAR)((BYTE)_fn[_lenfn]&0xdf));
   _lenfn = stradd(_fn, _lenfn, '_');
        _fn[_lenfn] = '\0';
        readfin(); //"
        _fin = nfopen(_fn, "rb");
   IF (_fin != (PBYTE)0) {
       goto loop;
///сюда попадём в конце файла
      inclq:
        fclose(_fin);
   }ELSE {
     errstr("no "); errstr(_fn); enderr();
   };
        DEC _ninclfiles;
        _fin = _inclfile[_ninclfiles];
        _waseof = +FALSE;
        goto loop;
      }

      case _CMDINCBIN: {
        _lenfn = 0;
        readfin(); //tab
        readfin(); //"
        //readfin(); //TOK_WRSTR
        _token = readfin(); //TOK_TEXT
        incbfnloop:
          asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
          IF ((_token==+_TOKENDTEXT)||_waseof) goto incbfnq; //BREAK;
          //IF (_waseof) BREAK; //на всякий случай
          _lenfn = stradd(_fn, _lenfn, (CHAR)_token); //asmbyte(_prefixedtoken);
          goto incbfnloop;
        incbfnq:
        _fn[_lenfn] = '\0';
        readfin(); //"
        _fincb = nfopen(_fn, "rb");
   IF (_fincb != (PBYTE)0) {
        incbloop:
          _token = readf(_fincb);
          IF (_waseof) goto incbq; //BREAK;
          asmbyte(_token);
          goto incbloop;
        incbq:
        fclose(_fincb);
   }ELSE {
     errstr("no "); errstr(_fn); enderr();
   };
        _waseof = +FALSE;
        goto loop;
      }

      //case _CMDREADSTATE: {asmreadstate(); goto loop;}
      case _CMDLABEL: {
        _isaddr = 0x00;
        _curdir = _token;
        asmdir_label(); //нельзя сейчас переопределять! иначе нельзя label=label+1
        goto loop;
      }

      case _CMDEXPORT: /**{
        _lenfn = 0;
        readfin(); //tab
        readfin(); //TOK_LABEL
        _token = readfin(); //TOK_TEXT
        getexploop:
          asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
          IF ((_token==+_TOKENDTEXT)||_waseof) goto getexpq; //BREAK;
          //IF (_waseof) BREAK; //на всякий случай
          _lenfn = stradd(_fn, _lenfn, (CHAR)_token); //asmbyte(_prefixedtoken);
          goto getexploop;
        getexpq:
        _fn[_lenfn] = '\0';
        goto loop;
      }*/

      case _CMDORG:
      case _CMDDISP:
      case _CMDDB:
      case _CMDDW:
      case _CMDDL:
      case _CMDDS:
      case _CMDALIGN:

        {_isaddr = 0x00; _curdir=_token; goto loop;}

      case _FMTREEQU: {
        asmfmt_reequ();
        goto loop;
      }
      case _FMTCMD: {
        IF (_curdir == +_CMDLABEL) {
          IF (_labelchanged) {
            errstr("redef "); errstr((PCHAR)_curlabeltext); enderr();
          };
        }ELSE IF (_curdir == +_CMDORG) {
          asmemitblock();
          _curaddr = +(UINT)asmpopvalue();
          _curbegin = _curaddr;
#ifdef TARGET_THUMB
        }ELSE IF (_curdir == +_CMDALIGN) {
          //i = -(_curaddr+_curshift) & ((UINT)asmpopvalue()-1); //no bias "+1"
          i = -(_curaddr+_curshift-_BIAS) & ((UINT)asmpopvalue()-1); //bias (thumb)
          i = i;
          WHILE (i!=0) {
            asmbyte(0x00);
            DEC i;
          };
#endif
        }ELSE IF (_curdir == +_CMDDISP) {
          _curshift = +(UINT)asmpopvalue() - _curaddr; //todo вложенно
        }ELSE IF (_curdir == +_CMDENT) {
          _curshift = 0; //todo вложенно
        }ELSE IF (_curdir == +_CMDDB) {
        }ELSE IF (_curdir == +_CMDDW) {
        }ELSE IF (_curdir == +_CMDDL) {
        }ELSE IF (_curdir == +_CMDDS) {
          IF (_nvalues==0x02) {_token = +(BYTE)asmpopvalue();
          }ELSE _token=0x00;
          i = +(UINT)asmpopvalue();
          WHILE (i != 0) {
            asmbyte(_token);
            DEC i;
          };
          //fwrite(+(PBYTE)&zeros, 1, i, _fout);
          //_curaddr = _curaddr + i;
          //todo while для ds группы байт, но трудно будет достать из стека
        }ELSE IF (_curdir == +_CMDEXPORT) {
          i = +(UINT)asmpopvalue();
          IF (_asms) { //сгенерировать <_curlabeltext>=<?modname?>+<i-?base?>
            decltoken(+_CMDLABEL);
            decltoken(+_TOKTEXT);
            fputs((PCHAR)_curlabeltext, _fdecl);
            decltoken(+_TOKENDTEXT);
            decltoken(+_TOKEQUAL/**'='*/);
            decltoken(+_TOKLABEL);
            decltoken(+_TOKTEXT);
            decltoken((BYTE)'_'); //todo <modname>?
            decltoken(+_TOKENDTEXT);
            decltoken(+_TOKPLUS/**'+'*/);
            decltoken(+_TOKNUM);
            decltoken(+_TOKTEXT);
            emitn(i-_curbegin/**_BASEADDR*/);
            fputs((PCHAR)_nbuf, _fdecl); //+_TOKENDTEXT==0
            decltoken(+_TOKENDTEXT);
            decltoken(+_OPADD);
            decltoken(+_FMTREEQU);
            decltoken(+_TOKEOL);
          }; //
        ;;}ELSE {err(+(CHAR)_token); enderr();
        };
        goto loop;
      }

      case _OPPUSH0: {asmpushvalue(0L); /**readfin();*/ goto loop;}

      case _OPADD:   {                           asmpushvalue(asmpopvalue()+asmpopvalue()); goto loop;}
      case _OPSUB:   {tempvalue=asmpopvalue();   asmpushvalue(asmpopvalue()-tempvalue); goto loop;}
      case _OPMUL:   {                           asmpushvalue(asmpopvalue()*asmpopvalue()); _isaddr = 0x00; goto loop;}
      case _OPDIV:   {
        tempvalue=asmpopvalue();
        {
        ;;IF (tempvalue!=0L)
          asmpushvalue(asmpopvalue()/tempvalue);
        }
        goto loop;
      }
      case _OPAND:   {                           asmpushvalue(asmpopvalue()&asmpopvalue()); goto loop;}
      case _OPOR:    {                           asmpushvalue(asmpopvalue()|asmpopvalue()); goto loop;}
      case _OPXOR:   {                           asmpushvalue(asmpopvalue()^asmpopvalue()); goto loop;}
      case _OPSHL:   {tempvalue=asmpopvalue();   asmpushvalue(asmpopvalue()<<tempvalue); goto loop;}
      case _OPSHR:   {tempvalue=asmpopvalue();   asmpushvalue(asmpopvalue()>>tempvalue); goto loop;}
      //case _OPEQ:    {                           asmpushbool((asmpopvalue()==asmpopvalue())); goto loop;} //иначе нельзя в лог.выражениях использовать константу TRUE (-1 или 1 непредсказуемо)
      //case _OPNOTEQ: {                           asmpushbool((asmpopvalue()!=asmpopvalue())); goto loop;}
      //case _OPLESS:  {tempvalue=asmpopvalue();   asmpushbool(+(UINT)asmpopvalue() <  +(UINT)tempvalue); goto loop;}
      //case _OPLESSEQ:{tempvalue=asmpopvalue();   asmpushbool(+(UINT)asmpopvalue() <= +(UINT)tempvalue); goto loop;}
      //case _OPMORE:  {tempvalue=asmpopvalue();   asmpushbool(+(UINT)asmpopvalue() >  +(UINT)tempvalue); goto loop;}
      //case _OPMOREEQ:{tempvalue=asmpopvalue();   asmpushbool(+(UINT)asmpopvalue() >= +(UINT)tempvalue); goto loop;}
      case _OPINV:   {                           asmpushvalue(~asmpopvalue()); goto loop;} //==invbool
      //case _OPPEEK:{/**asmpopvalue();*/ errstr("PEEK not supported"); enderr(); goto loop;}

      case _TOKEOL: {INC _curlnbeg; goto loop;}
      case _TOKEOF: {IF (_ninclfiles==0x00) {goto endloop;/**exit!!!*/}ELSE goto inclq;} //todo break

      case _TOKPLUS/**'+'*/:
      case _TOKMINUS/**'-'*/:
      case _TOKSTAR/**'*'*/:
      case _TOKSLASH/**'/'*/:
      case _TOKLESS/**'<'*/:
      case _TOKMORE/**'>'*/:
      case _TOKEQUAL/**'='*/:
      case _TOKAND/**'&'*/:
      case _TOKPIPE/**'|'*/:
      case _TOKCARON/**'^'*/:
      case _TOKTILDE/**'~'*/:
      case _TOKEXCL/**'!'*/:
      case _TOKPRIMESYM:
      case _TOKDBLQUOTESYM:
      case _TOKOPEN:
      case _TOKOPENSQ:
      case _TOKCLOSE:
      case _TOKCLOSESQ:
      case _TOKCOLON:
      case _TOKDIRECT:
      case _TOKSPC0:
      case _TOKSPC1:
      case _TOKSPC2:
      case _TOKSPC3:
      case _TOKSPC4:
      case _TOKSPC5:
      case _TOKSPC6:
      case _TOKSPC7:
      case _TOKSPC8:

        {goto loop;}

      case _TOKPRIME: {
        readfin(); //text
        asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
        asmpushvalue(+(LONG)_prefixedtoken);
        readfin(); //endtext
        readfin(); //закрывающий апостроф
        goto loop;
      }
      case _TOKDOLLAR: {asmpushvalue(+(LONG)(_curaddr+_curshift)); _isaddr = +_ASMLABEL_ISADDR; goto loop;}

      case _TOKCOMMENT: { /**skip cmt text*/
        REPEAT {
          _token=readfin();
        }UNTIL ((_token==+_TOKENDCOMMENT)||_waseof); /**токен, который не встречается в текстах*/
        goto loop;
      }
      case _TOKNUM: {
        readfin(); //TOK_TEXT
        _token = readfin(); //first digit or prefix (0x, 0b, 0)
        tempvalue = 0L;
        scale = 10;
        IF (+(CHAR)_token=='0'){
          _token=readfin(); //'x' (hex), 'b' (bin), 'o' (oct), else oct with error
          IF       (+(CHAR)_token=='x') {
            scale=16;
            rdbase:
            IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF (+(CHAR)_token=='b') {
            scale=2;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF (+(CHAR)_token=='o') {
            scale=8;
            goto rdbase; //IF (_token!=+_TOKENDTEXT) _token=readfin(); //first digit
          }ELSE IF (+(CHAR)_token=='L') { //0L
          }ELSE IF (_token!=+_TOKENDTEXT) {
            scale=8;
            errstr("Use 0o oct"); enderr();
          };
        };
        IF (_token!=+_TOKENDTEXT) {
          rdnumloop: //WHILE (+TRUE)
          { //первая цифра числа уже прочитана
            IF ((_token==+_TOKENDTEXT)||_waseof) goto rdnumend; //BREAK;
            //IF (_waseof) goto rdnumend; //BREAK; //на всякий случай
            IF (+(CHAR)_token!='L') {
              IF (_token>=+(BYTE)'a') {_token = _token - 0x27/**- +(BYTE)'a' + 0x0a + +(BYTE)'0'*/; //todo error
              }ELSE IF (_token>=+(BYTE)'A') {_token = _token - 0x07/**- +(BYTE)'A' + 0x0a + +(BYTE)'0'*/; //todo error
              };//ELSE _token = _token - +(BYTE)'0';
              tempvalue = (LONG)scale*tempvalue + (LONG)(_token - +(BYTE)'0');
            };
            _token = readfin();
            goto rdnumloop;
          };
          rdnumend:;
        };
        asmpushvalue(tempvalue);
        goto loop;
      }
      case _TOKLABEL: { //найти и прочитать метку
        readlabel();
        findlabel(_curlabeltext);
        asmpushvalue(getlabel());
        goto loop;
      }
      case _ERR: {
        _token=readfin();
        IF       (_token==+_ERRCMD) {errstr("badcmd \""); goto err;
        }ELSE IF (_token==+_ERREXPR) {errstr("badexpr \""); goto err;
        }ELSE IF (_token==+_ERRCOMMA) {errstr("need \',\' \""); goto err;
        }ELSE IF (_token==+_ERRPAR) {errstr("badpar \""); goto err;
        }ELSE IF (_token==+_ERROPEN) {errstr("need \'(\'/\'[\' \""); goto err;
        }ELSE IF (_token==+_ERRCLOSE) {errstr("need \')\'/\']\' \""); goto err;
        }ELSE IF (_token==+_ERRREG) {errstr("badreg \"");
          err:
          asmerrtext(); goto loop;
        };
      }

      case _OPWRSTR: { //до него quotesymbol
        //записать строку внутри text...endtext
        _token = readfin(); //TOK_TEXT
        writestringloop:
          asmreadprefixed(); //читаем через readfin, раскрываем \n \r \t \0
          IF ((_token==+_TOKENDTEXT)||_waseof) goto loop; //BREAK;
          //IF (_waseof) BREAK; //на всякий случай
          asmbyte(_prefixedtoken);
          goto writestringloop;
      }
      case _OPWRVAL: { //стоит после выражения
        IF       (_curdir==+_CMDDB) {asmbytepopvalue();
        }ELSE IF (_curdir==+_CMDDW) {asmwordpopvalue();
        }ELSE IF (_curdir==+_CMDDL) {asmlong(+(LONG)asmpopvalue());
        };
        goto loop;
      }

      //case _TOKTEXT: {errstr("TEXT"); enderr(); /**format error*/ goto loop;}
      //case _TOKENDTEXT: {errstr("ENDTEXT"); enderr(); /**format error*/ goto loop;}
      //case _TOKENDCOMMENT: {errstr("ENDCOMMENT"); enderr(); /**format error*/ goto loop;}
      //case _TOKENDERR: {errstr("ENDERR"); enderr(); goto loop;}
