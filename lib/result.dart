import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/settings.dart';
import 'package:quiz/explanation.dart';
import 'package:quiz/styles.dart';

class ResultPage extends StatefulWidget {
  final String total; // current total questions
  final String ptotal; // previous total questions
  final String area; // current category
  final int correct; // current number of correct answers
  final String pcorrect; // previous number of correct answers
  final int incorrect; // current number of incorrect answers
  final String pincorrect; // previous number of incorrect answers
  final String pnotanswered; // previous number of not answers
  final String pscore; // previous score
  final List incorrectarray; // current incorrect answers list
  final Map<String, dynamic> questiondata; // current quiz data

  ResultPage(
      {Key key,
      @required this.total,
      @required this.ptotal,
      @required this.area,
      @required this.correct,
      @required this.pcorrect,
      @required this.incorrect,
      @required this.pincorrect,
      @required this.pnotanswered,
      @required this.pscore,
      @required this.incorrectarray,
      @required this.questiondata})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int _selectedIndex = 0;
  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  int saveclick = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    saveclick++;
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
        break;
      case 1:
        exit(0);
        break;
      case 2:
        if (saveclick == 1) resultsave();
        break;
      case 3:
        resultreset();
        break;
      default:
    }
  }

  resultsave() async {
    final prefs = await SharedPreferences.getInstance();
    var number = prefs.containsKey('${this.widget.area}notanswered')
        ? int.parse(prefs.getString('${this.widget.area}number'))
        : 0; // quizing times
    var score1 = (int.parse(this.widget.pscore) * number +
            (this.widget.correct / int.parse(this.widget.total) * 100)
                .toInt()) /
        (number + 1);
    prefs.setString(
        '${this.widget.area}total',
        (int.parse(this.widget.ptotal) + int.parse(this.widget.total))
            .toString());
    prefs.setString('${this.widget.area}correct',
        (int.parse(this.widget.pcorrect) + this.widget.correct).toString());
    prefs.setString('${this.widget.area}incorrect',
        (int.parse(this.widget.pincorrect) + this.widget.incorrect).toString());
    prefs.setString(
        '${this.widget.area}notanswered',
        (int.parse(this.widget.pnotanswered) +
                (int.parse(this.widget.total) -
                    this.widget.incorrect -
                    this.widget.correct))
            .toString());
    prefs.setString('${this.widget.area}score', score1.toInt().toString());
    prefs.setString('${this.widget.area}', this.widget.area);
    number++;
    prefs.setString('${this.widget.area}number', number.toString());
  }

  resultreset() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${this.widget.area}total', '0');
    prefs.setString('${this.widget.area}correct', '0');
    prefs.setString('${this.widget.area}incorrect', '0');
    prefs.setString('${this.widget.area}notanswered', '0');
    prefs.setString('${this.widget.area}score', '0');
    prefs.setString('${this.widget.area}number', '0');
  }

  // overriding the main page
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {});
          return SafeArea(
            left: true,
            top: true,
            right: true,
            bottom: true,
            minimum: const EdgeInsets.all(16.0),
            child: Scaffold(
              body: TabBarView(
                children: <Widget>[
                  // previous and current result tab
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration:
                        BoxDecoration(color: Theme.of(context).cursorColor),
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
                      child: Column(
                        children: <Widget>[
                          // total questions container
                          Container(
                            height: screenHeight * 0.13,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 10,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Total Questions", style: titleStyle),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        this.widget.ptotal != ''
                                            ? Expanded(
                                                flex: 5,
                                                child: Center(
                                                    child: Text(
                                                        "${this.widget.ptotal}",
                                                        style:
                                                            previousStyle)))
                                            : Text(' '),
                                        Expanded(
                                            flex: 5,
                                            child: Center(
                                                child: Text(
                                                    "${this.widget.total}",
                                                    style: currentStyle))),
                                      ])
                                ],
                              )),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // score container
                          Container(
                            height: screenHeight * 0.13,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 10,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Score", style: titleStyle),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        this.widget.pscore != ''
                                            ? Expanded(
                                                flex: 5,
                                                child: Center(
                                                    child: Text(
                                                        "${this.widget.pscore}%",
                                                        style:
                                                            previousStyle)))
                                            : Text(' '),
                                        Expanded(
                                            flex: 5,
                                            child: Center(
                                                child: Text(
                                                    "${(this.widget.correct / int.parse(this.widget.total) * 100).toInt()}%",
                                                    style: currentStyle))),
                                      ])
                                ],
                              )),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // correct answers container
                          Container(
                            height: screenHeight * 0.13,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 10,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Correct Answers", style: titleStyle),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        this.widget.pcorrect != ''
                                            ? Expanded(
                                                flex: 5,
                                                child: Center(
                                                    child: Text(
                                                        "${this.widget.pcorrect}",
                                                        style:
                                                            previousStyle)))
                                            : Text(' '),
                                        Expanded(
                                            flex: 5,
                                            child: Center(
                                                child: Text(
                                                    "${this.widget.correct.toString()}",
                                                    style: currentStyle))),
                                      ])
                                ],
                              )),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // incorrect answers container
                          Container(
                            height: screenHeight * 0.13,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 10,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Incorrec Answers", style: titleStyle),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        this.widget.pincorrect != ''
                                            ? Expanded(
                                                flex: 5,
                                                child: Center(
                                                    child: Text(
                                                        "${this.widget.pincorrect}",
                                                        style:
                                                            previousStyle)))
                                            : Text(' '),
                                        Expanded(
                                            flex: 5,
                                            child: Center(
                                                child: Text(
                                                    "${this.widget.incorrect.toString()}",
                                                    style: currentStyle))),
                                      ])
                                ],
                              )),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // not answers container
                          Container(
                            height: screenHeight * 0.13,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              elevation: 10,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Not Answered", style: titleStyle),
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        this.widget.pnotanswered != ''
                                            ? Expanded(
                                                flex: 5,
                                                child: Center(
                                                    child: Text(
                                                        "${this.widget.pnotanswered}",
                                                        style:
                                                            previousStyle)))
                                            : Text(' '),
                                        Expanded(
                                            flex: 5,
                                            child: Center(
                                                child: Text(
                                                    "${int.parse(this.widget.total) - this.widget.incorrect - this.widget.correct}",
                                                    style: currentStyle))),
                                      ])
                                ],
                              )),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          // explanation button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  width: screenWidth * 0.7,
                                  height: screenHeight * 0.08,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      "Explanation",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    onPressed: () =>
                                        {tabController.index = 1},
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  //---------------------------
                  ExplanationPage(
                      total: this.widget.total,
                      area: this.widget.area,
                      correct: this.widget.correct,
                      incorrect: this.widget.incorrect,
                      incorrectarray: this.widget.incorrectarray,
                      questiondata: this.widget.questiondata)
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.backspace),
                    label: 'Again',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.exit_to_app),
                    label: 'Quit',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.save),
                    label: 'Save',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.refresh),
                    label: 'Reset',
                  ),
                ],
                currentIndex: _selectedIndex,
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.amber[800],
                onTap: _onItemTapped,
              ),
            ));
        }),
      ),
    );
  }
}
