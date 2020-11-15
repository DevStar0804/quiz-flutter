import 'package:flutter/material.dart';

class ExplanationPage extends StatefulWidget {
  final String total; // current total questions
  final String area; // current category
  final int correct; // current number of correct answers
  final int incorrect; // current number of incorrect answers
  final List incorrect_array; // current incorrect answers list
  final Map<String, dynamic> questiondata; // current quiz data

  ExplanationPage(
      {Key key,
      @required this.total,
      @required this.area,
      @required this.correct,
      @required this.incorrect,
      @required this.incorrect_array,
      @required this.questiondata})
      : super(key: key);

  @override
  _ExplanationPageState createState() => _ExplanationPageState();
}

class _ExplanationPageState extends State<ExplanationPage> {
  int saveclick=0;

  List<Widget> explanations() {
    this.widget.incorrect_array.sort();
    var index = 0;
    // explanations title
    final widgets = List<Widget>()
      ..add(Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          'Total Questions: ${this.widget.total}',
          style: TextStyle(
              color: Colors.lime,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic),
        ),
      ));
    // explanations container
    if (this.widget.incorrect_array.isNotEmpty) {
      widgets
        ..add(
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 32,
            color: Colors.indigo[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'WRONGS: ${this.widget.incorrect_array.length}',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        // explanation
        ..addAll(
          this.widget.incorrect_array.map((i) {
            index++;
            return detail(
                index, i, this.widget.questiondata['$i']['explanation']);
          }),
        );
    }
    return widgets;
  }

  Widget detail(int number, int index, String explanation) {
    String correct = "answer ${this.widget.questiondata['$index']['correct']}";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 12.0,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      '${this.widget.questiondata[index.toString()]["question"]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center),
                )),
          ],
        ),
        
        Row(
          children: <Widget>[
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32.0,8.0,8.0,8.0),
                  child: Text(
                      '${this.widget.questiondata[index.toString()][correct]}',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center),
                )),
          ],
        ),
        
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
              child: Text('$explanation'),
            ),
          ],
        )
      ],
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {});
        return Scaffold(
          body: TabBarView(
            children: <Widget>[
              // explanation result tab
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Theme.of(context).cursorColor,
                  Theme.of(context).cursorColor
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // expalnations list
                      ...explanations(),

                    ],
                  ),
                ),
              ),
              //---------------------------
            ],
          ),
        );
      }),
    );
  }
}
