import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/result.dart';
import 'package:quiz/styles.dart';
import 'package:condition/condition.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> questiondata;
  final String timevalue;
  final String randomvalue;
  final String areavalue;
  final String questionvalue;
  final int maxquestion;
  final List questionnumbers;
  QuizPage({
    Key key,
    @required this.questiondata,
    @required this.timevalue,
    @required this.randomvalue,
    @required this.areavalue,
    @required this.questionvalue,
    @required this.maxquestion,
    @required this.questionnumbers,
  }) : super(key: key);
  @override
  _QuizPageState createState() => _QuizPageState(questiondata, timevalue,randomvalue, areavalue, questionvalue, maxquestion, questionnumbers);
}

class _QuizPageState extends State<QuizPage> {
  final Map<String, dynamic> questiondata;
  final String timevalue;
  final String randomvalue;
  final String areavalue;
  final String questionvalue;
  final int maxquestion;
  final List questionnumbers;
  _QuizPageState(this.questiondata, this.timevalue, this.randomvalue,this.areavalue, this.questionvalue, this.maxquestion, this.questionnumbers);

  Color colortoshow = Colors.indigoAccent; // initial choice button color
  Color right = Colors.green; // choice button color when answer is right
  Color wrong = Colors.red; // choice button color when answer is wrong
  bool isQuiz = false; // the value informing to start quiz
  bool disableAnswer = false; // the value which be able to click choice button or not
  int correct = 0; // number of correct answers
  int incorrect = 0; // number of wrong answers

  // extra varibale to iterate
  int i = 1; // initial No. of quiz data
  int j = 1; // random array index
  int timer = 30; // intial value of countdown
  List randomarray; //randomizing questions list
  Timer test; // quiz Timer
  List incorrectarray = []; // incorrect answers and not answered list
  List assigned = [3,6,9,12,21];
  int randomimagevalue = 1;
  bool canceltimer = false; // initial value which be called when checking the answer
  // choice button initial color
  Map<String, Color> btncolor = {
    "answer a": Colors.indigoAccent,
    "answer b": Colors.indigoAccent,
    "answer c": Colors.indigoAccent,
    "answer d": Colors.indigoAccent,
  };

  // this function is called when a quiz is started.
  // this function returns random questions.
  genrandomarray() {
    var distinctIds = []; // randomizing questions index list
    var rand = new Random(); // 0~1 random value
    var l = 1;
    int i = 0; //question index value
    while (i == 0) {
      if (this.randomvalue == "yes") {
        distinctIds.add(rand.nextInt(maxquestion) * 1 + 1);
      } else {
        distinctIds.add(l);
        l++;
      }
      randomarray = distinctIds.toSet().toList();
      incorrectarray = distinctIds.toSet().toList();
      if (randomarray.length < int.parse(this.questionvalue)) {
        continue;
      } else {
        break;
      }
    }
    setState(() {
      i = randomarray[0];
    });
  }

