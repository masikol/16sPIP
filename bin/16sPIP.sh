#!/bin/bash
#
# This is the main driver script for the 16sPIP pipeline.
#
# Quick guide:
# 
#   $0 -i <forward> -r <reverse> -f <fastq/fasta/bam/sam/sff> -p <reference_path> -s <step> -m <fast/sensitive> -t <thread>
#
### Authors : Jiaojiao Miao <jjmiao1314@163.com>
# Forked by Maxim Sikolenko <maximdeynonih@gmail.com>
#


if [ $# -lt 1 ]
then
  echo "Please type $0 -h for help"
  exit 1
fi

FORMAT="fastq"
REF_PATH=TEMPORARY_STUB
MODE="fast"
THREAD=1
Version="0.1.1"
# step="step1"
# skipQC='false'
THREAD=1
Qformat=33

while getopts ":i:r:f:p:m:t:hv" opt
do
  case "${opt}" in
    i) NGS=${OPTARG}
       HELP=0
    ;;
    r) NGS_R2=${OPTARG}
    #echo "${OPTARG}"
    ;;
    f) FORMAT=${OPTARG}
    ;; 
    h) HELP=1
    # echo "HELP IS $HELP"
    ;;
    # s) skipQC='true'
    # ;;
    v) VERIFICATION=1 
    ;;
    p) REF_PATH=${OPTARG} #reference DB path
    ;;
    m) MODE=${OPTARG} #fast or sensitive
    ;;
    t) THREAD=${OPTARG}
    ;;
    ?) echo "Option -${opt} requires an argument. Please type $0 -h for helps" >&2
    exit 1
    ;;
  esac
done

if [ $HELP -eq 1 ]
then
  cat <<USAGE

16sPIP version ${Version}

This program will run the 16sPIP pipeline with the supplied parameters.

Command Line Switches:

  -h  Show this help & ignore all other switches

  -i  Specify NGS file or pair-end forward reads for processing

  -r  Specify pair-end reverse reads for processing

  -f  Specify NGS file format (fastq/fasta/bam/sam/sff) [fastq]
    
  -p  Specify the PATH for 16sPIP root directory

  -v  Verification mode

  -m  Specify the analysis mode: fast or sensitive [fast]

  -t  Number of threads [1]



Usage:

    $0 -i <NGSfile> -f <fastq/fasta/bam/sam/sff> -p <reference_path>

    $0 -i <forward> -r <reverse> -f <fastq> -p <reference_path> -m <fast>


USAGE
  exit
fi

if [[ ${REF_PATH} == TEMPORARY_STUB ]]; then

  echo "Error: main script is not properly configured by the installer."
  exit 1
fi

if [[ ! -d ${REF_PATH} ]]; then

  echo "Directory ${REF_PATH} does not exist!"
  exit 1
fi

if [ ! -f $NGS ]
then
  echo "$NGS file doesnot exist. Please check it"
  exit 65
fi 

if [ "$NGS_R2" -a "${FORMAT}" != "fastq" ]
then
        echo "$NGS_R2 must be in fastq format"
  exit 
fi

if [ "$MODE"x != "fast"x -a "$MODE"x != "sensitive"x ]
then
        echo "Specify the analysis mode: fast or sensitive [fast]"
  exit
fi

if [ "${FORMAT}" = "sam" -o "${FORMAT}" = "bam" ]
then
     picard-tools SamToFastq INPUT=$NGS FASTQ=${NGS}.tmp
     mv ${NGS}.tmp $NGS
elif [ "${FORMAT}" = "sff" ]
then
      python2 ${REF_PATH}/bin/sff_extract $NGS >${NGS}.fastq
      mv ${NGS}.fastq $NGS
fi

#if [ "$step" != "" ] 
#then 
#  goto ${step}
#fi

# step1:

echo ""
echo "Step 1: Quality control "
echo ""
if [ "${FORMAT}" = "fastq" -o "${FORMAT}" = "sam" -o "${FORMAT}" = "bam" -o "${FORMAT}" = "sff" ]
then
    if [ ${NGS_R2} -a -f ${NGS_R2} ]
    then
             perl ${REF_PATH}/bin/TrimmingReads.pl -i ${NGS} -irev ${NGS_R2} -q 20 -n 50
    else
             perl ${REF_PATH}/bin/TrimmingReads.pl -i $NGS -q 20 -n 50
    fi
elif [ "${FORMAT}" = "fasta" ]
then
          perl ${REF_PATH}/bin/TrimmingReads.pl -i $NGS -n 50
else
          echo "Specify NGS file format (fastq/fasta/bam/sam/sff) [fastq]"
    exit
fi


if [ $NGS_R2 -a -f $NGS_R2 ]
then
#       goto step2
#step2:
  echo ""
  echo "Step 2: Merge double-ended reads"
  echo ""
  Qformat=$(cat ${NGS}_Qformat)
  ${REF_PATH}/bin/pear -f ${NGS}_trimmed -r ${NGS_R2}_trimmed -o $NGS -q 20 -t 50 -b $Qformat
  mv ${NGS}.assembled.fastq ${NGS}_trimmed
  rm ${NGS_R2}_trimmed
else
#       goto step3
  echo ""
        echo "Step 2: Merge double-ended reads Skipped"
  echo ""
fi
  

