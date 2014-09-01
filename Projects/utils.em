/* Utils.em - a small collection of useful editing macros */



/*-------------------------------------------------------------------------
	I N S E R T   H E A D E R

	Inserts a comment header block at the top of the current function.
	This actually works on any type of symbol, not just functions.

	To use this, define an environment variable "MYNAME" and set it
	to your email name.  eg. set MYNAME=raygr
-------------------------------------------------------------------------*/
macro InsertHeader()
{
	// Get the owner's name from the environment variable: MYNAME.
	// If the variable doesn't exist, then the owner field is skipped.
	szMyName = getenv(MYNAME)

	// Get a handle to the current file buffer and the name
	// and location of the current symbol where the cursor is.
	hbuf = GetCurrentBuf()
	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)

	// begin assembling the title string
	sz = "/*   "

	/* convert symbol name to T E X T   L I K E   T H I S */
	cch = strlen(szFunc)
	ich = 0
	while (ich < cch)
		{
		ch = szFunc[ich]
		if (ich > 0)
			if (isupper(ch))
				sz = cat(sz, "   ")
			else
				sz = cat(sz, " ")
		sz = Cat(sz, toupper(ch))
		ich = ich + 1
		}

	sz = Cat(sz, "   */")
	InsBufLine(hbuf, ln, sz)
	InsBufLine(hbuf, ln+1, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	if (strlen(szMyName) > 0)
		{
		InsBufLine(hbuf, ln+2, "    Owner: @szMyName@")
		InsBufLine(hbuf, ln+3, " ")
		ln = ln + 4
		}
	else
		ln = ln + 2

	InsBufLine(hbuf, ln,   "    ") // provide an indent already
	InsBufLine(hbuf, ln+1, "-------------------------------------------------------------------------*/")

	// put the insertion point inside the header comment
	SetBufIns(hbuf, ln, 4)
}


/* InsertFileHeader:

   Inserts a comment header block at the top of the current function.
   This actually works on any type of symbol, not just functions.

   To use this, define an environment variable "MYNAME" and set it
   to your email name.  eg. set MYNAME=raygr
*/

macro InsertFileHeader()
{
	szMyName = getenv(MYNAME)

	hbuf = GetCurrentBuf()

	InsBufLine(hbuf, 0, "/*-------------------------------------------------------------------------")

	/* if owner variable exists, insert Owner: name */
	InsBufLine(hbuf, 1, "    ")
	if (strlen(szMyName) > 0)
		{
		sz = "    Owner: @szMyName@"
		InsBufLine(hbuf, 2, " ")
		InsBufLine(hbuf, 3, sz)
		ln = 4
		}
	else
		ln = 2

	InsBufLine(hbuf, ln, "-------------------------------------------------------------------------*/")
}



// Inserts "Returns True .. or False..." at the current line
macro ReturnTrueOrFalse()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLineCur(hbuf)

	InsBufLine(hbuf, ln, "    Returns True if successful or False if errors.")
}



/* Inserts ifdef REVIEW around the selection */
macro IfdefReview()
{
	IfdefSz("REVIEW");
}


/* Inserts ifdef BOGUS around the selection */
macro IfdefBogus()
{
	IfdefSz("BOGUS");
}


/* Inserts ifdef NEVER around the selection */
macro IfdefNever()
{
	IfdefSz("NEVER");
}


// Ask user for ifdef condition and wrap it around current
// selection.
macro InsertIfdef()
{
	sz = Ask("Enter ifdef condition:")
	if (sz != "")
		IfdefSz(sz);
}

macro InsertCPlusPlus()
{
	IfdefSz("__cplusplus");
}


// Wrap ifdef <sz> .. endif around the current selection
macro IfdefSz(sz)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)

	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @sz@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @sz@ */")
}


// Delete the current line and appends it to the clipboard buffer
macro KillLine()
{
	hbufCur = GetCurrentBuf();
	lnCur = GetBufLnCur(hbufCur)
	hbufClip = GetBufHandle("Clipboard")
	AppendBufLine(hbufClip, GetBufLine(hbufCur, lnCur))
	DelBufLine(hbufCur, lnCur)
}


// Paste lines killed with KillLine (clipboard is emptied)
macro PasteKillLine()
{
	Paste
	EmptyBuf(GetBufHandle("Clipboard"))
}



// delete all lines in the buffer
macro EmptyBuf(hbuf)
{
	lnMax = GetBufLineCount(hbuf)
	while (lnMax > 0)
		{
		DelBufLine(hbuf, 0)
		lnMax = lnMax - 1
		}
}


// Ask the user for a symbol name, then jump to its declaration
macro JumpAnywhere()
{
	symbol = Ask("What declaration would you like to see?")
	JumpToSymbolDef(symbol)
}