  // this fucntion is called when the page is loaded
  @override
  void initState() {
    starttimer();
    genrandomarray();
    super.initState();
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // this function is called when start the quiz
  // runs countdown
  void starttimer() async {
    const onesec = Duration(seconds: 1);
    timer = int.parse(this.timevalue);
    test = Timer.periodic(onesec, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
          nextquestion();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
      });
    });
  }

  // this function is called after check the answer
  void nextquestion() {
    canceltimer = false;
    timer = int.parse(this.timevalue);
    setState(() {
      randomimagevalue = new Random().nextInt(20)*1+1;
      if (j < int.parse(this.questionvalue)) {
        i = randomarray[j];
        j++;
      } else {
        result();
      }
      btncolor["answer a"] = Colors.indigoAccent;
      btncolor["answer b"] = Colors.indigoAccent;
      btncolor["answer c"] = Colors.indigoAccent;
      btncolor["answer d"] = Colors.indigoAccent;
      disableAnswer = false;
    });
    starttimer();
  }

  // this function is called when finish the quiz
  // this function transforms the variables to result page
  result() async {
    final prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => ResultPage(
          area: areavalue,
          correct: correct,
          pcorrect: prefs.containsKey('${this.areavalue}correct')
              ? prefs.getString('${this.areavalue}correct')
              : '0',
          total: questionvalue,
          ptotal: prefs.containsKey('${this.areavalue}total')
              ? prefs.getString('${this.areavalue}total')
              : '0',
          incorrect: incorrect,
          pincorrect: prefs.containsKey('${this.areavalue}incorrect')
              ? prefs.getString('${this.areavalue}incorrect')
              : '0',
          pnotanswered: prefs.containsKey('${this.areavalue}notanswered')
              ? prefs.getString('${this.areavalue}notanswered')
              : '0',
          pscore: prefs.containsKey('${this.areavalue}score')
              ? prefs.getString('${this.areavalue}score')
              : '0',
          incorrectarray: incorrectarray,
          questiondata: questiondata),
    ));
  }

  // this function is called when click the choice button, confirm the answer whether is right or not
  void checkanswer(String k) {
    // in the previous version this was
    // questiondata[i.toString()]['correct'] == k
    // which i forgot to change
    // so nake sure that this is now corrected
    if (test != null) {
      if ('answer ' + questiondata[i.toString()]['correct'] == k) {
        // just a print sattement to check the correct working
        // debugPrint('answer'+questiondata[i.toString()]['correct'] is equal to k);
        // changing the color variable to be green
        colortoshow = right;
        correct++;
        incorrectarray.removeWhere((item) => item == i);
      } else {
        // just a print sattement to check the correct working
        // debugPrint('answer'+questiondata[i.toString()]['correct'] is equal to k);
        colortoshow = wrong;
        incorrect++;
      }
      setState(() {
        // applying the changed color to the particular button that was selected
        btncolor[k] = colortoshow;
        canceltimer = true;
        disableAnswer = true;
      });
      // nextquestion();
      // changed timer duration to 1 second
      Timer(Duration(seconds: 1), nextquestion);
    }
  }

  // choice button widget
  Widget choicebutton(String k) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 5.0,
      ),
      child: SizedBox(
          width: screenWidth * 0.45,
          height: screenHeight * 0.25,
          child: FlatButton(
            onPressed: () => checkanswer(k),
            child: choiceText(questiondata[i.toString()][k]),
            //  Text(
            //   questiondata[i.toString()][k],
            //   style: choiceTextStyle,
            //   maxLines: 10,
            // ),
            color: btncolor[k],
            splashColor: Colors.indigo[700],
            highlightColor: Colors.indigo[700],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          )),
    );
  }

  // ignore: missing_return
  Widget choiceText(String choice) {
    if (choice.length < 50)
      return Text(
        choice,
        style: choiceTextStyle1,
        maxLines: 10,
      );
    else if (choice.length < 100)
      return Text(
        choice,
        style: choiceTextStyle2,
        maxLines: 10,
      );
    else if (choice.length < 150)
      return Text(
        choice,
        style: choiceTextStyle3,
        maxLines: 10,
      );
    else if (choice.length < 200)
      return Text(
        choice,
        style: choiceTextStyle4,
        maxLines: 10,
      );
  }

  // overriding the main page
  @override
  Widget build(BuildContext context) {
    var length = questiondata[i.toString()]['question'].length;
    return DefaultTabController(
      length: 1,
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          body: TabBarView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 25.0),
                  Row(children: [
                    Expanded(
                        flex: 4,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            j.toString() + '/${this.questionvalue}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        )),
                    Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            timer.toString(),
                            style: showTimerStyle,
                          ),
                        )),
                  ]),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(15.0),
                      alignment: Alignment.center,
                      child: Conditioned(
                        cases: [
                          Case(length < 160, builder: () => Text(questiondata[i.toString()]['question'],style: questionStyle1,)),
                          Case(length < 220, builder: () => Text(questiondata[i.toString()]['question'],style: questionStyle2,)),
                          Case(length < 300, builder: () => Text(questiondata[i.toString()]['question'],style: questionStyle3,)),
                        ],
                        defaultBuilder: () => Text(questiondata[i.toString()]['question'],style: questionStyle1,),

                      )
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: assigned.asMap().containsValue(int.parse(questionnumbers[i-1]))
                        ? Image(
                            image: AssetImage('assets/${questionnumbers[i-1]}.png'),
                          )
                        : Image(
                            image: AssetImage('assets/0$randomimagevalue.png'),
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: AbsorbPointer(
                      absorbing: disableAnswer,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                choicebutton('answer a'),
                                choicebutton('answer b'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                choicebutton('answer c'),
                                choicebutton('answer d'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
