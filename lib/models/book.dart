class Book {
    int id;
    String name;
    String author;
    String start_date;
    String end_date;

    Book({
        required this.id,
        required this.name,
        required this.author,
        required this.start_date,
        required this.end_date,
    });


    factory Book.fromJson(Map<String, dynamic> data) => Book(
        id: data["id"],
        name: data["name"],
        author: data["author"],
        start_date: data["start_date"],
        end_date: data["end_date"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "author": author,
        "start_date": start_date,
        "end_date": end_date,
    };
}