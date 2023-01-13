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
	if [[ ! -f ${1} ]] &&  [[ ! -d ${1} ]]
	then
		echo "${1} does not exist, will exit";
	else
		SRC=$(realpath ${1})
		FNAME=$(basename ${1})
		if [[ -n ${2} ]]
		then
			mkdir -vp ${PWD}/${2}
			ln -vs ${SRC} ${PWD}/${2}/${FNAME}
		else
			ln -vs ${SRC} ${PWD}/${FNAME}
		fi
	fi
}

# this is not mine, probably stole it from tunc or someone
#
# # ext - archive extractor
# # usage: ext <file>
ext ()
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


## index all; if you are too lazy to write a for loop
idxall(){
	if [[ -z ${1} ]];then #if no arg given
		for i in *{bam,cram};do
			if ! [[ -f ${i}.bai || -f ${i}.crai ]];then
				echo "${i} does not have an index file; will index";
				echo "running => nohup samtools index -@4 ${i} &";
				nohup samtools index -@4 ${i} &
			fi
		done
	else
		printf "${@}\n"
		for i in "${@}";do
			if ! [[ -f ${i}.bai || -f ${i}.crai ]];then
				echo "${i} does not have an index file; will index";
				echo "running => nohup samtools index -@4 ${i} &";
				nohup samtools index -@4 ${i} &
			fi
		done
	fi
}


##quick access to different projects
#lazy to type the path but not lazy to write a bash function for it :)
function cdp(){
        shp="/PATH/TO/projects"
	#if no arg given, cd to projects main dir
        if [[ -z ${1} ]];then 
                builtin cd ${shp}
        else
                #given project id
                TO=${shp}/${1}*
                builtin cd ${TO}
        fi
}

## safer way to remove possibly-important stuff, check files matching query
# query can contain wildcards
srm(){
	(ls "$@")
	local CODE=$?
	if [ ${CODE} -eq 0 ];then
		printf "Will delete following files:\n$(ls "$@")\n"|less 
		while true;do
			read -p "Will delete them all. Are you sure? " yn
			case $yn in
				[Yy]* ) rm -v "$@";break;;
				[Nn]* ) echo "You said no, will exit";break;;
				* ) echo "Yes or no?";;
			esac
		done
	fi
}

## count of files matching query
# too lazy to write it, not too lazy to write a function for it :)
cof(){ ls "${@}"|wc -l ;}

## less the ls with retaining the colors
lsl(){ ls --color "${@}" | less -r; }

## quick sam to bam conversion
# to have fun with modified sam files
s2b(){
	test -f ${1%.sam}.bam && rm -v ${1%.sam}.bam
	samtools view -bS ${1} > ${1%.sam}.bam
	samtools index ${1%.sam}.bam
}

## sumcol: easy way to get the sum of a column
# usage: sumcol ${file} ${seperator} ${colindex}
sumcol(){ awk -v SEPERATOR=${2} -v COLINDEX=${3} '{split($0,a,SEPERATOR); sum += a[COLINDEX]} END {print sum}' ${1}}

