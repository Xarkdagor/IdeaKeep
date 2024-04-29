import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/models/note.dart';
import 'package:notes/models/note_database.dart';
import 'package:notes/note_setting.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // text controller to access what the user typed
  final textController = TextEditingController();
  @override
  void initState() {
    super.initState();

    readNotes();
  }

  // create a note
  void createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        content: TextField(
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              hintText: "Type your note here"),
          controller: textController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              // add to db
              context.read<NoteDatabase>().addNote(textController.text);
              //clear the controller
              textController.clear();
              // pop the dialog
              Navigator.pop(context);
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }
  // Read a note

  void readNotes() async {
    await context.read<NoteDatabase>().fetchNotes();
  }

  // update a note

  void updateNote(Note note) {
    // pre-fill the current note text

    textController.text = note.text;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.green[100],
              title: Text(
                "Update note",
                style: GoogleFonts.sacramento(
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context
                        .read<NoteDatabase>()
                        .updateNote(note.id, textController.text);

                    // clear controller
                    textController.clear();

                    // pop the box after tapping the button
                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                )
              ],
            ));
  }

  // delete a note

  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  List<Color> tileColors = [
    Colors.blue[100]!,
    Colors.teal[100]!,
    Colors.green[100]!,
    Colors.amber[100]!,
    Colors.pink[100]!,
    Colors.indigo[100]!,
    Colors.deepPurple[100]!,
    Colors.lime[100]!
    // ... more colors as needed
  ];

  @override
  Widget build(context) {
    final noteDatabase = context.watch<NoteDatabase>();
    List currentNotes = noteDatabase.currentNotes;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "IdeaKeep",
            style: GoogleFonts.sacramento(
                textStyle:
                    const TextStyle(fontSize: 35, fontWeight: FontWeight.w900)),
          ),
        ),
        backgroundColor: Colors.green[100],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNote,
        backgroundColor: Colors.green[100],
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 20),
            child: Text(
              "Notes",
              style: GoogleFonts.sacramento(
                textStyle: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: currentNotes.length,
                itemBuilder: (context, index) {
                  final note = currentNotes[index];
                  final tileColor = tileColors[index % tileColors.length];

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                          title: Text(
                            note.text,
                            style: GoogleFonts.tangerine(
                                textStyle: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700)),
                          ),
                          trailing: Builder(builder: (context) {
                            return IconButton(
                                onPressed: () => showPopover(
                                    height: 100,
                                    width: 100,
                                    context: context,
                                    bodyBuilder: (context) => NoteSettings(
                                          onEditTap: () => updateNote(note),
                                          onDeleteTap: () =>
                                              deleteNote(note.id),
                                        )),
                                icon: const Icon(Icons.more_vert));
                          })),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
