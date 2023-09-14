function on_rcmd_pressed() -- Called when r-command key is pressed
    print("r-cmd has been pressed!")
end

function on_rcmd_released() -- Called when r-command key is released
    print("r-cmd has been released")
end

function on_rcmd_event(msg) -- Called when rcmd text has changed or been finalized
    print("rcmd has send: ", msg)
end
