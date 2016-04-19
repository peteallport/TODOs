ToDoView = require './to-do-view'
{CompositeDisposable} = require 'atom'

module.exports = ToDo =
  toDoView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @toDoView = new ToDoView(state.toDoViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @toDoView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # TODO: refine code to look fucking sexy
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'todos:toggle': => @toggle()

    subscription = atom.workspace.getActiveTextEditor().onDidSave (change) ->
      #console.log 'titties'

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @toDoView.destroy()

  serialize: ->
    toDoViewState: @toDoView.serialize()

  toggle: ->
    currentEditor = atom.workspace.getActiveTextEditor()
    allTodos = []
    createTodoList = (ln, todoText) ->
      containsTODO = /TODO:/.test(todoText)
      if containsTODO
        todoText = todoText.replace(/TODO:/, "")
        todoText = todoText.replace(/^\s+|\s+$/, "")
        todoText = todoText.replace(/#/, "")
        todoText = todoText.replace(/\/*/, "")
        todoText = todoText.replace(/<!--/, "")
        todoText = todoText.replace(/-->/, "")
        todoText = todoText.replace(/\/\//, "")
        allTodos.push 'Line '+ln + ': ' + todoText

    createTodoList(x+1, currentEditor.lineTextForBufferRow(x)) for x in [0..currentEditor.getLineCount()]

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @toDoView.setTodos(allTodos)
      @modalPanel.show()

  saved: ->
    #console.log 'yo yo yo'
