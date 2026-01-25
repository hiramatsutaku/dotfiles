function peco-ghostty-switch () {
    local windows=$(osascript -e 'tell application "System Events"
        tell process "ghostty"
            set output to ""
            set windowList to every window
            repeat with i from 1 to count of windowList
                set w to item i of windowList
                set output to output & i & "	" & (name of w) & "
"
            end repeat
            return output
        end tell
    end tell' 2>/dev/null)

    # CC ステータスを追加: ✳ があれば [CC] を付与
    local formatted=$(echo "$windows" | while IFS=$'\t' read -r idx title; do
        if [[ "$title" == *"✳"* ]]; then
            echo -e "$idx\t[CC] $title"
        else
            echo -e "$idx\t     $title"
        fi
    done)

    local selected=$(echo "$formatted" | peco --prompt="Ghostty> ")

    if [ -n "$selected" ]; then
        local index=$(echo "$selected" | cut -f1)
        osascript -e "tell application \"System Events\"
            tell process \"ghostty\"
                set frontmost to true
                set w to window $index
                perform action \"AXRaise\" of w
            end tell
        end tell"
    fi
    zle clear-screen
}
zle -N peco-ghostty-switch
