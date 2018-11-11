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
    todoTags = "(DONE:|)(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)"
    allTodos = []

    commentEnd = switch currentScope
      when ".source.gfm", ".source.html", ".source.css", ".source.css.less", ".source.php", ".text.html.php"
        '-->'
      when ".source.python", ".source.yaml"
        '(|"""|\'\'\')'
      when ".source.coffee"
        '###'
      when ".source.cpp", ".source.c", ".source.js", ".source.go"
        '\\*/'
      else
        ''

    createTodoList = (ln, todoText) ->
      # Check if current line is not empty and is a comment
      if not todoText
        return
      else if not currentEditor.isBufferRowCommented(ln-1)
        return

      # Search for all possible TODOs tags
      if ///#{todoTags}[:;.,].+///.test(todoText)
        # get TODO index
        idx = todoText.search(///#{todoTags}///)

        # get TODO type
        todoType = todoText.match(///#{todoTags}///)[0]

        # strip and remove comment keywords
        todoText = todoText.replace(/(^\s+|\s+$)/g, "")
        todoText = todoText.replace(///^.*#{todoTags}[:;.,]\s*///, "")
        todoText = todoText.replace(///\s*#{commentEnd}\s*$///, "") if commentEnd

        allTodos.push [ln, idx, todoType, todoText]

    createTodoList(x+1, currentEditor.lineTextForBufferRow(x)) for x in [0..currentEditor.getLineCount()]

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      # sort by type then line
      allTodos.sort (a,b) ->
        return (a[2] + a[0] > b[2] + b[0])
      @toDoView.setTodos(allTodos)
      @modalPanel.show()

  saved: ->
    #console.log 'yo yo yo'
