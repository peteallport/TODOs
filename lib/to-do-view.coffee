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
      textButton = document.createElement('span')

      gotoTodo = () ->
        currentEditor.setCursorBufferPosition([text[0], 0])

      textButton.type = 'button'
      textButton.textContent = text[1]
      textButton.onclick = gotoTodo

      message.classList.add('todoItem')
      message.appendChild(textButton)

      master.appendChild(message)

    runList(x) for x in todoItem
    @element.appendChild(master)
    title.textContent = "Looks like you don't have any TODOs..." unless todoItem.length