#step3:
echo ""
echo "Step 3: sequence filtering"
echo ""
if [ "$FORMAT" = "fasta" ]
then
       perl $REF_PATH/bin/FilterReads.pl ${NGS}_trimmed fasta 10
else
       perl $REF_PATH/bin/FilterReads.pl ${NGS}_trimmed fastq 10
fi

#step4:
echo ""
echo "Step 4: Results report"
echo ""
if [ "$FORMAT" = "fasta" ]
then
       python2 $REF_PATH/bin/basicStatistics.py ${NGS}_trimmed_filter fasta ${NGS}.basic_stat.txt
else
       python2 $REF_PATH/bin/basicStatistics.py ${NGS}_trimmed_filter fastq ${NGS}.basic_stat.txt
fi

if [ "$MODE" = "fast" ]
then
      bwa mem -t ${THREAD} ${REF_PATH}/db/155pathogens.fa ${NGS}_trimmed_filter > ${NGS}.sam
      perl ${REF_PATH}/bin/pathogenSamMatch.pl $NGS.sam ${NGS}.pathon.match.txt
      cat ${NGS}.pathon.match.txt >> ${NGS}.basic_stat.txt
      rm ${NGS}.pathon.match.txt
      perl ${REF_PATH}/bin/SamSingleResult.pl -i $NGS.sam -s 99 -l species -o $NGS.pathogen
      perl ${REF_PATH}/bin/PathogenAnnotation.pl -i $NGS.pathogen -l ${REF_PATH}/db/155pathogens.list -o $NGS.pathogen.list
      perl ${REF_PATH}/bin/FastReport.pl -l $NGS.pathogen.list -s ${NGS}.basic_stat.txt -o ${NGS}.pathogen.prediction.report
elif [ "$MODE" = "sensitive" ]
then
      bwa mem -t ${THREAD} ${REF_PATH}/db/16S-complete.fa ${NGS}_trimmed_filter > $NGS.com.sam &
      echo $! >Job_id
      bwa mem -t ${THREAD} ${REF_PATH}/db/155pathogens.fa ${NGS}_trimmed_filter > $NGS.sam
      perl ${REF_PATH}/bin/SamSingleResult.pl -i $NGS.sam -l species -s 99 -o $NGS.pathogen
      perl ${REF_PATH}/bin/PathogenAnnotation.pl -i $NGS.pathogen -l ${REF_PATH}/db/155pathogens.list -o $NGS.pathogen.list
      if [ "$FORMAT" = "fasta" ]
      then
         perl ${REF_PATH}/bin/extractSequence.pl -i ${NGS}_trimmed_filter -o ${NGS} -l $NGS.pathogen.list -f fasta
      else
         perl ${REF_PATH}/bin/extractSequence.pl -i ${NGS}_trimmed_filter -o ${NGS} -l $NGS.pathogen.list -f fastq
      fi
      for i in `ls ${NGS}.*.pathon.fa`
      do
       ${REF_PATH}/bin/blastn -query $i -out $i.blast -db ${REF_PATH}/db/16S-complete -outfmt 6 -evalue 1E-20 -num_threads ${THREAD} &
       echo $! >>Job_id
      done
      perl ${REF_PATH}/bin/pathogenSamMatch.pl $NGS.sam ${NGS}.pathon.match.txt
      cat ${NGS}.pathon.match.txt >> ${NGS}.basic_stat.txt
      while [ 1 ]
      do
       tag=1
       for i in `cat Job_id`
       do
          ID=`ps -A|grep "$i"`
       if [ "$ID" != "" ]
       then
           tag=0
           sleep 10
       fi
       done
       if [ $tag == 1 ]
       then
            break
       fi
    done
    perl ${REF_PATH}/bin/SamSingleResult.pl -i $NGS.com.sam -s 99 -l species 
    perl ${REF_PATH}/bin/SamSingleResult.pl -i $NGS.com.sam -s 97 -l genus
    perl ${REF_PATH}/bin/SamSingleResult.pl -i $NGS.com.sam -s 95 -l family
    perl ${REF_PATH}/bin/completeAnnotation.pl $NGS.com.sam.species ${REF_PATH}/db/16S-complete.list species $NGS.com.sam.species.list
    perl ${REF_PATH}/bin/completeAnnotation.pl $NGS.com.sam.genus ${REF_PATH}/db/16S-complete.list genus $NGS.com.sam.genus.list
    perl ${REF_PATH}/bin/completeAnnotation.pl $NGS.com.sam.family ${REF_PATH}/db/16S-complete.list family $NGS.com.sam.family.list
    cat ${NGS}.*.pathon.fa.blast >$NGS.tmp.blast
    rm ${NGS}.*.pathon.fa*
    perl ${REF_PATH}/bin/completeAnnotation.pl $NGS.tmp.blast ${REF_PATH}/db/16S-complete.list species $NGS.tmp.blast.list.species
    perl ${REF_PATH}/bin/sensitiveReport.pl -l $NGS.pathogen.list -t ${NGS}.basic_stat.txt -g $NGS.com.sam.genus.list -f $NGS.com.sam.family.list -b $NGS.tmp.blast.list.species -s $NGS.com.sam.species.list -o ${NGS}.pathogen.prediction.report
fi

enscript -p ${NGS}.pathogen.prediction.report.ps ${NGS}.pathogen.prediction.report
ps2pdf ${NGS}.pathogen.prediction.report.ps ${NGS}.pathogen.prediction.report.pdf
