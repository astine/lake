#set defaults
LISP=sbcl
LISP_HOME=/usr/lib/sbcl/
ASDF_REGISTRY=

#load user defaults
if test -e ~/.lisprc
then
    sh ~/.lisprc
elif test -e /etc/lisprc
then
    sh /etc/lisprc
fi

function usage()
{
    cat <<EOF
Options:

--lisp - The lisp program to be used (defaults to sbcl)
--lisp-home - The lisp home directory (defaults to /usr/lib/sbcl/)
--asdf-registry - The location for the asdf file symlinks (automatically set using lisp if not set)

EOF
}

    
#parse command line
set -- `getopt h "$@"`;
while [ $# -gt 0 ]
do
    case "$1" in
	--lisp) LISP=$2; shift;;
	--lisp-home) LISP_HOME=$2; shift;;
	--asdf-registry) ASDF_REGISTRY=$2; shift;;
	--) shift; break;;
	-h) usage;;
	-*) echo "Bad option: $1"; usage;;
	*) break;;
    esac
    shift;
done

#find the central registry
if test ! "${ASDF_REGISTRY+set}" = set;
then
    case "$LISP" in
	sbcl) ASDF_REGISTRY=`sbcl --noinform --eval "(progn (princ (eval (first asdf:*central-registry*))) (quit))"`;;
	clisp) ASDF_REGISTRY=`clisp --silent -x "(progn (princ (eval (first asdf:*central-registry*))) (quit))"`;;
    esac
fi

#make sure the registry exists
if ! test -e $ASDF_REGISTRY;
then
    mkdir -p $ASDF_REGISTRY;
fi

#loop through all asd files in the current directory and create 
#links to them in central registry
function link_files
{
    if [ *.asd = "*.asd" ];
    then 
	echo "No systems found in: `pwd`";
    else
	for file in *.asd
	do
	    if test -e $ASDF_REGISTRY/$file;
	    then
		echo "System: $file, already registered.";
		input="x";
		while ! [ $input = "y" ] && ! [ $input = "n" ] ;
		do
		    read -s -n 1 -p "Overwrite (y/n)" input;
		    echo "";
		    if [ $input = "y" ];
		    then
			echo "Overwriting link to $file in $ASDF_REGISTRY";
			rm $ASDF_REGISTRY/$file;
			ln -s `pwd`/$file $ASDF_REGISTRY;
		    fi
		done
		echo "Ok";
	    else
		echo "Linking $file in $ASDF_REGISTRY";
		ln -s `pwd`/$file $ASDF_REGISTRY;
	    fi
	done	
	echo "Soft install complete.";
    fi
}
link_files;
