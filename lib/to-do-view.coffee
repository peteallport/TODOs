module.exports =
class ToDoView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('todos')

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  setTodos: (todoItem) ->
    @element.textContent = ""
    title = document.createElement('div')
    title.textContent = "TODOs in this file ("+todoItem.length+"):"
    title.classList.add('title')
    @element.appendChild(title)
    master = document.createElement('div')
    currentEditor = atom.workspace.getActiveTextEditor()

    runList = (text) ->
      message = document.createElement('div')
      todoText = document.createElement('span')

      message.type = 'button'
      message.onclick = () ->
        cursor = currentEditor.getCursorBufferPosition()
        currentEditor.setCursorBufferPosition([text[0]-1, text[1]+text[2].length])
        if cursor.row == text[0] - 1
          currentEditor.moveLeft(text[2].length)
          tag = currentEditor.getTextInBufferRange([[text[0]-1, text[1]], [text[0]-1, text[1]+5]])
          if tag == 'DONE:'
            currentEditor.setTextInBufferRange([[text[0]-1, text[1]], [text[0]-1, text[1]+5]], '')
          else
            currentEditor.insertText('DONE:')

      todoText.textContent = "#{text[2]}: Line #{text[0]}: #{text[3]}"

      message.classList.add('todoItem')
      message.appendChild(todoText)

      master.appendChild(message)

    runList(x) for x in todoItem
    @element.appendChild(master)
    title.textContent = "Looks like you don't have any TODOs..." unless todoItem.length