// list all siblings of a user specified symbol
// A sibling is any other symbol declared in the same file.
macro OutputSiblingSymbols()
{
	symbol = Ask("What symbol would you like to list siblings for?")
	hbuf = ListAllSiblings(symbol)
	SetCurrentBuf(hbuf)
}


// Given a symbol name, open the file its declared in and
// create a new output buffer listing all of the symbols declared
// in that file.  Returns the new buffer handle.
macro ListAllSiblings(symbol)
{
	loc = GetSymbolLocation(symbol)
	if (loc == "")
		{
		msg ("@symbol@ not found.")
		stop
		}

	hbufOutput = NewBuf("Results")

	hbuf = OpenBuf(loc.file)
	if (hbuf == 0)
		{
		msg ("Can't open file.")
		stop
		}

	isymMax = GetBufSymCount(hbuf)
	isym = 0;
	while (isym < isymMax)
		{
		AppendBufLine(hbufOutput, GetBufSymName(hbuf, isym))
		isym = isym + 1
		}

	CloseBuf(hbuf)

	return hbufOutput

}

// molink_slcho_20041004 : YYMMDD ���·� ���ڸ� ��ȯ
macro get_datetime()
{
    today = GetSysTime(1);

    fdate = "0"
    fdate = cat(fdate, (today.Year - 2000));
    if (today.year < 10)
        fdate = cat(fdate, "0");

    if (today.Month < 10)
        fdate = cat(fdate,"0");

    fdate = cat(fdate, today.Month);

    if (today.Day < 10)
        fdate = cat(fdate, "0");

    fdate = cat(fdate, today.Day);

    return fdate;
}

// molink_slcho_20050512 : yxDD ���·� ���ڸ� ��ȯ
macro get_datetime_a()
{
    today = GetSysTime(1);

	//slcho.yj05 : 10�ڸ� �޿��� ǥ�Ⱑ �̻��ϰ� �Ǵ� ���� ����.
    fdate = "z";
    //slcho.yj05 : 10�ڸ� �޿��� ǥ�Ⱑ �̻��ϰ� �Ǵ� ���� ����.
    fdate = cat(fdate, CharFromAscii(96 + today.Month));

    // �Ʒ��� ���ڷ� ��¥�� �����ϴ� ���
//    fdate = "20"
//    fdate = cat(fdate, (today.Year - 2000));
//    if (today.year < 10)
//        fdate = cat(fdate, "0");

//    if (today.Month < 10)
//        fdate = cat(fdate,"0");

//    fdate = cat(fdate, today.Month);

//    if (today.Day < 10)
//        fdate = cat(fdate, "0");

    fdate = cat(fdate, today.Day);

    return fdate;
}

// molink_slcho_20050512 : YYYY.MM.DD ������ ���ڸ� ��ȯ
macro get_datetime_n()
{
    today = GetSysTime(1);

    // �Ʒ��� ���ڷ� ��¥�� �����ϴ� ���
    fdate = ""
    fdate = cat(fdate, today.Year);
    fdate = cat(fdate, ".")

    if (today.Month < 10)
        fdate = cat(fdate,"0");

    fdate = cat(fdate, today.Month);
                    fdate = cat(fdate, ".");

    if (today.Day < 10)
        fdate = cat(fdate, "0");
        fdate = cat(fdate, today.Day)

    return fdate;
}

// molink_slcho_20050512 : �̸��� ����ϴ� �κ��� ���� �и���.
macro get_userID()
{
//****************************************************
// �ּ��� ���� �̸��� �����ϴ� ��쿡�� �Ʒ� �κ��� �����ϼ���.
//****************************************************
    gUserID = "jhson"
    return gUserID
}

// molink_slcho_20050512 : user_id.yxDD ���·� prefix�� ��ȯ
macro make_prefix()
{
//    current_datetime = get_datetime_a();
    current_datetime = get_datetime_n();
    user_id = get_userID()
    prefix = "@user_id@.@current_datetime@"
    return prefix;
}


// ���� ��ġ�� �ּ��� �ֱ� ���� ��ũ��
macro remark_molink()
{
    prefix = make_prefix()

    remark_text = Ask("�ּ� �޾ƺ���~ ���ϰ�.")

    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)

    hBuffer = GetCurrentBuf()
    s = GetBufLine(hBuffer, first_line)

    DelBufLine(hBuffer, first_line);
    InsBufLine(hBuffer, first_line, "@s@ //@prefix@ : @remark_text@");
}

