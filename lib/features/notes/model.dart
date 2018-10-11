class Note extends Object {
  static const TABLE_NAME = "notes";
  static const COL_ID = "_id";
  static const COL_TITLE = "_title";
  static const COL_CONTENT = "_content";
  static const COL_IS_PINNED = "_isPinned";
  static const COL_CREATED_AT = "_createdAt";
  static const COL_MODIFIED_AT = "_modifiedAt";
  static const COL_DELETED_AT = "_deletedAt";
  static const COL_CATEGORY_ID = "categoryId";

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map[COL_ID],
      title: map[COL_TITLE],
      content: map[COL_CONTENT],
      isPinned: map[COL_IS_PINNED] != 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map[COL_CREATED_AT]),
      modifiedAt: map[COL_MODIFIED_AT] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[COL_MODIFIED_AT])
          : null,
      deletedAt: map[COL_DELETED_AT] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[COL_DELETED_AT])
          : null,
      categoryId: map[COL_CATEGORY_ID],
    );
  }

  Note({
    this.id,
    this.title,
    this.content,
    this.isPinned: false,
    this.createdAt,
    this.modifiedAt,
    this.deletedAt,
    this.categoryId,
  });
  final int id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime deletedAt;
  final int categoryId;
  bool isSelected = false;

  Note copy(Note note) {
    return Note(
      id: note.id ?? id,
      title: note.title ?? title,
      content: note.content ?? content,
      isPinned: note.isPinned ?? isPinned,
      createdAt: note.createdAt ?? createdAt,
      modifiedAt: note.modifiedAt ?? modifiedAt,
      deletedAt: note.deletedAt ?? deletedAt,
      categoryId: note.categoryId ?? categoryId,
    );
  }

  Map<String, dynamic> toMap() => {
        COL_ID: id,
        COL_TITLE: title,
        COL_CONTENT: content,
        COL_IS_PINNED: isPinned != null ? isPinned ? 1 : 0 : 0,
        COL_CREATED_AT: createdAt.millisecondsSinceEpoch,
        COL_MODIFIED_AT: modifiedAt != null ? modifiedAt.millisecondsSinceEpoch : null,
        COL_DELETED_AT: deletedAt != null ? deletedAt.millisecondsSinceEpoch : null,
        COL_CATEGORY_ID: categoryId,
      };

  @override
  bool operator ==(other) {
    return id == other.id &&
        title == other.title &&
        content == other.content &&
        isPinned == other.isPinned &&
        createdAt == other.createdAt &&
        modifiedAt == other.modifiedAt &&
        deletedAt == other.deletedAt &&
        categoryId == other.categoryId;
  }
}
