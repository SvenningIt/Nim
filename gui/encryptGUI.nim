import nigui, strutils

proc transform(text: string, key: int, mode: int): string =
    result = ""

    for i in text:
        let number = ord(i)

        var shifted = (number - 32 + (key * mode)) mod 94 
        if shifted < 0:
            shifted += 94
        result.add(chr(shifted + 32))

app.init()

var window = newWindow("Crypter")
window.width = 600.int
window.height = 400.int

var mainContainer = newLayoutContainer(Layout_Vertical)
window.add(mainContainer)

#input
mainContainer.add(newLabel("Bericht: "))
var inputArea = newTextArea()
mainContainer.add(inputArea)

#key
var keyContainer = newLayoutContainer(Layout_Horizontal)
mainContainer.add(keyContainer)
keyContainer.add(newLabel("Sleutel: "))

var keyInput = newTextBox("0")
keyInput.width = 50.int
var btnUp = newButton("▲")
btnUp.height = 30.int
btnUp.width = 30.int
var btnDown = newButton("▼")
btnDown.height = 30.int
btnDown.width = 30.int

keyContainer.add(btnUp)
keyContainer.add(keyInput)
keyContainer.add(btnDown)

btnUp.onClick = proc(event: ClickEvent) =
  let currentKey = keyInput.text.parseInt()
  keyInput.text = $(currentKey + 1)

btnDown.onClick = proc(event: ClickEvent) =
  let currentKey = keyInput.text.parseInt()
  keyInput.text = $(currentKey - 1)

#buttons
var btnContainer = newLayoutContainer(Layout_Horizontal)
mainContainer.add(btnContainer)

var btnEncrypt = newButton("Encrypt")
btnContainer.add(btnEncrypt)
var btnDecrypt = newButton("Decrypt")
btnContainer.add(btnDecrypt)

#output
mainContainer.add(newLabel("Resultaat: "))
var outputArea = newTextArea()
outputArea.editable = false
mainContainer.add(outputArea)

btnEncrypt.onClick = proc(event: ClickEvent) =
  try:
    let message = inputArea.text
    let key = keyInput.text.parseInt()
    outputArea.text = transform(message, key, 1)
  except ValueError:
    outputArea.text = "💀!"

btnDecrypt.onClick = proc(event: ClickEvent) =
  try:
    let message = inputArea.text
    let key = keyInput.text.parseInt()
    outputArea.text = transform(message, key, -1)
  except ValueError:
    outputArea.text = "💀!"

window.show()
app.run()