#!/usr/bin/env python
# for regular expression

import os
import sys
import getopt
import re
import pp

def relpath(dir, cwd=None): 
    if cwd is None: 
        cwd = os.path.realpath(os.getcwd()) 
    dir = os.path.realpath(dir) 
    cpfx = os.path.commonprefix([dir, cwd]).split(os.sep) 
    if cpfx[-1] == '': 
        del cpfx[-1] 
    dirpaths = dir.split(os.sep) 
    cwdpaths = cwd.split(os.sep) 
    return os.sep.join(['..'] * (len(cwdpaths) - len(cpfx)) 
                + dirpaths[len(cpfx):])

workingpath = "."
toppath = ""
kernelcompiledpath = ""
outfilename = "filelist.txt"
filelist = {}
kernelext = ".o.cmd"
depext = ".P"
specialfilename = "droiddoc-src-list"
kernelonly = False
andro_only = False

kernel_rules_split = [
			re.compile("^deps_.+ := (.*)\\\\ *$"),
			re.compile("^ *"+toppath+"/*(.+)\\\\ *$"),
			re.compile("^ *\$\(wildcard *include/config/(.+)\)"),
			re.compile("^source_.+ := (.*)"),
			re.compile("^ *([a-zA-Z0-9_\-/]+\.[chCH]) *")
			]
#print kernel_rules_split

kernel_rules_for_count = re.compile("^.*\\\\ *$")

def kernel_conv(line):
	match_id=0
	cont=0
	i=0
	for ro in kernel_rules_split:
		match = ro.match(line)
		if match:
			match_id=i
			filename = ''
			#print "match %d %s" %(match_id, match.group(1))
			#
			if match_id==1:
				filename = toppath + "/" +  match.group(1)
			elif match_id==2:
				#filename = toppath + "/kernel/arch/arm/include/asm/" + match.group(1)
				filename = toppath + "/arch/arm/include/asm/" + match.group(1)
			elif match_id==3:
				filename = match.group(1)
				if filename[0] != '/':
					#tempname = toppath + "/kernel/" + filename
					tempname = toppath + "/" + filename
					if os.path.isfile(tempname) == False:
						tempname = kernelcompiledpath + "/" + filename
						if os.path.isfile(tempname) == False:
							print "\'" + filename + "\'" + " was not found."
							filename = ''
						else:
							filename = tempname
					else:
						filename = tempname						
			elif match_id==4:
				tempname = match.group(1)
				#print "tempname :"+tempname
				#filename = toppath + "/kernel/"+tempname
				tempname = toppath + "/" + filename

			if filename != '':
				if(match_id == 0 or match_id == 3):
					if filename[0] != '/':
						print "match id : %d" %(match_id)
						print "old filename " + filename
						filename = os.path.realpath(filename) 
						print "new filename " + filename + "\n"

#				if os.path.isfile(filename) == False:
#					print "cannot found : "+filename+"!!!!!!!!!!!!!!"

				filename = os.path.abspath(filename)
				rpath = relpath(filename, toppath)
				#print "rpath = " + rpath
				filelist[rpath] = 1
		i=i+1
	match=kernel_rules_for_count.match(line)
	if match:
		cont=1
	else:
		cont=0
	return (match_id,cont)

andro_rule = re.compile("^([a-zA-Z0-9/_\-\+\.]+)")
def andro_conv(line):
	ret=0
	#print line
	for word in line.split():
		#print word+"--->"
		match = andro_rule.match(word)
		if match:
			newpath = os.path.abspath(match.group(1))
			if newpath[-2:] != '.o':
				ret = ret+1
				#print newpath
				newpath = relpath(newpath, toppath)
				#print newpath
				filelist[newpath] = 1
	return ret

def print_usage():
	print "usage> " + sys.argv[0] + " [-w working_path] [-o output-filename]"

def search_toppath(dirname):
	newdir_name = dirname
	while(newdir_name != '/'):
		#print "dirname = "+newdir_name
		
		#if(os.path.isdir(newdir_name+'/.repo') == True):
		#	print "topdir is detected! : " + newdir_name
		#	break
		if(os.path.lexists(newdir_name+'/.config') == True):
			print "topdir is detected! : " + newdir_name
			break
		index = newdir_name.rfind('/')
		#print "index : %d" %(index)
		newdir_name = newdir_name[:index]
		#print "newdir_name = " + newdir_name
	return newdir_name


def search_kernel_base_path(dirname):
	newdir_name = dirname
	while(newdir_name != '/'):
		if(os.path.isfile(newdir_name+'/vmlinux') == True):
			print "base compiled folder of kernel is detected! : " + newdir_name
			break
		index = newdir_name.rfind('/')
		#print "index : %d" %(index)
		newdir_name = newdir_name[:index]
		#print "newdir_name = " + newdir_name
	return newdir_name

options, args = getopt.getopt(sys.argv[1:], 'w:o:c:d:hka', [ 'help', 'output=' ])
#print options
#print args

if(options==[]) :
	print_usage()
	exit()

for op, value in options:
	if op == '-w':
		workingpath = value
	elif op == '-o' or op == '--output':
		outfilename = value
	elif op == '-c':
		kernelext = '.' + value
	elif op == '-d':
		depext = '.' + value
	elif op == '-k':
		kernelonly = True
	elif op == '-a':
		andro_only = True
	elif op == '-h'or op == '--help':
		print_usage()
		exit()

workingpath = os.path.realpath(workingpath)

#set again for changing toppath
if toppath != '':
	kernel_rules_split[1] = re.compile("^ *"+toppath+"/*(.+)\\\\ *$")

#os.chdir(w)
#workingpath = os.
#toppath = os.path.abspath(toppath)
#print "t " + toppath
#print "w " + workingpath
#print "o " + outfilename
kernelext_rindex = -1*len(kernelext)
andro_rindex = -1*len(depext)

for dirname, dirnames, filenames in os.walk(workingpath):
	#for subdirname in dirnames:
	#  name = os.path.join(dirname, subdirname)
	for filename in filenames:
		fullpathname=os.path.join(dirname, filename)
		if toppath == '' :
			toppath = search_toppath(dirname)
			kernel_rules_split[1] = re.compile("^ *"+toppath+"/*(.+)\\\\ *$")

		#dependancy file of kernel
		if andro_only == False and fullpathname[kernelext_rindex:] == kernelext:
			if kernelcompiledpath == '':
				kernelcompiledpath = search_kernel_base_path(dirname)
			f=open(fullpathname,'r')
			#print "filename = " + fullpathname
			while 1:
				line = f.readline()
				if not line: break
				#print "line = " + line
				kernel_conv(line)
			f.close()
		##dependancy file of android
		elif (kernelonly == False and (fullpathname[andro_rindex:] == depext or filename == specialfilename) ):
			f=open(fullpathname,'r')
			while 1:
				line = f.readline()
				if not line: break
				andro_conv(line)
			f.close()

w=open(outfilename, 'w')
for fname in filelist.keys():
#	if os.path.isfile(fname) == False:
#		print "cannot found : "+fname+"!!!!!!!!!!!!!!"
	w.write(fname+"\n")
w.close()
