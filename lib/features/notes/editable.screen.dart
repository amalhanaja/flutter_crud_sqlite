import 'package:flutter/material.dart';
import 'package:notes/features/notes/model.dart';
import 'package:notes/features/notes/repository.dart';

const EdgeInsetsGeometry _kContentPadding =
    EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0);

class EditableScreen extends StatefulWidget {
  final Note note;

  static Route getRoute(Note note) {
    return MaterialPageRoute(builder: (c) => EditableScreen(note: note));
  }

  const EditableScreen({Key key, this.note}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateEditableScreen();
}

class _StateEditableScreen extends State<EditableScreen> {
  FocusNode _contentFocusNode;
  Note _currentNote;
  NoteRepository _repo;
  TextEditingController _titleController, _contentController;

  @override
  void initState() {
    _currentNote = widget.note ?? Note();
    _contentFocusNode = FocusNode();
    _repo = NoteRepository();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleController.addListener(
        () => _updateNote(Note(title: _titleController.value.text)));
    _contentController.addListener(
        () => _updateNote(Note(content: _contentController.value.text)));
    if (widget.note != null) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: DateTime.now().toString(),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _isSubmitButtonEnabled ? _submitNote : null,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          TextField(
            controller: _titleController,
            style: Theme.of(context).textTheme.headline,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_contentFocusNode),
            decoration: InputDecoration(
              hintText: "Title",
              border: InputBorder.none,
              hintStyle: Theme.of(context)
                  .textTheme
                  .headline
                  .copyWith(color: Theme.of(context).hintColor),
              contentPadding: _kContentPadding,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              style: Theme.of(context).textTheme.body1,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: "Note",
                border: InputBorder.none,
                hintStyle: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Theme.of(context).hintColor),
                contentPadding: _kContentPadding,
              ),
            ),
          )
        ],
      ),
    );
  }

  _updateNote(Note note) {
    setState(() {
      _currentNote = _currentNote.copy(note);
    });
  }

  _submitNote() async {
    if (_currentNote.id == null) {
      await _repo
          .insertNote(_currentNote.copy(Note(createdAt: DateTime.now())));
    } else {
      await _repo.updateNote(_currentNote);
    }
    Navigator.of(context).pop();
  }

  bool get _isSubmitButtonEnabled {
    return _currentNote.content != null &&
        _currentNote.content.isNotEmpty &&
        _currentNote.title != null &&
        _currentNote.title.isNotEmpty;
  }
}
