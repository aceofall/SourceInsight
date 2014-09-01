/*=============================================================================
���� �̸��� ������ϰ� �ҽ����ϰ��� �̵��� ���� ��ũ��
20061213
��â��
=============================================================================*/

macro test_strcmp()
{
  if( '_' == '-' )
  {
    msg_1( "_ == -" ) ;
  }

  // �ΰ��� ���ٰ� ���´�. ����±���..
  if( AsciiFromChar('_') == AsciiFromChar('-') )
  {
    msg_1( "AsciiFromChar('_') == AsciiFromChar('-')" ) ;
  }

  if( "mdm_" == "mdm-" )
  {
    msg_1("hummm1...") ;
  }

  left = "mdm_image.c" ;
  right = "mdmcommon.h" ;
  i = strcmp( left, right ) ;
  msg_1( i ) ;
}

macro find_last( str, find )
{
	i = strlen( str ) ;
	while( i > 0 )
	{
		if( str[ i - 1 ] == find )
		{
			return i - 1 ;
		}
		i = i - 1 ;
	}
	return -1 ;
}

// �н����� Ȯ���ڸ� ���� 
macro get_fileext( path )
{
	ext = "" ;
	i = find_last( path, "." ) ;
	if( i == -1 )
	{
		return "" ;
	}
	
	while( i < strlen( path ) )
	{
		ext = ext # path[i + 1] ;
		i = i + 1 ;
	}
	
	return ext ;
}

// �н����� ���� �̸� �κи� ���� 
macro get_filename( path )
{
	filename = "" ;
	f = find_last( path, "\\") ;
	if( f == -1 )
	{
		f = 0 ;
	}
	else
	{
		f = f + 1 ;
	}

	l = find_last( path, ".") ;
	if( l == -1 )
	{
		l = strlen( path ) ;
	}

	filename = strmid( path, f, l) ;
	return filename ;
}

// filename . ext
macro get_filename_ext( path )
{
	fileext = "" ;
    f = find_last( path, "\\") ;
	if( f == -1 )
	{
		f = 0 ;
	}
	else
	{
		f = f + 1 ;
	}

	fileext = strmid( path, f, strlen( path ) ) ;

	return fileext ;
}

/*
macro strcmp( a, b)
{
	i = 0 ;
	while( a[i] != "" && a[i] == b[i] )
	{
		i = i + 1;
	}

	if( a[i] == "" && b[i] == "")
	{
		return 0 ;
	}
	else if( a[i] == "" )
	{
		return -AsciiFromChar(b[i]);
	}
	else if( b[i] == "" )
	{
		return AsciiFromChar( a[i] ) ;
	}
	
	return AsciiFromChar( a[i] ) - AsciiFromChar(b[i]) ;
}
*/


macro strcmp( left, right)
{
	i = 0 ;
	while( left[i] != "" && left[i] == right[i] )
	{
		i = i + 1;
	}

  if( left[i] == "" )
	{
		a = 0
	}
  else if( left[i] == "_" )
  {
// ������Ʈ ���Ͽ� ���ļ����� ���� "_" �� alphabet���� ū������ ���ĵȴ�.
    //a = 95 ;  
    a = 127 ;  
  }
  else
  {
    a = AsciiFromChar( left[i] ) ;
  }


  if( right[i] == "" )
  {
    b = 0 ;
  }
  else if( right[i] == "_" )
  {
// ������Ʈ ���Ͽ� ���ļ����� ���� "_" �� alphabet���� ū ������ ���ĵȴ�.
    //b = 95 ;  
    b = 127 ;  
  }
  else
  {
    b = AsciiFromChar(right[i]) ;
  }
/*
debug_trace_2("i:", i) ;
debug_trace_2("left :", left[i]) ;
debug_trace_2("right :", right[i]) ;
  
debug_trace_2("a :", a) ;
debug_trace_2("b :", b) ;
*/
  return ( a - b ) ;
}


// ���ϸ� �� , left�� ���ϸ��� .c�� ������ ��� 
macro compare_filename( left, right )
{
	if( left == right )
	{
		return True ;
	}
	return False ;
}


// ���Ͽ� �ش��ϴ� �����츦 ã�´� .
macro find_window( filename )
{
	wnd_count = WndListCount() ;
	i = 0 ;
	while( i < wnd_count )
	{
		hwnd = WndListItem( i ) ;
		buff = GetWndBuf( hwnd ) ;
		prop = GetBufProps( buff ) ;

		if( get_filename_ext(prop.Name) == filename) 
		{
			return hwnd ;
		}
		i = i + 1 ;
	}
	return hNil ;
}

