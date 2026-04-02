import std/os, strutils

proc transform(text: string, key: int, mode: int): string =
    result = ""

    for i in text:
        let number = ord(i)

        var shifted = (number - 32 + (key * mode)) mod 94 
        if shifted < 0:
            shifted += 94
        result.add(chr(shifted + 32))

while true:
    echo "Wat wil je doen vandaag?"
    echo "0. Stoppen"
    echo "1. Informatie versleutelen"
    echo "2. Informatie ontsleutelen\n"
    let choice = readLine(stdin)
    if choice == "0" or choice == "s":
        break

    case choice:
    of "1":
        echo "1. Losse informatie encrypten"
        echo "2. Uit een bestand informatie encrypten"
        var choiceDecrypt = readLine(stdin)
        var fileName = ""
        var encryptedFile = ""

        case choiceDecrypt:
        of "1":
            stdout.write("Informatie: ")
            var input = readLine(stdin)
            stdout.write("Key: ")
            let key = readLine(stdin).parseInt

            encryptedFile = transform(input, key, 1)

            stdout.write("Hoe moet het bestand noemen: ")
            fileName = readLine(stdin)

            echo "Encrypted bericht opgeslaan in ", fileName, "\n"
            writeFile(fileName, encryptedFile)
        of "2":
            echo "Hoe noemt het bestand?"
            let fileNameIn = readLine(stdin)
            stdout.write("Key: ")
            let key = readLine(stdin).parseInt

            if fileExists(fileNameIn):
                let decryptedFile = readFile(fileNameIn)
                encryptedFile = transform(decryptedFile, key, 1)
                
                stdout.write("Hoe moet het bestand noemen: ")
                fileName = readLine(stdin)

                echo "Encrypted bericht opgeslaan in ", fileName, "\n"
                writeFile(fileName, encryptedFile)
            else:
                echo "Er is geen bestand met deze naam."
    of "2":
        echo "1. Losse informatie ingeven"
        echo "2. Uit een bestand informatie halen"
        var choiceDecrypt = readLine(stdin)

        case choiceDecrypt:
        of "1":
            stdout.write("Informatie: ")
            var input = readLine(stdin)
            stdout.write("Key: ")
            let key = readLine(stdin).parseInt
            
            let decryptedFile = transform(input, key, -1)
            echo decryptedFile, "\n"

        of "2":
            echo "Hoe noemt het bestand?"
            let fileName = readLine(stdin)
            stdout.write("Key: ")
            let key = readLine(stdin).parseInt

            if fileExists(fileName):
                let encryptedFile = readFile(fileName)
                let decryptedFile = transform(encryptedFile, key, -1)
                
                echo decryptedFile, "\n"

            else:
                echo "Er is geen bestand met deze naam."