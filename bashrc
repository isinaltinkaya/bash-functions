
# ssh and cd to the current directory
# use just like you use ssh

complete -F _ssh sshh #to copy the ssh auto completion
sshh(){
	echo "sshing to ${1} and cding to ${PWD}" #my ugly made-up terms
	ssh -t ${1} "cd $PWD;bash --login" #change this accordingly if you want to use x11 forwarding etc
}

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
