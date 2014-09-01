/*=============================================================================
같은 이름에 헤더파일과 소스파일간에 이동을 위한 매크로
20061213
이창주
=============================================================================*/

macro test_strcmp()
{
  if( '_' == '-' )
  {
    msg_1( "_ == -" ) ;
  }

  // 두값이 같다고 나온다. 웃기는구만..
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

// 패스에서 확장자만 추출 
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

// 패스에서 파일 이름 부분만 추출 
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
// 프로젝트 파일에 정렬순서를 보면 "_" 는 alphabet보다 큰값으로 정렬된다.
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
// 프로젝트 파일에 정렬순서를 보면 "_" 는 alphabet보다 큰 값으로 정렬된다.
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


// 파일명 비교 , left에 파일명이 .c로 끝나는 경우 
macro compare_filename( left, right )
{
	if( left == right )
	{
		return True ;
	}
	return False ;
}


// 파일에 해당하는 윈도우를 찾는다 .
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
// 프로젝트에 포함된 파일 검색해서 버퍼를 넘긴다. 
macro find_file_in_project( filename )
{
	proj = GetCurrentProj() ;

	// 뒤에서부터 검색하는게 더 빠를듯 
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

// 프로젝트에 포함된 파일 검색해서 버퍼를 넘긴다. 
// 프로젝트에 목록은 파일이름부분에 대해서 ascending으로 정렬되어 있다. 
// binary search 사용 
macro find_file_in_project( filename_ext1, filename_ext2 )
{
	filename1 = tolower( filename_ext1 ) ;
  filename2 = tolower( filename_ext2 ) ;
	//filename1 = ( filename_ext1 ) ;
  //filename2 = ( filename_ext2 ) ;

	proj = GetCurrentProj() ;
	// 뒤에서부터 검색하는게 더 빠를듯 
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

	// .h -> .c파일, .c -> .h 로 이름 변경 
	ext = get_fileext( prop.Name ) ;
	if( ext == "" )
	{
		msg_2("invalid filename : ", prop.Name) ;
		return ;
	}

	// 확장자를 제외한 파일 이름  
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

	// .h 파일이면 기본적으로 .c를 찾도록 한다. 
	else if( tolower( ext ) == "h" )
	{
		toggle_fileext1 = filename # ".c" ;
		toggle_fileext2 = filename # ".cpp" ;
	}

	// 없는 경우 에러 처리 
	else
	{
		msg_2("unknwon extention : ", ext ) ;
		return ;
	}

	// 현재 열려 있는 윈도우에서 해당 파일이 존재하는지 찾는다. 
	wnd = find_window( toggle_fileext1 ) ;
	if( wnd == hNil && strlen( toggle_fileext2) > 0 )
  {
	  wnd = find_window( toggle_fileext1 ) ;
	}

	// 윈도우를 찾지 못했으면 프로젝트 목록에서 찾는다. 
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
