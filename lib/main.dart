import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'models/book.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
void main() {
  runApp(Phoenix(child: const MaterialApp(home: MyApp())));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(190, 0, 30, 71),
          centerTitle: true,
          titleTextStyle: GoogleFonts.patrickHand(
            fontSize: 35,
            
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 225, 225, 225)
          ),
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 108, 180, 239), background: Color.fromARGB(255, 255, 255, 250)),  
        
        primaryColor: const Color.fromARGB(255, 214, 214, 214),
        highlightColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      
      textSelectionTheme: const TextSelectionThemeData(selectionColor: Color.fromARGB(255, 121, 121, 121))
        
      ),
      themeMode: ThemeMode.dark,

      debugShowCheckedModeBanner: false,
      title: "FBooks",
      home: const Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});
  @override
  PageExtends createState() => PageExtends();
}

class PageExtends extends State<Page> {
  List<Book> books = [];
  bool loading = true;
  Future fetchData() async {
    Database database = await getConnection();
    var tempd = await getRawData(database, 1);
    for (var temp in tempd) {
      books.add(Book.fromJson(temp));
    }
    setState(() {
      loading = false;
    });
  }

  var search_type;
  var search_query;
  var name;
  var author;
  DateTime StartDate = DateTime.now();
  DateTime EndDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> _selectDateForStart(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: StartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != StartDate) {
      setState(() {
        StartDate = picked;
      });
    }
  }

  Future<void> _selectDateForEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: EndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != EndDate) {
      setState(() {
        EndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    
    
    return Scaffold (
        appBar: AppBar(title: const Text("FBooks")),
        body: Center(
          child: SingleChildScrollView(child: Column(
          
          children: [


            Container(
              margin: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                
                children: [
                  const Text("Insert Data", textAlign: TextAlign.center, style: TextStyle(fontSize: 20),),
                  TextField(decoration: const InputDecoration(hintText: "Name"), onChanged: (value) => name = value,),
                  TextField(decoration: const InputDecoration(hintText: "Author"), onChanged: (value) => author = value,),
                  Row(children: [Text("Start Date: ${StartDate.toLocal()}".split(' ')[0], textAlign: TextAlign.center), TextButton(onPressed: () => _selectDateForStart(context), child: Text("${StartDate.toLocal()}".split(' ')[0]))]),
                  Row(children: [Text("End Date: ${EndDate.toLocal()}".split(' ')[0], textAlign: TextAlign.center), TextButton(onPressed: () => _selectDateForEnd(context), child: Text("${EndDate.toLocal()}".split(' ')[0]))]),
                  Row(children: [Container(margin: const EdgeInsets.all(10), child: ElevatedButton(onPressed: () {addData(context);}, child: const Text("Add Data"))), Container(margin: const EdgeInsets.all(10),child: ElevatedButton(onPressed: () {Phoenix.rebirth(context);}, child: const Text("Reload App")))]),
                  // Row(children: [TextField(decoration: const InputDecoration(hintText: "Search: Search Type, Search Query"), onChanged: (value) {search_query = value.split(",")[1]; search_type = value.split(",")[0];},), Container(margin: const EdgeInsets.all(10), child: ElevatedButton(onPressed: () {getData();}, child: const Text("Get Data")))],)
                ]
              )
              ),


            Container(
              margin: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child:SingleChildScrollView(scrollDirection: Axis.horizontal,child: DataTable(
                columnSpacing: 25,
                columns: const [
                  DataColumn(label: Text("ID", textAlign: TextAlign.center)),
                  DataColumn(label: Text("Name", textAlign: TextAlign.center)),
                  DataColumn(label: Text("Author", textAlign: TextAlign.center)),
                  DataColumn(label: Text("Start Date", textAlign: TextAlign.center)),
                  DataColumn(label: Text("End Date", textAlign: TextAlign.center)),
                ],
                rows: books.map<DataRow>((e) => DataRow(cells:[
                  DataCell(Text(e.id.toString(), textAlign: TextAlign.center,)),
                  DataCell(Text(e.name.toString(), textAlign: TextAlign.center,)),
                  DataCell(Text(e.author.toString(), textAlign: TextAlign.center,)),
                  DataCell(Text(e.start_date.toString(), textAlign: TextAlign.center,)),
                  DataCell(Text(e.end_date.toString(), textAlign: TextAlign.center,)),
                ]
                
                )).toList()
                ))
              ),
              ElevatedButton(child: const Text("DELETE ALL DATA"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red), foregroundColor: MaterialStateProperty.all(Colors.white)), onPressed: () {showDeleteDialog(context);},)
              
              
            ]
          )
        ),
      ));
  }
  void getData() async {
    Database database = await getConnection();
    var data = await getRawData(database, 1);
    print(data);
    database.close();
  }

  Future<Database> getConnection() async {
    // databaseFactory = databaseFactoryFfi;
    String databasesPath = await getDatabasesPath();
    String path = '${databasesPath}books.db';

    var database = await openDatabase(path, version: 1, onCreate: populateDb);
    return database;
  }
  void populateDb(Database database, int version) async {
    await database.execute("CREATE TABLE books ("
            "id INTEGER PRIMARY KEY,"
            "name VARCHAR(30),"
            "author VARCHAR(50),"
            "start_date DATE,"
            "end_date DATE"
            ");");
  }
  Future<List<Map<String, Object?>>> getRawData(Database database, int version) async {
    var books = await database.rawQuery("SELECT * FROM books;");
    return books;
  }
  Future insertData(Database database, int version, Book book) async {
    await database.execute(
      "INSERT INTO books (name, author, start_date, end_date) VALUES ('${book.name}','${book.author}','${book.start_date}','${book.end_date}')"
    );
    print(await getRawData(database, version));
  }

  void addData(context) async {
    var data = Book(
      id: 0,
      name: name,
      author: author,
      start_date: StartDate.toLocal().toString().split(' ')[0],
      end_date: EndDate.toLocal().toString().split(' ')[0]
    );
    if (data.name == "" || data.author == "" || data.start_date == "" || data.end_date == "") {
      return;
    }
    Database database = await getConnection();
    await insertData(database, 1, data);
    print("Added data: $data");
    database.close();
  }

  void deleteData() async {
    Database database = await getConnection();
    await database.execute("DELETE FROM books");
  }

  void showDeleteDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  const Text("Are you sure?"),
          content: const Text("Are you sure you want to delete all data?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(child: const Text("OK"), onPressed: () {deleteData(); Navigator.of(context).pop();},)
          ],
        );

      }
    );
  }

}



