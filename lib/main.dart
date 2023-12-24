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

  var name;
  var author;
  var startDate;
  var endDate;

  @override
  void initState() {
    super.initState();
    fetchData();
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
                  TextField(decoration: const InputDecoration(hintText: "Start Date YYYY-MM-DD"), onChanged: (value) => startDate = value, ),
                  TextField(decoration: const InputDecoration(hintText: "End Date YYYY-MM-DD"), onChanged: (value) => endDate = value, ),
                  Row(children: [Container(margin: const EdgeInsets.all(10),child: ElevatedButton(onPressed: () {addData(context);}, child: const Text("Add Data"))), Container(margin: const EdgeInsets.all(10),child: ElevatedButton(onPressed: () {Phoenix.rebirth(context);}, child: const Text("Reload App")))])
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
              )
              
              
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
      start_date: startDate,
      end_date: endDate
    );
    if (data.name == "" || data.author == "" || data.start_date == "" || data.end_date == "") {
      return;
    }
    Database database = await getConnection();
    await insertData(database, 1, data);
    print("Added data: $data");
    database.close();
  }

}



