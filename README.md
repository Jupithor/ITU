# Repo for digital forensics ITU lecture 18. nov 2025

## Preparation
### Before doing anything, please shut down your VM and make a snapshot/restore point

### Clone repo
In your Kali VM terminal
    
    git clone https://github.com/Jupithor/ITU.git

### Run the scripts
You should look through the scripts to verify what they do
Next make them executable

    chmod +x gettools.sh downloadevidence.sh

Run the scripts

    ./downloadevidence.sh
    ./gettools.sh

You should also have some application for viewing CSV files.  
I am using Tablecruncher (https://tablecruncher.com/), but any application will do.  

### Regarding the use of AI during this exercise.  
  Please do: Ask about generic help, eg. "make a function that will do x", "make a find command that til sort for x"....  
  Please don't: copy-paste output/code from the terminal/evidence directly into the AI

## Tips and guides (To follow along in the lecture)

### 1 Data acquisition
Verify that your downloads was successful

    md5sum 001Evidence.001

Make sure it matches the checksum from the 001Evidence.001.txt

    cat 001Evidence.001.txt | grep md5

### 2 Mount evidence
#### 2.1 Check filesystem type

    parted 001Evidence.001 p

#### 2.2 Mounting a ntfs filesystem 
ro (read only),  
show_sys_files (system files),  
streams_interface=windows (alternate data streams)  
$type is the filesystem type that you got from the previous parted command

    sudo mkdir -p /mnt/case/001Evidence
    sudo mount -t $type -o ro,show_sys_files,streams_interface=windows 001Evidence.001 /mnt/case/001Evidence

Now the evidence is mounted at /mnt/case/001Evidence

### 3 Analyzing metadata
Look for files with metadata that "sticks out" or maybe you can deduct that some files are missing?

Below are some commands that might be useful, try to use multiple of them.

List files:

    ls -lah

Find files based on size.
replace $size with your actual value.    
The "c" after the size is for bytes.

    find . -type f -size $sizec 

Check out "man find" on how to do logical negation.

To count the number of files named $name.  
remember wildcards (\*) before and after if you are searching for something that contains \"\*\$name\*\".

    find . -type -f -iname "*$name*" | wc -l

To look for files that are not of certain type where $string is the type.

    file * | grep -v $string

### 4 Analyze $MFT 

#### 4.1 Parsing the $MFT

Use mftecmd to analyze the $MFT
$MFT is the path to MFT in your mounted evidence

    mftecmd -f $MFT ~/analysedmft --csv

Open the output with your favorite csv viewer.

    Tablecruncher ~/analyzedmft/<date>MFTE_output.csv

#### 4.1 Recovering deleted files 

Use fls and icat to extract the deleted file  
(check man fls for flag to see only deleted files)

    fls 001Evidence.001

This will show you the inode for the file.  Is it the digits right before the filename.
Output example:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1node nr. here  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;v  

   + r/r 12-345-6: $filename

Use the inode with icat to extract the deleted file.

    icat 001Evidence.001 12-345-6 > $recoveredfile

WARNING: DO NOT TRY TO RUN/EXECUTE THE FILES

### 5 Reverse engineering
After recovering the deleted files, we can use file to see what the files are

    file $recoveredfile

To decompile a dotnet application we can use tools like ilspy  
(not the exe file, but the dll)  
ANOTHER WARNING: DO NOT RUN/EXECUTE THE FILES(!!!)

    ilspycmd $recoveredfile

Focus on these functions:  
EncryptFile​  
SaveObfuscatedKeyToFileStream​  
Swipswap​  
Try to identify the necessary information to decrypt AES  

<details> 
  <summary><h3> Stuck? See hints here</h3></summary>
    Cipher: The file we recovered ending in .enc<br>
    IV: The IV is written to the file as well, it is usually prefixed (meaning the first 16 bytes is the IV)<br>
    Mode: CBC<br>
    padding: PKCS7<br>
    Key: Obfuscated and written to an Alternate data stream to the file<br>
</details>


#### 5.1 Finding and reading Alternate Data Streams
You can find alternate data streams by looking at the MFT output   
(try sorting the column "IsADS")  
Recover the file in the same way you would recover a deleted file. fls -> find inode -> icat > file  
Note you can recover the ADS itself right away

### 6 Recover the encrypted file

Use all the components to recover the encrypted file.  

Feel free to use AI to generate a generic AES decryption function and just paste your values.

### 7 Want more?

Try to answer these questions

* What was the original filename of the encrypted file?
* What does it mean that the modified timestamp is BEFORE the created timestamp?
* How would you delete something without any chance of recovery?