/*
// ������Ʈ�� ���Ե� ���� �˻��ؼ� ���۸� �ѱ��. 
macro find_file_in_project( filename )
{
	proj = GetCurrentProj() ;

	// �ڿ������� �˻��ϴ°� �� ������ 
	i = GetProjFileCount( proj ) ;
	while( i > 0 )
	{
		proj_file = GetProjFileName( proj, i - 1) ;
		if( get_filename_ext(proj_file) == filename )
		{
			return OpenBuf( proj_file ) ;	
		}
		i = i - 1 ;
	}
	
	return hNil ;
}
*/

// ������Ʈ�� ���Ե� ���� �˻��ؼ� ���۸� �ѱ��. 
// ������Ʈ�� ����� �����̸��κп� ���ؼ� ascending���� ���ĵǾ� �ִ�. 
// binary search ��� 
macro find_file_in_project( filename_ext1, filename_ext2 )
{
	filename1 = tolower( filename_ext1 ) ;
  filename2 = tolower( filename_ext2 ) ;
	//filename1 = ( filename_ext1 ) ;
  //filename2 = ( filename_ext2 ) ;

	proj = GetCurrentProj() ;
	// �ڿ������� �˻��ϴ°� �� ������ 
	count = GetProjFileCount( proj ) ;
	if( count == 0 )
	{
		return hNil ;
	}

	left = 0 ;
	right = count - 1 ;
	mid = 0 ;
	i = 0 ;
	while( left <= right )
	{
		mid = (right + left) / 2 ;
		
		proj_file = GetProjFileName( proj, mid ) ;
		proj_file = get_filename_ext(proj_file)  ;
		proj_file = tolower( proj_file) ;

		i = strcmp( filename1, proj_file ) ;
    if( i != 0 && strlen( filename2 ) > 0 )
    {
		  i = strcmp( filename2, proj_file ) ;
    }

    if( i < 0 )
		{
			right = mid - 1 ;
		}
		else if( i == 0 )
		{
			return OpenBuf( proj_file ) ;	
		}
		else 
		{
			left = mid + 1 ;
		}
	}

	return hNil ;
}


macro toggle_file()
{
  //test_strcmp() ;
  //return ;

	cbuff = GetCurrentBuf() ;
	if( cbuff == hNil )
	{
		return ;
	}

	prop = GetBufProps(cbuff) ;
	if( prop == hNil )
	{
		return ;
	}

	// .h -> .c����, .c -> .h �� �̸� ���� 
	ext = get_fileext( prop.Name ) ;
	if( ext == "" )
	{
		msg_2("invalid filename : ", prop.Name) ;
		return ;
	}

	// Ȯ���ڸ� ������ ���� �̸�  
	filename = get_filename( prop.Name ) ;	

	toggle_fileext1 = "" ; // .c
  toggle_fileext2 = "" ; // .cpp
	// c -> h
	if( tolower(ext) == "c" )
	{
		toggle_fileext1 = filename # ".h" ;
	}

	// cpp -> h
	else if( tolower( ext ) == "cpp" )
	{
		toggle_fileext1 = filename # ".h" ;
	}

	// .h �����̸� �⺻������ .c�� ã���� �Ѵ�. 
	else if( tolower( ext ) == "h" )
	{
		toggle_fileext1 = filename # ".c" ;
		toggle_fileext2 = filename # ".cpp" ;
	}

	// ���� ��� ���� ó�� 
	else
	{
		msg_2("unknwon extention : ", ext ) ;
		return ;
	}

	// ���� ���� �ִ� �����쿡�� �ش� ������ �����ϴ��� ã�´�. 
	wnd = find_window( toggle_fileext1 ) ;
	if( wnd == hNil && strlen( toggle_fileext2) > 0 )
  {
	  wnd = find_window( toggle_fileext1 ) ;
	}

	// �����츦 ã�� �������� ������Ʈ ��Ͽ��� ã�´�. 
	if( wnd == hNil )
	{
		buff = find_file_in_project( toggle_fileext1, toggle_fileext2 ) ;
		if( buff == hNil )
		{
			msg_2( "file not found : ", toggle_fileext1 ) ;
			return ;
		}

		wnd = NewWnd( buff ) ;
	}

	if( wnd == hNil )
	{
		msg_2( "file not found : ", toggle_fileext1 ) ;
		return ;
	}

  SetCurrentWnd( wnd ) ;

}