#for i in
fin(){
	USAGE="Usage: fin <wildcard> <command to execute with \$i>"
	if [ "$#" == "0" ]; then
		echo "$USAGE"
	else
		ITEMS=( "${@:1:$(($# - 1))}" )
		CMD=${@:${#@}}
		#echo "Executing command $CMD"

		for i in "${ITEMS[@]}";do
			echo $i
			eval ${CMD} ${i}
		done
	fi
}


putrm(){
	README=${PWD}/README.txt
	if test -f "${README}";then
		printf "\n${README} already exists; will open it instead!\n"
		vim + ${README} # goes to last line
	else
		printf "Will put README.md in PWD: ${PWD}\n"
		cat > "$README" << EOF
# ${README}
$(date +'# %D #%n# %T #%n')
# Isin Altinkaya [isinaltinkaya[at]gmail.com]
# NOTE:
EOF
		vim $README -c ":5"
	fi
}



## find all files/dirs and chmod $1
### credit: https://stackoverflow.com/a/42975697/7870777

chmodf() {
        find $2 -type f -exec chmod $1 {} \;
}
chmodd() {
        find $2 -type d -exec chmod $1 {} \;
}


setsink(){

    sinkid=${1}

    #cable + headphones
    if [[ ${sinkid} == "chp" ]]; then
        mysink="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink" 
    else
        echo "Unknown sink ${sinkid}"
        mysink=""
    fi
    
    #if known sink
    if [ ! -z ${mysink+x} ];then

        pactl set-default-sink ${mysink} 

        if [ ! -z ${2+x} ];then

            if [[ ${2} == *% ]];then
                pactl set-sink-volume ${mysink} ${2} 
                echo "Sink set to ${mysink} with volume ${2}"
            else
                pactl set-sink-volume ${mysink} ${2}% 
                echo "Sink set to ${mysink} with volume ${2}%"
            fi

        else
            echo "Sink set to ${mysink}"
        fi
    fi

}


#check file list
#input is a list of files, one file per line
cfl(){
	
	INFILE=${1}
	for Fi in $(cat ${INFILE});do
		if [[ -f ${Fi} ]]; then
			ANY=0
		else
			printf "File not found: ${Fi}"
			ANY=1
		fi
	done

}

#gzip keep original
#-k does not work with some versions
gzik(){
	gzip < ${1} > ${1}.gz
}


#cd to dir workaround
cdd(){

        CDTO=$(realpath $(dirname ${1}))
        echo "cding to ${CDTO}"
        cd ${CDTO}

}


#set default source to tp source
pactl set-default-source 'alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_6__source'
pactl set-source-volume 'alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_6__source' 60%

#you never know when you'll need a fresh installation of angsd
getangsd(){

        if [[ -z ${1} ]];then BRANCH="master";
                else
                BRANCH=${1}
        fi

        git clone git@github.com:ANGSD/angsd.git;
        cd angsd;
        git checkout ${BRANCH};
        make


}


# runda- env-safe runner for conda. fixes all the annoying conda related issues.
function runda() {

        CONDABIN="/home/isin/Programs/anaconda3/bin"
        CONDA="${CONDABIN}/conda"

        # Check if conda is in the PATH or use ${CONDABIN}/conda if it is not
        if ! command -v conda > /dev/null; then
                printf "\n[INFO]: \`conda\` is not available in PATH; will try \${CONDABIN}/conda\n"
                CONDA="${CONDABIN}/conda"
        fi

        if ! command -v ${CONDA} > /dev/null; then
                printf "\n[ERROR]: Cannot find conda at \$\{CONDABIN\}/conda. Please update CONDABIN to the bin path of your conda installation.\n\te.g. /home/isin/Programs/anaconda3/bin\n\n"
        else



                # Activate or deactivate conda based on the passed option
                case "$1" in
                        activate)
                                eval "$(command ${CONDA} 'shell.bash' 'hook' 2> /dev/null)"
                                export PATH="${CONDABIN}:$PATH";
                                conda ${@}
                                ;;
                        deactivate)
                                conda deactivate
                                export PATH=${PATH%:${CONDABIN}};
                                ;;
                        *)
                                "${CONDA}" "$@"
                                ;;
                esac
        fi
}




# print tree structure of a git repository and format it for markdown 
function treemd(){
        ID=$(basename -s .git $(git config --get remote.origin.url))
        URL=$(git config --get remote.origin.url)
        tree=$(tree -f --noreport --charset ascii -F ${@} -I "README.md|README.MD|readme.MD|readme.md" | sed -e 's/| \+/  /g' -e 's/[|`]-\+/ */g' -e 's:\(* \)\(\(.*/\)\([^/]\+\)\):\1[\4](\2):g' | sed -E 's/^(\ \*\ \[)(([a-z_-]+))/\1**\2**/g' | sed -e "s/^.$/**${ID}**/g")
        printf "## Repository structure\n${tree}\n"
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




## unmount all
## credit: https://www.joeldare.com/wiki/linux:unmount_all_fuse_mount_points
umall(){
	mount -l -t fuse.sshfs | awk -F " " '{print "fusermount -u " $3}' | bash
}