// ������ ������ �ּ�ó��(/**/)�ϰ�, ó���� �������� comment�� �ܴ�.
// ���� ������ ������ ����ϸ� ��.
macro remark_all()
{
    prefix = make_prefix()

    remark_text = Ask("�ּ��� ���� �ּ���.")

    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)
    last_line = GetWndSelLnLast(hWnd)

    hBuffer = GetCurrentBuf()
    s = GetBufLine(hBuffer, first_line)

    i = 0
    length = strlen(s)

    white_space = "";

    while (i < length)
    {
        ch = s[i]
        if (ch == " " || ch == "\t")
            white_space = cat(white_space, ch);
        else
            break

        i = i + 1
    }

    InsBufLine(hBuffer, first_line,    white_space # "/* //[[ @prefix@_BEGIN -- @remark_text@")
    InsBufLine(hBuffer, last_line + 2, white_space # "*/ //]] @prefix@_END -- @remark_text@");
}

// ������ ������ if 0�� ���� ó���� �������� comment�� �ܴ�.
// ���� ������ ������ ����ϸ� ��.
macro remark_if0()
{
    prefix = make_prefix()

    remark_text = Ask("�ּ��� ���� �ּ���.")

    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)
    last_line = GetWndSelLnLast(hWnd)

    hBuffer = GetCurrentBuf()
    s = GetBufLine(hBuffer, first_line)

    InsBufLine(hBuffer, first_line,    "#if 0 //[[ @prefix@_BEGIN -- @remark_text@")
    InsBufLine(hBuffer, last_line + 2, "#endif //]] @prefix@_END -- @remark_text@");
}

// molink_slcho_20050516 : ���� ������ //�� �ּ�ó���ϴ� ��ũ��
// ������ ������ �� ��ũ�θ� �����ϸ� ��ü�� //�� �ּ�ó����.
macro remark_slash()
{
    prefix = make_prefix()

    remark_text = Ask("�ּ��� ���� �ּ���.")

    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)
    last_line = GetWndSelLnLast(hWnd)

    hBuffer = GetCurrentBuf()
    s = GetBufLine(hBuffer, first_line)

    InsBufLine(hBuffer, first_line,    "//[[ @prefix@_BEGIN -- @remark_text@")
    line = first_line +1
    while(line<= last_line +1)
    {
    s = GetBufLine(hBuffer, line)


    PutBufLine (hBuffer, line, "//@s@");
    line = line +1
    }
    InsBufLine(hBuffer, last_line + 2, "//]] @prefix@_END -- @remark_text@");
}

//molink_slcho_20050512 : ó���� �������� comment�� �ܴ�.
// ���� ������ ������ ����ϸ� ��.
macro remark_begin_end()
{
    prefix = make_prefix()
    remark_text = Ask("�ּ��� ���� �ּ���.")
    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)
    last_line = GetWndSelLnLast(hWnd)
    hBuffer = GetCurrentBuf()
    s = GetBufLine(hBuffer, first_line)
    i = 0
    length = strlen(s)
    white_space = "";

    while (i < length)
    {
        ch = s[i]
        if (ch == " " || ch == "\t")
            white_space = cat(white_space, ch);
        else
            break
        i = i + 1
    }
    InsBufLine(hBuffer, first_line,    white_space # "//[[ @prefix@_BEGIN -- @remark_text@")
    InsBufLine(hBuffer, last_line + 2, white_space # "//]] @prefix@_END -- @remark_text@");
}


// molink_slcho_20050708 : //�� �ּ�ó���� ������ //�� �����ϴ� ��ũ��
// ������ ������ �� ��ũ�θ� �����ϸ� //�� ������.
macro remove_slash()
{
    hWnd = GetCurrentWnd()
    first_line = GetWndSelLnFirst(hWnd)
    last_line = GetWndSelLnLast(hWnd)

    hBuffer = GetCurrentBuf()
//    s = GetBufLine(hBuffer, first_line)

    line = first_line
    while(line<= last_line)
    {
        s = GetBufLine(hBuffer, line)
        str_len = strlen(s)

		space_count = 0
		tab_count = 0
    	while (1)
    	{
    		if (s[0] == "/")
    		{
        		break
    		}

    		if (s[0] == "\t")
    		{
	    		tab_count = tab_count + 1
    		}
            else
            {
	            space_count = space_count + 1
            }

            s = strmid(s, 1, str_len)
            str_len = strlen(s)
    	}

        if((str_len > 2) && (s[0] == "/") &&( s[1] == "/"))
        {
            tem = strmid(s, 2, str_len)
            /*
            i = 2   zz
            while(i< str_len)
            {
                tem[i-2] = s[i]
                i = i+1
            }*/
        }

        i = 0
        if (tab_count != 0)
        {
	        while (i < tab_count)
	        {
	        	i = i + 1
	        	tem = cat ("\t", "@tem@")
	        }
        }

        if (space_count != 0)
        {

	        while (i < space_count)
	        {
	        	i = i + 1
	        	tem = cat (" ", "@tem@")
	        }
        }
        PutBufLine (hBuffer, line, "@tem@")
        line = line +1
    }
}

