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
    currentScope = currentEditor.getRootScopeDescriptor().toString()
    allTodos = []

    if currentScope in [".source.gfm", ".source.html", ".source.css", ".source.css.less"]
      reComment = ["^\s*<!--.+-->\s*$", "<!--", "-->"]
    else if currentScope in [".source.python", ".source.coffee", ".source.shell", ".source.yaml"]
      reComment = ["^#.+", "#", ""]
    else if currentScope == ".source.haskell"
      reComment = ["^--.+", "--", ""]
    else if currentScope in [".source.cpp", ".source.c", ".source.js", ".source.go"]
      reComment = ["^//.+", "//", ""]
    else
      reComment = ["", "", ""]

    createTodoList = (ln, todoText) ->
      # check if line is comment
      if todoText and todoText.search(reComment[0]) == -1
        return

      # Search for all possible TODOs tags
      containsTODO = /(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/.test(todoText)
      if containsTODO
        # get TODOs type
        todoType = todoText.match(/(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/)[0]
        todoType = todoType.replace(/[:;.,]$/, "")

        # get TODOs text
        todoText = todoText.replace(/(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)[:;.,]?/, "")

        # remove comment keywords and strip
        todoText = todoText.replace(/(^\s+|\s+)$/g, "")
        todoText = todoText.replace(reComment[1], "")
        todoText = todoText.replace(reComment[2], "")
        todoText = todoText.replace(/(^\s+|\s+)$/g, "")

        allTodos.push todoType + ': ' + 'Line ' + ln + ': ' + todoText

    createTodoList(x+1, currentEditor.lineTextForBufferRow(x)) for x in [0..currentEditor.getLineCount()]

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      # sort by type then line
      allTodos.sort (a,b) ->
        return (a > b)
      @toDoView.setTodos(allTodos)
      @modalPanel.show()

  saved: ->
    #console.log 'yo yo yo'
