#tried all with bash and some with zsh, use at your own risk of messing up your everything :)

# ssh and cd to the current directory
# use just like you use ssh

sshh(){
	source /usr/share/bash-completion/completions/ssh #load _ssh function
	complete -F _ssh sshh #to copy the ssh auto completion
	echo "sshing to ${1} and cding to ${PWD}" #my ugly made-up terms
	ssh -t ${1} "cd $PWD;bash --login" #change this accordingly if you want to use x11 forwarding etc
}

## or feed it with a list
SERVERS="server1 server2 server3"
sshh(){
	echo "sshing to ${1} and cding to ${PWD}" #my ugly made-up terms
	ssh -t ${1} "cd $PWD;bash --login" #change this accordingly if you want to use x11 forwarding etc
}
IFS=" " command eval 'complete -W "${SERVERS}" sshh'


# easy and proper symbolic link
# since it's not that safe to use relative paths
# How it works:
# lns ../someFile
# gets realpath of ../someFile
# if none defined put the symbolic link to the current dir
# ./someFile -> realpath/of/someFile
# to define another dir use `lns ../someFile anotherDir`
# anotherDir/someFile -> realpath/of/someFile
lns(){
	SRC=$(realpath ${1})
	CDIR=$(pwd)
	FNAME=$(basename ${1})
	if [[ -n ${2} ]]
	then
		mkdir -vp ${CDIR}/${2}
		ln -vs ${SRC} ${CDIR}/${2}/${FNAME}
	else
		ln -vs ${SRC} ${CDIR}/${FNAME}
	fi
}

# this is not mine, probably stole it from tunc or someone
#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# you have the file name with path in the clipboard but need to cd to its dir instead?
# if you can't cd to /path/to/someFile this will cd you to /path/to
function cd(){
	if [[ -z ${1} ]];then #if no arg given
		builtin cd ${HOME} #default cd behavior
	else
		#proper dir given
		if [[ -d ${1} ]];then
			builtin cd ${1}
		#if it's a file
		elif [[ -f ${1} ]];then
			TO=$(dirname ${1})
			if [[ ${TO} != "." ]];then
				echo "cding to ${TO} instead"
				builtin cd ${TO}
			fi
		elif [[ ${1} == "-" ]];then
			builtin cd ${OLDPWD}
		else
			echo "${1}?"
		fi
	fi
}

# get better output from uniq -c
# comma delimited, e.g.:
# 2,1044035
# 1,1044038
# instead of ugly:
#       2 1044035
#       1 1044038

uniqc(){
        uniq -c |sed -e 's/^ *//;s/ /,/'
}


## run Rscript in echo=TRUE spaced=TRUE mode, easily
rsc(){
	Rscript -e 'source(file("stdin"),echo=TRUE,spaced=TRUE)'< ${1}
}

###
# below are not functions but hey
###

# quickly source your bashrc
# with printing what you just did
alias src="type src; source ~/.bashrc"

# screen
alias scls="screen -ls"
alias scs="screen -S"
alias scr="screen -r"
