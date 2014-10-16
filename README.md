# Fuzzer project for SWEN-331

## Setup 
If your system does not have Ruby installed follow the instructions located on this page: https://www.ruby-lang.org/en/installation/

Once Ruby is installed run `./setup.sh` in the directory where the project is located.

## Usage 

To run the project run `./fuzzer.sh COMMAND URL [args]`

    COMMANDS:
      discover  Output a comprehensive, human-readable list of all discovered inputs to the system. Techniques include both crawling and guessing. 
      test      Discover all inputs, then attempt a list of exploit vectors on those inputs. Report potential vulnerabilities.

    OPTIONS: 
      --custom-auth=string     Signal that the fuzzer should use hard-coded authentication for a specific application (e.g. dvwa). Optional.

      Discover options:
        --common-words=file    Newline-delimited file of common words to be used in page guessing and input guessing. Required.

      Test options:
        --vectors=file         Newline-delimited file of common exploits to vulnerabilities. Required.
        --sensitive=file       Newline-delimited file data that should never be leaked. It's assumed that this data is in the application's database (e.g. test data), but is not reported in any response. Required.
        --random=[true|false]  When off, try each input to each page systematically.  When on, choose a random page, then a random input field and test all vectors. Default: false.
        --slow=500             Number of milliseconds considered when a response is considered "slow". Default is 500 milliseconds
        

    ### Examples:
      # Discover inputs 
      ./fuzzer.sh discover http://localhost:8080 --common-words=mywords.txt

      # Discover inputs to DVWA using our hard-coded authentication 
      ./fuzzer.sh discover http://localhost:8080 --common-words=mywords.txt

      # Discover and Test DVWA without randomness
      ./fuzzer.sh test http://localhost:8080 --custom-auth=dvwa --common-words=words.txt --vectors=vectors.txt --sensitive=creditcards.txt --random=false
