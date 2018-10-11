import 'package:flutter/material.dart';
import 'package:notes/features/notes/editable.screen.dart';
import 'package:notes/features/notes/repository.dart';
import 'package:notes/features/notes/model.dart';

class ListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateListScreen();
}

class _StateListScreen extends State<ListScreen> with WidgetsBindingObserver {
  NoteRepository _repo;
  List<Note> _noteList;
  FocusNode _searchFocusNode;
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _repo = NoteRepository();
    _searchFocusNode = FocusNode();
    _searchController = TextEditingController();
    _searchController.addListener(() =>
        setState(() => _noteList.forEach((note) => note.isSelected = false)));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isMultiSelect) {
          setState(() {
            _noteList.forEach((note) => note.isSelected = false);
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Container(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                _isMultiSelect
                    ? _buildMultiSelectActionButton("Cancel", _deselectAllNote)
                    : Container(),
                Expanded(
                    child: Center(
                  child: Text("Notes"),
                )),
                _isMultiSelect
                    ? _buildMultiSelectActionButton(
                        "Select All",
                        _selectAllNote,
                      )
                    : Container(),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Container(
              height: 48.0,
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Search Note",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26, width: 1.0),
                    gapPadding: 0.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 1.0),
                    gapPadding: 0.0,
                  ),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: _repo.searchNote(_searchController.value.text.trim()),
          builder: (c, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              if (!_isMultiSelect) {
                _noteList = snapshot.data;
              }
              return _buildList(_noteList);
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        bottomNavigationBar:
            _isMultiSelect ? _buldMultiSelectBottomActionButton() : null,
        floatingActionButton:
            _isMultiSelect ? null : _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildList(List<Note> notes) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) =>
          _buildRow(context, notes[index], index, notes.length - 1),
      itemCount: notes.length,
    );
  }

  Widget _buildRow(BuildContext context, Note note, int index, int lastIndex) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: note.isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent),
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: index == 0 ? 8.0 : 4.0,
          bottom: index == lastIndex ? 8.0 : 4.0),
      child: InkWell(
        onTap: _isMultiSelect
            ? () => _updateSelectableNote(note)
            : () => _editNote(note),
        onLongPress: () {
          _updateSelectableNote(note);
        },
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Text(
                  note.title,
                  style: Theme.of(context)
                      .textTheme
                      .body2
                      .copyWith(fontWeight: FontWeight.w900),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4.0, bottom: 8.0),
                width: double.infinity,
                child: Text(
                  note.content,
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(note.createdAt.toIso8601String()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buldMultiSelectBottomActionButton() {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        border: Border(
          top: Divider.createBorderSide(context, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: ButtonTheme.bar(
          child: SafeArea(
            top: false,
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _repo.deleteNote(
                      _noteList.where((n) => n.isSelected).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectActionButton(String text, VoidCallback onPressed,
      {Key key}) {
    return ButtonTheme(
      key: key,
      minWidth: 100.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        side: BorderSide(color: Colors.white),
      ),
      child: FlatButton(
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () =>
          Navigator.of(context).push(EditableScreen.getRoute(null)),
    );
  }

  _editNote(Note note) {
    Navigator.of(context).push(EditableScreen.getRoute(note));
  }

  _updateSelectableNote(Note note) {
    _dismissKeyboard();
    setState(() => note.isSelected = !note.isSelected);
  }

  bool get _isMultiSelect {
    if (_noteList == null) return false;
    return _noteList.where((n) => n.isSelected).length != 0;
  }

  _selectAllNote() {
    _dismissKeyboard();
    _searchFocusNode.unfocus();
    setState(() => _noteList.forEach((note) => note.isSelected = true));
  }

  _deselectAllNote() {
    _dismissKeyboard();
    _searchFocusNode.unfocus();
    setState(() => _noteList.forEach((note) => note.isSelected = false));
  }

  _dismissKeyboard() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }
}
