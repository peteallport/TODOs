module.exports =
class ToDoView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('to-do')

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

    runList = (text) ->
      message = document.createElement('div')
      textSpan = document.createElement('span')
      # checkbox = document.createElement('input')
      # checkbox.type = "checkbox"
      textSpan.textContent = text   #textSpan.textContent = " " + text
      message.classList.add('todoItem')
      #message.appendChild(checkbox)
      message.appendChild(textSpan)
      #console.log(master)
      master.appendChild(message)

    runList(x) for x in todoItem
    @element.appendChild(master)
    title.textContent = "Looks like you don't have any TODOs..." unless todoItem.length
