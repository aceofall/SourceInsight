
macro debug_find_buff()
{
	count = BufListCount () ;
	i = 0 ;
	while( i < count ) 
	{
		buff = BufListItem(i) ;
		prop = GetBufProps( buff ) ;
		if( prop.Name == "__internal_debug" )
		{
			return buff ;
		}
		i = i + 1 ;
	}
	return hNil ;
}

macro debug_get_buff()
{
	buff = debug_find_buff() ;

	if( buff == hNil )
	{
		buff = NewBuf( "__internal_debug" ) ;
		if( buff == hNil )
		{
			Msg( "debug buffer create error" ) ;
			return hNil ;
		}
	}
	return buff ;
}

macro debug_trace( s )
{

	buff = debug_get_buff() ;
	if( buff == hNil )
	{
		Msg( "debug_get_buff error" ) ;
		return ;	
	}

	// 라인 추가 
	AppendBufLine( buff, s ) ;	

	// debug용 출력 윈도우를 찾는다. 
	wnd = GetWndHandle ( buff ) ;
	if( wnd == hNil )
	{
		// 없으면 생성 
		wnd = NewWnd( buff ) ;
		if( wnd == hNil )
		{
			Msg("Fail to create window") ;
			return ;
		}
	}
}

// 디버그 버퍼 해제 
macro debug_end()
{
	buff = debug_get_buff() ;
	if( buff != hNil )
	{
		CloseBuf( buff ) ;
	}
}


macro debug_trace_1( s )
{
	debug_trace( s ) ;
}

macro debug_trace_2( s1, s2 )
{
	s = s1 # s2 ;
	debug_trace( s ) ;
}

macro debug_trace_3( s1, s2, s3 )
{
	s = s1  #  s2 # s3 ;
	debug_trace( s ) ;
}

macro debug_trace_pair( str, val )
{
	s = str # val ;
	debug_trace( s ) ;
}

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
