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
    todoTags = "(TODO|FIXME|CHANGED|XXX|IDEA|HACK|NOTE|REVIEW|NB|BUG|QUESTION|COMBAK|TEMP|DEBUG|OPTIMIZE|WARNING)"
    allTodos = []

    # declare opening and closing comment keywords
    reComment = switch currentScope
      when ".source.gfm", ".source.html", ".source.css", ".source.css.less"
        ['<!--', '-->']
      when ".source.python", ".source.yaml"
        ['(#|"""|\'\'\')', '(|"""|\'\'\')']
      when ".source.coffee"
        ['(###|#)', '(###|)']
      when ".source.cpp", ".source.c", ".source.js", ".source.go"
        ['(//|/\\*)', '(|\\*/)']
      when ".source.haskell"
        ['--', '']
      when ".source.php", ".text.html.php"
        ['(#|//|<!--)', '(|-->)']
      when ".source.shell"
        ['#', '']
      else
        ['.*', '.*']

    createTodoList = (ln, todoText) ->
      # Search for all possible TODOs tags
      if ///^\s*#{reComment[0]}\s*#{todoTags}[:;.,]?.+#{reComment[1]}\s*$///.test(todoText)
        # strip and remove comment keywords
        todoText = todoText.replace(/(^\s+|\s+$)/g, "")
        todoText = todoText.replace(///^#{reComment[0]}\s*///, "") unless reComment[0] == ".*"
        todoText = todoText.replace(///\s*#{reComment[1]}$///, "") unless reComment[1] == ".*"

        # get TODO type
        todoType = todoText.match(///#{todoTags}///)[0]

        # get TODO text
        todoText = todoText.replace(///\s*#{todoTags}[:;.,]?\s*///, "") unless reComment[0] == ".*"

        allTodos.push "#{todoType}: Line #{ln}: #{todoText}"

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
