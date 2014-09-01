//	Toggle File (.h ↔ .c)

macro msg_1( str )
{
	Msg( str ) ;
}

macro msg_2( str1, str2 )
{
	s = str1 # str2 ;
	msg_1( s ) ;
}

macro msg_3( str1, str2, str3 )
{
	s = str1 # str2 # str3 ;
	msg_1( s ) ;
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


macro strcmp( a, b)
{
	i = 0 ;
	while( a[i] == b[i] && a[i] != "" )
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

macro compare_filename( a, b )
{
	if( a == b )
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

		if( compare_filename( get_filename_ext(prop.Name), filename) )
		{
			return hwnd ;
		}
		i = i + 1 ;
	}
	return hNil ;
}

// 프로젝트에 포함된 파일 검색해서 버퍼를 넘긴다. 
// 프로젝트에 목록은 파일이름부분에 대해서 ascending으로 정렬되어 있다. 
// binary search 사용 
macro find_file_in_project( filename )
{
	filename = tolower( filename ) ;
	
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
		i = strcmp( proj_file, filename ) ;
		if( i < 0 )
		{
			left = mid + 1 ;
		}
		else if( i == 0 )
		{
			return OpenBuf( proj_file ) ;	
		}
		else 
		{
			right = mid - 1 ;
		}
	}

	return hNil ;
}


macro toggle_file()
{

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

	toggle_filename = "" ;
	// c -> h
	if( tolower(ext) == "c" )
	{
		toggle_filename = filename # ".h" ;
	}

	// cpp -> h
	else if( tolower( ext ) == "cpp" )
	{
		toggle_filename = filename # ".h" ;
	}

	// .h 파일이면 기본적으로 .c를 찾도록 한다. 
	else if( tolower( ext ) == "h" )
	{
		toggle_filename = filename # ".c" ;
	}

	// 없는 경우 에러 처리 
	else
	{
		msg_2("unknwon extention : ", ext ) ;
		return ;
	}

	// 현재 열려 있는 윈도우에서 해당 파일이 존재하는지 찾는다. 
	wnd = find_window( toggle_filename ) ;
	
	// 윈도우를 찾지 못했으면 프로젝트 목록에서 찾는다. 
	if( wnd == hNil )
	{
		buff = find_file_in_project( toggle_filename ) ;
		if( buff == hNil )
		{
			msg_2( "file not found : ", toggle_filename ) ;
			return ;
		}

		wnd = NewWnd( buff ) ;
	}

	if( wnd == hNil )
	{
		msg_2( "file not found : ", toggle_filename ) ;
		return ;
	}

    SetCurrentWnd( wnd ) ;

}
