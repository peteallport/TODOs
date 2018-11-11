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

    runList = (todo) ->
      message = document.createElement('div')
      todoText = document.createElement('span')

      message.type = 'button'
      message.onclick = () ->
        currentEditor.setCursorBufferPosition([todo[0]-1, todo[1]+todo[2].length])
      message.ondblclick = () ->
        currentEditor.setCursorBufferPosition([todo[0]-1, todo[1]])
        if currentEditor.getTextInBufferRange([[todo[0]-1, todo[1]], [todo[0]-1, todo[1]+5]]) == 'DONE:'
          currentEditor.setTextInBufferRange([[todo[0]-1, todo[1]], [todo[0]-1, todo[1]+5]], '')
          todoText.textContent = "#{todo[2]}: Line #{todo[0]}: #{todo[3]}"
        else
          currentEditor.insertText('DONE:')
          todoText.textContent = "DONE:#{todo[2]}: Line #{todo[0]}: #{todo[3]}"

      todoText.textContent = "#{todo[2]}: Line #{todo[0]}: #{todo[3]}"

      message.classList.add('todoItem')
      message.appendChild(todoText)

      master.appendChild(message)

    runList(x) for x in todoItem
    @element.appendChild(master)
    title.textContent = "Looks like you don't have any TODOs..." unless todoItem.length
