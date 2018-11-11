ToDoView = require './to-do-view'
{CompositeDisposable} = require 'atom'

module.exports = ToDo =
  toDoView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @toDoView = new ToDoView(state.toDoViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @toDoView.getElement(), visible: false)

    # Events subscribed to an atom's system can be easily cleaned up with a CompositeDisposable
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
    # Close panel and exit if toggling it off
    if @modalPanel.isVisible()
      @modalPanel.hide()
      return

    # Get current editor and scope
    currentEditor = atom.workspace.getActiveTextEditor()
    currentScope = currentEditor.getRootScopeDescriptor().toString()

    # Create regex variables for TODO tags and block comments
    todoTags = "(DONE:|)(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)"
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

    # Create array to contain TODOs
    allTodos = []

    createTodoList = (ln, todoText) ->
      # Check if current line is not empty and is a comment
      if not todoText
        return
      else if not currentEditor.isBufferRowCommented(ln-1)
        return

      # Search for all possible TODOs tags
      if ///#{todoTags}[:;.,].+///.test(todoText)
        # Get TODO index
        idx = todoText.search(///#{todoTags}///)

        # Get TODO type
        todoType = todoText.match(///#{todoTags}///)[0]

        # Strip and remove comment keywords
        todoText = todoText.replace(/(^\s+|\s+$)/g, "")
        todoText = todoText.replace(///^.*#{todoTags}[:;.,]\s*///, "")
        todoText = todoText.replace(///\s*#{commentEnd}\s*$///, "") if commentEnd

        allTodos.push [ln, idx, todoType, todoText]

    # Check each line of the buffer
    createTodoList(x+1, currentEditor.lineTextForBufferRow(x)) for x in [0..currentEditor.getLineCount()]

    # Sort by type then line
    allTodos.sort (a,b) ->
      return (a[2] + a[0] > b[2] + b[0])

    # Save TODOs and show panel
    @toDoView.setTodos(allTodos)
    @modalPanel.show()

  saved: ->
    #console.log 'yo yo yo'
