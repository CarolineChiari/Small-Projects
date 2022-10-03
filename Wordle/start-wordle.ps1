# Pseudo code
# 1. Load english words (5 letters)
# 2. Pick a random word
# 3. Ask player to guess word
# 4. Check if word is valid (English & 5 letters long)
# 5. Check the letters to make sure they are in the right place
# 6. Highlight proper letters (Correct position or in the word)
# 7. Repeat 3 -> 6 until word is correct or too many guesses (6)
# Word.txt can be found here: https://github.com/dwyl/english-words
param(
    [int]$WordLength = 5,
    [int]$NumberOfGuesses = 6,
    [switch]$Infinite
)


function Get-Characters {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Word
    )
    $result = @()
    for ($i = 0; $i -lt $word.Length; $i++) {
        $result += $word.Substring($i, 1)
        # "string" --> @("s","t","i","n","g")
    }
    return $result
}

# 1. Load english words (5 letters)
$words = Get-Content ./words.txt | Where-Object { $_.length -eq $wordLength -and $_ -cmatch "^[a-z]{$wordLength}" }

do{
    # 2. Pick a random word
    $wordToGuess = $words[(get-random -Minimum 0 -Maximum $words.count)]
    $wordToGuessChars = Get-Characters -Word $wordToGuess
    # write-host $wordToGuess

    $guesses = 1
    $correctGuess = $false
    $incorrectLetters = @()
    do {
        # 3. Ask player to guess word
        $guessPrompt = "$guesses. Guess the word"
        $guess = Read-Host -Prompt $guessPrompt

        # 4. Check if word is valid (English & 5 letters long)
        if ($guess.length -eq $wordLength -and $words -contains $guess) {
            $guesses++
            if ($guess -eq $wordToGuess) {
                $correctGuess = $true
            }
            $guessChars = Get-Characters -Word $guess

            # 5. Check the letters to make sure they are in the right place
            for ($i = 0 ; $i -lt $guessChars.count; $i++){
                $letter = $guessChars[$i]
                if ($wordToGuessChars -contains $letter){
                    $correctPlace = $false
                    if ($wordToGuessChars[$i] -eq $letter){
                        $correctPlace = $true
                    }
                    # 6. Highlight proper letters (Correct position or in the word)
                    $Host.UI.RawUI.CursorPosition = @{
                        X = $guessPrompt.length + 2 + $i
                        Y = $Host.UI.RawUI.CursorPosition.Y - 1
                    }
                    $color = "Yellow"
                    if ($correctPlace){
                        $color = "Green"
                    }
                    write-host $letter -backgroundcolor $color
                }else{
                    $incorrectLetters += $letter
                }
            }
            $Host.UI.RawUI.CursorPosition = @{
                X = $guessPrompt.length + 2 + $wordLength + 5
                Y = $Host.UI.RawUI.CursorPosition.Y - 1
            }
            write-host "Bad Letters: " -foregroundcolor "red" -nonewline
            $incorrectLetters = $incorrectLetters | sort-object -unique
            foreach ($letter in $incorrectLetters){
                write-host $letter -nonewline
            }
            write-host ""
        }
    # 7. Repeat 3 -> 6 until word is correct or too many guesses (6)
    }while ($guesses -le $NumberOfGuesses -and -not $correctGuess)
    if ($correctGuess){
        write-host "Good job!" -foregroundcolor "Green"
    }else{
        write-host "Better luck next time..." -foregroundcolor "Blue"
    }
}while($infinite)