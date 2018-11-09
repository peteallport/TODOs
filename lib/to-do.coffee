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
      # Search for all possible TODOs tags
      containsTODO = /(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/.test(todoText)
      if containsTODO
        # get TODOs type
        todoType = todoText.match(/(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/)[0]
        todoType = todoType.replace(/[:;.,]$/, "")

        # get TODOs text
        todoText = todoText.replace(/(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/, "")
        todoText = todoText.replace(/^\s+|\s+$/, "")       # strip spaces
        todoText = todoText.replace(/^#+/, "")             # hashtag comment (Python, CoffeeScript, shell, etc...)
        todoText = todoText.replace(/^\"\"\"|\"\"\"$/, "") # Python multiline comment 1
        todoText = todoText.replace(/^\'\'\'|\'\'\'$/, "") # Python multiline comment 2
        todoText = todoText.replace(/^\/\//, "")           # C++ single line comment
        todoText = todoText.replace(/^\/\*|\*\/$/, "")     # C++ multiline comment
        todoText = todoText.replace(/^<!--|-->$/, "")      # html comment
        todoText = todoText.replace(/^\s+|\s+$/, "")       # strip spaces

        # push TODOs type, line and text
        allTodos.push todoType + ': ' + 'Line ' + ln + ': ' + todoText

    createTodoList(x+1, currentEditor.lineTextForBufferRow(x)) for x in [0..currentEditor.getLineCount()]

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @toDoView.setTodos(allTodos)
      @modalPanel.show()

  saved: ->
    #console.log 'yo yo yo'
