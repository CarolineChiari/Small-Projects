param (
    [int]$wordLength = 5,
    [switch]$infinite,
    [int]$guesses = 5
)
#convert string to array of letters
function get-characters {
    param(
        $word
    )
    $res = @()
    for ($i = 0; $i -lt $word.length; $i++) {
        $res += $word.substring($i, 1)
    }
    return $res
}
#location for the list of words
$wordsLocation = "C:\users\Caroline\downloads\english.txt"

# get the words that have the right lengths
$words = get-content $wordsLocation | Where-Object { $_.length -eq $wordLength -and $_ -match "^[a-z]+" }

do {
    # Initialize the game
    # pick a word at a random index
    $word = $words[(Get-Random -Minimum 0 -Maximum $words.count)]
    $wordLetters = get-characters -word $word

    $correctGuess = $false
    $guessNumber = 0 
    $badGuesses = @()
    while (-not $correctGuess -and $guessNumber -lt $guesses) {
        # Ask for a guess
        $prompt = "$guessNumber`. Enter your guess"
        $guess = Read-Host $prompt

        # Check if guess is the correct length and is an actual word
        if ($guess.length -eq $wordLength -and $words -contains $guess) {
            if ($guess -eq $word) { # if the guess is correct
                $correctGuess = $true
            }
            $guessNumber++
            # Get the guess letters
            $guessLetters = get-characters $guess
            
            $i = 0 

            # Write the colors for the letters
            # Get where the cursor currently is
            $cursorColor = $host.UI.RawUI.BackgroundColor
            $cursorPosition = $host.UI.RawUI.CursorPosition
            #check each letter to make sure it is in the word, and if it is correctly placed
            foreach ($letter in $guessLetters) {
                $correct = $false
                $misplaced = $false
                if ($wordLetters -contains $letter) {
                    if ($wordLetters[$i] -eq $letter) {
                        $correct = $true
                    }
                    else {
                        $misplaced = $true
                    }
                }
                #update the letters
                # move the letter to the current letter position
                $host.UI.RawUI.CursorPosition = @{X = $i + $prompt.length + 2; Y = $cursorPosition.Y - 1 }

                # Set the background color for the letter
                if ($correct) {
                    $host.UI.RawUI.BackgroundColor = "green"
                }
                elseif ($misplaced) {
                    $host.UI.RawUI.BackgroundColor = "yellow"
                }
                else {
                    $badGuesses += $letter 
                    $badGuesses = $badGuesses | Sort-Object -Unique
                }

                # set the background for the letter
                write-host $letter
                $host.UI.RawUI.BackgroundColor = $cursorColor
                $host.UI.RawUI.CursorPosition = $cursorPosition
                $i++
            }

            # Write the bad letter guesses
            # Move the cursor to the end of the prompt
/            $host.UI.RawUI.CursorPosition = @{X = $i + $prompt.length + 2 + $wordLength + 3; Y = $cursorPosition.Y - 1 }
            write-host "Bad Guesses: " -NoNewline -ForegroundColor Red
            foreach ($badLetter in $badGuesses) {
                write-host $badLetter -NoNewline
            }
            write-host ""
        }
    }
    write-host $word
}while ($infinite)
